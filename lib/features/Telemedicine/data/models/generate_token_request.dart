class GenerateTokenRequest {
  final String channel;
  final String role;
  final int uid;


  GenerateTokenRequest({
    required this.channel,
    this.role = "publisher",
    required this.uid
   
  });

  Map<String, dynamic> toJson() {
    return {
      "channel": channel,
      "role": role,
      "uid": uid,
      
    };
  }
}