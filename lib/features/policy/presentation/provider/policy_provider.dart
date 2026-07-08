import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/policy/domain/repositories/repository_implementation.dart';

import '../../../../core/provider/core_provider.dart';

import '../../data/datasource/policy_remote_datasource.dart';
import '../../domain/usecase/get_policy_usecase.dart';
import '../../domain/usecase/get_utilization_usecase.dart';
import '../../domain/usecase/get_dependants_usecase.dart';
import '../../domain/usecase/get_card_usecase.dart';

import '../state/policy_state.dart';
import '../viewmodel/policy_view_model.dart';

final policyRemoteDatasourceProvider = Provider(
  (ref) => PolicyRemoteDatasource(ref.read(apiClientProvider)),
);

final policyRepositoryProvider = Provider(
  (ref) => PolicyRepositoryImpl(ref.read(policyRemoteDatasourceProvider)),
);

final getPolicyUseCaseProvider = Provider(
  (ref) => GetPolicyUsecase(ref.read(policyRepositoryProvider)),
);

final getUtilizationUseCaseProvider = Provider(
  (ref) => GetUtilizationUseCase(ref.read(policyRepositoryProvider)),
);

final getDependantsUseCaseProvider = Provider(
  (ref) => GetDependantsUseCase(ref.read(policyRepositoryProvider)),
);

final getPolicyCardUseCaseProvider = Provider(
  (ref) => GetPolicyCardUseCase(ref.read(policyRepositoryProvider)),
);

final policyProvider = NotifierProvider<PolicyViewModel, PolicyState>(
  PolicyViewModel.new,
);
