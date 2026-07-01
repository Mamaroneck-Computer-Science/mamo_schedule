import 'package:flutter/material.dart';
import '../classes/class_period.dart';
import '../classes/period.dart';
import 'calendar.dart';
import 'preferences.dart';
import 'schedule_config.dart';
import '../utils/schedule_builder.dart';

class ScheduleModel extends ChangeNotifier {
  DateTime dt = DateTime.now();
  DateTime day = DateTime.now()
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
      // We don't want to re-run all of this code, every time.
      this.school = getSchool(scheduleProfileName);
      this.dayType = '1'; //await getDayType(school, this.day);
      this.daySchedule = getDaySchedule(school, dayType, this.day);
      this.studentSchedule = getStudentSchedule(scheduleProfileName);

      refreshSchedule();
    }
  }

  void refreshSchedule() {
    // if today's date, use dt.now
    // otherwise, use like midnight or smth, & don't render time until / starting in.
    if (DateTime.now().difference(day) <= Duration(hours: 24)) {
      dt = DateTime.now();
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
