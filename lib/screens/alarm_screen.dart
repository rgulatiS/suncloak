import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import '../viewmodels/alarm_viewmodel.dart';
import '../helper/alarm_creation_helper.dart';
import '../widgets/alarm_tile.dart';
import '../widgets/alarm_edit_dialog.dart';
import 'package:geolocator/geolocator.dart';
import '../services/alarm_service.dart';

class AlarmScreen extends StatefulWidget {
  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final uuid = Uuid();
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      userLat = position.latitude;
      userLng = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AlarmViewModel>(context);
    final alarms = viewModel.alarms;

    Future<void> _editAlarm(BuildContext context, AlarmModel alarm) async {
      final viewModel = Provider.of<AlarmViewModel>(context, listen: false);
      final result = await showAlarmEditDialog(context, alarm);

      if (result != null) {
        viewModel.updateAlarmFull(
          alarm.id,
          result.time,
          result.label,
          result.type,
          repeatDays: result.repeatDays,
        );
        if (alarm.isActive && userLat != null && userLng != null) {
          await AlarmService.scheduleNextAlarm(
            alarm,
            lat: userLat!,
            lng: userLng!,
          );
        }
      }
    }

    Future<void> createRegularAlarm(BuildContext context,
        AlarmViewModel viewModel) async {
      final now = DateTime.now().add(Duration(minutes: 1));
      final newAlarm = AlarmModel(
        id: uuid.v4(),
        time: now,
        type: AlarmType.regular,
        label: "",
      );

      final result = await showAlarmEditDialog(context, newAlarm);

      if (result != null) {
        final alarmToAdd = AlarmModel(
          id: newAlarm.id,
          time: result.time,
          type: result.type,
          label: result.label,
          repeatDays: result.repeatDays,
          isActive: true,
        );

        viewModel.addAlarm(alarmToAdd);

        if (userLat != null && userLng != null) {
          await AlarmService.scheduleNextAlarm(
            alarmToAdd,
            lat: userLat!,
            lng: userLng!,
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('SunCloak Alarms')),
      body: userLat == null || userLng == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (_, index) {
          final alarm = alarms[index];
          return Dismissible(
            key: Key(alarm.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Delete Alarm?'),
                  content:
                  Text('Are you sure you want to delete this alarm?'),
                  actions: [
                    TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false),
                        child: Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete')),
                  ],
                ),
              );
            },
            onDismissed: (_) async {
              await AlarmService.cancelAlarm(alarm);
              viewModel.deleteAlarm(alarm.id);
            },
            child: buildAlarmListTile(
              context: context,
              alarm: alarm,
              viewModel: viewModel,
              onEdit: _editAlarm,
              userLat: userLat!,
              userLng: userLng!,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Center(child: CircularProgressIndicator()),
          );
          try {
            final selectedType = await showDialog<AlarmType>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text('Select Alarm Type'),
                children: [
                  SimpleDialogOption(
                    child: Text('Regular'),
                    onPressed: () => Navigator.pop(context, AlarmType.regular),
                  ),
                  SimpleDialogOption(
                    child: Text('Sunrise'),
                    onPressed: () => Navigator.pop(context, AlarmType.sunrise),
                  ),
                  SimpleDialogOption(
                    child: Text('Sunset'),
                    onPressed: () => Navigator.pop(context, AlarmType.sunset),
                  ),
                ],
              ),
            );

            if (selectedType == null) return;

            if (selectedType == AlarmType.regular) {
              await createRegularAlarm(context, viewModel);
            } else {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) {
                  bool isBefore = true;
                  final offsetController = TextEditingController(text: '10');

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(
                            '${selectedType == AlarmType.sunrise ? "Sunrise" : "Sunset"} Alarm Settings'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text('Before'),
                                Radio<bool>(
                                  value: true,
                                  groupValue: isBefore,
                                  onChanged: (val) {
                                    setState(() {
                                      isBefore = val!;
                                    });
                                  },
                                ),
                                Text('After'),
                                Radio<bool>(
                                  value: false,
                                  groupValue: isBefore,
                                  onChanged: (val) {
                                    setState(() {
                                      isBefore = val!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            TextField(
                              controller: offsetController,
                              keyboardType: TextInputType.number,
                              decoration:
                              InputDecoration(labelText: 'Offset in minutes'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, {
                                'isBefore': isBefore,
                                'offset': int.tryParse(offsetController.text) ?? 0,
                              });
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

              if (result == null) return;

              final isBefore = result['isBefore'] as bool;
              final offset = result['offset'] as int;

              final alarm = await AlarmCreationHelper.createSunriseSunsetAlarm(
                type: selectedType,
                isBefore: isBefore,
                beforeAfterMinutes: offset,
              );

              if (alarm != null) {
                viewModel.addAlarm(alarm);

                if (userLat != null && userLng != null) {
                  await AlarmService.scheduleNextAlarm(
                    alarm,
                    lat: userLat!,
                    lng: userLng!,
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to get location for alarm')),
                );
              }
            }
          } finally {
            Navigator.of(context).pop(); // remove loading
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
