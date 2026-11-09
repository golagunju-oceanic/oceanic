class CallSessionEntity {
  final String callId;
  final String appointmentId;
  final String status;
  final String callType;

  CallSessionEntity({
    required this.callId,
    required this.appointmentId,
    required this.status,
    required this.callType,
  });
}

class AgoraConnectionCredentials {
  final String appId;
  final String token;
  final String channel;
  final int uid;
  final bool isVideo;

  AgoraConnectionCredentials({
    required this.appId,
    required this.token,
    required this.channel,
    required this.uid,
    required this.isVideo,
  });
}