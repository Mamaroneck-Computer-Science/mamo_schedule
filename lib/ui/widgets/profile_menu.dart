import 'package:flutter/material.dart';

import '../../data/preferences.dart';
import '../theme.dart';

enum ProfileAction { manage, settings }

sealed class _MenuEntry {
  const _MenuEntry();
}

class _SwitchTo extends _MenuEntry {
  final String profileName;
  const _SwitchTo(this.profileName);
}

class _DoAction extends _MenuEntry {
  final ProfileAction action;
  const _DoAction(this.action);
}

/// Header pill showing the active profile with a dropdown. Mirrors the
/// mockup's profile-menu: a "Switch profile" list of every saved schedule
/// (each row clickable, checkmark on the active one), then the Manage /
/// Settings actions.
class ProfileMenu extends StatefulWidget {
  final String profileName;
  final ValueChanged<ProfileAction> onAction;
  final ValueChanged<String> onSelectProfile;

  const ProfileMenu({
    super.key,
    required this.profileName,
    required this.onAction,
    required this.onSelectProfile,
  });

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  List<ScheduleSummary> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final summaries = await getScheduleSummaries();
    if (!mounted) return;
    setState(() => _profiles = summaries);
  }

  String get _initial => widget.profileName.isEmpty
      ? '?'
      : widget.profileName.characters.first.toUpperCase();

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
      child: PopupMenuButton<_MenuEntry>(
        borderRadius: BorderRadius.circular(999),
        padding: EdgeInsets.zero,
        splashRadius: 999,
        onOpened: _loadProfiles,
        onSelected: (entry) => switch (entry) {
          _SwitchTo(:final profileName) => widget.onSelectProfile(profileName),
          _DoAction(:final action) => widget.onAction(action),
        },
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
            height: 28,
            child: Text(
              'SWITCH PROFILE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: c.text3,
              ),
            ),
          ),
          if (_profiles.isEmpty)
            PopupMenuItem(
              enabled: false,
              child: Text('No schedules yet',
                  style: TextStyle(color: c.text3, fontWeight: FontWeight.w600)),
            )
          else
            for (final s in _profiles)
              PopupMenuItem<_MenuEntry>(
                value: _SwitchTo(s.profileName),
                child: Row(
                  children: [
                    _Avatar(
                      initial: s.profileName.isEmpty
                          ? '?'
                          : s.profileName.characters.first.toUpperCase(),
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.profileName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          Text(
                            s.school,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (s.profileName == widget.profileName)
                      Icon(Icons.check, size: 16, color: c.accent),
                  ],
                ),
              ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: const _DoAction(ProfileAction.manage),
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
            value: const _DoAction(ProfileAction.settings),
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
                  widget.profileName.isEmpty ? 'Profile' : widget.profileName,
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
