// lib/services/alarm_service.dart

import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';
import '../utils/sun_time_util.dart';
import 'alarm_notification_helper.dart';

class AlarmService {
  static final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  /// Compatibility alias for older code in ViewModel
  static Future<void> scheduleAlarm(AlarmModel alarm,
      {double lat = 0.0, double lng = 0.0}) async {
    await scheduleNextAlarm(alarm, lat: lat, lng: lng);
  }

  /// Schedule next alarm (supports sun and regular)
  static Future<void> scheduleNextAlarm(
      AlarmModel alarm, {
        required double lat,
        required double lng,
      }) async {
    final nextTime = getNextTriggerTime(alarm, lat, lng);

    if (nextTime.isBefore(DateTime.now())) {
      log('Skipping past alarm: ${nextTime.toIso8601String()}');
      return;
    }

    final notificationDetails = AlarmNotificationHelper.getNotificationDetails(alarm);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id.hashCode,
      alarm.label.isNotEmpty ? alarm.label : 'Alarm',
      'Time: ${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}',
      tz.TZDateTime.from(nextTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    log('Scheduled alarm: ${alarm.label} at $nextTime');
  }

  static Future<void> cancelAlarm(AlarmModel alarm) async {
    await _flutterLocalNotificationsPlugin.cancel(alarm.id.hashCode);
    log('Cancelled alarm: ${alarm.label}');
  }

  /// Compute next trigger time for sunrise/sunset or regular alarms
  static DateTime getNextTriggerTime(AlarmModel alarm, double lat, double lng) {
    final now = DateTime.now();
    DateTime candidateDate = now;

    // Skip non-repeat days if repeatDays is set
    while (alarm.repeatDays.isNotEmpty &&
        !alarm.repeatDays.contains(candidateDate.weekday)) {
      candidateDate = candidateDate.add(const Duration(days: 1));
    }

    DateTime alarmTime;

    if (alarm.type == AlarmType.sunrise || alarm.type == AlarmType.sunset) {
      final sunTime = alarm.type == AlarmType.sunrise
          ? SunTimeUtil.calculateSunrise(candidateDate, lat, lng)
          : SunTimeUtil.calculateSunset(candidateDate, lat, lng);

      alarmTime = alarm.isBefore == true
          ? sunTime.subtract(Duration(minutes: alarm.beforeAfterMinutes ?? 0))
          : sunTime.add(Duration(minutes: alarm.beforeAfterMinutes ?? 0));
    } else {
      alarmTime = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
        alarm.time.hour,
        alarm.time.minute,
      );
    }

    if (!alarmTime.isAfter(now)) {
      candidateDate = candidateDate.add(const Duration(days: 1));
      return getNextTriggerTime(alarm, lat, lng);
    }

    return alarmTime;
  }
}
