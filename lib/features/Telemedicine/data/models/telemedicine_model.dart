class CallSessionModel {
  final String id;
  final String appointmentId;
  final String status; // "RINGING", "ACCEPTED", "MISSED", "DECLINED", "ENDED"
  final String? type; // "VIDEO" or "AUDIO"

  CallSessionModel({
    required this.id,
    required this.appointmentId,
    required this.status,
    this.type,
  });

  factory CallSessionModel.fromJson(Map<String, dynamic> json) {
    return CallSessionModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      status: json['status'] as String,
      type: json['type'] as String?,
    );
  }
}
