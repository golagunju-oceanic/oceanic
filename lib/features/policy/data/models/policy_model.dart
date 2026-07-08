class PolicyModel {
  final String memberId;
  final String firstName;
  final String lastName;
  final String status;
  final String? policyNumber;
  final DateTime dateJoined;

  const PolicyModel({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.policyNumber,
    required this.dateJoined,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      memberId: json["memberId"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      status: json["status"],
      policyNumber: json["policyNumber"],
      dateJoined: DateTime.parse(json["dateJoined"]),
    );
  }
}