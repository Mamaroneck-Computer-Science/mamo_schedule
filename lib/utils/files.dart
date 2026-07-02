import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

const SCHEDULE_FILE_NAME = 'schedule.json';
const PREFERENCE_FILE_NAME = 'preferences.json';
const CONFIG_FILE_NAME = 'schedule_config.json';

Future<File> _getFile(String file_name) async {
  final directory = (await getApplicationDocumentsDirectory()).path;

  return File('$directory/$file_name');
}

Future<Map> readCalendar() async {
  final cal_file = await _getFile(SCHEDULE_FILE_NAME);
  if (await cal_file.exists() == false) {
    return {};
    print('file does not exist');
  }

  try {
    final content = await cal_file.readAsString();

    final data = jsonDecode(content);
    return data;
  } catch (e) {
    print(e);
    return {};
  }
}

Future<void> writeCalendar(String CalendarJson) async {
  final cal_file = await _getFile(SCHEDULE_FILE_NAME);

  await cal_file.writeAsString(CalendarJson);
  return;
}

Future<Map> readPreferences() async {
  final pref_file = await _getFile(PREFERENCE_FILE_NAME);

  if (await pref_file.exists() == false) {
    return {};
    print('Preferences file does not exist');
  }

  try {
    final content = await pref_file.readAsString();
    final data = jsonDecode(content);
    return data;
  } catch (e) {
    print(e);
    return {};
  }
}

Future<void> writePrefences(String PreferenceJson) async {
  final pref_file = await _getFile(PREFERENCE_FILE_NAME);
  await pref_file.writeAsString(PreferenceJson);
  return;
}

Future<Map> readScheduleConfig() async {
  final schedule_config_file = await _getFile(CONFIG_FILE_NAME);
  if (await schedule_config_file.exists() == false) {
    return {};
    print('schedule config file does not exist');
  }

  try {
    final content = await schedule_config_file.readAsString();

    final data = jsonDecode(content);
    return data;
  } catch (e) {
    print(e);
    return {};
  }
}

Future<void> writeScheduleCOnfig(String ConfigJson) async {
  final cal_file = await _getFile(CONFIG_FILE_NAME);

  await cal_file.writeAsString(ConfigJson);
  return;
}
