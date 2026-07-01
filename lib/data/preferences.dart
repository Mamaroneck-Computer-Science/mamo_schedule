import '../classes/class_period.dart';
import 'package:flutter/material.dart';

String getSchool(String profileName) {
  return 'MHS';
}

List<ClassPeriod> getStudentSchedule(String profileName) {
  return [
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
