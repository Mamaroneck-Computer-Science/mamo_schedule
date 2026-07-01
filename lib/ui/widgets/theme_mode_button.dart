import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

/// ============================================================================
/// DARK MODE TOGGLE — parked here for the future Settings tab.
/// ============================================================================
///
/// This widget used to live in the [ScheduleScreen] header. It has been moved
/// out so the header stays clean; the dark-mode control is meant to live in the
/// Settings screen once that is built.
///
/// HOW THE FUNCTIONALITY WORKS
/// ---------------------------
/// Theme switching is owned by [ThemeController] (see `lib/ui/theme.dart`),
/// a [ChangeNotifier] provided app-wide in `main.dart`:
///
///   ChangeNotifierProvider(create: (_) => ThemeController()),
///
/// `MamoApp` watches it and feeds `controller.mode` into
/// `MaterialApp.themeMode`, so flipping the controller re-themes the whole app.
///
/// TO RE-ADD A DARK-MODE CONTROL IN THE SETTINGS TAB
/// -------------------------------------------------
/// Just drop this widget anywhere inside the widget tree (it's already wired to
/// the provider), e.g. as a trailing control on a settings ListTile:
///
///   ListTile(
///     title: const Text('Dark mode'),
///     trailing: const ThemeModeButton(),
///   )
///
/// Or, for a Switch instead of a button, read/write the controller directly:
///
///   Switch(
///     value: context.watch<ThemeController>().isDark,
///     onChanged: (_) => context.read<ThemeController>().toggle(),
///   )
///
/// For an explicit 3-way (System / Light / Dark) selector later, add a
/// `setMode(ThemeMode)` method to [ThemeController] and bind it to a
/// SegmentedButton — the controller already drives `MaterialApp.themeMode`.
/// ============================================================================
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final c = context.colors;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: controller.toggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Icon(
            controller.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            size: 20,
            color: c.text2,
          ),
        ),
      ),
    );
  }
}
