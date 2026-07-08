class DependantModel {
  final String memberId;
  final String fullName;
  final String relationship;

  const DependantModel({
    required this.memberId,
    required this.fullName,
    required this.relationship,
  });

  factory DependantModel.fromJson(Map<String, dynamic> json) {
    return DependantModel(
      memberId: json["memberId"],
      fullName: json["fullName"],
      relationship: json["relationship"],
    );
  }
}