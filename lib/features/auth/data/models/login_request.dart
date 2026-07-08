class LoginRequest {
  final String memberId;
  final String password;

  LoginRequest({
    required this.memberId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "memberId": memberId,
      "password": password,
    };
  }
}