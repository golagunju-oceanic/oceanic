import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/doctor/dashboard/presentation/screen/appointment_card.dart';
import 'package:oceanic/features/doctor/dashboard/presentation/screen/consultation_card.dart';
import 'package:oceanic/features/doctor/dashboard/presentation/screen/doctor_bottom_nav.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  int _currentIndex = 0;
  bool _isAvailable = true;
  late String _searchQuery;

  // final String doctorName = 'Dr. John Doe';
  // final String doctorSpecialty = 'Cardiologist • MBBS, FWACP';

  final List<Map<String, dynamic>> upcomingAppointments = [
    {
      'id': 'APT-101',
      'name': 'Ganiyu Olagunju',
      'time': '10:00 AM',
      'type': 'Video Consultation',
      'status': 'Confirmed',
      'gender': 'Male',
      'age': '34 yrs',
    },
    {
      'id': 'APT-102',
      'name': 'Sarah Johnson',
      'time': '11:30 AM',
      'type': 'Audio Consultation',
      'status': 'Confirmed',
      'gender': 'Female',
      'age': '28 yrs',
    },
    {
      'id': 'APT-103',
      'name': 'Michael Brown',
      'time': '02:00 PM',
      'type': 'Video Consultation',
      'status': 'Pending',
      'gender': 'Male',
      'age': '45 yrs',
    },
  ];

  final List<Map<String, dynamic>> patientDirectory = [
    {
      'name': 'Ganiyu Olagunju',
      'id': 'PT-8821',
      'lastVisit': '12 Apr 2026',
      'condition': 'Hypertension Checkup',
    },
    {
      'name': 'Sarah Johnson',
      'id': 'PT-8822',
      'lastVisit': '10 Apr 2026',
      'condition': 'Post-Op Follow-up',
    },
    {
      'name': 'Michael Brown',
      'id': 'PT-8823',
      'lastVisit': '05 Apr 2026',
      'condition': 'Routine ECG Review',
    },
    {
      'name': 'Amanda Smith',
      'id': 'PT-8824',
      'lastVisit': '28 Mar 2026',
      'condition': 'Chest Pain Evaluation',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final doctorName = user?.fullName ?? 'Doctor';
    final doctorSpecialty = user?.specialty ?? '';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(scheme),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardTab(scheme, doctorName),
            _buildAppointmentsTab(scheme),
            _buildPatientsTab(scheme),
            _buildProfileTab(scheme, doctorName, doctorSpecialty),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildAppBar(ColorScheme scheme) {
    return AppBar(
      elevation: 0,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_rounded,
              color: scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor Portal',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Oceanic Tele-Health',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                color: scheme.onSurface,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- TAB 0: MAIN DASHBOARD ---
  Widget _buildDashboardTab(ColorScheme scheme, String doctorName) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingCard(scheme, doctorName),
            const SizedBox(height: 18),
            _buildAvailabilityCard(scheme),
            const SizedBox(height: 24),
            _buildSectionHeader(
              scheme,
              title: "Today's Overview",
              actionText: 'View All',
              onAction: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(height: 12),
            _buildOverviewCards(scheme),
            const SizedBox(height: 24),
            _buildSectionHeader(scheme, title: 'Next Consultation'),
            const SizedBox(height: 12),
            ConsultationCard(
              patientName: 'Ganiyu Olagunju',
              time: '10:00 AM (In 15 mins)',
              type: 'Video Consultation',
              onStart: () {
                // Launch Consultation Screen
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              scheme,
              title: 'Upcoming Schedule',
              actionText: 'See All',
              onAction: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(height: 12),
            _buildUpcomingList(),
            const SizedBox(height: 24),
            _buildSectionHeader(scheme, title: 'Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(scheme),
            const SizedBox(height: 24),
            _buildSectionHeader(scheme, title: 'Recent Activity'),
            const SizedBox(height: 12),
            _buildRecentActivityList(scheme),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: APPOINTMENTS ---
  Widget _buildAppointmentsTab(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search patient by name or ID...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: upcomingAppointments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final apt = upcomingAppointments[index];
                return AppointmentCard(
                  patientName: apt['name'],
                  time: apt['time'],
                  type: apt['type'],
                  status: apt['status'],
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: PATIENTS DIRECTORY ---
  Widget _buildPatientsTab(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Directory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: patientDirectory.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final patient = patientDirectory[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerLow ?? scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${patient['id']} • ${patient['condition']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chat_outlined, color: scheme.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: DOCTOR PROFILE ---
  Widget _buildProfileTab(
    ColorScheme scheme,
    String doctorName,
    String doctorSpecialty,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.person, size: 48, color: scheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorSpecialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MD License: MD-993821-NG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text(
                'Logout Portal',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB WIDGETS FOR DASHBOARD TAB ---

  Widget _buildGreetingCard(ColorScheme scheme, String doctorName) {
    String _getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Good afternoon';
      return 'Good evening';
    }

    final formattedDate = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
    final greeting = _getGreeting();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$greeting, Dr $doctorName ',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You have 3 consultations scheduled for today.',
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAvailable
            ? const Color(0xFF28A745).withValues(alpha: 0.08)
            : scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isAvailable
              ? const Color(0xFF28A745).withValues(alpha: 0.25)
              : scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isAvailable
                  ? const Color(0xFF28A745).withValues(alpha: 0.15)
                  : scheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isAvailable ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              color: _isAvailable
                  ? const Color(0xFF28A745)
                  : scheme.onSurface.withValues(alpha: 0.4),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isAvailable ? 'Online & Available' : 'Offline',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isAvailable
                            ? const Color(0xFF28A745)
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isAvailable
                      ? 'Receiving telemedicine calls'
                      : 'Not receiving consultation calls',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAvailable,
            activeThumbColor: const Color(0xFF28A745),
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    ColorScheme scheme, {
    required String title,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewCards(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            scheme,
            icon: Icons.calendar_today_rounded,
            value: '8',
            label: 'Today Total',
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            scheme,
            icon: Icons.people_rounded,
            value: '24',
            label: 'Patients',
            color: const Color(0xFF0EA5E9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            scheme,
            icon: Icons.pending_actions_rounded,
            value: '3',
            label: 'Pending',
            color: const Color(0xFFD97706),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    ColorScheme scheme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingAppointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final apt = upcomingAppointments[index];
        return AppointmentCard(
          patientName: apt['name'],
          time: apt['time'],
          type: apt['type'],
          status: apt['status'],
          onTap: () {},
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            scheme,
            icon: Icons.calendar_month_rounded,
            title: 'Schedule',
            onTap: () => setState(() => _currentIndex = 1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            scheme,
            icon: Icons.folder_shared_rounded,
            title: 'Records',
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            scheme,
            icon: Icons.history_rounded,
            title: 'History',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    ColorScheme scheme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildActivityRow(
            scheme,
            icon: Icons.check_circle_rounded,
            title: 'Video Consultation Completed',
            subtitle: 'Ganiyu Olagunju • 09:30 AM',
            color: const Color(0xFF28A745),
          ),
          Divider(
            height: 1,
            indent: 56,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
          _buildActivityRow(
            scheme,
            icon: Icons.chat_rounded,
            title: 'New Patient Note Uploaded',
            subtitle: 'Sarah Johnson • 08:45 AM',
            color: scheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    ColorScheme scheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
