import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock/clock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/preferences.dart';
import 'data/schedule_model.dart';
import 'ui/schedule_screen.dart';
import 'ui/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clock/clock.dart';

Future<void> main() async {
  final mockTime = DateTime(2025, 9, 1);
  withClock(Clock.fixed(mockTime), () async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    print(await getApplicationDocumentsDirectory());

    final schedule = ScheduleModel();
    final activeProfile = await getActiveProfile();
    String? profileToLoad = activeProfile;
    if (profileToLoad == null) {
      final names = (await getProfileNames()).cast<String>();
      profileToLoad = names.isNotEmpty ? names.first : null;
    }
    if (profileToLoad != null) {
      schedule.setSchedule(clock.now(), profileToLoad);
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: schedule),
          ChangeNotifierProvider(create: (_) => ThemeController()),
        ],
        child: const MamoApp(),
      ),
    );
  });
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
