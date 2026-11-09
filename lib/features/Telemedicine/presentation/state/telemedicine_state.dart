enum TelemedicineCallStatus {
  idle,
  ringing,
  connecting,
  connected,
  callEnded,
  error,
}

class TelemedicineState {
  final TelemedicineCallStatus status;
  final String statusMessage;
  final String? errorMessage;
  final String? callId;
  final int? remoteUid;
  final bool isMuted;
  final bool isVideoDisabled;
  final bool isJoined;

  TelemedicineState({
    this.status = TelemedicineCallStatus.idle,
    this.statusMessage = '',
    this.errorMessage,
    this.callId,
    this.remoteUid,
    this.isMuted = false,
    this.isVideoDisabled = false,
    this.isJoined = false,
  });

  TelemedicineState copyWith({
    TelemedicineCallStatus? status,
    String? statusMessage,
    String? errorMessage,
    String? callId,
    int? remoteUid,
    bool? isMuted,
    bool? isVideoDisabled,
    bool? isJoined,
  }) {
    return TelemedicineState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage,
      callId: callId ?? this.callId,
      remoteUid: remoteUid ?? this.remoteUid,
      isMuted: isMuted ?? this.isMuted,
      isVideoDisabled: isVideoDisabled ?? this.isVideoDisabled,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
