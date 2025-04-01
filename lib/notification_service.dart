import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() async {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@drawable/push_logo');

    const DarwinInitializationSettings iOSInitSettings =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    InitializationSettings initSettings = const InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  static void showNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/push_logo'
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails, iOS: iOSDetails);

    _notificationsPlugin.show(
      0,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      platformDetails,
    );
  }
}
