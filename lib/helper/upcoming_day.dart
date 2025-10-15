String getUpcomingDayText(DateTime alarmTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final alarmDate = DateTime(alarmTime.year, alarmTime.month, alarmTime.day);

  final difference = alarmDate.difference(today).inDays;

  if (difference == 0) return "Today";
  if (difference == 1) return "Tomorrow";

  // Otherwise, show weekday name
  final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdayNames[alarmDate.weekday - 1];
}
