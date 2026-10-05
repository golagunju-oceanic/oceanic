class UserModel {
  final String id;
  final String role; // "member" | "doctor"

  // Member-only fields
  final String? memberId;
  final String? firstName;
  final String? lastName;
  final String? email;

  // Doctor-only fields
  final String? doctorId;
  final String? fullName;
  final String? specialty;

  UserModel({
    required this.id,
    required this.role,
    this.memberId,
    this.firstName,
    this.lastName,
    this.email,
    this.doctorId,
    this.fullName,
    this.specialty,
  });

  bool get isDoctor => role == "doctor";
  bool get isMember => role == "member";

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      role: json["role"],
      memberId: json["memberId"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      doctorId: json["doctorId"],
      fullName: json["fullName"],
      specialty: json["specialty"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "role": role,
      "memberId": memberId,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "doctorId": doctorId,
      "fullName": fullName,
      "specialty": specialty,
    };
  }

  /// Display name regardless of role
  String get displayName => isDoctor ? (fullName ?? "") : "$firstName $lastName";
}