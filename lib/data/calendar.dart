import '../utils/files.dart';
import 'schedule_config.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'dart:convert';

Future<String> getDayType(String school, DateTime date) async {
  Map calendar = await readCalendar();

  if (calendar.isEmpty) {
    await _saveCalendar();
    calendar = await readCalendar();
    print('Getting calendar from web');
  }

  String dateKey = date.hashCode.toString();
  String dayType = '';
  if (calendar[school].containsKey(dateKey)) {
    dayType = calendar[school][dateKey];
  } else {
    dayType = '';
  }

  return dayType;
}

Future<void> _saveCalendar() async {
  final config = getCalendarConfig();
  String calJsonStr =
      await getCalendarJson(config['link'] ?? '', config['regex'] ?? '');
  await writeCalendar(calJsonStr);
  // retry logic or smth
}

Future<String> getCalendarJson(String link, String regex) async {
  final response = await http.get(Uri.parse(link));

  if (response.statusCode ~/ 100 != 2) {
    return "";
  }

  String ics = response.body;

  Map<String, dynamic> iCalendar = ICalendar.fromString(ics).toJson();

  Map<String, Map<String, String>> condenseCal = {
    'ELEM': {},
    'MHS': {},
    'HMX': {}
  };

  RegExp exp = RegExp(regex);

  late RegExpMatch? ma;
  for (var entry in iCalendar['data']) {
    ma = exp.firstMatch(entry['summary']);
    if (ma != null &&
        ma[1] != null &&
        ma[2] != null &&
        condenseCal.containsKey(ma[1])) {
      String school = ma[1]!;
      String date = entry['dtstart']?['dt'] ?? '';
      String dt_date = DateTime.parse(date).hashCode.toString();
      String dayType = ma[2]!;

      condenseCal[school]![dt_date] = dayType;
    }
  }

  return jsonEncode(condenseCal);
}
