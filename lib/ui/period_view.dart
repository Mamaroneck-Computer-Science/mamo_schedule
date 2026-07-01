import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/period.dart';
import 'theme.dart';

enum PeriodStatus { past, current, future }

/// A single renderable row in the day list, pairing a [Period] with its
/// computed status relative to the current time.
class PeriodView {
  final Period period;
  final PeriodStatus status;

  const PeriodView(this.period, this.status);

  bool get isPast => status == PeriodStatus.past;
  bool get isCurrent => status == PeriodStatus.current;

  /// A class block the student actually has (has a [ClassPeriod] attached).
  bool get isClass => period.isClass && period.scheduledClass != null;

  /// A class block where the student has nothing scheduled — a free period.
  bool get isFree => period.isClass && period.scheduledClass == null;

  /// A non-class block that still shows on the schedule (lunch, tiger-time…).
  bool get isBreak => !period.isClass;

  DateTime get start => period.startTime;
  DateTime get end => period.startTime.add(Duration(minutes: period.duration));

  String get title {
    final c = period.scheduledClass;
    if (c != null) return c.name;
    if (isFree) return 'Free';
    return _prettyId(period.id);
  }

  String? get room => period.scheduledClass?.room;

  /// Period label shown in the numbered chip ("3", "🍴" for lunch, etc.).
  String get chipLabel {
    if (isBreak) return _breakIcon(period.id);
    return period.id;
  }

  /// Colour for the row accent — uses the class colour when set, otherwise a
  /// stable palette colour derived from the period number.
  Color resolvedColor(Color fallback) {
    final c = period.scheduledClass?.color;
    if (c != null && c != Colors.black) return c;
    final n = int.tryParse(period.id);
    if (n != null) return kClassPalette[(n - 1) % kClassPalette.length];
    return fallback;
  }
}

String _prettyId(String id) {
  switch (id) {
    case 'lunch':
      return 'Lunch';
    case 'tiger-time':
      return 'Tiger Time';
    default:
      return id;
  }
}

String _breakIcon(String id) {
  switch (id) {
    case 'lunch':
      return '🍴';
    case 'tiger-time':
      return '🐯';
    default:
      return '•';
  }
}

/// Builds the ordered, display-ready list of rows from the model's three
/// buckets, dropping anything flagged not to show (transitions).
List<PeriodView> buildPeriodViews({
  required List<Period> past,
  required Period? current,
  required List<Period> future,
}) {
  final views = <PeriodView>[
    for (final p in past) PeriodView(p, PeriodStatus.past),
    if (current != null) PeriodView(current, PeriodStatus.current),
    for (final p in future) PeriodView(p, PeriodStatus.future),
  ];
  return views.where((v) => v.period.showOnSchedule).toList();
}

final DateFormat _timeFmt = DateFormat('h:mm');

String formatTime(DateTime t) => _timeFmt.format(t);
