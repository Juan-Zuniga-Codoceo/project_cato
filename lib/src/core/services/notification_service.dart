import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Android permissions
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // 1. Request permission to SHOW notifications (Android 13+)
        await androidPlugin.requestNotificationsPermission();

        // 2. Request permission to SCHEDULE exact alarms (Android 12+)
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    // iOS/macOS permissions (only request on those platforms)
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  /// Schedule a daily notification at a specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    // Create notification details
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'mens_lifestyle_channel_v3', // Updated channel ID
      'Recordatorios de Hábitos',
      channelDescription: 'Notificaciones para recordar tus hábitos diarios',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Safe status bar icon
      largeIcon: DrawableResourceAndroidBitmap('app_icon'), // Rich large icon
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('app_icon'),
        largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      ),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate the scheduled time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Schedule the notification with error handling and fallback
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
      );

      debugPrint(
        'Scheduled exact notification $id for ${time.hour}:${time.minute}',
      );
    } catch (e) {
      debugPrint('⚠️ Error scheduling exact notification: $e');

      // Fallback to inexact scheduling
      try {
        debugPrint('🔄 Attempting fallback to inexact scheduling...');
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
          '✅ Scheduled inexact notification $id for ${time.hour}:${time.minute}',
        );
      } catch (e2) {
        debugPrint('❌ Fatal error scheduling notification: $e2');
      }
    }
  }

  /// Schedule a notification at a specific date and time
  Future<void> scheduleDateNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Validate that the date is in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Cannot schedule notification in the past: $scheduledDate');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mens_lifestyle_channel_v3',
          'Recordatorios de Hábitos',
          channelDescription:
              'Notificaciones para recordar tus hábitos diarios',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('app_icon'),
          styleInformation: BigPictureStyleInformation(
            DrawableResourceAndroidBitmap('app_icon'),
            largeIcon: DrawableResourceAndroidBitmap('app_icon'),
          ),
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // No matchDateTimeComponents for one-time notification
      );

      debugPrint('✅ Scheduled date notification $id for $scheduledDate');
    } catch (e) {
      debugPrint('⚠️ Error scheduling date notification: $e');
      // Fallback to inexact
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tzScheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint(
          '✅ Scheduled inexact date notification $id for $scheduledDate',
        );
      } catch (e2) {
        debugPrint('❌ Fatal error scheduling date notification: $e2');
      }
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Cancelled notification $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mens_lifestyle_channel_v3',
          'Recordatorios de Hábitos',
          channelDescription:
              'Notificaciones para recordar tus hábitos diarios',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('app_icon'),
          styleInformation: BigPictureStyleInformation(
            DrawableResourceAndroidBitmap('app_icon'),
            largeIcon: DrawableResourceAndroidBitmap('app_icon'),
          ),
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999, // Test ID
      '🔔 Notificación de Prueba',
      'Si ves esto, las notificaciones funcionan correctamente.',
      notificationDetails,
    );
    debugPrint('Test notification sent');
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mens_lifestyle_channel_v3',
          'Recordatorios de Hábitos',
          channelDescription:
              'Notificaciones para recordar tus hábitos diarios',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('app_icon'),
          styleInformation: BigPictureStyleInformation(
            DrawableResourceAndroidBitmap('app_icon'),
            largeIcon: DrawableResourceAndroidBitmap('app_icon'),
          ),
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
  }
}
