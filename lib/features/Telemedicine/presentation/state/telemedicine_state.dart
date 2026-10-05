class TelemedicineState {
  final bool isLoading;
  final String? error;
  final bool localUserJoined;
  final int? remoteUid;
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final String? channel;

  const TelemedicineState({
    required this.isLoading,
    this.error,
    required this.localUserJoined,
    this.remoteUid,
    required this.microphoneEnabled,
    required this.cameraEnabled,
    this.channel,
  });

  /// Initial state when entering the screen
  factory TelemedicineState.initial() {
    return const TelemedicineState(
      isLoading: false,
      error: null,
      localUserJoined: false,
      remoteUid: null,
      microphoneEnabled: true,
      cameraEnabled: true,
      channel: null,
    );
  }

  /// Copy helper to update state immutably
  TelemedicineState copyWith({
    bool? isLoading,
    String? error,
    bool? localUserJoined,
    int? remoteUid,
    bool? microphoneEnabled,
    bool? cameraEnabled,
    String? channel,
  }) {
    return TelemedicineState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      localUserJoined: localUserJoined ?? this.localUserJoined,
      remoteUid: remoteUid ?? this.remoteUid,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      channel: channel ?? this.channel,
    );
  }
}
