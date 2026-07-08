class RegisterRequest {
  final String memberId;
  final String password;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;

  RegisterRequest({
    required this.memberId,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "memberId": memberId,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
    };
  }
}