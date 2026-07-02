import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/class_period.dart';
import '../../data/preferences.dart';
import '../../data/schedule_config.dart';
import '../../data/schedule_model.dart';
import '../theme.dart';
import 'edit_class_screen.dart';
import 'form_widgets.dart';

/// "Edit schedule" — rename, pick the school (sets the bell schedule), and
/// edit the flat list of classes, one slot per period. Pass `profileName:
/// null` to create a new schedule instead of editing an existing one.
class EditScheduleScreen extends StatefulWidget {
  final String? profileName;

  const EditScheduleScreen({super.key, required this.profileName});

  bool get isNew => profileName == null;

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late final TextEditingController _nameCtrl;
  String _school = getSchools().first;
  List<ClassPeriod> _classes = [];
  List<String> _periods = [];
  bool _loading = true;

  /// The name under which this schedule currently lives on disk, or null if it
  /// hasn't been created yet. Kept separate from [widget.profileName] because
  /// auto-saving a rename changes the storage key while the screen stays open.
  String? _currentName;

  @override
  void initState() {
    super.initState();
    _currentName = widget.profileName;
    _nameCtrl = TextEditingController(text: widget.profileName ?? '');
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!widget.isNew) {
      final data = await getSchoolSchedule(widget.profileName!);
      if (!mounted) return;
      _school = data.$1;
      _classes = List.of(data.$2);
    }
    final periods = await getClassPeriods(_school);
    if (!mounted) return;
    setState(() {
      _periods = periods;
      _loading = false;
    });
  }

  ClassPeriod? _classForPeriod(String period) {
    for (final c in _classes) {
      if (c.period == period) return c;
    }
    return null;
  }

  Future<void> _onSchoolChanged(String? newSchool) async {
    if (newSchool == null || newSchool == _school) return;
    final periods = await getClassPeriods(newSchool);
    final validPeriods = periods.toSet();
    if (!mounted) return;
    setState(() {
      _school = newSchool;
      _periods = periods;
      _classes =
          _classes.where((c) => validPeriods.contains(c.period)).toList();
    });
    await _persistSchedule();
  }

  /// Writes the current school + classes back to the on-disk profile and
  /// refreshes the home screen if it's showing this schedule. No-op for a
  /// schedule that hasn't been created yet (name not committed).
  Future<void> _persistSchedule() async {
    final name = _currentName;
    if (name == null || !mounted) return;
    final model = context.read<ScheduleModel>();
    await updateSchedule(name, _school, _classes);
    if (model.scheduleProfileName == name) {
      await model.reload();
    }
  }

  /// Commits a pending name change (or first-time creation) to disk. Returns
  /// false if the name is empty or collides with another schedule, in which
  /// case nothing is written. Idempotent when the name is unchanged.
  Future<bool> _commitName() async {
    if (!mounted) return false;
    final name = _nameCtrl.text.trim();
    if (name == _currentName) return true;
    if (name.isEmpty) return false;
    final model = context.read<ScheduleModel>();
    final messenger = ScaffoldMessenger.of(context);
    if (await _nameCollides(name)) {
      messenger.showSnackBar(
        SnackBar(content: Text('A schedule named "$name" already exists.')),
      );
      return false;
    }
    final previous = _currentName;
    if (previous == null) {
      await addSchedule(name, _school, _classes);
    } else {
      await renameSchedule(previous, name);
    }
    _currentName = name;
    if (previous != null && model.scheduleProfileName == previous) {
      await model.switchProfile(name);
    }
    return true;
  }

  Future<void> _editPeriod(String period) async {
    final existing = _classForPeriod(period);
    final result = await Navigator.of(context).push<EditClassResult>(
      MaterialPageRoute(
        builder: (_) => EditClassScreen(
          period: period,
          existing: existing,
          scheduleName: _nameCtrl.text.trim().isEmpty
              ? 'New schedule'
              : _nameCtrl.text.trim(),
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _classes.removeWhere((c) => c.period == period);
      final saved = result.classPeriod;
      if (saved != null) _classes.add(saved);
    });

    // Persist the edit right away so it isn't lost if the user leaves without
    // pressing "Save schedule". Commit any pending name first so a brand-new
    // schedule exists on disk before we try to write the class into it.
    await _commitName();
    await _persistSchedule();
  }

  Future<bool> _nameCollides(String name) async {
    final names = (await getProfileNames()).cast<String>();
    return names.any((n) => n == name && n != _currentName);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the schedule a name.')),
      );
      return;
    }
    // Everything is auto-saved as it's edited; this just flushes any pending
    // name change, makes the schedule active, and leaves the screen.
    if (!await _commitName()) return;
    if (!mounted) return;
    final name = _currentName!;
    await updateSchedule(name, _school, _classes);
    if (!mounted) return;
    await context.read<ScheduleModel>().switchProfile(name);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Commits a pending name change, then leaves the screen. Wired to the back
  /// and close buttons so a typed-but-unsubmitted name isn't lost on exit.
  Future<void> _closeScreen() async {
    await _commitName();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _delete() async {
    final c = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Delete this schedule?', style: TextStyle(color: c.text)),
        content: Text(
          'This removes "$_currentName" and its classes. This can\'t be undone.',
          style: TextStyle(color: c.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final oldName = _currentName!;
    await deleteSchedule(oldName);
    if (!mounted) return;

    final model = context.read<ScheduleModel>();
    if (model.scheduleProfileName == oldName) {
      final remaining = (await getProfileNames()).cast<String>();
      if (remaining.isNotEmpty) {
        await model.switchProfile(remaining.first);
      } else {
        model.clear();
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final periods = _periods;

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
                      RoundIconButton(
                        icon: Icons.chevron_left,
                        onTap: _closeScreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit schedule',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.3,
                            color: c.text,
                          ),
                        ),
                      ),
                      RoundIconButton(
                        icon: Icons.close,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ManageField(
                    label: 'Schedule name',
                    child: styledTextField(
                      c,
                      _nameCtrl,
                      'e.g. Maya Chen',
                      onSubmitted: (_) => _commitName(),
                    ),
                  ),
                  ManageField(
                    label: 'School',
                    child: StyledDropdown(
                      value: _school,
                      options: getSchools(),
                      onChanged: _onSchoolChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 10, top: 2),
                    child: Text(
                      '${periods.length} periods',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: c.text3,
                      ),
                    ),
                  ),
                  for (final period in periods)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PeriodRow(
                        period: period,
                        classPeriod: _classForPeriod(period),
                        onTap: () => _editPeriod(period),
                      ),
                    ),
                  const SizedBox(height: 18),
                  PrimaryButton(label: 'Save schedule', onTap: _save),
                  if (!widget.isNew)
                    DangerButton(
                      label: 'Delete this schedule',
                      onTap: _delete,
                    ),
                ],
              ),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final String period;
  final ClassPeriod? classPeriod;
  final VoidCallback onTap;
  const _PeriodRow({
    required this.period,
    required this.classPeriod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cls = classPeriod;

    if (cls == null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                _PeriodNum(
                    period: period,
                    color: c.text3,
                    background: c.text3.withValues(alpha: 0.12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No class set',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.text3,
                        ),
                      ),
                      Text(
                        'Period $period · tap to add a class',
                        style: TextStyle(fontSize: 12, color: c.text3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.add, size: 18, color: c.text3),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              _PeriodNum(
                period: period,
                color: cls.color,
                background: cls.color.withValues(alpha: 0.14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    Text(
                      'Period $period · Room ${cls.room} · ${cls.teacherName}',
                      style: TextStyle(fontSize: 12, color: c.text3),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, size: 16, color: c.text2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodNum extends StatelessWidget {
  final String period;
  final Color color;
  final Color background;
  const _PeriodNum({
    required this.period,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        period,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
