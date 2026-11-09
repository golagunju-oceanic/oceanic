import 'package:oceanic/features/policy/data/models/policy_overview.dart';
import 'package:oceanic/features/policy/domain/repositories/repository_implementation.dart';

class GetBenefitsUseCase {
  const GetBenefitsUseCase(this._repository);

  final PolicyRepository _repository;

  Future<PolicyBenefitsModel> call() {
    return _repository.getBenefits();
  }
}
