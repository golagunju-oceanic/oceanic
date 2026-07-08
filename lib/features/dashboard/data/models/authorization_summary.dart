class AuthorizationSummary {
  final int pending;
  final int approved;
  final int rejected;

  AuthorizationSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory AuthorizationSummary.fromJson(Map<String, dynamic> json) {
    return AuthorizationSummary(
      pending: json['pending'],
      approved: json['approved'],
      rejected: json['rejected'],
    );
  }
}