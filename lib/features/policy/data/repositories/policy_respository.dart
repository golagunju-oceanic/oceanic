import 'package:oceanic/features/policy/data/datasource/policy_remote_datasource.dart';

import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/policy_overview.dart';

import 'package:oceanic/features/policy/data/models/utilization_model.dart';

import 'package:oceanic/features/policy/domain/repositories/repository_implementation.dart';

class PolicyRepositoryImpl implements PolicyRepository {
  final PolicyRemoteDatasource datasource;

  PolicyRepositoryImpl(this.datasource);

  // =====================================================
  // EXISTING POLICY DETAILS
  // =====================================================

  @override
  Future<PolicyModel> getPolicy() {
    return datasource.getPolicy();
  }

  // =====================================================
  // NEW COMPREHENSIVE POLICY OVERVIEW
  // =====================================================

  @override
  Future<PolicyOverviewModel> getPolicyOverview() {
    return datasource.getPolicyOverview();
  }

  // =====================================================
  // NEW HEALTHCARE BENEFITS
  // =====================================================

  @override
  Future<PolicyBenefitsModel> getBenefits() {
    return datasource.getBenefits();
  }

  // =====================================================
  // EXISTING UTILIZATION
  // =====================================================

  @override
  Future<UtilizationModel> getUtilization() {
    return datasource.getUtilization();
  }

  // =====================================================
  // EXISTING DEPENDANTS
  // =====================================================

  @override
  Future<List<DependantModel>> getDependants() {
    return datasource.getDependants();
  }

  // =====================================================
  // EXISTING DIGITAL MEMBER CARD
  // =====================================================

  @override
  Future<MemberCardModel> getMemberCard() {
    return datasource.getMemberCard();
  }
}
