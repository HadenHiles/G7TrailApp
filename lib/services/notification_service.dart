import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android configurations
  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    "G7", // Channel ID Required for Android 8.0 or after
    "Group of Seven Lake Superior Trail", // Channel title Required for Android 8.0 or after
    channelDescription: "Group of seven", // Required for Android 8.0 or after
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  // IOS Configurations
  final IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
    presentAlert: true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
    presentBadge: true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
    presentSound: true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
    badgeNumber: 1, // The application's icon badge number
  );

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  }

  Future selectNotification(String? payload) async {
    //Handle notification tapped logic here
  }

  Future<void> notify(int id, String? title, String? body) async {
    await flutterLocalNotificationsPlugin.show(
      12345,
      title ?? "Trail Beacon Found",
      body ?? "You discovered a painting site!",
      Platform.isAndroid ? NotificationDetails(android: androidPlatformChannelSpecifics) : NotificationDetails(iOS: iOSPlatformChannelSpecifics),
      payload: 'data',
    );
  }

  Future<void> schedule(int id, String? title, String? body, DateTime? date) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title ?? "Lake Superior Group of Seven Trail",
      body ?? "A scheduled notification from G7 Trail",
      tz.TZDateTime.from(date ?? DateTime.now().add(Duration(minutes: 5)), tz.local),
      Platform.isAndroid ? NotificationDetails(android: androidPlatformChannelSpecifics) : NotificationDetails(iOS: iOSPlatformChannelSpecifics),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
