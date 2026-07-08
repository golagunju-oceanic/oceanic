class UserModel {
  final String id;
  final String memberId;
  final String firstName;
  final String lastName;
  final String? email;

  UserModel({
    required this.id,
    required this.memberId,
    required this.firstName,
    required this.lastName,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      memberId: json["memberId"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "memberId": memberId,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
    };
  }
}