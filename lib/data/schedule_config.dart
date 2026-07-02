import 'package:http/http.dart' as http;
import 'package:mamo_schedule/utils/files.dart';
import 'dart:convert';
import '../classes/period.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getJson(String link) async {
  try {
    final response = await http.get(Uri.parse(link));

    return response.body;
  } catch (e) {
    print(e);
    return '';
  }
}

Future<void> _saveConfig() async {
  String link = dotenv.env['SCHEDULE_CONFIG_URL'] ??
      'https://raw.githubusercontent.com/Mamaroneck-Computer-Science/mamo_schedule/refs/heads/master/schedule_config.json';
  print(link);
  final data = await getJson(link);
  await writeScheduleCOnfig(data);
  return;
}

Future<Map> _getConfig() async {
  Map config = await readScheduleConfig();

  if (config.isEmpty) {
    await _saveConfig();
    config = await readScheduleConfig();
    print('Getting config from web');
  }

  return config;
}

Future<Map<String, String>> getCalendarConfig() async {
  Map config = await _getConfig();
  return {
    'link': config['calendar_link'],
    'regex': r'(MHS|HMX|ELEM) (?:Day|Even|Odd) \[?(.+\]?)'
  };
}

Future<List<Period>> getDaySchedule(
    String school, String dayType, DateTime date) async {
  if (dayType.isEmpty) {
    return [];
  }
  Map config = await _getConfig();
  Map day_type_config = config['day_config'][dayType];

  Map period_config = config['period_config'];
  config.clear();

  // Day 1 schedule starting at 8:00 AM (480 minutes)
  final baseTime =
      DateTime(date.year, date.month, date.day, 0, day_type_config['start']);
  // need to set start of day

  List<Period> daySchedule = [];
  int sum_duration = 0;

  int i = 0;

  for (var (period) in day_type_config['periods']) {
    daySchedule.add(Period(
        i,
        period['period'],
        baseTime.add(Duration(minutes: sum_duration)),
        period['duration'],
        period_config[period['period']]['class'],
        period_config[period['period']]['show']));

    sum_duration += period['duration'] as int;
    i += 1;
  }

  return daySchedule;

  return [
    Period(0, '3', baseTime.add(Duration(minutes: 0)), 55, true, true),
    Period(
        1, 'transition', baseTime.add(Duration(minutes: 55)), 6, false, false),
    Period(2, '4', baseTime.add(Duration(minutes: 61)), 55, true, true),
    Period(
        3, 'tiger-time', baseTime.add(Duration(minutes: 116)), 6, false, true),
    Period(
        4, 'transition', baseTime.add(Duration(minutes: 122)), 6, false, false),
    Period(5, '5', baseTime.add(Duration(minutes: 128)), 55, true, true),
    Period(6, 'lunch', baseTime.add(Duration(minutes: 183)), 45, false, true),
    Period(7, '6', baseTime.add(Duration(minutes: 228)), 55, true, true),
    Period(
        8, 'transition', baseTime.add(Duration(minutes: 283)), 6, false, false),
    Period(9, '7', baseTime.add(Duration(minutes: 289)), 55, true, true),
    Period(10, 'transition', baseTime.add(Duration(minutes: 344)), 6, false,
        false),
    Period(11, '8', baseTime.add(Duration(minutes: 350)), 55, true, true),
  ];
}

List<String> getSchools() {
  return ['MHS', 'HMX', 'ELEM'];
}

Future<List<String>> getClassPeriods(String school) async {
  // I don't want this to be an O(n) operation - this should maybe stay in memory? Idk how many times this is called.
  Map config = await _getConfig();

  Map period_config = config['period_config'];
  config.clear();
  List<String> classes = [];

  for (String key in period_config.keys) {
    if (period_config[key]['class']) {
      classes.add(key);
    }
  }

  return classes;
}
