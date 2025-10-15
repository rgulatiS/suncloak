// lib/models/alarm_model.dart

enum AlarmType { regular, sunrise, sunset }

class AlarmModel {
  final String id;
  DateTime time;
  AlarmType type;
  String label;
  final bool isActive;
  String? musicAppLink; // Deep link to open music app
  Set<int> repeatDays; // 0=Sunday, 1=Monday, ...

  // For sunrise/sunset alarms:
  int? beforeAfterMinutes;
  bool? isBefore;


  AlarmModel({
    required this.id,
    required this.time,
    required this.type,
    this.label = '',
    this.isActive = true,
    this.musicAppLink,
    this.repeatDays = const {},
    this.beforeAfterMinutes,
    this.isBefore,
  });

  AlarmModel copyWith({
    String? id,
    DateTime? time,
    AlarmType? type,
    String? label,
    bool? isActive,
    String? musicAppLink,
    Set<int>? repeatDays,
    int? beforeAfterMinutes,
    bool? isBefore,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      type: type ?? this.type,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      musicAppLink: musicAppLink ?? this.musicAppLink,
      repeatDays: repeatDays ?? this.repeatDays,
      beforeAfterMinutes: beforeAfterMinutes ?? this.beforeAfterMinutes,
      isBefore: isBefore ?? this.isBefore,
    );
  }
  AlarmModel toAlarmModel({required String id}) {
    return AlarmModel(
      id: id,
      time: time,
      label: label,
      type: type,
      repeatDays: repeatDays,
      musicAppLink: null,
    );
  }
}
