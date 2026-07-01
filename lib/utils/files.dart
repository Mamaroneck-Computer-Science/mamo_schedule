import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

const SCHEDULE_FILE_NAME = 'schedule.json';

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

  cal_file.writeAsString(CalendarJson);
  return;
}
