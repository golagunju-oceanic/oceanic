class TelemedicineState {
  final bool isLoading;
  final bool localUserJoined;
  final int? remoteUid;
  final String? error;
  final bool microphoneEnabled;
  final bool cameraEnabled;

  const TelemedicineState({
    this.isLoading = false,
    this.localUserJoined = false,
    this.remoteUid,
    this.error,
    this.microphoneEnabled = true,
    this.cameraEnabled = true,
  });

  TelemedicineState copyWith({
    bool? isLoading,
    bool? localUserJoined,
    int? remoteUid,
    String? error,
    bool? microphoneEnabled,
    bool? cameraEnabled,
  }) {
    return TelemedicineState(
      isLoading: isLoading ?? this.isLoading,
      localUserJoined: localUserJoined ?? this.localUserJoined,
      remoteUid: remoteUid ?? this.remoteUid,
      error: error,
      microphoneEnabled:
          microphoneEnabled ?? this.microphoneEnabled,
      cameraEnabled:
          cameraEnabled ?? this.cameraEnabled,
    );
  }
}