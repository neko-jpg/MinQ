import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/app_logger.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
  );
});

class PushNotificationService {
  final FirebaseMessaging _fcm;
  final FirebaseFirestore _firestore;

  PushNotificationService(this._fcm, this._firestore);

  Future<void> initialize() async {
    // 1. Request permission
    await _fcm.requestPermission();

    // 2. Get the token
    final token = await _fcm.getToken();
    logger.info('FCM Token: $token');

    // 3. Save the token for the user
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (token != null && userId != null) {
      await _saveTokenToDatabase(token, userId);
    }

    // 4. Listen for token refreshes
    _fcm.onTokenRefresh.listen((token) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        _saveTokenToDatabase(token, userId);
      }
    });

    // 5. Set up foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.info('Got a message whilst in the foreground!');
      logger.info('Message data: ${message.data}');

      if (message.notification != null) {
        logger.info(
          'Message also contained a notification: ${message.notification}',
        );
        // Here you could use flutter_local_notifications to show a heads-up notification
      }
    });
  }

  Future<void> _saveTokenToDatabase(String token, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId) // Assumes a logged-in user
          .collection('device_tokens')
          .doc(token)
          .set({
            'createdAt': FieldValue.serverTimestamp(),
            'platform': 'android', // In a real app, detect the platform
          });
    } catch (e) {
      logger.error('Error saving FCM token: $e');
    }
  }
}
