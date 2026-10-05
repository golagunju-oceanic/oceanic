class GenerateTokenRequest {
  final String channel;
  final String role;
  final int uid;

  GenerateTokenRequest({
    required this.channel,
    this.role = 'publisher',
    this.uid = 0,
  });
  Map<String, dynamic> toJson() => {
    'channel': channel,
    'role': role,
    'uid': uid,
  };
}
