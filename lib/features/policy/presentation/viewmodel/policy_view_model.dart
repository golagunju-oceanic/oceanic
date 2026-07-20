import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/policy/domain/usecase/get_card_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_dependants_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_policy_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_utilization_usecase.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';

import '../state/policy_state.dart';

class PolicyViewModel extends Notifier<PolicyState> {
  late final GetPolicyUsecase _getPolicyUseCase;
  late final GetUtilizationUseCase _getUtilizationUseCase;
  late final GetDependantsUseCase _getDependantsUseCase;
  late final GetPolicyCardUseCase _getPolicyCardUseCase;

  @override
  PolicyState build() {
    _getPolicyUseCase = ref.read(getPolicyUseCaseProvider);

    _getUtilizationUseCase = ref.read(getUtilizationUseCaseProvider);

    _getDependantsUseCase = ref.read(getDependantsUseCaseProvider);

    _getPolicyCardUseCase = ref.read(getPolicyCardUseCaseProvider);

    Future.microtask(loadPolicy);

    return const PolicyState(isLoading: true);
  }

  Future<void> loadPolicy() async {
    try {
      print("1. Fetching policy...");
      final policy = await _getPolicyUseCase();
      print("Policy loaded");

      print("2. Fetching utilization...");
      final utilization = await _getUtilizationUseCase();
      print("Utilization loaded");

      print("3. Fetching dependants...");
      final dependants = await _getDependantsUseCase();
      print("Dependants loaded");

      print("4. Fetching card...");
      final card = await _getPolicyCardUseCase();
      print("Card loaded");

      state = state.copyWith(
        isLoading: false,
        policy: policy,
        utilization: utilization,
        dependants: dependants,
        card: card,
      );
    } catch (e, s) {
      print(e);
      print(s);

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
