import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/alarm_model.dart';

final _uuid = Uuid();

/// Shows the edit alarm dialog and returns the updated alarm data.
/// Returns null if user cancels.
Future<AlarmModel?> showAlarmEditDialog(BuildContext context, AlarmModel alarm) async {
  final labelController = TextEditingController(text: alarm.label);
  AlarmType selectedType = alarm.type;

  List<bool> selectedRepeatDays = List.generate(7, (index) {
    // 1=Monday ... 7=Sunday
    return alarm.repeatDays.contains(index + 1);
  });

  DateTime selectedDateTime = alarm.time;

  // Date picker
  Future<bool> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        selectedDateTime.hour,
        selectedDateTime.minute,
      );
      return true;
    }
    return false;
  }

  // Time picker
  Future<bool> pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      selectedDateTime = DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      return true;
    }
    return false;
  }

  return showDialog<AlarmModel>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isSunEvent = alarm.type == AlarmType.sunrise || alarm.type == AlarmType.sunset;
          final timeFormatter = DateFormat('yyyy-MM-dd HH:mm'); // 24-hour format
          return AlertDialog(
            title: Text('Edit Alarm'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(labelText: 'Label'),
                    ),
                    SizedBox(height: 10),

                    // Date picker (always shown)
                    ElevatedButton(
                      onPressed: () async {
                        if (await pickDate()) setState(() {});
                      },
                      child: Text('Date'),
                    ),

                    // Time picker — only if NOT sunrise/sunset
                    if (!isSunEvent)
                      ElevatedButton(
                        onPressed: () async {
                          if (await pickTime()) setState(() {});
                        },
                        child: Text('Time'),
                      ),

                    SizedBox(height: 8),
                    Text(
                      "Selected: ${timeFormatter.format(selectedDateTime.toLocal())}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),

                    SizedBox(height: 10),

                    // Repeat Days
                    Text('Repeat Days'),
                    Wrap(
                      spacing: 4,
                      children: List.generate(7, (index) {
                        final dayLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
                        final isSelected = selectedRepeatDays[index];

                        return FilterChip(
                          label: Text(
                            dayLabel,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                          onSelected: (selected) {
                            setState(() {
                              selectedRepeatDays[index] = selected;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newLabel = labelController.text.trim();
                  if (newLabel.isEmpty) return;

                  final repeatDaysSet = <int>{};
                  for (int i = 0; i < selectedRepeatDays.length; i++) {
                    if (selectedRepeatDays[i]) {
                      repeatDaysSet.add(i + 1);
                    }
                  }

                  Navigator.of(context).pop(
                    alarm.copyWith(
                      label: newLabel,
                      time: selectedDateTime,
                      repeatDays: repeatDaysSet,
                    ),
                  );
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
