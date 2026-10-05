import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  final String patientName;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'Patient Details',
          style: TextStyle(fontWeight: FontWeight.w700),
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
            _buildPatientHeader(scheme),

            const SizedBox(height: 28),

            _buildSectionTitle('Personal Information', scheme),

            const SizedBox(height: 12),

            _buildInfoCard(scheme, [
              _buildInfoRow(
                scheme,
                Icons.badge_outlined,
                'Patient ID',
                patientId,
              ),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.person_outline,
                'Full Name',
                patientName,
              ),
              _buildDivider(scheme),
              _buildInfoRow(scheme, Icons.cake_outlined, 'Age', '34 years'),
              _buildDivider(scheme),
              _buildInfoRow(scheme, Icons.wc_outlined, 'Gender', 'Male'),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.bloodtype_outlined,
                'Blood Group',
                'O+',
              ),
            ]),

            const SizedBox(height: 28),

            _buildSectionTitle('Contact Information', scheme),

            const SizedBox(height: 12),

            _buildInfoCard(scheme, [
              _buildInfoRow(
                scheme,
                Icons.phone_outlined,
                'Phone',
                '+234 801 234 5678',
              ),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.email_outlined,
                'Email',
                'patient@email.com',
              ),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.location_on_outlined,
                'Address',
                'Lagos, Nigeria',
              ),
            ]),

            const SizedBox(height: 28),

            _buildSectionTitle('Medical Information', scheme),

            const SizedBox(height: 12),

            _buildInfoCard(scheme, [
              _buildInfoRow(
                scheme,
                Icons.warning_amber_outlined,
                'Allergies',
                'Penicillin',
                valueColor: Colors.orange,
              ),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.medication_outlined,
                'Current Medication',
                'None',
              ),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.history_outlined,
                'Medical History',
                'Hypertension',
              ),
              _buildDivider(scheme),
              _buildInfoRow(
                scheme,
                Icons.emergency_outlined,
                'Emergency Contact',
                'Jane Doe',
              ),
            ]),

            const SizedBox(height: 28),

            _buildSectionTitle('Recent Consultation', scheme),

            const SizedBox(height: 12),

            _buildRecentConsultationCard(scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: scheme.onPrimary.withValues(alpha: 0.15),
            child: Icon(Icons.person, size: 46, color: scheme.onPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            patientName,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Patient ID: $patientId',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onPrimary.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme scheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme scheme, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    ColorScheme scheme,
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: scheme.primary),
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
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.08));
  }

  Widget _buildRecentConsultationCard(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.video_call_outlined, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General Consultation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'July 28, 2026 • 10:30 AM',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Completed',
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
