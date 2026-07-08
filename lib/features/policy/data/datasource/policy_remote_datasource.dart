import 'package:oceanic/core/network/api_client.dart';
import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';

class PolicyRemoteDatasource {
  final ApiClient apiClient;

  PolicyRemoteDatasource(this.apiClient);

  Future<PolicyModel> getPolicy() async {
    final response = await apiClient.get("/policies");

    return PolicyModel.fromJson(response.data["data"]);
  }

  Future<UtilizationModel> getUtilization() async {
    final response = await apiClient.get("/policies/utilization");

    return UtilizationModel.fromJson(response.data["data"]);
  }

  Future<List<DependantModel>> getDependants() async {
    final response = await apiClient.get("/policies/dependants");

    return (response.data["data"] as List)
        .map((e) => DependantModel.fromJson(e))
        .toList();
  }

  Future<MemberCardModel> getMemberCard() async {
    final response = await apiClient.get("/policies/card");

    return MemberCardModel.fromJson(response.data["data"]);
  }
}
