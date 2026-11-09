import '../../domain/repositories/wellness_repository.dart';
import '../datasource/wellness_remote_datasource.dart';
import '../models/wellness_benefit_model.dart';

class WellnessRepositoryImpl implements WellnessRepository {
  final WellnessRemoteDatasource remoteDatasource;

  const WellnessRepositoryImpl({required this.remoteDatasource});

  @override
  Future<WellnessBenefitsResponse> getWellnessBenefits() async {
    return await remoteDatasource.getWellnessBenefits();
  }
}
