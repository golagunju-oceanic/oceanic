
import '../../data/models/wellness_benefit_model.dart';
import '../repositories/wellness_repository.dart';

class GetWellnessBenefitsUseCase {
  final WellnessRepository repository;

  const GetWellnessBenefitsUseCase({
    required this.repository,
  });

  Future<WellnessBenefitsResponse> call() async {
    return await repository.getWellnessBenefits();
  }
}
