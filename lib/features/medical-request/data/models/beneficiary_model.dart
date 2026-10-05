class BeneficiaryModel {
  final int id;
  final String memberId;
  final String fullName;
  final bool isChronicEligible;

  const BeneficiaryModel({
    required this.id,
    required this.memberId,
    required this.fullName,
    required this.isChronicEligible,
  });

  factory BeneficiaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BeneficiaryModel(
      id: json['id'] as int,
      memberId: json['member_id'] as String,
      fullName: json['full_name'] as String,
      isChronicEligible:
          json['is_chronic_eligible'] as bool? ?? false,
    );
  }
}