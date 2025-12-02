import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
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

  Future<void> initialize(String userId) async {
    // 1. Request permission
    await _fcm.requestPermission();

    // 2. Get the token
    final token = await _fcm.getToken();
    AppLogger().logJson('FCM Token', {'token': token ?? 'null'}, level: Level.debug);

    // 3. Save the token for the user
    if (token != null) {
      await _saveTokenToDatabase(token, userId);
    }

    // 4. Listen for token refreshes
    _fcm.onTokenRefresh.listen((token) => _saveTokenToDatabase(token, userId));

    // 5. Set up foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger().info('Got a message whilst in the foreground!');
      AppLogger().logJson('Message data', message.data, level: Level.debug);

      if (message.notification != null) {
        AppLogger().info('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> _saveTokenToDatabase(String token, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('device_tokens')
          .doc(token)
          .set({
            'createdAt': FieldValue.serverTimestamp(),
            'platform': 'android', // In a real app, detect the platform
          });
    } catch (e, stack) {
      AppLogger().error('Error saving FCM token', e, stack);
    }
  }
}
