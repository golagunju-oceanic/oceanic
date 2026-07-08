class User {
  final String id;
  final String memberId;
  final String firstName;
  final String lastName;
  final String? email;

  const User({
    required this.id,
    required this.memberId,
    required this.firstName,
    required this.lastName,
    this.email,
  });
}