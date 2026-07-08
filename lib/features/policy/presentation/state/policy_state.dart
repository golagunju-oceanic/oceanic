import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';

class PolicyState {
  final bool isLoading;
  final String? error;

  final PolicyModel? policy;
  final UtilizationModel? utilization;
  final List<DependantModel> dependants;
  final MemberCardModel? card;

  const PolicyState({
    this.isLoading = false,
    this.error,
    this.policy,
    this.utilization,
    this.dependants = const [],
    this.card,
  });

  PolicyState copyWith({
    bool? isLoading,
    String? error,
    PolicyModel? policy,
    UtilizationModel? utilization,
    List<DependantModel>? dependants,
    MemberCardModel? card,
  }) {
    return PolicyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      policy: policy ?? this.policy,
      utilization: utilization ?? this.utilization,
      dependants: dependants ?? this.dependants,
      card: card ?? this.card,
    );
  }
}
