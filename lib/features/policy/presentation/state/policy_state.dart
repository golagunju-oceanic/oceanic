import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/policy_overview.dart';

import 'package:oceanic/features/policy/data/models/utilization_model.dart';

class PolicyState {
  // General loading and error
  final bool isLoading;
  final String? error;

  // Existing fields
  final PolicyModel? policy;
  final UtilizationModel? utilization;
  final List<DependantModel> dependants;
  final MemberCardModel? card;

  // New comprehensive policy overview
  final PolicyOverviewModel? overview;

  // Benefits can also be refreshed independently
  final PolicyBenefitsModel? benefits;
  final bool isLoadingBenefits;
  final String? benefitsError;

  const PolicyState({
    this.isLoading = false,
    this.error,

    this.policy,
    this.utilization,
    this.dependants = const [],
    this.card,

    this.overview,
    this.benefits,
    this.isLoadingBenefits = false,
    this.benefitsError,
  });

  PolicyState copyWith({
    bool? isLoading,
    String? error,

    PolicyModel? policy,
    UtilizationModel? utilization,
    List<DependantModel>? dependants,
    MemberCardModel? card,

    PolicyOverviewModel? overview,
    PolicyBenefitsModel? benefits,
    bool? isLoadingBenefits,
    String? benefitsError,
  }) {
    return PolicyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,

      policy: policy ?? this.policy,
      utilization: utilization ?? this.utilization,
      dependants: dependants ?? this.dependants,
      card: card ?? this.card,

      overview: overview ?? this.overview,
      benefits: benefits ?? this.benefits,

      isLoadingBenefits: isLoadingBenefits ?? this.isLoadingBenefits,

      benefitsError: benefitsError,
    );
  }

  // Use this getter when displaying benefits.
  // An independently refreshed response takes priority.
  PolicyBenefitsModel? get currentBenefits => benefits ?? overview?.benefits;

  bool get hasPolicyOverview => overview != null;
}
