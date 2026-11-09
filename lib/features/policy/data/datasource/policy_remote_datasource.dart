import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:oceanic/core/network/api_client.dart';

import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/policy_overview.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';

class PolicyRemoteDatasource {
  final ApiClient apiClient;

  PolicyRemoteDatasource(this.apiClient);

  // =====================================================
  // EXISTING POLICY DETAILS
  // GET /api/policies
  // =====================================================

  Future<PolicyModel> getPolicy() async {
    try {
      final response = await apiClient.get("/policies");

      final data = Map<String, dynamic>.from(response.data["data"] as Map);

      return PolicyModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        "[POLICY] Get policy failed: "
        "${e.response?.statusCode} - ${e.message}",
      );
      rethrow;
    }
  }

  // =====================================================
  // NEW COMPREHENSIVE POLICY OVERVIEW
  // GET /api/policies/overview
  // =====================================================

  Future<PolicyOverviewModel> getPolicyOverview() async {
    try {
      final response = await apiClient.get("/policies/overview");

      final data = Map<String, dynamic>.from(response.data["data"] as Map);

      return PolicyOverviewModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        "[POLICY] Get overview failed: "
        "${e.response?.statusCode} - ${e.message}",
      );
      rethrow;
    }
  }

  // =====================================================
  // NEW HEALTHCARE BENEFITS
  // GET /api/policies/benefits
  // =====================================================

  Future<PolicyBenefitsModel> getBenefits() async {
    try {
      final response = await apiClient.get("/policies/benefits");

      final data = Map<String, dynamic>.from(response.data["data"] as Map);

      return PolicyBenefitsModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        "[POLICY] Get benefits failed: "
        "${e.response?.statusCode} - ${e.message}",
      );
      rethrow;
    }
  }

  // =====================================================
  // EXISTING UTILIZATION
  // GET /api/policies/utilization
  // =====================================================

  Future<UtilizationModel> getUtilization() async {
    try {
      final response = await apiClient.get("/policies/utilization");

      final data = Map<String, dynamic>.from(response.data["data"] as Map);

      return UtilizationModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        "[POLICY] Get utilization failed: "
        "${e.response?.statusCode} - ${e.message}",
      );
      rethrow;
    }
  }

  // =====================================================
  // EXISTING DEPENDANTS
  // GET /api/policies/dependants
  // =====================================================

  Future<List<DependantModel>> getDependants() async {
    try {
      final response = await apiClient.get("/policies/dependants");

      final data = response.data["data"] as List;

      return data.map((item) {
        return DependantModel.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    } on DioException catch (e) {
      debugPrint(
        "[POLICY] Get dependants failed: "
        "${e.response?.statusCode} - ${e.message}",
      );
      rethrow;
    }
  }

  // =====================================================
  // EXISTING DIGITAL MEMBER CARD
  // GET /api/policies/card
  // =====================================================

  Future<MemberCardModel> getMemberCard() async {
    try {
      final response = await apiClient.get("/policies/card");

      final data = Map<String, dynamic>.from(response.data["data"] as Map);

      return MemberCardModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        "[POLICY] Get member card failed: "
        "${e.response?.statusCode} - ${e.message}",
      );
      rethrow;
    }
  }
}
