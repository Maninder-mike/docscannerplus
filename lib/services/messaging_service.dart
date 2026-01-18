import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  static final MessagingService instance = MessagingService._internal();
  factory MessagingService() => instance;
  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? fcmToken;

  Future<void> initialize() async {
    // 1. Request Permission (iOS & Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined notification permission');
    }

    // 2. Enable Foreground Notifications (Android)
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Get FCM Token (for testing/targeting)
    try {
      fcmToken = await _fcm.getToken();
      debugPrint('FCM Token: $fcmToken');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 4. Background Message Handler
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      debugPrint('Error registering background handler: $e');
    }

    // 5. Message Click Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Navigate to deep link if present
    });
  }
}

// Global/Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're using other Firebase services here, you must call Firebase.initializeApp()
  // await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
