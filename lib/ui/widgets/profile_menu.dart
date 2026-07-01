import 'package:flutter/material.dart';

import '../theme.dart';

enum ProfileAction { manage, settings }

/// Header pill showing the active profile with a dropdown. Profile switching
/// itself is owned by the model (single profile for now), so this surfaces the
/// current profile plus the Manage / Settings actions from the mockup.
class ProfileMenu extends StatelessWidget {
  final String profileName;
  final ValueChanged<ProfileAction> onAction;

  const ProfileMenu({
    super.key,
    required this.profileName,
    required this.onAction,
  });

  String get _initial =>
      profileName.isEmpty ? '?' : profileName.characters.first.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: c.text.withValues(alpha: 0.1),
        highlightColor: c.text.withValues(alpha: 0.05),
        // splashColor: Colors.green,
        // highlightColor: Colors.green,
      ),
      child: PopupMenuButton<ProfileAction>(
        borderRadius: BorderRadius.circular(999),
        padding: EdgeInsets.zero,
        splashRadius: 999,
        onSelected: onAction,
        tooltip: 'Profile',
        offset: const Offset(0, 48),
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Row(
              children: [
                _Avatar(initial: _initial, size: 30),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    profileName.isEmpty ? 'No profile' : profileName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: ProfileAction.manage,
            child: Row(
              children: [
                const Text('📚'),
                const SizedBox(width: 10),
                Text('Manage schedules',
                    style:
                        TextStyle(color: c.text, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          PopupMenuItem(
            value: ProfileAction.settings,
            child: Row(
              children: [
                const Text('⚙️'),
                const SizedBox(width: 10),
                Text('Settings',
                    style:
                        TextStyle(color: c.text, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        child: Ink(
          padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar(initial: _initial, size: 28),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Text(
                  profileName.isEmpty ? 'Profile' : profileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: c.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  final double size;
  const _Avatar({required this.initial, required this.size});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: c.accentGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.46,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
