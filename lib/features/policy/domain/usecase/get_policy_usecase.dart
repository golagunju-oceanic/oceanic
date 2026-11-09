import 'package:oceanic/features/policy/data/models/policy_model.dart';

import 'package:oceanic/features/policy/domain/repositories/repository_implementation.dart';

class GetPolicyUsecase {
  const GetPolicyUsecase(this._repository);

  final PolicyRepository _repository;

  Future<PolicyModel> call() {
    return _repository.getPolicy();
  }
}
