import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/features/auth/presentations/screen/auth_screen.dart';
import 'package:oceanic/presentation/features/home/view/Profile.dart';
import 'package:oceanic/presentation/features/home/view/settings.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: scheme.surface,
      child: Column(
        children: [
          // --- DRAWER HEADER ---
          _buildDrawerHeader(context, scheme),

          // --- MENU LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionTitle('MAIN MENU', scheme),

                // Profile Option (Clickable)
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile & Member Card',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context); // Close Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.shield_outlined,
                  title: 'My Policy & Benefits',
                  subtitle: 'View plan details & limits',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Claims & Authorizations',
                  subtitle: 'Track approvals & refunds',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.local_hospital_outlined,
                  title: 'Find Healthcare Provider',
                  subtitle: 'Hospitals & clinics near you',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.video_camera_front_outlined,
                  title: 'Telemedicine Consult',
                  subtitle: 'Speak with a doctor online',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),

                _buildSectionTitle('SUPPORT & SETTINGS', scheme),

                _buildDrawerItem(
                  icon: Icons.phone_in_talk_outlined,
                  title: 'Emergency Hotlines',
                  subtitle: '24/7 Oceanic helpdesk',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                    _showEmergencyBottomSheet(context, scheme);
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQs & Support',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // Settings Option (Clickable)
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // --- FOOTER & LOGOUT ---
          const Divider(height: 1),
          _buildLogoutTile(context, scheme),

          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 4),
            child: Text(
              'Oceanic Health HMO v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DRAWER HEADER WIDGET ---
  Widget _buildDrawerHeader(BuildContext context, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E62), kNavyBlue, Color(0xFF2C2F7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Oceanic Health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'HMO Member Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

  // --- SECTION TITLE ---
  Widget _buildSectionTitle(String title, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: scheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  // --- REUSABLE DRAWER ITEM ---
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(
        icon,
        size: 22,
        color: scheme.onSurface.withValues(alpha: 0.75),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: scheme.onSurface.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }

  // --- LOGOUT TILE ---
  Widget _buildLogoutTile(BuildContext context, ColorScheme scheme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.logout_rounded, size: 18, color: scheme.error),
      ),
      title: Text(
        'Logout',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: scheme.error,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close Drawer
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      },
    );
  }

  // --- EMERGENCY SUPPORT BOTTOM SHEET ---
  void _showEmergencyBottomSheet(BuildContext context, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_in_talk, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Oceanic Emergency Hotlines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _emergencyNumberTile(
              '24/7 Call Center Desk',
              '02013300300',
              scheme,
            ),
            _emergencyNumberTile('Emergency Approvals', '02013300301', scheme),
            _emergencyNumberTile(
              'Email Support',
              'hmo@oceanichealthng.com',
              scheme,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _emergencyNumberTile(
    String title,
    String contact,
    ColorScheme scheme,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        contact,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: scheme.primary,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.call, color: scheme.primary, size: 20),
        onPressed: () {},
      ),
    );
  }
}
