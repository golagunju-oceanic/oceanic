class MemberCardModel {
  final String memberId;
  final String fullName;
  final String planVariant;
  final String status;
  final String? gender;
  final String? bloodGroup;
  final String? genotype;
  final String photo;

  const MemberCardModel({
    required this.memberId,
    required this.fullName,
    required this.planVariant,
    required this.status,
    this.gender,
    this.bloodGroup,
    this.genotype,
    required this.photo,
  });

  factory MemberCardModel.fromJson(Map<String, dynamic> json) {
    return MemberCardModel(
      memberId: json["memberId"],
      fullName: json["fullName"],
      planVariant: json["planVariant"],
      status: json["status"],
      gender: json["gender"],
      bloodGroup: json["bloodGroup"],
      genotype: json["genotype"],
      photo: json["photo"] ?? "",
    );
  }
}