import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:oceanic/presentation/features/home/view/delete_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = false;

  static const _navy = Color(0xFF2D2D8E);
  static const _navyLight = Color(0xFFEEEEF8);
  static const _danger = Color(0xFFD32F2F);
  static const _dangerLight = Color(0xFFFDECEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _SectionLabel('Account'),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.person_fill,
                      iconBg: _navyLight,
                      iconColor: _navy,
                      label: 'Profile',
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: CupertinoIcons.lock_fill,
                      iconBg: _navyLight,
                      iconColor: _navy,
                      label: 'Change Password',
                      onTap: () {},
                    ),
                    _Divider(),
                    _ToggleTile(
                      icon: CupertinoIcons.bell_fill,
                      iconBg: _navyLight,
                      iconColor: _navy,
                      label: 'Push Notifications',
                      value: _pushNotifications,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _SectionLabel('Account Actions'),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.person_badge_minus_fill,
                      iconBg: _dangerLight,
                      iconColor: _danger,
                      label: 'Delete Profile',
                      labelColor: _danger,
                      onTap: () => _confirmDelete(context),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: CupertinoIcons.square_arrow_right_fill,
                      iconBg: _navyLight,
                      iconColor: _navy,
                      label: 'Logout',
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    // showDialog(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //     title: const Text('Delete Profile'),
    //     content: const Text(
    //       'This action is permanent and cannot be undone. Are you sure?',
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text('Cancel'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text(
    //           'Delete',
    //           style: TextStyle(color: Color(0xFFD32F2F)),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => DeleteProfilePage()));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFF2D2D8E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  static const _navy = Color(0xFF2D2D8E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              _CircleButton(
                icon: CupertinoIcons.chevron_left,
                onTap: () => Navigator.maybePop(context),
              ),
              const Expanded(
                child: Text(
                  'Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              _CircleButton(
                icon: CupertinoIcons.line_horizontal_3,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D2D8E),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Card container ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Tile variants ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon, bg: iconBg, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBox(icon: icon, bg: iconBg, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF2D2D8E),
          ),
        ],
      ),
    );
  }
}

// ── Shared pieces ─────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _IconBox({required this.icon, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: Colors.grey[100],
    );
  }
}
