
import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/policy_overview.dart';

import 'package:oceanic/features/policy/data/models/utilization_model.dart';

abstract class PolicyRepository {
  // Existing policy details
  Future<PolicyModel> getPolicy();

  // New comprehensive policy overview
  Future<PolicyOverviewModel> getPolicyOverview();

  // New healthcare benefits
  Future<PolicyBenefitsModel> getBenefits();

  // Existing utilization
  Future<UtilizationModel> getUtilization();

  // Existing dependants
  Future<List<DependantModel>> getDependants();

  // Existing digital member card
  Future<MemberCardModel> getMemberCard();
}
