import 'package:oceanic/features/policy/data/models/policy_overview.dart';
import 'package:oceanic/features/policy/domain/repositories/repository_implementation.dart';

class GetPolicyOverviewUseCase {
  const GetPolicyOverviewUseCase(this._repository);

  final PolicyRepository _repository;

  Future<PolicyOverviewModel> call() {
    return _repository.getPolicyOverview();
  }
}
