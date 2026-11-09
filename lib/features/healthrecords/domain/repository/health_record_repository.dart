
import 'package:oceanic/features/healthrecords/data/models/health_record_model.dart';

abstract class HealthRecordRepository {
  Future<List<HealthRecordModel>> getHealthRecords();
}