DateTime getNextAlarmTime(AlarmModel alarm, double lat, double lng) {
  final now = DateTime.now();
  DateTime candidateDate = now;

  // Find next valid day according to repeatDays
  while (alarm.repeatDays.isNotEmpty &&
      !alarm.repeatDays.contains(candidateDate.weekday % 7)) {
    candidateDate = candidateDate.add(Duration(days: 1));
  }

  // Calculate alarm time
  DateTime alarmTime;
  if (alarm.type == AlarmType.sunrise || alarm.type == AlarmType.sunset) {
    final sunTime = alarm.type == AlarmType.sunrise
        ? SunTimeUtil.calculateSunrise(candidateDate, lat, lng)
        : SunTimeUtil.calculateSunset(candidateDate, lat, lng);

    alarmTime = alarm.isBefore!
        ? sunTime.subtract(Duration(minutes: alarm.beforeAfterMinutes!))
        : sunTime.add(Duration(minutes: alarm.beforeAfterMinutes!));
  } else {
    // Regular alarm
    alarmTime = DateTime(candidateDate.year, candidateDate.month, candidateDate.day,
        alarm.time.hour, alarm.time.minute);
  }

  // If the calculated time is already past, try the next valid day
  if (!alarmTime.isAfter(now)) {
    return getNextAlarmTime(alarm.copyWith(time: alarm.time), lat, lng)
        .add(Duration(days: 1));
  }

  return alarmTime;
}
