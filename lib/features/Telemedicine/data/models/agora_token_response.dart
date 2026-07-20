class AgoraTokenResponse {
  final bool success;
  final String token;
  final String appId;
  final String channel;
  final int uid;
  final int expiresIn;

  AgoraTokenResponse({
    required this.success,
    required this.token,
    required this.appId,
    required this.channel,
    required this.uid,
    required this.expiresIn,
  });

  factory AgoraTokenResponse.fromJson(Map<String, dynamic> json) {
    return AgoraTokenResponse(
      success: json["success"],
      token: json["token"],
      appId: json["appId"],
      channel: json["channel"],
      uid: json["uid"],
      expiresIn: json["expiresIn"],
    );
  }
}