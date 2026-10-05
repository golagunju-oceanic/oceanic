import 'package:flutter/material.dart';

import 'patient_details_screen.dart';

class ConsultationDetailsScreen extends StatelessWidget {
  const ConsultationDetailsScreen({
    super.key,
    required this.consultation,
  });

  final Map<String, dynamic> consultation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final patientName = consultation['patientName'] ?? 'Unknown Patient';
    final patientId = consultation['patientId'] ?? 'N/A';
    final consultationType =
        consultation['type'] ?? 'Video Consultation';
    final date = consultation['date'] ?? '';
    final time = consultation['time'] ?? '';
    final status = consultation['status'] ?? '';
    final reason = consultation['reason'] ?? 'No reason provided';

    final isUpcoming = status == 'Upcoming';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'Consultation Details',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(
              scheme,
              patientName,
              patientId,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Consultation Information',
              scheme,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              scheme: scheme,
              children: [
                _buildInfoRow(
                  scheme: scheme,
                  icon: Icons.medical_services_outlined,
                  title: 'Consultation Type',
                  value: consultationType,
                ),

                _buildDivider(scheme),

                _buildInfoRow(
                  scheme: scheme,
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  value: date,
                ),

                _buildDivider(scheme),

                _buildInfoRow(
                  scheme: scheme,
                  icon: Icons.access_time,
                  title: 'Time',
                  value: time,
                ),

                _buildDivider(scheme),

                _buildInfoRow(
                  scheme: scheme,
                  icon: Icons.info_outline,
                  title: 'Status',
                  value: status,
                  valueColor:
                      isUpcoming ? Colors.orange : Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Reason for Consultation',
              scheme,
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: scheme.onSurface.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Patient',
              scheme,
            ),

            const SizedBox(height: 12),

            _buildPatientCard(
              context,
              scheme,
              patientName,
              patientId,
            ),

            const SizedBox(height: 30),

            if (isUpcoming)
              _buildStartButton(
                context,
                scheme,
                consultationType,
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Screen-specific helpers
  // ------------------------------------------------------------

  Widget _buildPatientHeader(
    ColorScheme scheme,
    String patientName,
    String patientId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: scheme.onPrimary.withValues(
              alpha: 0.15,
            ),
            child: Icon(
              Icons.person,
              size: 34,
              color: scheme.onPrimary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Patient ID: $patientId',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onPrimary.withValues(
                      alpha: 0.75,
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

  Widget _buildSectionTitle(
    String title,
    ColorScheme scheme,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    );
  }

  Widget _buildInfoCard({
    required ColorScheme scheme,
    required List<Widget> children,
  }) {
    return Container(
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
    );
  }

  Widget _buildInfoRow({
    required ColorScheme scheme,
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
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
                color: scheme.onSurface.withValues(
                  alpha: 0.65,
                ),
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(
      height: 1,
      color: scheme.onSurface.withValues(
        alpha: 0.08,
      ),
    );
  }

  Widget _buildPatientCard(
    BuildContext context,
    ColorScheme scheme,
    String patientName,
    String patientId,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailsScreen(
              patientName: patientName,
              patientId: patientId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primary.withValues(
                alpha: 0.1,
              ),
              child: Icon(
                Icons.person_outline,
                color: scheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Patient ID: $patientId',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: scheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    ColorScheme scheme,
    String consultationType,
  ) {
    final isVideo =
        consultationType.toLowerCase().contains('video');

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          // Agora will be connected here later.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isVideo
                    ? 'Starting video consultation...'
                    : 'Starting audio consultation...',
              ),
            ),
          );
        },
        icon: Icon(
          isVideo
              ? Icons.videocam_outlined
              : Icons.call_outlined,
        ),
        label: Text(
          isVideo
              ? 'Start Video Consultation'
              : 'Start Audio Consultation',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}