import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/schedule_model.dart';
import 'add_class_screen.dart';
import 'period_view.dart';
import 'theme.dart';
import 'widgets/active_period_row.dart';
import 'widgets/day_switcher.dart';
import 'widgets/period_row.dart';
import 'widgets/profile_menu.dart';

/// The primary "Today" screen — the whole day on one screen, driven entirely
/// by [ScheduleModel].
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Whole-day offset of the viewed day relative to today.
  int _dayOffset(DateTime day) =>
      _midnight(day).difference(_midnight(DateTime.now())).inDays;

  String _heading(int offset, DateTime day) {
    switch (offset) {
      case 0:
        return 'Today';
      case -1:
        return 'Yesterday';
      case 1:
        return 'Tomorrow';
      default:
        return DateFormat('EEEE').format(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ScheduleModel>();
    final theme = context.watch<ThemeController>();
    final c = context.colors;

    final views = buildPeriodViews(
      past: model.pastPeriods,
      current: model.currentPeriod,
      future: model.futurePeriods,
    );

    final offset = _dayOffset(model.day);
    final isToday = offset == 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              dateLabel: DateFormat('EEEE · MMM d').format(model.day),
              dayType: model.dayType,
              heading: _heading(offset, model.day),
              profileName: model.scheduleProfileName,
              isDark: theme.isDark,
              onToggleTheme: theme.toggle,
              onAdd: () => _openManage(context),
              onProfileAction: (_) => _openManage(context),
            ),
            _DayMeta(views: views, offset: offset),
            Expanded(
              child: model.scheduleProfileName.isEmpty || views.isEmpty
                  ? _EmptyState(
                      hasProfile: model.scheduleProfileName.isNotEmpty)
                  : _ScheduleList(views: views),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DaySwitcher(
          day: model.day,
          dayType: model.dayType,
          isToday: isToday,
          onPrev: () => _shiftDay(context, model, -1),
          onNext: () => _shiftDay(context, model, 1),
          onToday: () => model.setSchedule(DateTime.now(), null),
        ),
      ),
      backgroundColor: c.bg,
    );
  }

  void _shiftDay(BuildContext context, ScheduleModel model, int days) {
    model.setSchedule(model.day.add(Duration(days: days)), null);
  }

  void _openManage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddClassScreen()),
    );
  }
}

class _Header extends StatelessWidget {
  final String dateLabel;
  final String dayType;
  final String heading;
  final String profileName;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onAdd;
  final ValueChanged<ProfileAction> onProfileAction;

  const _Header({
    required this.dateLabel,
    required this.dayType,
    required this.heading,
    required this.profileName,
    required this.isDark,
    required this.onToggleTheme,
    required this.onAdd,
    required this.onProfileAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 18, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        dateLabel.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: c.accent,
                        ),
                      ),
                    ),
                    if (dayType.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _DayTag(dayType: dayType),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                    color: c.text,
                  ),
                ),
              ],
            ),
          ),
          ProfileMenu(profileName: profileName, onAction: onProfileAction),
        ],
      ),
    );
  }
}

class _DayTag extends StatelessWidget {
  final String dayType;
  const _DayTag({required this.dayType});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Day $dayType',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: c.accent,
        ),
      ),
    );
  }
}

class _DayMeta extends StatelessWidget {
  final List<PeriodView> views;
  final int offset;
  const _DayMeta({required this.views, required this.offset});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final classes = views.where((v) => v.isClass).toList();
    final endTime = classes.isEmpty
        ? null
        : classes.map((v) => v.end).reduce((a, b) => a.isAfter(b) ? a : b);

    final int left;
    if (offset > 0) {
      left = classes.length;
    } else if (offset < 0) {
      left = 0;
    } else {
      left = classes.where((v) => !v.isPast).length;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
      child: Row(
        children: [
          _metaChip(c, '${classes.length}', ' classes'),
          const SizedBox(width: 14),
          if (endTime != null)
            _metaChip(c, '', 'Ends ', trailing: formatTime(endTime)),
          if (endTime != null) const SizedBox(width: 14),
          _metaChip(c, '$left', ' left'),
        ],
      ),
    );
  }

  Widget _metaChip(AppColors c, String bold, String label, {String? trailing}) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: c.text2,
        ),
        children: [
          if (bold.isNotEmpty)
            TextSpan(
              text: bold,
              style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
            ),
          TextSpan(text: label),
          if (trailing != null)
            TextSpan(
              text: trailing,
              style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<PeriodView> views;
  const _ScheduleList({required this.views});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 2, 24, 10),
          child: Text(
            "TODAY'S SCHEDULE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: c.text3,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            itemCount: views.length,
            separatorBuilder: (_, __) => const SizedBox(height: 7),
            itemBuilder: (context, i) {
              final v = views[i];
              if (v.isCurrent) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NowDivider(),
                    const SizedBox(height: 3),
                    ActivePeriodRow(view: v),
                  ],
                );
              }
              return PeriodRow(view: v);
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasProfile;
  const _EmptyState({required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48, color: c.text3),
            const SizedBox(height: 16),
            Text(
              hasProfile ? 'No classes this day' : 'No schedule loaded',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.text2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasProfile
                  ? 'Enjoy the day off.'
                  : 'Pick a schedule profile to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: c.text3),
            ),
          ],
        ),
      ),
    );
  }
}
