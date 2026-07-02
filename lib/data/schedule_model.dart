import 'package:flutter/material.dart';
import '../classes/class_period.dart';
import '../classes/period.dart';
import 'calendar.dart';
import 'preferences.dart';
import 'schedule_config.dart';
import '../utils/schedule_builder.dart';
import 'package:clock/clock.dart';

class ScheduleModel extends ChangeNotifier {
  DateTime dt = clock.now();
  DateTime day = clock
      .now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  String scheduleProfileName = '';

  String dayType = '';
  String school = '';
  List<Period> daySchedule = [];
  List<ClassPeriod> studentSchedule = [];
  List<Period> pastPeriods = [];
  Period? currentPeriod;
  List<Period> futurePeriods = [];

  ScheduleModel();

  void setSchedule(DateTime? date, String? profileName) async {
    if (date != null) {
      this.dt = date;
      this.day = date.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    }
    if (profileName != null) {
      this.scheduleProfileName = profileName;
    }

    if (this.scheduleProfileName == '') {
      print('no schedule');
    } else {
      await _loadStudentData();
      refreshSchedule();
    }
  }

  Future<void> _loadStudentData() async {
    final data = await getSchoolSchedule(scheduleProfileName);
    this.school = data.$1;
    this.studentSchedule = data.$2;
    this.dayType = await getDayType(school, this.day);
    this.daySchedule = await getDaySchedule(school, dayType, this.day);
  }

  /// Activates [profileName] as the schedule shown on the home screen and
  /// persists it so it's restored on next launch.
  Future<void> switchProfile(String profileName) async {
    await setActiveProfile(profileName);
    scheduleProfileName = profileName;
    await _loadStudentData();
    refreshSchedule();
  }

  /// Re-reads the current profile from disk (e.g. after saving an edit).
  Future<void> reload() async {
    if (scheduleProfileName.isEmpty) return;
    await _loadStudentData();
    refreshSchedule();
  }

  /// Resets to the empty state, used when the active profile is deleted and
  /// no other schedule takes its place.
  void clear() {
    scheduleProfileName = '';
    school = '';
    daySchedule = [];
    studentSchedule = [];
    pastPeriods = [];
    currentPeriod = null;
    futurePeriods = [];
    notifyListeners();
  }

  void refreshSchedule() {
    // if today's date, use dt.now
    // otherwise, use like midnight or smth, & don't render time until / starting in.
    if (clock.now().difference(day) <= Duration(hours: 24)) {
      dt = clock.now();
    } else {
      dt = day;
    }
    final result = getSchedule(dt, daySchedule, studentSchedule);

    pastPeriods = result.$1;
    currentPeriod = result.$2;
    futurePeriods = result.$3;
    notifyListeners();
  }
}
