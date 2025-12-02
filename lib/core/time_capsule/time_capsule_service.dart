import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/time_capsule/time_capsule.dart';
import 'package:uuid/uuid.dart';

// Provider for the service
final timeCapsuleServiceProvider = Provider<TimeCapsuleService>((ref) {
  return TimeCapsuleService(FirebaseFirestore.instance);
});

class TimeCapsuleService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  TimeCapsuleService(this._firestore);

  /// Creates and stores a new time capsule for the user.
  Future<void> createTimeCapsule({
    required String userId,
    required String message,
    required String prediction,
    required DateTime deliveryDate,
  }) async {
    final capsule = TimeCapsule(
      id: _uuid.v4(),
      userId: userId,
      message: message,
      prediction: prediction,
      createdAt: DateTime.now(),
      deliveryDate: deliveryDate,
    );
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('time_capsules')
          .doc(capsule.id)
          .set(capsule.toJson());

      // In a real app, you would schedule a push notification here using a service
      // like Firebase Functions + Cloud Scheduler, or a local notification service.
      print(
        'Created and saved time capsule ${capsule.id} for user $userId to be delivered on $deliveryDate.',
      );
    } catch (e) {
      print('Error creating time capsule: $e');
    }
  }

  /// Delivers a time capsule to the user.
  Future<void> deliverTimeCapsule({
    required String userId,
    required String capsuleId,
  }) async {
    // This function would typically be triggered by a scheduled background job.
    // It marks the capsule as ready to be opened by the user.
    try {
      final capsuleRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('time_capsules')
          .doc(capsuleId);
      await capsuleRef.update({'delivered': true});

      final notificationPayload = {
        'title': 'A Message From Your Past Self!',
        'body': 'A time capsule you created is ready to be opened.',
        'type': 'time_capsule',
        'capsuleId': capsuleId,
      };

      // It would also send a notification to the user.
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            ...notificationPayload,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Trigger the backend function
      await _firestore.collection('notifications_to_send').add({
        'targetUserId': userId,
        'title': notificationPayload['title'],
        'body': notificationPayload['body'],
        'data': {'type': 'time_capsule', 'capsuleId': capsuleId},
      });

      print('Queued delivery notification for time capsule $capsuleId.');
    } catch (e) {
      print('Error delivering time capsule: $e');
    }
  }

  /// Generates a reflection comparing the user's past expectations with their current reality.
  String generateReflection({
    required TimeCapsule capsule,
    required String
    currentReality, // User's input about their current situation
  }) {
    final createdDate = capsule.createdAt.toLocal().toString().split(' ')[0];
    return '## A Look Back... and a Look Forward\n\n'
        '**On $createdDate, you sent a message to your future self:**\n'
        '> *${capsule.message}*\n\n'
        '**You predicted your life would be like this:**\n'
        '> *${capsule.prediction}*\n\n'
        "**And here's where you are today:**\n"
        '> *$currentReality*\n\n'
        'Take a moment to reflect on the journey. What has changed? What has stayed the same? What have you learned?';
  }
}
