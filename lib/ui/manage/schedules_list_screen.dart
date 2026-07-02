import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/preferences.dart';
import '../../data/schedule_model.dart';
import '../theme.dart';
import 'edit_schedule_screen.dart';

/// "Schedules" screen — pick a schedule to edit (which also activates it for
/// the home screen), or add a new one.
class SchedulesListScreen extends StatefulWidget {
  const SchedulesListScreen({super.key});

  @override
  State<SchedulesListScreen> createState() => _SchedulesListScreenState();
}

class _SchedulesListScreenState extends State<SchedulesListScreen> {
  List<ScheduleSummary> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summaries = await getScheduleSummaries();
    if (!mounted) return;
    setState(() {
      _summaries = summaries;
      _loading = false;
    });
  }

  Future<void> _openSchedule(ScheduleSummary s) async {
    final model = context.read<ScheduleModel>();
    await model.switchProfile(s.profileName);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditScheduleScreen(profileName: s.profileName),
      ),
    );
    _load();
  }

  Future<void> _createSchedule() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditScheduleScreen(profileName: null),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activeProfile = context.watch<ScheduleModel>().scheduleProfileName;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  Row(
                    children: [
                      RoundBtnBack(onTap: () => Navigator.of(context).maybePop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Schedules',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3,
                                color: c.text,
                              ),
                            ),
                            Text(
                              'Pick one to edit, or add a new schedule',
                              style: TextStyle(fontSize: 12.5, color: c.text3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (final s in _summaries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: _ScheduleCard(
                        summary: s,
                        selected: s.profileName == activeProfile,
                        onTap: () => _openSchedule(s),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _NewScheduleButton(onTap: _createSchedule),
                ],
              ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleSummary summary;
  final bool selected;
  final VoidCallback onTap;
  const _ScheduleCard({
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = summary.profileName.isEmpty
        ? '?'
        : summary.profileName.characters.first.toUpperCase();

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? c.accent : c.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: c.accentGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.profileName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.2,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${summary.school} · ${summary.classCount} classes',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: c.text2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewScheduleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewScheduleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: c.accent),
            const SizedBox(width: 9),
            Text(
              'New schedule',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: c.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Local back button (kept here to avoid a cross-import of AddClassScreen's
/// private widgets).
class RoundBtnBack extends StatelessWidget {
  final VoidCallback onTap;
  const RoundBtnBack({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Icon(Icons.chevron_left, size: 22, color: c.text2),
        ),
      ),
    );
  }
}
