

import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/repositories/policy_respository.dart';

class GetPolicyCardUseCase {
  const GetPolicyCardUseCase(this._repository);

  final PolicyRepository _repository;

  Future<MemberCardModel> call() {
    return _repository.getMemberCard();
  }
}