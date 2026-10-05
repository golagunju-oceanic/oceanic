import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          children: [
            _buildProfileHeader(scheme),

            const SizedBox(height: 28),

            _buildSection(
              title: 'Professional Information',
              scheme: scheme,
              children: [
                _buildInfoTile(
                  scheme: scheme,
                  icon: Icons.badge_outlined,
                  title: 'Doctor ID',
                  value: 'DOC-00124',
                ),
                _buildDivider(scheme),
                _buildInfoTile(
                  scheme: scheme,
                  icon: Icons.medical_services_outlined,
                  title: 'Specialization',
                  value: 'General Practitioner',
                ),
                _buildDivider(scheme),
                _buildInfoTile(
                  scheme: scheme,
                  icon: Icons.local_hospital_outlined,
                  title: 'Hospital',
                  value: 'St. Mary\'s Hospital',
                ),
                _buildDivider(scheme),
                _buildInfoTile(
                  scheme: scheme,
                  icon: Icons.verified_outlined,
                  title: 'License Number',
                  value: 'MDCN-123456',
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Contact Information',
              scheme: scheme,
              children: [
                _buildInfoTile(
                  scheme: scheme,
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: '+234 801 234 5678',
                ),
                _buildDivider(scheme),
                _buildInfoTile(
                  scheme: scheme,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: 'doctor@example.com',
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Account',
              scheme: scheme,
              children: [
                _buildActionTile(
                  scheme: scheme,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    _showComingSoon(context, 'Change Password');
                  },
                ),
                _buildDivider(scheme),
                _buildActionTile(
                  scheme: scheme,
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {
                    _showComingSoon(context, 'Notifications');
                  },
                ),
                _buildDivider(scheme),
                _buildActionTile(
                  scheme: scheme,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    _showComingSoon(context, 'Settings');
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, scheme);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme scheme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: scheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            size: 52,
            color: scheme.primary,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Dr. John Smith',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'General Practitioner',
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: Colors.green,
              ),
              SizedBox(width: 6),
              Text(
                'Available',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required ColorScheme scheme,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required ColorScheme scheme,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: scheme.primary,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required ColorScheme scheme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: scheme.primary,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(
      height: 1,
      color: scheme.onSurface.withValues(alpha: 0.08),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    ColorScheme scheme,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // Logout logic will be added later.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout coming soon'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}