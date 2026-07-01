import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/schedule_model.dart';
import 'ui/schedule_screen.dart';
import 'ui/theme.dart';

void main() {
  final schedule = ScheduleModel()..setSchedule(DateTime.now(), 'testName');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: schedule),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: const MamoApp(),
    ),
  );
}

class MamoApp extends StatelessWidget {
  const MamoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeController>().mode;
    return MaterialApp(
      title: 'ClassDay',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: const ScheduleScreen(),
    );
  }
}
