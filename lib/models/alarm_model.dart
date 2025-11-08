// lib/models/alarm_model.dart

enum AlarmType { regular, sunrise, sunset }

class AlarmModel {
  final String id;
  DateTime time;
  AlarmType type;
  String label;
  final bool isActive;
  String? musicAppLink;
  Set<int> repeatDays;

  // For sunrise/sunset alarms:
  int? offsetMinutes;
  int? beforeAfterMinutes;
  bool? isBefore;

  // Notification preferences
  String? sound;
  int? soundVolumePercent; // 0–100
  int? vibrationPercent;   // 0–100

  // Snooze settings
  bool? snoozeEnabled;
  int? snoozeIntervalMinutes;
  int? snoozeTimes;

  AlarmModel({
    required this.id,
    required this.time,
    required this.type,
    this.label = '',
    this.isActive = true,
    this.musicAppLink,
    this.repeatDays = const {},
    this.offsetMinutes,
    this.beforeAfterMinutes,
    this.isBefore,
    this.sound,
    this.soundVolumePercent,
    this.vibrationPercent,
    this.snoozeEnabled,
    this.snoozeIntervalMinutes,
    this.snoozeTimes,
  });

  AlarmModel copyWith({
    String? id,
    DateTime? time,
    AlarmType? type,
    String? label,
    bool? isActive,
    String? musicAppLink,
    Set<int>? repeatDays,
    int? offsetMinutes,
    int? beforeAfterMinutes,
    bool? isBefore,
    String? sound,
    int? soundVolumePercent,
    int? vibrationPercent,
    bool? snoozeEnabled,
    int? snoozeIntervalMinutes,
    int? snoozeTimes,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      type: type ?? this.type,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      musicAppLink: musicAppLink ?? this.musicAppLink,
      repeatDays: repeatDays ?? this.repeatDays,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      beforeAfterMinutes: beforeAfterMinutes ?? this.beforeAfterMinutes,
      isBefore: isBefore ?? this.isBefore,
      sound: sound ?? this.sound,
      soundVolumePercent: soundVolumePercent ?? this.soundVolumePercent,
      vibrationPercent: vibrationPercent ?? this.vibrationPercent,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeIntervalMinutes:
      snoozeIntervalMinutes ?? this.snoozeIntervalMinutes,
      snoozeTimes: snoozeTimes ?? this.snoozeTimes,
    );
  }
}
