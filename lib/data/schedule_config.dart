import 'package:http/http.dart' as http;
import 'dart:convert';
import '../classes/period.dart';

Map<String, String> getCalendarConfig() {
  return {
    'link':
        'https://www.mamkschools.org/cf_calendar/feed.cfm?type=ical&feedID=816A4F51E2B9463196235942E2F3C372',
    'regex': r'(MHS|HMX|ELEM) (?:Day|Even|Odd) \[?(.+\]?)'
  };
}

Future<Map> getJson(String link) async {
  try {
    final response = await http.get(Uri.parse(link));

    return jsonDecode(response.body);
  } catch (e) {
    print(e);
    return {};
  }
}

List<Period> getDaySchedule(String school, String dayType, DateTime date) {
  // Day 1 schedule starting at 8:00 AM (480 minutes)
  final baseTime = DateTime(date.year, date.month, date.day, 8, 0);
  // need to set start of day

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
