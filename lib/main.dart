// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/alarm_screen.dart';
import 'viewmodels/alarm_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmViewModel()),
      ],
      child: SunCloakApp(),
    ),
  );
}

class SunCloakApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunCloak',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AlarmScreen(),
    );
  }
}
