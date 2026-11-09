
import 'package:oceanic/features/healthrecords/data/models/health_record_model.dart';
import 'package:oceanic/features/healthrecords/domain/repository/health_record_repository.dart';

class GetHealthRecordsUseCase {
  final HealthRecordRepository repository;

  GetHealthRecordsUseCase(
    this.repository,
  );

  Future<List<HealthRecordModel>> call() {
    return repository.getHealthRecords();
  }
}