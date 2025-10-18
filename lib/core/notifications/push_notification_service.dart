import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/features/home/presentation/screens/home_screen_v2.dart'; // for _userId

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
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
    print("FCM Token: $token");

    // 3. Save the token for the user
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    // 4. Listen for token refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // 5. Set up foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Here you could use flutter_local_notifications to show a heads-up notification
      }
    });
  }

  Future<void> _saveTokenToDatabase(String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId) // Assumes a logged-in user
          .collection('device_tokens')
          .doc(token)
          .set({
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'android', // In a real app, detect the platform
      });
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }
}