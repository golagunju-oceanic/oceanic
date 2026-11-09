import 'utilization_model.dart';
import 'member_card_model.dart';
import 'dependant_model.dart';

// =====================================================
// JSON HELPERS
// =====================================================

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

// =====================================================
// MEMBER
// =====================================================

class PolicyOverviewMemberModel {
  final String id;
  final String memberId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String status;
  final DateTime? dateJoined;
  final String? profilePicture;
  final String? profilePictureUrl;

  const PolicyOverviewMemberModel({
    required this.id,
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.status,
    this.dateJoined,
    this.profilePicture,
    this.profilePictureUrl,
  });

  factory PolicyOverviewMemberModel.fromJson(Map<String, dynamic> json) {
    return PolicyOverviewMemberModel(
      id: json['id']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      status: json['status']?.toString() ?? '',
      dateJoined: _asDate(json['dateJoined']),
      profilePicture: json['profilePicture']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
    );
  }
}

// =====================================================
// ASSIGNED HMO PLAN
// =====================================================

class PolicyOverviewPlanModel {
  final String id;
  final String name;
  final String basePlanId;
  final String? basePlanName;
  final String? hospitalTier;
  final String? variantType;
  final String? policyId;
  final bool? basePlanActive;

  const PolicyOverviewPlanModel({
    required this.id,
    required this.name,
    required this.basePlanId,
    this.basePlanName,
    this.hospitalTier,
    this.variantType,
    this.policyId,
    this.basePlanActive,
  });

  factory PolicyOverviewPlanModel.fromJson(Map<String, dynamic> json) {
    return PolicyOverviewPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      basePlanId: json['basePlanId']?.toString() ?? '',
      basePlanName: json['basePlanName']?.toString(),
      hospitalTier: json['hospitalTier']?.toString(),
      variantType: json['variantType']?.toString(),
      policyId: json['policyId']?.toString(),
      basePlanActive: json['basePlanActive'] is bool
          ? json['basePlanActive'] as bool
          : null,
    );
  }
}

// =====================================================
// POLICY DETAILS
// =====================================================

class PolicyOverviewDetailsModel {
  final String? policyNumber;
  final String? corporatePolicyId;
  final bool? corporatePolicyActive;
  final DateTime? startDate;
  final DateTime? endDate;

  final String? individualPolicyId;
  final String? individualPolicyStatus;
  final String? individualPlanId;
  final String? memberStatus;

  const PolicyOverviewDetailsModel({
    this.policyNumber,
    this.corporatePolicyId,
    this.corporatePolicyActive,
    this.startDate,
    this.endDate,
    this.individualPolicyId,
    this.individualPolicyStatus,
    this.individualPlanId,
    this.memberStatus,
  });

  factory PolicyOverviewDetailsModel.fromJson(Map<String, dynamic> json) {
    return PolicyOverviewDetailsModel(
      policyNumber: json['policyNumber']?.toString(),
      corporatePolicyId: json['corporatePolicyId']?.toString(),
      corporatePolicyActive: json['corporatePolicyActive'] is bool
          ? json['corporatePolicyActive'] as bool
          : null,
      startDate: _asDate(json['startDate']),
      endDate: _asDate(json['endDate']),
      individualPolicyId: json['individualPolicyId']?.toString(),
      individualPolicyStatus: json['individualPolicyStatus']?.toString(),
      individualPlanId: json['individualPlanId']?.toString(),
      memberStatus: json['memberStatus']?.toString(),
    );
  }
}

// =====================================================
// SINGLE PLAN BENEFIT
// =====================================================

class PolicyBenefitItemModel {
  final String benefitId;
  final String? description;
  final String? limitAmount;
  final int? limitCount;

  final String? coverageStatus;
  final String? limitType;
  final String? limitPeriod;
  final String? applicableTo;
  final String? capStrategy;

  final bool? isUnlimitedOverride;
  final bool hasOverride;

  const PolicyBenefitItemModel({
    required this.benefitId,
    this.description,
    this.limitAmount,
    this.limitCount,
    this.coverageStatus,
    this.limitType,
    this.limitPeriod,
    this.applicableTo,
    this.capStrategy,
    this.isUnlimitedOverride,
    required this.hasOverride,
  });

  factory PolicyBenefitItemModel.fromJson(Map<String, dynamic> json) {
    return PolicyBenefitItemModel(
      benefitId: json['benefitId']?.toString() ?? '',
      description: json['description']?.toString(),
      limitAmount: json['limitAmount']?.toString(),
      limitCount: _asInt(json['limitCount']),
      coverageStatus: json['coverageStatus']?.toString(),
      limitType: json['limitType']?.toString(),
      limitPeriod: json['limitPeriod']?.toString(),
      applicableTo: json['applicableTo']?.toString(),
      capStrategy: json['capStrategy']?.toString(),
      isUnlimitedOverride: json['isUnlimitedOverride'] is bool
          ? json['isUnlimitedOverride'] as bool
          : null,
      hasOverride: json['hasOverride'] == true,
    );
  }
}

// =====================================================
// BENEFITS COLLECTION
// =====================================================

class PolicyBenefitsModel {
  final String benefitDataStatus;
  final String? benefitMessage;
  final int totalBenefits;
  final List<PolicyBenefitItemModel> items;

  const PolicyBenefitsModel({
    required this.benefitDataStatus,
    this.benefitMessage,
    required this.totalBenefits,
    required this.items,
  });

  factory PolicyBenefitsModel.fromJson(Map<String, dynamic> json) {
    // Overview uses "items".
    // Dedicated benefits endpoint uses "benefits".
    final rawItems = json['items'] ?? json['benefits'];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => PolicyBenefitItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <PolicyBenefitItemModel>[];

    return PolicyBenefitsModel(
      benefitDataStatus: json['benefitDataStatus']?.toString() ?? 'UNKNOWN',
      benefitMessage: json['benefitMessage']?.toString(),
      totalBenefits: _asInt(json['totalBenefits']) ?? items.length,
      items: items,
    );
  }

  bool get hasConfiguredBenefits =>
      benefitDataStatus == 'AVAILABLE' && items.isNotEmpty;
}

// =====================================================
// COMPLETE POLICY OVERVIEW
// =====================================================

class PolicyOverviewModel {
  final PolicyOverviewMemberModel member;
  final PolicyOverviewPlanModel? plan;
  final PolicyOverviewDetailsModel policy;
  final PolicyBenefitsModel benefits;
  final UtilizationModel utilization;
  final List<DependantModel> dependants;
  final MemberCardModel memberCard;

  const PolicyOverviewModel({
    required this.member,
    this.plan,
    required this.policy,
    required this.benefits,
    required this.utilization,
    required this.dependants,
    required this.memberCard,
  });

  factory PolicyOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawPlan = json['plan'];
    final rawDependants = json['dependants'];

    return PolicyOverviewModel(
      member: PolicyOverviewMemberModel.fromJson(_asMap(json['member'])),

      plan: rawPlan is Map
          ? PolicyOverviewPlanModel.fromJson(_asMap(rawPlan))
          : null,

      policy: PolicyOverviewDetailsModel.fromJson(_asMap(json['policy'])),

      benefits: PolicyBenefitsModel.fromJson(_asMap(json['benefits'])),

      utilization: UtilizationModel.fromJson(_asMap(json['utilization'])),

      dependants: rawDependants is List
          ? rawDependants
                .whereType<Map>()
                .map(
                  (item) =>
                      DependantModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <DependantModel>[],

      memberCard: MemberCardModel.fromJson(_asMap(json['memberCard'])),
    );
  }

  String get planName =>
      plan?.name.trim().isNotEmpty == true ? plan!.name : 'Plan not available';
}
