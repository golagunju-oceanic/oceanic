
import 'package:oceanic/features/healthrecords/data/datasource/health_record_remote_data_source.dart';
import 'package:oceanic/features/healthrecords/data/models/health_record_model.dart';
import 'package:oceanic/features/healthrecords/domain/repository/health_record_repository.dart';

class HealthRecordRepositoryImpl
    implements HealthRecordRepository {
  final HealthRecordRemoteDatasource remoteDatasource;

  HealthRecordRepositoryImpl(
    this.remoteDatasource,
  );

  @override
  Future<List<HealthRecordModel>> getHealthRecords() {
    return remoteDatasource.getHealthRecords();
  }
}