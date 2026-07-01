import 'package:flutter/material.dart';

import '../period_view.dart';
import '../theme.dart';

/// A compact, non-active schedule row: a past class, an upcoming class, a free
/// period, or a break (lunch / tiger-time).
class PeriodRow extends StatelessWidget {
  final PeriodView view;
  final VoidCallback? onTap;

  /// Whether the row belongs to the day currently being viewed as *today*. The
  /// "already happened" (struck-through / muted) treatment is a live cue for
  /// today only — on past or future days every class renders at full strength
  /// so the list never looks greyed out. See [ScheduleScreen].
  final bool isToday;

  const PeriodRow({
    super.key,
    required this.view,
    this.isToday = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (view.isBreak || view.isFree) {
      return _BreakRow(view: view, done: view.isPast && isToday);
    }

    final rowColor = view.resolvedColor(c.accent);
    // Only fade/strike classes that have genuinely finished *today*.
    final done = view.isPast && isToday;

    return Material(
      color: done ? c.surface2 : c.surface,
      // color: c.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: c.border),
            // boxShadow: _softShadow,
          ),
          child: Row(
            children: [
              _PeriodChip(label: view.chipLabel, color: rowColor),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        view.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.1,
                          color: done ? c.text2 : c.text,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationThickness: 1.5,
                          decorationColor: c.text2,
                        ),
                      ),
                    ),
                    if (view.room != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        view.room!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: c.text3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${formatTime(view.start)}–${formatTime(view.end)}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: done ? c.text3 : c.text2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakRow extends StatelessWidget {
  final PeriodView view;

  /// Whether this break has already finished *today* — mirrors the class rows'
  /// struck-through / muted "done" cue so lunch and tiger-time fade with the
  /// rest of the past schedule.
  final bool done;

  const _BreakRow({required this.view, this.done = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        // color: c.surface,
        color: done ? c.surface2 : c.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      foregroundDecoration: _DashedBorder(color: c.border, radius: 13),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Text(
                view.chipLabel,
                style: TextStyle(fontSize: 15, color: c.text3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              view.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: done ? c.text3 : c.text2,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationThickness: 1.5,
                decorationColor: c.text3,
              ),
            ),
          ),
          Text(
            '${formatTime(view.start)}–${formatTime(view.end)}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: c.text3,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The small rounded square holding the period number, tinted with the row's
/// colour at low opacity (matching the mockup's `color-mix` chip).
class _PeriodChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PeriodChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

const List<BoxShadow> _softShadow = [
  BoxShadow(color: Color(0x0A14161F), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F14161F), blurRadius: 24, offset: Offset(0, 8)),
];

/// Paints a dashed rounded rectangle over a child (used for break rows).
class _DashedBorder extends Decoration {
  final Color color;
  final double radius;
  const _DashedBorder({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _DashedBorderPainter(color, radius);
}

class _DashedBorderPainter extends BoxPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter(this.color, this.radius);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size!;
    final rect = offset & size;
    final rrect =
        RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(
          metric.extractPath(dist, dist + dash),
          paint,
        );
        dist += dash + gap;
      }
    }
  }
}
