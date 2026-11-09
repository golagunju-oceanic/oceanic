import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/policy_overview.dart';

import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/features/policy/presentation/state/policy_state.dart';

class PolicyViewModel extends Notifier<PolicyState> {
  bool _disposed = false;
  int _loadSequence = 0;

  @override
  PolicyState build() {
    ref.onDispose(() {
      _disposed = true;
    });

    // Start loading after the initial state is available.
    Future.microtask(loadPolicy);

    return const PolicyState(isLoading: true);
  }

  // =====================================================
  // LOAD COMPLETE POLICY OVERVIEW
  // =====================================================

  Future<void> loadPolicy() async {
    if (_disposed) return;

    final requestId = ++_loadSequence;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final overview = await ref.read(getPolicyOverviewUseCaseProvider).call();

      // Avoid updating a disposed provider or applying
      // an older response after a newer refresh.
      if (_disposed || requestId != _loadSequence) {
        return;
      }

      // Preserve the old PolicyModel for screens
      // that still depend on state.policy.
      final legacyPolicy = _buildLegacyPolicy(overview);

      // One API response populates the complete state.
      state = PolicyState(
        isLoading: false,
        error: null,

        // Existing state fields
        policy: legacyPolicy,
        utilization: overview.utilization,
        dependants: overview.dependants,
        card: overview.memberCard,

        // New state fields
        overview: overview,
        benefits: overview.benefits,

        isLoadingBenefits: false,
        benefitsError: null,
      );
    } catch (error) {
      if (_disposed || requestId != _loadSequence) {
        return;
      }

      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  // =====================================================
  // REFRESH BENEFITS INDEPENDENTLY
  // =====================================================

  Future<void> loadBenefits() async {
    if (_disposed) return;

    state = state.copyWith(isLoadingBenefits: true, benefitsError: null);

    try {
      final benefits = await ref.read(getBenefitsUseCaseProvider).call();

      if (_disposed) return;

      state = state.copyWith(
        isLoadingBenefits: false,
        benefits: benefits,
        benefitsError: null,
      );
    } catch (error) {
      if (_disposed) return;

      state = state.copyWith(
        isLoadingBenefits: false,
        benefitsError: error.toString(),
      );
    }
  }

  // =====================================================
  // CONVERT OVERVIEW TO EXISTING POLICY MODEL
  // =====================================================

  PolicyModel? _buildLegacyPolicy(PolicyOverviewModel overview) {
    final member = overview.member;
    final plan = overview.plan;
    final policy = overview.policy;

    // Existing PolicyModel requires a joining date.
    // Do not invent one if the API does not supply it.
    final dateJoined = member.dateJoined;

    if (dateJoined == null) {
      return null;
    }

    return PolicyModel(
      memberId: member.memberId,
      firstName: member.firstName,
      lastName: member.lastName,
      status: member.status,
      policyNumber: policy.policyNumber,
      dateJoined: dateJoined,

      // Fields added to your updated PolicyModel
      planName: plan?.name,
      basePlanName: plan?.basePlanName,
      hospitalTier: plan?.hospitalTier,
      planVariant: plan?.variantType,

      corporatePolicyId: policy.corporatePolicyId,
      corporatePolicyActive: policy.corporatePolicyActive,
      startDate: policy.startDate,
      endDate: policy.endDate,
    );
  }
}
