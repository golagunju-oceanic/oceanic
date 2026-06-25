import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class PolicyDetailsScreen extends ConsumerStatefulWidget {
  const PolicyDetailsScreen({super.key});

  @override
  ConsumerState<PolicyDetailsScreen> createState() =>
      _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  bool _beneficiariesExpanded = false;
  bool _benefitsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Policy Details')),
      endDrawer: CustomDrawer(),
      backgroundColor: scheme.surface,
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Policy Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPolicySummaryCard(scheme),
              const SizedBox(height: 12),
              _buildExpandableCard(
                scheme: scheme,
                title: 'View Beneficiaries',
                isExpanded: _beneficiariesExpanded,
                onTap: () => setState(
                  () => _beneficiariesExpanded = !_beneficiariesExpanded,
                ),
                content: _buildBeneficiariesContent(scheme),
              ),
              const SizedBox(height: 12),
              _buildExpandableCard(
                scheme: scheme,
                title: 'View list of Benefits',
                isExpanded: _benefitsExpanded,
                onTap: () =>
                    setState(() => _benefitsExpanded = !_benefitsExpanded),
                content: _buildBenefitsContent(scheme),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySummaryCard(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Policy Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildPolicyRow('Policy Holder', 'User', scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Policy Type', 'Group', scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Plan', 'AQUA SINGLE', scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Network', 'TIER 4', scheme),
          _buildDivider(scheme),
          _buildStatusRow(scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Effective Date', '01-01-2026', scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Expiry Date', '31-12-2026', scheme),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF28A745),
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

  Widget _buildExpandableCard({
    required ColorScheme scheme,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: content,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiariesContent(ColorScheme scheme) {
    final beneficiaries = [
      {'name': 'Ganiyu Ayodele Olagunju', 'relation': 'Primary'},
    ];

    return Column(
      children: beneficiaries
          .map(
            (b) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(Icons.person, color: scheme.primary, size: 20),
              ),
              title: Text(
                b['name']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
              subtitle: Text(
                b['relation']!,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBenefitsContent(ColorScheme scheme) {
    final benefits = [
      'Outpatient Consultation',
      'Laboratory Tests',
      'Prescription Drugs',
      'Emergency Care',
      'Dental (Basic)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits
          .map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF28A745),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    b,
                    style: TextStyle(fontSize: 14, color: scheme.onSurface),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
