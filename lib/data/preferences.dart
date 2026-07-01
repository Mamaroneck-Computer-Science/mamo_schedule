import 'dart:convert';

import '../classes/class_period.dart';
import 'package:flutter/material.dart';
import '../utils/files.dart';

Future<List> getProfileNames() async {
  final preferences = await readPreferences();
  return preferences.keys.toList();
}

String _getSchool(String profileName, Map preferences) {
  if (preferences.containsKey(profileName) &&
      preferences[profileName].containsKey("school")) {
    return preferences[profileName]["school"];
  } else {
    return 'MHS'; // shoud this be an empty string?
  }
}

Color stringToColor(String colorString) {
  return Color(int.parse(colorString, radix: 16));
}

String colorToString(Color col) {
  return col.toARGB32().toRadixString(16);
}

List<ClassPeriod> _getStudentSchedule(String profileName, Map preferences) {
  List<ClassPeriod> schedule = [];
  if (preferences.containsKey(profileName) &&
      preferences[profileName].containsKey('classes')) {
    for (var per in preferences[profileName]['classes']) {
      schedule.add(ClassPeriod(per['period'], per['name'], per['room'],
          per['teacher'], stringToColor(per['color'])));
    }
  } else {
    // update with a default based on the number of periods for that school / thing
    schedule = [
      ClassPeriod('1', 'Math', 'B256', 'MJL3', Colors.black),
      ClassPeriod('2', 'Journalism', 'B256', 'MJL3', Colors.black),
      ClassPeriod('3', 'Physics', 'B256', 'MJL3', Colors.black),
      ClassPeriod('4', 'PE', 'B256', 'MJL3', Colors.black),
      ClassPeriod('5', 'OSR', 'B256', 'MJL3', Colors.black),
      ClassPeriod('6', 'Engyy', 'B256', 'MJL3', Colors.black),
      ClassPeriod('7', 'Macro', 'B256', 'MJL3', Colors.black),
      ClassPeriod('8', 'Spanish', 'B256', 'MJL3', Colors.black),
    ];
  }
  return schedule;
}

Future<(String, List<ClassPeriod>)> getSchoolSchedule(
    String profileName) async {
  final preferences = await readPreferences();

  String school = _getSchool(profileName, preferences);
  List<ClassPeriod> schedule = _getStudentSchedule(profileName, preferences);

  return (school, schedule);
}

List<Map> getStudentScheduleMap(List<ClassPeriod> schedule) {
  List<Map> jsonObj = [];
  for (var per in schedule) {
    jsonObj.add({
      "class_name": per.name,
      "period": per.period,
      "room": per.room,
      "teacher": per.teacherName,
      "color": colorToString(per.color)
    });
  }
  return jsonObj;
}

Future<void> _savePreferences(Map preferences) async {
  try {
    String jsonOut = jsonEncode(preferences);
    await writePrefences(jsonOut);
    return;
  } catch (e) {
    print(e);
    return;
    // Add error handling - show success / failure.
  }
}

Future<void> addSchedule(
    String profileName, String school, List<ClassPeriod> schedule) async {
  Map preferences = await readPreferences();
  preferences[profileName] = {
    "school": school,
    "classes": getStudentScheduleMap(schedule)
  };

  await _savePreferences(preferences);
  return;
}

Future<void> renameSchedule(
    String oldProfileName, String newProfileName) async {
  Map preferences = await readPreferences();
  preferences[newProfileName] = preferences[oldProfileName];
  preferences.remove(oldProfileName);

  await _savePreferences(preferences);
  return;
}

Future<void> updateSchedule(
    String profileName, String? school, List<ClassPeriod>? schedule) async {
  Map preferences = await readPreferences();
  if (school != null) {
    preferences[profileName]['school'] = school;
  }
  if (schedule != null) {
    preferences[profileName]['classes'] = getStudentScheduleMap(schedule);
  }

  await _savePreferences(preferences);
  return;
}

Future<void> deleteSchedule(String profileName) async {
  Map preferences = await readPreferences();

  preferences.remove(profileName);

  await _savePreferences(preferences);
  return;
}
