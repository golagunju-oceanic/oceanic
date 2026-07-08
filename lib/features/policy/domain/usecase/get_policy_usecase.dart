import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/repositories/policy_respository.dart';

class GetPolicyUsecase {
  const GetPolicyUsecase(this._repository);

  final PolicyRepository _repository;


  Future<PolicyModel> call (){
    return _repository.getPolicy();
  }
}
