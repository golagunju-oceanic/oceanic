
import '../../data/models/wellness_benefit_model.dart';

abstract class WellnessRepository {
  Future<WellnessBenefitsResponse> getWellnessBenefits();
}
