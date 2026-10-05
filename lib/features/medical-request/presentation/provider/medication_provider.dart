import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/core/network/api_client.dart';
import 'package:oceanic/core/network/dio_provider.dart';

import 'package:oceanic/features/medical-request/data/datasource/medication_remote_data_source.dart';
import 'package:oceanic/features/medical-request/data/repository/medication_repository_impl.dart';

import 'package:oceanic/features/medical-request/domain/repository/medication_repository.dart';

import 'package:oceanic/features/medical-request/presentation/state/medication_state.dart';
import 'package:oceanic/features/medical-request/presentation/viewmodel/medication_viewmodel.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);

  return ApiClient(dio);
});

final medicationRemoteDataSourceProvider = Provider<MedicationRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);

    return MedicationRemoteDataSource(apiClient);
  },
);

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final remoteDataSource = ref.watch(medicationRemoteDataSourceProvider);

  return MedicationRepositoryImpl(remoteDataSource);
});

final medicationViewModelProvider =
    NotifierProvider<MedicationViewModel, MedicationState>(
      MedicationViewModel.new,
    );
