import 'package:oceanic/features/policy/data/models/utilization_model.dart';

import 'package:oceanic/features/policy/data/repositories/policy_respository.dart';

class GetUtilizationUseCase {
  const GetUtilizationUseCase(this._repository);

  final PolicyRepository _repository;

  Future<UtilizationModel> call() {
    return _repository.getUtilization();
  }
}