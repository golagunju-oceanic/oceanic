class PrescriptionResponseModel {
  final bool success;
  final String requestNumber;
  final String status;

  const PrescriptionResponseModel({
    required this.success,
    required this.requestNumber,
    required this.status,
  });

  factory PrescriptionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrescriptionResponseModel(
      success: json['success'] as bool? ?? false,
      requestNumber:
          json['request_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}