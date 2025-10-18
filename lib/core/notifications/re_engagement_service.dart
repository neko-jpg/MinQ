import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/notifications/notification_personalization_engine.dart';
import 'package:minq/domain/user/user.dart';

// Provider for the service
final reEngagementServiceProvider = Provider<ReEngagementService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final personalizationEngine = ref.watch(notificationPersonalizationEngineProvider);
  return ReEngagementService(firestore, personalizationEngine);
});

class ReEngagementService {
  final FirebaseFirestore _firestore;
  final NotificationPersonalizationEngine _personalizationEngine;

  ReEngagementService(this._firestore, this._personalizationEngine);

  /// Detects users who have been inactive for a specified number of days.
  Future<List<User>> getInactiveUsers(int daysInactive) async {
    // TODO: Implement logic to query users based on last activity date
    return [];
  }

  /// Sends re-engagement notifications to a list of inactive users.
  Future<void> sendReEngagementNotifications(List<User> inactiveUsers) async {
    for (final user in inactiveUsers) {
      // TODO: Calculate actual days of inactivity
      final message = _personalizationEngine.generateReEngagementMessage(
        user: user,
        daysInactive: 3, // Placeholder
      );
      // TODO: Integrate with a push notification service to send the message
      print("Sending to ${user.id}: $message");
    }
  }
}