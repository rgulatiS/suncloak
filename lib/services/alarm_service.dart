// lib/services/alarm_service.dart

import '../models/alarm_model.dart';

class AlarmService {
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    // TODO: Implement native notification/alarm logic
    print("Scheduling alarm: ${alarm.label} at ${alarm.time}");
  }

  static Future<void> cancelAlarm(AlarmModel alarm) async {
    // TODO: Cancel the scheduled alarm
    print("Canceling alarm: ${alarm.label}");
  }
}
