class InitiateCallRequest {
  final String doctorId;
  final String callType; // 'video' or 'audio'

  InitiateCallRequest({required this.doctorId, this.callType = 'video'});

  Map<String, dynamic> toJson() => {'doctorId': doctorId, 'callType': callType};
}
