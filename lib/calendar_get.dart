import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'dart:convert';

import 'dart:io';

void main() async {
  String link =
      'https://www.mamkschools.org/cf_calendar/feed.cfm?type=ical&feedID=816A4F51E2B9463196235942E2F3C372';
  final response = await http.get(Uri.parse(link));

  String ics = response.body;

  Map<String, dynamic> iCalendar = ICalendar.fromString(ics).toJson();

  // String cal_json = JsonEncoder.withIndent('  ').convert(iCalendar);
  // final file = File('calendar_data.json');
  // await file.writeAsString(cal_json, mode: FileMode.write);

  Map<String, Map<DateTime, String>> condenseCal = {
    'ELEM': {},
    'MHS': {},
    'HMX': {}
  };

  RegExp exp = RegExp(r'(MHS|HMX|ELEM) (?:Day|Even|Odd) \[?(.+\]?)');

  late RegExpMatch? ma;
  for (var entry in iCalendar['data']) {
    ma = exp.firstMatch(entry['summary']);
    if (ma != null &&
        ma[1] != null &&
        ma[2] != null &&
        condenseCal.containsKey(ma[1])) {
      String school = ma[1]!;
      String date = entry['dtstart']?['dt'] ?? '';
      DateTime dt_date = DateTime.parse(date);
      String dayType = ma[2]!;
      condenseCal[school]![dt_date] = dayType;
    }
  }

  DateTime fdsa = DateTime.now();
  // print(DateTime(fdsa.year, fdsa.month, fdsa.day).toIso8601String());

  print(condenseCal['MHS']);
}

// String getCalendarJSON(String link, String regex) async* {
//   final response = await http.get(Uri.parse(link));

//   Map<String, dynamic> iCalendar = ICalendar.fromString(response.body).toJson();
  
//   Map<String, Map<String, String>> condenseCal = {
//     'ELEM': {},
//     'MHS': {},
//     'HMX': {}
//   };


//   RegExp exp = RegExp(regex); //r'(MHS|HMX|ELEM) (?:Day|Even|Odd) \[?(.+\]?)'

//   late RegExpMatch? ma;
//   for (var entry in iCalendar['data']) {
//     ma = exp.firstMatch(entry['summary']);
//     if (ma != null &&
//         ma[1] != null &&
//         ma[2] != null &&
//         condenseCal.containsKey(ma[1])) {
//       String school = ma[1]!;
//       String date = entry['dtstart']?['dt'] ?? '';
//       String dt_date = DateTime.parse(date).toIso8601String();
//       String dayType = ma[2]!;
//       condenseCal[school]![dt_date] = dayType;
//     }
//   }

//   return 
// }
