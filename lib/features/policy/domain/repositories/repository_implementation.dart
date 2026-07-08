import 'package:oceanic/features/policy/data/datasource/policy_remote_datasource.dart';
import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';
import 'package:oceanic/features/policy/data/repositories/policy_respository.dart';

class PolicyRepositoryImpl
    implements PolicyRepository {
  final PolicyRemoteDatasource datasource;

  PolicyRepositoryImpl(this.datasource);

  @override
  Future<PolicyModel> getPolicy() {
    return datasource.getPolicy();
  }

  @override
  Future<UtilizationModel> getUtilization() {
    return datasource.getUtilization();
  }

  @override
  Future<List<DependantModel>> getDependants() {
    return datasource.getDependants();
  }

  @override
  Future<MemberCardModel> getMemberCard() {
    return datasource.getMemberCard();
  }
}