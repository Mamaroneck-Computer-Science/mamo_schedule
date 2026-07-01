import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> _getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> _getLocalFile() async {
  final path = await _getLocalPath();
  return File('$path/schedule_test.json');
}

Future<File> writeCounter(int counter) async {
  final file = await _getLocalFile();
  return file.writeAsString('$counter');
}
