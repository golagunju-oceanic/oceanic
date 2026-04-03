class UserModel {
  final String id;
  final String username;
  final String memberId;
  final String? password; // Optional
  final String? confirmPassword; // Optional
  final String token;

  const UserModel({
    required this.id,
    required this.memberId,
    this.password,
    this.confirmPassword,
    required this.token,
    required this.username,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      memberId: map['memberId']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      token: map['token']?.toString() ?? '',
      password: map['password']?.toString(), // Can be null
      confirmPassword: map['confirmPassword']?.toString(), // Can be null
    );
  }
}
