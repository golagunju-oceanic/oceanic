import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class PolicyDetailsScreen extends ConsumerStatefulWidget {
  const PolicyDetailsScreen({super.key});

  @override
  ConsumerState<PolicyDetailsScreen> createState() =>
      _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  bool _beneficiariesExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(policyProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const CustomDrawer(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.error, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final policy = state.policy;
    final utilization = state.utilization;
    final dependants = state.dependants;
    final card = state.card;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController, // Attached ScrollController
              padding: const EdgeInsets.fromLTRB(16, 92, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card != null) ...[
                    _buildMemberCardWidget(scheme, card),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Policy Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (utilization != null) ...[
                    _buildUtilizationGrid(scheme, utilization),
                    const SizedBox(height: 16),
                  ],

                  if (policy != null)
                    _buildPolicySummaryCard(scheme, policy),

                  const SizedBox(height: 16),

                  _buildExpandableCard(
                    scheme: scheme,
                    title: 'Beneficiaries (${dependants.length})',
                    icon: Icons.people_outline_rounded,
                    isExpanded: _beneficiariesExpanded,
                    onTap: () => setState(
                      () => _beneficiariesExpanded = !_beneficiariesExpanded,
                    ),
                    content: _buildDependantsContent(scheme, dependants),
                  ),
                ],
              ),
            ),
            FloatingAppBar(
              scrollController: _scrollController,
              text: "Policy Details",
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- MEMBER ID CARD ---
  Widget _buildMemberCardWidget(ColorScheme scheme, MemberCardModel card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  backgroundImage: card.photo.isNotEmpty
                      ? NetworkImage(card.photo)
                      : null,
                  child: card.photo.isEmpty
                      ? const Icon(Icons.person, size: 36, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "ID: ${card.memberId}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        card.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardInfo("Plan Variant", card.planVariant.toUpperCase()),
              _buildCardInfo("Gender", card.gender ?? "--"),
              _buildCardInfo("Blood Group", card.bloodGroup ?? "--"),
              _buildCardInfo("Genotype", card.genotype ?? "--"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- STATS / UTILIZATION METRICS ---
  Widget _buildUtilizationGrid(ColorScheme scheme, UtilizationModel utilization) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            scheme: scheme,
            title: "Total Claims",
            value: utilization.totalClaims.toString(),
            icon: Icons.receipt_long_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            scheme: scheme,
            title: "Authorizations",
            value: utilization.totalAuthorizations.toString(),
            icon: Icons.verified_user_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required ColorScheme scheme,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- POLICY SUMMARY CARD ---
  Widget _buildPolicySummaryCard(ColorScheme scheme, PolicyModel policy) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
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
          const SizedBox(height: 12),
          _buildPolicyRow('Policy Holder', "${policy.firstName} ${policy.lastName}", scheme),
          _buildDivider(scheme),
          _buildPolicyRow("Member ID", policy.memberId, scheme),
          _buildDivider(scheme),
          _buildPolicyRow("Policy Number", policy.policyNumber ?? "-", scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Network Tier', 'TIER 4', scheme),
          _buildDivider(scheme),
          _buildStatusRow(scheme, policy.status),
          _buildDivider(scheme),
          _buildPolicyRow(
            "Date Joined",
            DateFormat("dd MMM yyyy").format(policy.dateJoined),
            scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildStatusRow(ColorScheme scheme, String status) {
    final isActive = status.toLowerCase() == 'active';
    final statusColor = isActive ? const Color(0xFF28A745) : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Status",
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3));
  }

  // --- BENEFICIARIES SECTION ---
  Widget _buildExpandableCard({
    required ColorScheme scheme,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: scheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
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

  Widget _buildDependantsContent(
    ColorScheme scheme,
    List<DependantModel> dependants,
  ) {
    if (dependants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text("No beneficiaries registered."),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dependants.length,
      separatorBuilder: (_, __) => _buildDivider(scheme),
      itemBuilder: (context, index) {
        final d = dependants[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: scheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person_outline, color: scheme.primary),
          ),
          title: Text(
            d.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            d.relationship,
            style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.6)),
          ),
        );
      },
    );
  }
}