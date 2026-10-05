class SubmitReimbursementResponse {
  final String message;
  final int id;

  SubmitReimbursementResponse({
    required this.message,
    required this.id,
  });

  factory SubmitReimbursementResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubmitReimbursementResponse(
      message: json['message'] ?? '',
      id: json['id'],
    );
  }
}