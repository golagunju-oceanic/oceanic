import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/core/provider/core_provider.dart';

import 'package:oceanic/features/policy/data/datasource/policy_remote_datasource.dart';
import 'package:oceanic/features/policy/data/repositories/policy_respository.dart';

// Import the file where PolicyRepositoryImpl is declared.
// This path matches the implementation file used by
// your earlier Policy use cases.
import 'package:oceanic/features/policy/domain/repositories/repository_implementation.dart';

import 'package:oceanic/features/policy/domain/usecase/get_policy_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_utilization_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_dependants_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_card_usecase.dart';

// New use cases
import 'package:oceanic/features/policy/domain/usecase/get_policy_overview_usecase.dart';
import 'package:oceanic/features/policy/domain/usecase/get_benefits_usecase.dart';

import 'package:oceanic/features/policy/presentation/state/policy_state.dart';
import 'package:oceanic/features/policy/presentation/viewmodel/policy_view_model.dart';

// =====================================================
// DATA SOURCE
// =====================================================

final policyRemoteDatasourceProvider = Provider<PolicyRemoteDatasource>((ref) {
  return PolicyRemoteDatasource(ref.read(apiClientProvider));
});

// =====================================================
// REPOSITORY
// =====================================================

final policyRepositoryProvider = Provider<PolicyRepository>((ref) {
  return PolicyRepositoryImpl(ref.read(policyRemoteDatasourceProvider));
});

// =====================================================
// EXISTING USE CASES
// =====================================================

final getPolicyUseCaseProvider = Provider<GetPolicyUsecase>((ref) {
  return GetPolicyUsecase(ref.read(policyRepositoryProvider));
});

final getUtilizationUseCaseProvider = Provider<GetUtilizationUseCase>((ref) {
  return GetUtilizationUseCase(ref.read(policyRepositoryProvider));
});

final getDependantsUseCaseProvider = Provider<GetDependantsUseCase>((ref) {
  return GetDependantsUseCase(ref.read(policyRepositoryProvider));
});

final getPolicyCardUseCaseProvider = Provider<GetPolicyCardUseCase>((ref) {
  return GetPolicyCardUseCase(ref.read(policyRepositoryProvider));
});

// =====================================================
// NEW COMPREHENSIVE POLICY OVERVIEW
// =====================================================

final getPolicyOverviewUseCaseProvider = Provider<GetPolicyOverviewUseCase>((
  ref,
) {
  return GetPolicyOverviewUseCase(ref.read(policyRepositoryProvider));
});

// =====================================================
// NEW POLICY BENEFITS
// =====================================================

final getBenefitsUseCaseProvider = Provider<GetBenefitsUseCase>((ref) {
  return GetBenefitsUseCase(ref.read(policyRepositoryProvider));
});

// =====================================================
// POLICY VIEWMODEL
// =====================================================

final policyProvider = NotifierProvider<PolicyViewModel, PolicyState>(
  PolicyViewModel.new,
);
