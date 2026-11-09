class AgoraTokenResponse {
  final String appId;
  final String token;
  final String channel;
  final int uid;
  final String role;
  final int expiresIn;
  final String appointmentId;
  final String appointmentType;

  AgoraTokenResponse({
    required this.appId,
    required this.token,
    required this.channel,
    required this.uid,
    required this.role,
    required this.expiresIn,
    required this.appointmentId,
    required this.appointmentType,
  });

  factory AgoraTokenResponse.fromJson(Map<String, dynamic> json) {
    return AgoraTokenResponse(
      appId: json['appId'] as String,
      token: json['token'] as String,
      channel: json['channel'] as String,
      uid: json['uid'] as int,
      role: json['role'] as String? ?? 'member',
      expiresIn: json['expiresIn'] as int? ?? 3600,
      appointmentId: json['appointmentId'] as String,
      appointmentType: json['appointmentType'] as String? ?? 'VIDEO',
    );
  }
}
