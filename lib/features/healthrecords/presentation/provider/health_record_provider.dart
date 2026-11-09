import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/core/provider/core_provider.dart';
import 'package:oceanic/features/healthrecords/data/datasource/health_record_remote_data_source.dart';
import 'package:oceanic/features/healthrecords/data/models/health_record_model.dart';
import 'package:oceanic/features/healthrecords/data/repository/health_record/data/repository/health_record_repository_impl.dart';
import 'package:oceanic/features/healthrecords/domain/repository/health_record_repository.dart';
import 'package:oceanic/features/healthrecords/domain/usecase/get_health_records_usecase.dart';

final healthRecordRemoteDatasourceProvider =
    Provider<HealthRecordRemoteDatasource>((ref) {
      final apiClient = ref.read(apiClientProvider);

      return HealthRecordRemoteDatasource(apiClient);
    });

final healthRecordRepositoryProvider = Provider<HealthRecordRepository>((ref) {
  final remoteDatasource = ref.read(healthRecordRemoteDatasourceProvider);

  return HealthRecordRepositoryImpl(remoteDatasource);
});

final getHealthRecordsUseCaseProvider = Provider<GetHealthRecordsUseCase>((
  ref,
) {
  final repository = ref.read(healthRecordRepositoryProvider);

  return GetHealthRecordsUseCase(repository);
});

final healthRecordsProvider = FutureProvider<List<HealthRecordModel>>((
  ref,
) async {
  final useCase = ref.read(getHealthRecordsUseCaseProvider);

  return useCase();
});
