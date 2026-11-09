class PolicyModel {
  final String memberId;
  final String firstName;
  final String lastName;
  final String status;
  final String? policyNumber;
  final DateTime dateJoined;

  // New plan information
  final String? planName;
  final String? basePlanName;
  final String? hospitalTier;
  final String? planVariant;

  // New policy information
  final String? corporatePolicyId;
  final bool? corporatePolicyActive;
  final DateTime? startDate;
  final DateTime? endDate;

  const PolicyModel({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.policyNumber,
    required this.dateJoined,
    this.planName,
    this.basePlanName,
    this.hospitalTier,
    this.planVariant,
    this.corporatePolicyId,
    this.corporatePolicyActive,
    this.startDate,
    this.endDate,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] is Map
        ? Map<String, dynamic>.from(json['plan'] as Map)
        : <String, dynamic>{};

    final policy = json['policy'] is Map
        ? Map<String, dynamic>.from(json['policy'] as Map)
        : <String, dynamic>{};

    return PolicyModel(
      memberId: json['memberId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      policyNumber: json['policyNumber']?.toString(),
      dateJoined: DateTime.parse(json['dateJoined'].toString()),

      planName: plan['name']?.toString(),
      basePlanName: plan['basePlanName']?.toString(),
      hospitalTier: plan['hospitalTier']?.toString(),
      planVariant: plan['variantType']?.toString(),

      corporatePolicyId: policy['corporatePolicyId']?.toString(),
      corporatePolicyActive: policy['corporatePolicyActive'] is bool
          ? policy['corporatePolicyActive'] as bool
          : null,
      startDate: DateTime.tryParse(policy['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(policy['endDate']?.toString() ?? ''),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get displayPlanName =>
      planName?.trim().isNotEmpty == true ? planName! : 'Plan not available';
}
