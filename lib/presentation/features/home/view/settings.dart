import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oceanic/features/auth/presentations/screen/auth_screen.dart';
import 'package:oceanic/presentation/features/home/view/Profile.dart';
import 'package:oceanic/presentation/features/home/view/delete_profile.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings Toggles State
  bool _pushNotifications = true;
  bool _smsClaimAlerts = true;
  bool _biometricsEnabled = false;

  String _selectedPrimaryHospital = "St. Mary's Specialist Hospital";

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _primaryHospitals = [
    "St. Mary's Specialist Hospital",
    "City General Hospital",
    "HealthLab Diagnostic Center",
    "Lekki Medical Center",
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final primaryBg = scheme.primary.withValues(alpha: 0.1);
    final dangerBg = scheme.error.withValues(alpha: 0.1);

    return Scaffold(
      key: _scaffoldKey, // Connected Scaffold Key
      drawer: const CustomDrawer(), // Added Drawer Widget
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Settings List
            ListView(
              controller: _scrollController, // Connected ScrollController
              padding: const EdgeInsets.fromLTRB(
                20,
                88,
                20,
                32,
              ), // Top padding prevents header overlap
              children: [
                // --- ACCOUNT & PROFILE ---
                const _SectionLabel('Account & Identity'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.person_crop_circle_fill,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'Personal Profile',
                      subtitle: 'View member ID & info',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const _Divider(),
                    _SettingsTile(
                      icon: CupertinoIcons.lock_fill,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'Change Password',
                      subtitle: 'Update your login password',
                      onTap: () => _showChangePasswordSheet(context, scheme),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- HMO & COVERAGE PREFERENCES ---
                const _SectionLabel('HMO & Provider Preferences'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.building_2_fill,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'Primary Hospital Facility',
                      subtitle: _selectedPrimaryHospital,
                      onTap: () =>
                          _showPrimaryHospitalSelector(context, scheme),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- NOTIFICATIONS & SECURITY ---
                const _SectionLabel('Security & Notifications'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _ToggleTile(
                      icon: CupertinoIcons.bell_fill,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'Push Notifications',
                      subtitle: 'App updates & reminders',
                      value: _pushNotifications,
                      activeColor: scheme.primary,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                    ),
                    const _Divider(),
                    _ToggleTile(
                      icon: CupertinoIcons.chat_bubble_text_fill,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'SMS Claim Alerts',
                      subtitle: 'Instant SMS on authorization updates',
                      value: _smsClaimAlerts,
                      activeColor: scheme.primary,
                      onChanged: (v) => setState(() => _smsClaimAlerts = v),
                    ),
                    const _Divider(),
                    _ToggleTile(
                      icon: CupertinoIcons.viewfinder,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'Biometric Log-in',
                      subtitle: 'Use Face ID / Fingerprint',
                      value: _biometricsEnabled,
                      activeColor: scheme.primary,
                      onChanged: (v) => setState(() => _biometricsEnabled = v),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- LEGAL & SUPPORT ---
                const _SectionLabel('Support & Information'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.doc_text_fill,
                      iconBg: primaryBg,
                      iconColor: scheme.primary,
                      label: 'Terms of Service & Privacy Policy',
                      onTap: () => _showPrivacyPolicySheet(context, scheme),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --- ACCOUNT ACTIONS (DANGER ZONE) ---
                const _SectionLabel('Account Actions'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.person_badge_minus_fill,
                      iconBg: dangerBg,
                      iconColor: scheme.error,
                      label: 'Delete Profile',
                      labelColor: scheme.error,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeleteProfilePage(),
                        ),
                      ),
                    ),
                    const _Divider(),
                    _SettingsTile(
                      icon: CupertinoIcons.square_arrow_right_fill,
                      iconBg: dangerBg,
                      iconColor: scheme.error,
                      label: 'Logout',
                      labelColor: scheme.error,
                      onTap: () => _confirmLogout(context, scheme),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // App Version Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Oceanic Health HMO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Version 1.0.0 (Build 104)',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Connected FloatingAppBar
            FloatingAppBar(
              scrollController: _scrollController,
              text: 'Settings',
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- CHANGE PASSWORD SHEET ---
  void _showChangePasswordSheet(BuildContext context, ColorScheme scheme) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(CupertinoIcons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(CupertinoIcons.lock_shield),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password updated successfully!'),
                      backgroundColor: scheme.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PRIMARY HOSPITAL SELECTOR ---
  void _showPrimaryHospitalSelector(BuildContext context, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Primary Provider Facility',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            ..._primaryHospitals.map(
              (hospital) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(hospital),
                trailing: _selectedPrimaryHospital == hospital
                    ? Icon(Icons.check_circle_rounded, color: scheme.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedPrimaryHospital = hospital);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PRIVACY POLICY SHEET ---
  void _showPrivacyPolicySheet(BuildContext context, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Privacy Policy & Terms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '1. Information Collection\n'
                  'Oceanic Health Management Limited collects medical record information, claims history, and personal demographics necessary for HMO healthcare administration.\n\n'
                  '2. Usage & Medical Confidentiality\n'
                  'Your health data is protected under medical privacy protocols and is strictly used for treatment authorization, provider claims reimbursement, and healthcare coordination.\n\n'
                  '3. Data Protection\n'
                  'We utilize industry-grade encryption standards for all app transactions, medical records, and digital identity details.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGOUT DIALOG ---
  void _confirmLogout(BuildContext context, ColorScheme scheme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: Text(
          'Are you sure you want to log out of your HMO account?',
          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext); // Close Dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false, // Remove all previous screens
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// --- UI CARD & TILE HELPERS ---

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: scheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _IconBox(icon: icon, bg: iconBg, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: scheme.onSurface.withValues(alpha: 0.3),
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
  final String? subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBox(icon: icon, bg: iconBg, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _IconBox({required this.icon, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      indent: 64,
      endIndent: 16,
      color: scheme.outlineVariant.withValues(alpha: 0.3),
    );
  }
}
