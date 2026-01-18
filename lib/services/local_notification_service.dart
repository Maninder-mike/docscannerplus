import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> checkAndShowWelcomeNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('has_shown_welcome_notification') ?? false;

    if (!hasShown) {
      // Show immediately or with a slight delay
      await Future.delayed(const Duration(seconds: 2));

      await showNotification(
        id: 0,
        title: 'Welcome to DocScanner+!',
        body: 'Tap here to start scanning your first document.',
      );

      await prefs.setBool('has_shown_welcome_notification', true);
      debugPrint('Shown welcome notification');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'welcome_channel',
          'Welcome Notifications',
          channelDescription: 'Notifications for new users',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, details);
  }
}
