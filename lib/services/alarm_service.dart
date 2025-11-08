// lib/services/alarm_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/alarm_model.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notifications (call this in main.dart before runApp)
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('app_icon'); // Make sure you have an app_icon.png in res/drawable
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    const InitializationSettings settings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _notificationsPlugin.initialize(settings);
    _initialized = true;
  }

  /// Schedule an alarm at a specific time
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    await init();

    final alarmTime = tz.TZDateTime.from(alarm.time, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'), // Add alarm_sound.mp3 in android/res/raw
      fullScreenIntent: true, // Full-screen notification
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    await _notificationsPlugin.zonedSchedule(
      alarm.hashCode, // unique id per alarm
      alarm.label.isNotEmpty ? alarm.label : 'Alarm',
      'Alarm time!',
      alarmTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily optional
    );
  }

  /// Cancel a scheduled alarm
  static Future<void> cancelAlarm(AlarmModel alarm) async {
    await init();
    await _notificationsPlugin.cancel(alarm.hashCode);
  }
}
