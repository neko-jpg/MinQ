import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock for FirebaseFirestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

void main() {
  late GamificationEngine gamificationEngine;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUserCollection;
  late MockDocumentReference mockUserDocument;
  late MockCollectionReference mockPointsCollection;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUserCollection = MockCollectionReference();
    mockUserDocument = MockDocumentReference();
    mockPointsCollection = MockCollectionReference();
    gamificationEngine = GamificationEngine(mockFirestore);

    // Mock the chained Firestore calls
    when(() => mockFirestore.collection('users')).thenReturn(mockUserCollection);
    when(() => mockUserCollection.doc(any())).thenReturn(mockUserDocument);
    when(() => mockUserDocument.collection('points_transactions')).thenReturn(mockPointsCollection);
    when(() => mockPointsCollection.add(any())).thenAnswer((_) async => mockUserDocument); // Return a dummy doc ref
  });

  group('GamificationEngine', () {
    test('awardPoints calls firestore with correct data', () async {
      // Act
      await gamificationEngine.awardPoints(
        userId: 'testUser',
        basePoints: 10,
        reason: 'Test reason',
      );

      // Assert
      final captured = verify(() => mockPointsCollection.add(captureAny())).captured.first;
      expect(captured['userId'], 'testUser');
      expect(captured['value'], 10);
      expect(captured['reason'], 'Test reason');
    });

    test('awardPoints applies multipliers correctly and calls firestore', () async {
      // Act
      await gamificationEngine.awardPoints(
        userId: 'testUser',
        basePoints: 10,
        reason: 'Test reason with multipliers',
        difficultyMultiplier: 1.5,
        consistencyMultiplier: 2.0,
      );

      // Assert
      final captured = verify(() => mockPointsCollection.add(captureAny())).captured.first;
      expect(captured['userId'], 'testUser');
      expect(captured['value'], 30); // 10 * 1.5 * 2.0 = 30
      expect(captured['reason'], 'Test reason with multipliers');
    });
  });
}