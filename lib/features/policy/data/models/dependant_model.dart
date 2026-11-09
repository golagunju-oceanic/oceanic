class DependantModel {
  final String memberId;
  final String fullName;
  final String relationship;
  final String? status;

  const DependantModel({
    required this.memberId,
    required this.fullName,
    required this.relationship,
    this.status,
  });

  factory DependantModel.fromJson(Map<String, dynamic> json) {
    final firstName =
        json['first_name']?.toString() ?? json['firstName']?.toString() ?? '';

    final lastName =
        json['last_name']?.toString() ?? json['lastName']?.toString() ?? '';

    final fullName =
        json['fullName']?.toString() ?? '$firstName $lastName'.trim();

    return DependantModel(
      memberId:
          json['memberId']?.toString() ?? json['member_id']?.toString() ?? '',
      fullName: fullName,
      relationship: json['relationship']?.toString() ?? '',
      status: json['status']?.toString(),
    );
  }
}
