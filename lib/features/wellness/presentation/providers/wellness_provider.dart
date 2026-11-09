
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/core/provider/core_provider.dart';

import '../../data/datasource/wellness_remote_datasource.dart';
import '../../data/models/wellness_benefit_model.dart';
import '../../data/repositories/wellness_repository_impl.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../../domain/usecase/get_wellness_benefits_usecase.dart';

// 1. Remote Datasource Provider
final wellnessRemoteDatasourceProvider =
    Provider<WellnessRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return WellnessRemoteDatasource(
    get: apiClient.get,
  );
});

// 2. Repository Provider
final wellnessRepositoryProvider = Provider<WellnessRepository>((ref) {
  final remoteDatasource =
      ref.watch(wellnessRemoteDatasourceProvider);

  return WellnessRepositoryImpl(
    remoteDatasource: remoteDatasource,
  );
});

// 3. Use Case Provider
final getWellnessBenefitsUseCaseProvider =
    Provider<GetWellnessBenefitsUseCase>((ref) {
  final repository = ref.watch(wellnessRepositoryProvider);

  return GetWellnessBenefitsUseCase(
    repository: repository,
  );
});

// 4. Wellness Benefits State Provider
final wellnessBenefitsProvider =
    FutureProvider.autoDispose<WellnessBenefitsResponse>((ref) async {
  final getWellnessBenefits =
      ref.watch(getWellnessBenefitsUseCaseProvider);

  return getWellnessBenefits();
});
