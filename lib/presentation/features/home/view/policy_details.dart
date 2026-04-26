import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/data/models/user_model.dart';
import 'package:oceanic/data/repositories/providers/user_provider.dart';
import 'package:oceanic/presentation/widgets/bottom_nav_bar.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class PolicyDetailsScreen extends ConsumerStatefulWidget {
  const PolicyDetailsScreen({super.key});

  @override
  ConsumerState<PolicyDetailsScreen> createState() =>
      _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  bool _beneficiariesExpanded = false;
  bool _benefitsExpanded = false;
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final userAsync = ref.watch(authAsyncProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: const Text(
                      'Policy Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPolicySummaryCard(),
                  const SizedBox(height: 12),
                  _buildExpandableCard(
                    title: 'View Beneficiaries',
                    isExpanded: _beneficiariesExpanded,
                    onTap: () => setState(
                      () => _beneficiariesExpanded = !_beneficiariesExpanded,
                    ),
                    content: _buildBeneficiariesContent(),
                  ),
                  const SizedBox(height: 12),
                  _buildExpandableCard(
                    title: 'View list of Benefits',
                    isExpanded: _benefitsExpanded,
                    onTap: () =>
                        setState(() => _benefitsExpanded = !_benefitsExpanded),
                    content: _buildBenefitsContent(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: FloatingAppBar(
                scrollController: _scrollController,
                username: 'User',
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  Widget _buildPolicySummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Policy Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 16),
          _buildPolicyRow('Policy Holder', 'User'),
          _buildDivider(),
          _buildPolicyRow('Policy Type', 'Group'),
          _buildDivider(),
          _buildPolicyRow('Plan', 'AQUA SINGLE'),
          _buildDivider(),
          _buildPolicyRow('Network', 'TIER 4'),
          _buildDivider(),
          _buildStatusRow(),
          _buildDivider(),
          _buildPolicyRow('Effective Date', '01-01-2026'),
          _buildDivider(),
          _buildPolicyRow('Expiry Date', '31-12-2026'),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Status',
            style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4EDDA),
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

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF2F2F7));
  }

  Widget _buildExpandableCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF8E8E93),
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

  Widget _buildBeneficiariesContent() {
    final beneficiaries = [
      {'name': 'Ganiyu Ayodele Olagunju', 'relation': 'Primary'},
    ];

    return Column(
      children: beneficiaries
          .map(
            (b) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8E8F0),
                child: Icon(Icons.person, color: Color(0xFF2D2D7F), size: 20),
              ),
              title: Text(
                b['name']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                b['relation']!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBenefitsContent() {
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
