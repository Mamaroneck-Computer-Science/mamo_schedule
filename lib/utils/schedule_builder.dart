import '../classes/class_period.dart';
import '../classes/period.dart';

(List<Period>, Period?, List<Period>) getSchedule(
    DateTime dt, List<Period> daySchedule, List<ClassPeriod> studentSchedule) {
  // Implement this such that it just returns a list of periods or smth (i.e. if studentSchedule is empty.)
  Map schedule = {
    'previous': [],
    'current': null,
    'future': [],
  };
  List<Period> previousPeriods = [];
  Period? currentPeriod;
  List<Period> futurePeriods = [];

  List<String> studentScheduleIds = [];

  for (var classPeriod in studentSchedule) {
    studentScheduleIds.add(classPeriod.period);
  }

  for (var schedulePeriod in daySchedule) {
    if (schedulePeriod.isClass &&
        studentScheduleIds.contains(schedulePeriod.id)) {
      int class_index = studentScheduleIds.indexOf(schedulePeriod.id);
      schedulePeriod.setScheduledClass(studentSchedule[class_index]);
    }

    if (schedulePeriod.startTime.isAfter(dt)) {
      futurePeriods.add(schedulePeriod);
    } else if (dt.difference(schedulePeriod.startTime) >
        Duration(minutes: schedulePeriod.duration)) {
      previousPeriods.add(schedulePeriod);
    } else {
      if (currentPeriod != null) {
        print('ERROR');
      }
      currentPeriod = schedulePeriod;
    }
  }

  return (previousPeriods, currentPeriod, futurePeriods);
}
