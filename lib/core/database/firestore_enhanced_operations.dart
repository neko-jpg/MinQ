import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/core/error/exceptions.dart';
import 'package:minq/core/utils/firestore_retry.dart';

/// Enhanced Firestore operations with improved retry logic and conflict resolution
class FirestoreEnhancedOperations {
  final FirebaseFirestore _firestore;
  final RetryConfig _defaultRetryConfig;
  final RateLimiter _rateLimiter;
  
  FirestoreEnhancedOperations({
    FirebaseFirestore? firestore,
    RetryConfig? retryConfig,
    int maxRequestsPerSecond = 10,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _defaultRetryConfig = retryConfig ?? RetryConfig.defaultConfig,
       _rateLimiter = RateLimiter(maxRequestsPerSecond: maxRequestsPerSecond);
  
  /// Enhanced document read with retry and caching
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String path, {
    RetryConfig? retryConfig,
    Source source = Source.serverAndCache,
  }) async {
    return _rateLimiter.execute(() async {
      return RetryUtil.execute(
        action: () => _firestore.doc(path).get(GetOptions(source: source)),
        config: retryConfig ?? _defaultRetryConfig,
      );
    });
  }
  
  /// Enhanced collection query with retry
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String path, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
    RetryConfig? retryConfig,
    Source source = Source.serverAndCache,
  }) async {
    return _rateLimiter.execute(() async {
      return RetryUtil.execute(
        action: () {
          var query = _firestore.collection(path);
          if (queryBuilder != null) {
            query = queryBuilder(query) as CollectionReference<Map<String, dynamic>>;
          }
          return query.get(GetOptions(source: source));
        },
        config: retryConfig ?? _defaultRetryConfig,
      );
    });
  }
  
  /// Enhanced document write with conflict resolution
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    SetOptions? options,
    ConflictResolutionPolicy conflictPolicy = ConflictResolutionPolicy.lastWriteWins,
    RetryConfig? retryConfig,
  }) async {
    return _rateLimiter.execute(() async {
      final docRef = _firestore.doc(path);
      
      switch (conflictPolicy) {
        case ConflictResolutionPolicy.lastWriteWins:
          return RetryUtil.execute(
            action: () => docRef.set(data, options),
            config: retryConfig ?? RetryConfig.conflictConfig,
          );
          
        case ConflictResolutionPolicy.firstWriteWins:
          return RetryUtil.execute(
            action: () async {
              final snapshot = await docRef.get();
              if (snapshot.exists) {
                throw const ConflictException('Document already exists');
              }
              return docRef.set(data, options);
            },
            config: retryConfig ?? RetryConfig.conflictConfig,
          );
          
        case ConflictResolutionPolicy.merge:
          return ConflictResolver.resolveWithMerge(
            docRef: docRef,
            localChanges: data,
            mergeFunction: (server, local) => {...server, ...local},
            retryConfig: retryConfig ?? RetryConfig.conflictConfig,
          );
          
        case ConflictResolutionPolicy.throwError:
          return RetryUtil.execute(
            action: () async {
              final snapshot = await docRef.get();
              if (snapshot.exists) {
                throw const ConflictException('Document conflict detected');
              }
              return docRef.set(data, options);
            },
            config: retryConfig ?? RetryConfig.conflictConfig,
          );
      }
    });
  }
  
  /// Enhanced document update with optimistic locking
  Future<void> updateDocument(
    String path,
    Map<String, dynamic> data, {
    bool useOptimisticLock = true,
    RetryConfig? retryConfig,
  }) async {
    return _rateLimiter.execute(() async {
      final docRef = _firestore.doc(path);
      
      if (useOptimisticLock) {
        return ConflictResolver.resolveWithOptimisticLock(
          docRef: docRef,
          updateFunction: (currentData) => {...currentData, ...data},
          retryConfig: retryConfig ?? RetryConfig.conflictConfig,
        );
      } else {
        return RetryUtil.execute(
          action: () => docRef.update(data),
          config: retryConfig ?? _defaultRetryConfig,
        );
      }
    });
  }
  
  /// Enhanced batch operations with automatic chunking
  Future<void> executeBatch(
    List<BatchOperation> operations, {
    int maxBatchSize = 500,
    RetryConfig? retryConfig,
  }) async {
    if (operations.isEmpty) return;
    
    final batchWriter = BatchWriteWithRetry(
      firestore: _firestore,
      retryConfig: retryConfig ?? _defaultRetryConfig,
    );
    
    // Convert operations to batch functions
    final batchOperations = operations.map((op) => (WriteBatch batch) {
      switch (op.type) {
        case BatchOperationType.set:
          batch.set(op.reference, op.data!, op.setOptions);
          break;
        case BatchOperationType.update:
          batch.update(op.reference, op.data!);
          break;
        case BatchOperationType.delete:
          batch.delete(op.reference);
          break;
      }
    }).toList();
    
    // Execute with automatic chunking
    await batchWriter.executeLarge(batchOperations, batchSize: maxBatchSize);
  }
  
  /// Enhanced transaction with retry and conflict resolution
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction, {
    Duration timeout = const Duration(seconds: 30),
    RetryConfig? retryConfig,
  }) async {
    return RetryUtil.execute(
      action: () => _firestore.runTransaction(
        updateFunction,
        timeout: timeout,
      ),
      config: retryConfig ?? RetryConfig.conflictConfig,
    );
  }
  
  /// Stream with automatic retry on connection issues
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(
    String path, {
    bool includeMetadataChanges = false,
  }) {
    return _firestore
        .doc(path)
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .handleError((error) {
          developer.log('Document stream error: $error');
          // Stream will automatically retry on connection issues
        });
  }
  
  /// Collection stream with automatic retry
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String path, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
    bool includeMetadataChanges = false,
  }) {
    var query = _firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query) as CollectionReference<Map<String, dynamic>>;
    }
    
    return query
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .handleError((error) {
          developer.log('Collection stream error: $error');
          // Stream will automatically retry on connection issues
        });
  }
  
  /// Bulk write operations with progress tracking
  Future<void> bulkWrite(
    List<BatchOperation> operations, {
    int batchSize = 500,
    Function(int completed, int total)? onProgress,
    RetryConfig? retryConfig,
  }) async {
    if (operations.isEmpty) return;
    
    int completed = 0;
    final total = operations.length;
    
    for (int i = 0; i < operations.length; i += batchSize) {
      final end = (i + batchSize < operations.length) ? i + batchSize : operations.length;
      final chunk = operations.sublist(i, end);
      
      await executeBatch(chunk, retryConfig: retryConfig);
      
      completed += chunk.length;
      onProgress?.call(completed, total);
      
      // Rate limiting between batches
      if (end < operations.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
  
  /// Clean up resources
  void dispose() {
    _rateLimiter.reset();
  }
}

/// Batch operation definition
class BatchOperation {
  final BatchOperationType type;
  final DocumentReference<Map<String, dynamic>> reference;
  final Map<String, dynamic>? data;
  final SetOptions? setOptions;
  
  BatchOperation.set(
    this.reference,
    this.data, {
    this.setOptions,
  }) : type = BatchOperationType.set;
  
  BatchOperation.update(
    this.reference,
    this.data,
  ) : type = BatchOperationType.update,
      setOptions = null;
  
  BatchOperation.delete(
    this.reference,
  ) : type = BatchOperationType.delete,
      data = null,
      setOptions = null;
}

/// Batch operation types
enum BatchOperationType {
  set,
  update,
  delete,
}

/// Conflict exception for Firestore operations
class ConflictException extends DatabaseException {
  const ConflictException(super.message) : super(code: 'conflict');
}

/// Enhanced Firestore service with connection management
class EnhancedFirestoreService {
  final FirestoreEnhancedOperations _operations;
  final List<StreamSubscription> _subscriptions = [];
  bool _isDisposed = false;
  
  EnhancedFirestoreService({
    FirebaseFirestore? firestore,
    RetryConfig? retryConfig,
    int maxRequestsPerSecond = 10,
  }) : _operations = FirestoreEnhancedOperations(
         firestore: firestore,
         retryConfig: retryConfig,
         maxRequestsPerSecond: maxRequestsPerSecond,
       );
  
  /// Get enhanced operations instance
  FirestoreEnhancedOperations get operations => _operations;
  
  /// Add a managed stream subscription
  void addSubscription(StreamSubscription subscription) {
    if (!_isDisposed) {
      _subscriptions.add(subscription);
    }
  }
  
  /// Remove and cancel a subscription
  void removeSubscription(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
    subscription.cancel();
  }
  
  /// Check connection status
  Future<bool> isConnected() async {
    try {
      // Try a simple operation to check connectivity
      await _operations.getDocument(
        'connectivity_test/test',
        source: Source.server,
      );
      return true;
    } catch (error) {
      return false;
    }
  }
  
  /// Dispose of all resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    try {
      // Cancel all subscriptions
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      _subscriptions.clear();
      
      // Clean up operations
      _operations.dispose();
      
      developer.log('Enhanced Firestore service disposed');
      
    } catch (error) {
      developer.log('Error during Firestore service disposal: $error');
    }
  }
}