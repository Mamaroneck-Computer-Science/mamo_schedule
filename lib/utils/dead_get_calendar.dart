// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:icalendar_parser/icalendar_parser.dart';
// import 'dart:convert';

// import 'dart:io';

// void main() async {
//   String link =
//       'https://www.mamkschools.org/cf_calendar/feed.cfm?type=ical&feedID=816A4F51E2B9463196235942E2F3C372';

//   String regexString = r'(MHS|HMX|ELEM) (?:Day|Even|Odd) \[?(.+\]?)';

//   print(jsonDecode(await getCalendarJson(link, regexString))['MHS']);

//   String olink =
//       'https://raw.githubusercontent.com/mamorobotics/Ventgarden/refs/heads/master/config.json';
// }

// Future<String> getCalendarJson(String link, String regex) async {
//   final response = await http.get(Uri.parse(link));

//   if (response.statusCode ~/ 100 != 2) {
//     return "";
//   }

//   String ics = response.body;

//   Map<String, dynamic> iCalendar = ICalendar.fromString(ics).toJson();

//   Map<String, Map<String, String>> condenseCal = {
//     'ELEM': {},
//     'MHS': {},
//     'HMX': {}
//   };

//   RegExp exp = RegExp(regex);

//   late RegExpMatch? ma;
//   for (var entry in iCalendar['data']) {
//     ma = exp.firstMatch(entry['summary']);
//     if (ma != null &&
//         ma[1] != null &&
//         ma[2] != null &&
//         condenseCal.containsKey(ma[1])) {
//       String school = ma[1]!;
//       String date = entry['dtstart']?['dt'] ?? '';
//       String dt_date = DateTime.parse(date).hashCode.toString();
//       String dayType = ma[2]!;

//       condenseCal[school]![dt_date] = dayType;
//     }
//   }

//   return jsonEncode(condenseCal);
// }




// // String getCalendarJSON(String link, String regex) async* {
// //   final response = await http.get(Uri.parse(link));

// //   Map<String, dynamic> iCalendar = ICalendar.fromString(response.body).toJson();
  
// //   Map<String, Map<String, String>> condenseCal = {
// //     'ELEM': {},
// //     'MHS': {},
// //     'HMX': {}
// //   };


// //   RegExp exp = RegExp(regex); //r'(MHS|HMX|ELEM) (?:Day|Even|Odd) \[?(.+\]?)'

// //   late RegExpMatch? ma;
// //   for (var entry in iCalendar['data']) {
// //     ma = exp.firstMatch(entry['summary']);
// //     if (ma != null &&
// //         ma[1] != null &&
// //         ma[2] != null &&
// //         condenseCal.containsKey(ma[1])) {
// //       String school = ma[1]!;
// //       String date = entry['dtstart']?['dt'] ?? '';
// //       String dt_date = DateTime.parse(date).toIso8601String();
// //       String dayType = ma[2]!;
// //       condenseCal[school]![dt_date] = dayType;
// //     }
// //   }

// //   return 
// // }
