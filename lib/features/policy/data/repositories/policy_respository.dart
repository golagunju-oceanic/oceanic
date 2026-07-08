import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';

abstract class PolicyRepository {
  Future<PolicyModel> getPolicy();

  Future<UtilizationModel> getUtilization();

  Future<List<DependantModel>> getDependants();

  Future<MemberCardModel> getMemberCard();
}