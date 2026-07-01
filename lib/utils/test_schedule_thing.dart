void main() {
  DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Whole-day offset of the viewed day relative to today.
  Duration _dayOffset(DateTime day) =>
      _midnight(day).difference(_midnight(DateTime.now()));

  DateTime test1 = DateTime(2026, 6, 30, 6, 30);
  DateTime test2 = DateTime(2026, 7, 1, 4, 30);

  print(_dayOffset(test1));
}
