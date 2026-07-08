import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/repositories/policy_respository.dart';


class GetDependantsUseCase {
  const GetDependantsUseCase(this._repository);

  final PolicyRepository _repository;

  Future<List<DependantModel>> call() {
    return _repository.getDependants();
  }
}