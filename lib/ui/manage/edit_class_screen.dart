import 'package:flutter/material.dart';

import '../../classes/class_period.dart';
import '../theme.dart';
import 'form_widgets.dart';

/// Result of the [EditClassScreen] — either a saved [ClassPeriod] for this
/// period, or a signal that the class was removed from the period.
class EditClassResult {
  final ClassPeriod? classPeriod;
  final bool deleted;

  const EditClassResult.saved(this.classPeriod) : deleted = false;
  const EditClassResult.deleted()
      : classPeriod = null,
        deleted = true;
}

/// "Edit class" — name, color, room, teacher for a single, fixed period.
/// Period start/end times come from the school's bell schedule, so this form
/// only collects the period-independent details.
class EditClassScreen extends StatefulWidget {
  final String period;
  final ClassPeriod? existing;
  final String scheduleName;

  const EditClassScreen({
    super.key,
    required this.period,
    required this.existing,
    required this.scheduleName,
  });

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roomCtrl;
  late final TextEditingController _teacherCtrl;
  late int _colorIndex;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _roomCtrl = TextEditingController(text: existing?.room ?? '');
    _teacherCtrl = TextEditingController(text: existing?.teacherName ?? '');
    _colorIndex = existing != null ? _paletteIndexFor(existing.color) : 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _teacherCtrl.dispose();
    super.dispose();
  }

  int _paletteIndexFor(Color color) {
    final idx = kClassPalette.indexWhere((c) => c == color);
    return idx == -1 ? 0 : idx;
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the class a name.')),
      );
      return;
    }
    final result = ClassPeriod(
      widget.period,
      name,
      _roomCtrl.text.trim(),
      _teacherCtrl.text.trim(),
      kClassPalette[_colorIndex],
    );
    Navigator.of(context).pop(EditClassResult.saved(result));
  }

  void _removeClass() {
    Navigator.of(context).pop(const EditClassResult.deleted());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Row(
              children: [
                RoundIconButton(
                  icon: Icons.chevron_left,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit class',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.3,
                          color: c.text,
                        ),
                      ),
                      Text(
                        widget.scheduleName,
                        style: TextStyle(fontSize: 12.5, color: c.text3),
                      ),
                    ],
                  ),
                ),
                RoundIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PeriodFlag(period: widget.period, color: kClassPalette[_colorIndex]),
            ManageField(
              label: 'Class name',
              child: styledTextField(c, _nameCtrl, 'e.g. Chemistry'),
            ),
            ManageField(
              label: 'Color',
              child: ColorSwatches(
                selected: _colorIndex,
                onSelect: (i) => setState(() => _colorIndex = i),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ManageField(
                    label: 'Room',
                    child: styledTextField(c, _roomCtrl, '118'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ManageField(
                    label: 'Teacher',
                    child: styledTextField(c, _teacherCtrl, 'Mr. Doyle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            PrimaryButton(label: 'Save class', onTap: _save),
            if (widget.existing != null)
              DangerButton(
                label: 'Remove class from this period',
                onTap: _removeClass,
              ),
          ],
        ),
      ),
    );
  }
}

class _PeriodFlag extends StatelessWidget {
  final String period;
  final Color color;
  const _PeriodFlag({required this.period, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              period,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Period $period',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
