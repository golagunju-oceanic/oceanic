class GenerateTokenRequest {
  final String channel;
  final String role;


  GenerateTokenRequest({
    required this.channel,
    this.role = "publisher",
   
  });

  Map<String, dynamic> toJson() {
    return {
      "channel": channel,
      "role": role,
      
    };
  }
}