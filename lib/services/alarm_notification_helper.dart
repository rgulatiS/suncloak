// lib/services/alarm_notification_helper.dart

import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alarm_model.dart';

class AlarmNotificationHelper {
  static NotificationDetails getNotificationDetails(AlarmModel alarm) {
    final vibrationStrength = (alarm.vibrationPercent ?? 60).clamp(0, 100);
    final soundVolume = (alarm.soundVolumePercent ?? 80).clamp(0, 100);

    // Simple scaled vibration pattern
    final vibrationPattern = Int64List.fromList([
      0,
      500 + (vibrationStrength * 5),
      300,
      500 + (vibrationStrength * 5),
    ]);

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Sunrise/Sunset Alarms',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: vibrationStrength > 0,
      vibrationPattern: vibrationPattern,
      sound: RawResourceAndroidNotificationSound(alarm.sound ?? 'alarm_sound'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      additionalFlags: Int32List.fromList([soundVolume]),
    );

    final iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      sound: alarm.sound ?? 'alarm_sound.aiff',
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }
}
