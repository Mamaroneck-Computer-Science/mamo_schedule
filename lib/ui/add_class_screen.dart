import 'package:flutter/material.dart';

import 'theme.dart';

/// ============================================================================
/// ADD / EDIT CLASS — self-contained UI, parked for the future Manage screen.
/// ============================================================================
///
/// This is the full add/edit-class form (name, colour, room, teacher, period).
/// It is **UI only**: tapping "Save" currently just pops the route — it does
/// NOT write back to [ScheduleModel], because schedule editing is owned
/// elsewhere. Period start/end times come from the school's bell schedule, so
/// the form deliberately only collects the period number, not raw times.
///
/// WHERE IT'S REACHED FROM TODAY
/// -----------------------------
/// There is no standalone "+" button anymore. This screen is opened from the
/// profile dropdown's "Manage schedules & classes" item (see
/// `schedule_screen.dart` -> `_openManage`). That's a temporary entry point.
///
/// HOW TO RE-HOME IT INSIDE A REAL MANAGE SCREEN LATER
/// ---------------------------------------------------
/// When you build the "Manage schedules & classes" screen, host an "Add class"
/// button there and push this screen:
///
///   Navigator.of(context).push(
///     MaterialPageRoute(builder: (_) => const AddClassScreen()),
///   );
///
/// TO MAKE IT ACTUALLY SAVE
/// ------------------------
/// Add a write method to [ScheduleModel] (e.g. `addClass(ClassPeriod)`) and
/// call it from [_SaveButton]'s onTap with the collected field values:
/// `_nameCtrl.text`, `_roomCtrl.text`, `_teacherCtrl.text`,
/// `kClassPalette[_colorIndex]`, and `_period`. Pass an optional existing
/// `ClassPeriod` into the constructor to reuse this same form for editing.
/// ============================================================================
class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _nameCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _teacherCtrl = TextEditingController();
  int _colorIndex = 0;
  int? _period;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _teacherCtrl.dispose();
    super.dispose();
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
                _RoundBtn(
                  icon: Icons.chevron_left,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add class',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.3,
                      color: c.text,
                    ),
                  ),
                ),
                _RoundBtn(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Field(
              label: 'Class name',
              child: _input(c, _nameCtrl, 'e.g. Chemistry'),
            ),
            _Field(
              label: 'Color',
              child: _Swatches(
                selected: _colorIndex,
                onSelect: (i) => setState(() => _colorIndex = i),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    label: 'Room',
                    child: _input(c, _roomCtrl, '118'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'Teacher',
                    child: _input(c, _teacherCtrl, 'Mr. Doyle'),
                  ),
                ),
              ],
            ),
            _Field(
              label: 'Period',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PeriodPicker(
                    selected: _period,
                    onSelect: (p) => setState(() => _period = p),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🕒'),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Start & end times come from your school's bell "
                          'schedule — just pick the period.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: c.text3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _SaveButton(onTap: () => Navigator.of(context).maybePop()),
          ],
        ),
      ),
    );
  }

  Widget _input(AppColors c, TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 16, color: c.text, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.text3),
        filled: true,
        fillColor: c.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.accent, width: 2),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: c.text2,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _Swatches({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        for (int i = 0; i < kClassPalette.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kClassPalette[i],
                  borderRadius: BorderRadius.circular(12),
                  border: selected == i
                      ? Border.all(color: c.surface, width: 3)
                      : null,
                  boxShadow: selected == i
                      ? [
                          BoxShadow(
                            color: kClassPalette[i],
                            blurRadius: 0,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: selected == i
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  const _PeriodPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        for (int p = 1; p <= 8; p++)
          GestureDetector(
            onTap: () => onSelect(p),
            child: Container(
              decoration: BoxDecoration(
                gradient: selected == p ? c.accentGradient : null,
                color: selected == p ? null : c.surface,
                borderRadius: BorderRadius.circular(12),
                border: selected == p ? null : Border.all(color: c.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '$p',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: selected == p ? Colors.white : c.text2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

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
          child: Icon(icon, size: 20, color: c.text2),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: c.accentGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: c.accent.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Save class',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
