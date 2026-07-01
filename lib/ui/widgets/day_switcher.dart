import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

/// The floating bottom pill that moves between days. The center button jumps
/// back to today; the arrows step one day at a time.
class DaySwitcher extends StatelessWidget {
  final DateTime day;
  final String dayType;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const DaySwitcher({
    super.key,
    required this.day,
    required this.dayType,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final weekday = DateFormat('EEEE').format(day);
    final dateStr = DateFormat('MMM d').format(day);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      height: 70,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
        boxShadow: const [
          BoxShadow(color: Color(0x1F14161F), blurRadius: 48, offset: Offset(0, 18)),
        ],
      ),
      child: Row(
        children: [
          _Arrow(icon: Icons.chevron_left, onTap: onPrev),
          Expanded(
            child: InkWell(
              onTap: onToday,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.1,
                          color: c.text,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 7),
                        _TodayBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    dayType.isEmpty ? dateStr : '$dateStr · Day $dayType',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: c.text2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Arrow(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Arrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: 52,
      height: 48,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 30, color: c.accent),
        splashRadius: 24,
      ),
    );
  }
}

class _TodayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'TODAY',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: c.accent,
        ),
      ),
    );
  }
}
