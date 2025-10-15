// lib/viewmodels/alarm_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../helper/alarm_creation_helper.dart';

class AlarmViewModel extends ChangeNotifier {
  final List<AlarmModel> _alarms = [];

  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  void addAlarm(AlarmModel alarm) {
    _alarms.add(alarm);
    AlarmService.scheduleAlarm(alarm);
    notifyListeners();
  }

  void deleteAlarm(String id) {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    AlarmService.cancelAlarm(alarm);
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      final updated = alarm.copyWith(isActive: !alarm.isActive);
      _alarms[index] = updated;

      if (updated.isActive) {
        AlarmService.scheduleAlarm(updated);
      } else {
        AlarmService.cancelAlarm(updated);
      }

      notifyListeners();
    }
  }

  void updateAlarmFull(String id, DateTime newTime, String newLabel, AlarmType newType) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      _alarms[index].time = newTime;
      _alarms[index].label = newLabel;
      _alarms[index].type = newType;
      notifyListeners();
    }
  }


  Future<void> addSunriseSunsetAlarm({
    required AlarmType type,
    required bool isBefore,
    required int beforeAfterMinutes,
    Set<int>? repeatDays,
  }) async {
    final newAlarm = await AlarmCreationHelper.createSunriseSunsetAlarm(
      type: type,
      isBefore: isBefore,
      beforeAfterMinutes: beforeAfterMinutes,
    );

    if (newAlarm != null) {
      // Add repeat days if any
      newAlarm.repeatDays = repeatDays ?? const {};

      // Add alarm to your list and notify listeners
      addAlarm(newAlarm);
    } else {
      // Handle location error or null result
      print('Failed to create sunrise/sunset alarm: location not available');
    }
  }



}
