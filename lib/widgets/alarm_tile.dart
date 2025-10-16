import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm_model.dart';
import '../viewmodels/alarm_viewmodel.dart';
import '../helper/upcoming_day.dart';

Widget buildAlarmListTile({
  required BuildContext context,
  required AlarmModel alarm,
  required AlarmViewModel viewModel,
  required void Function(BuildContext, AlarmModel) onEdit,
}) {
  final upcomingDayText = getUpcomingDayText(alarm.time);
  // final timeText =
  //     "${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}";
  final timeText = DateFormat('HH:mm').format(alarm.time);
  Icon alarmIcon;
  switch (alarm.type) {
    case AlarmType.sunrise:
      alarmIcon = Icon(Icons.wb_sunny, color: Colors.orange);
      break;
    case AlarmType.sunset:
      alarmIcon = Icon(Icons.nights_stay, color: Colors.deepPurple);
      break;
    case AlarmType.regular:
    default:
      alarmIcon = Icon(Icons.alarm, color: Colors.blue);
  }

  final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<Widget> repeatDayBoxes = List.generate(7, (index) {
    final dayIndex = index + 1; // Monday=1 ... Sunday=7
    final isSelected = alarm.repeatDays.contains(dayIndex);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        weekDays[index],
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  });

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onEdit(context, alarm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  alarmIcon,
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alarm.label.isNotEmpty ? alarm.label : "Alarm",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "$upcomingDayText, $timeText",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: alarm.isActive,
                    onChanged: (_) => viewModel.toggleAlarm(alarm.id),
                  ),
                ],
              ),
              if (alarm.repeatDays.isNotEmpty) ...[
                SizedBox(height: 10),
                Row(children: repeatDayBoxes),
              ]
            ],
          ),
        ),
      ),
    ),
  );

}
