import 'class_period.dart';

class Period {
  int index;
  String id;
  DateTime startTime;
  int duration;
  bool isClass;
  bool showOnSchedule;
  ClassPeriod? scheduledClass;

  Period(this.index, this.id, this.startTime, this.duration, this.isClass,
      this.showOnSchedule);

  void setScheduledClass(ClassPeriod scheduledClass) {
    this.scheduledClass = scheduledClass;
  }

  @override
  String toString() {
    String name;
    final scheduled = scheduledClass;
    if (scheduled != null) {
      name = scheduled.name;
    } else {
      name = id;
    }

    return '$name at $startTime for $duration minutes';
  }
}
