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
    // TODO: Save the capsule to the 'timeCapsules' collection in Firestore.
    // TODO: Schedule a delivery notification for the deliveryDate.
    print("Created time capsule for user $userId to be delivered on $deliveryDate.");
  }

  /// Delivers a time capsule to the user.
  Future<void> deliverTimeCapsule(String capsuleId) async {
    // TODO: This would be triggered by a scheduled function.
    // It would send a notification to the user that their time capsule is ready.
    print("Delivering time capsule $capsuleId.");
  }

  /// Generates a reflection comparing the user's past expectations with their current reality.
  String generateReflection({
    required TimeCapsule capsule,
    required String currentReality, // User's input about their current situation
  }) {
    // TODO: Create a formatted string that compares the past and present.
    return "Back on ${capsule.createdAt.toLocal()}, you predicted: '${capsule.prediction}'.\n\n"
           "Today, you've shared: '$currentReality'.\n\n"
           "How do you feel about the journey?";
  }
}