class PlanModel {
  final String id;
  final String name;
  final String basePlanId;
  final String? basePlanName;
  final String? hospitalTier;
  final String? variantType;
  final String policyId;
  final bool isActive;

  const PlanModel({
    required this.id,
    required this.name,
    required this.basePlanId,
    this.basePlanName,
    this.hospitalTier,
    this.variantType,
    required this.policyId,
    required this.isActive,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      basePlanId: json['basePlanId'].toString(),
      basePlanName: json['basePlanName']?.toString(),
      hospitalTier: json['hospitalTier']?.toString(),
      variantType: json['variantType']?.toString(),
      policyId: json['policyId'].toString(),
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'basePlanId': basePlanId,
      'basePlanName': basePlanName,
      'hospitalTier': hospitalTier,
      'variantType': variantType,
      'policyId': policyId,
      'isActive': isActive,
    };
  }
}
