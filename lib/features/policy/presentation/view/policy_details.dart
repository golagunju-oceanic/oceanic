import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class PolicyDetailsScreen extends ConsumerStatefulWidget {
  const PolicyDetailsScreen({super.key});

  @override
  ConsumerState<PolicyDetailsScreen> createState() =>
      _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  bool _beneficiariesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final state = ref.watch(policyProvider);

    final policy = state.policy;
    final utilization = state.utilization;
    final dependants = state.dependants;
    final card = state.card;

    if (state.isLoading
    // || state.policy == null
    // || state.utilization == null
    ) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Policy Details")),
        body: Center(child: Text(state.error!)),
      );
    }

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
              if (card != null) ...[
                _buildMemberCardWidget(scheme, card),
                const SizedBox(height: 20),
              ],
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
              _buildPolicySummaryCard(scheme, policy, utilization),
              const SizedBox(height: 12),
              _buildExpandableCard(
                scheme: scheme,
                title: 'View Beneficiaries',
                isExpanded: _beneficiariesExpanded,
                onTap: () => setState(
                  () => _beneficiariesExpanded = !_beneficiariesExpanded,
                ),
                content: _buildDependantsContent(scheme, dependants),
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDependantsContent(
    ColorScheme scheme,
    List<DependantModel> dependants,
  ) {
    if (dependants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No dependants found"),
      );
    }

    return Column(
      children: dependants.map((d) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: const Icon(Icons.person)),
          title: Text(d.fullName),
          subtitle: Text(d.relationship),
        );
      }).toList(),
    );
  }

  Widget _buildPolicySummaryCard(
    ColorScheme scheme,
    PolicyModel? policy,
    UtilizationModel? utilization,
  ) {
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
          _buildPolicyRow(
            'Policy Holder',
            "${policy!.firstName} ${policy.lastName}",
            scheme,
          ),
          _buildDivider(scheme),
          _buildPolicyRow("Member ID", policy.memberId, scheme),
          _buildDivider(scheme),
          _buildPolicyRow("Policy Number", policy.policyNumber ?? "-", scheme),
          _buildDivider(scheme),
          _buildPolicyRow('Network', 'TIER 4', scheme),
          _buildDivider(scheme),
          _buildStatusRow(scheme, policy.status),
          _buildDivider(scheme),
          _buildPolicyRow(
            "Date Joined",
            DateFormat("dd MMM yyyy").format(policy.dateJoined),
            scheme,
          ),
          _buildDivider(scheme),
          _buildPolicyRow('Expiry Date', '31-12-2026', scheme),
          _buildDivider(scheme),
          _buildUtilizationCard(scheme, utilization!),
        ],
      ),
    );
  }

  Widget _buildUtilizationCard(
    ColorScheme scheme,
    UtilizationModel utilization,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                utilization.totalClaims.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Claims"),
            ],
          ),

          Column(
            children: [
              Text(
                utilization.totalAuthorizations.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Authorizations"),
            ],
          ),
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

  Widget _buildStatusRow(ColorScheme scheme, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            status.toUpperCase(),
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
}

Widget _buildMemberCardWidget(ColorScheme scheme, MemberCardModel card) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: scheme.primary.withValues(alpha: .25),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white,
              backgroundImage: card.photo.isNotEmpty
                  ? NetworkImage(card.photo)
                  : null,
              child: card.photo.isEmpty
                  ? Icon(Icons.person, size: 38, color: scheme.primary)
                  : null,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Member ID: ${card.memberId}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      card.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        Row(
          children: [
            Expanded(
              child: _buildCardInfo("Plan", card.planVariant.toUpperCase()),
            ),
            Expanded(child: _buildCardInfo("Gender", card.gender ?? "--")),
          ],
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _buildCardInfo("Blood Group", card.bloodGroup ?? "--"),
            ),
            Expanded(child: _buildCardInfo("Genotype", card.genotype ?? "--")),
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
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
