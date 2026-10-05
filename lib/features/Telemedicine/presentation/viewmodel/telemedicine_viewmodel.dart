import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:oceanic/features/Telemedicine/domain/usecase/telemidicine_usecase.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/telemedicine_state.dart';

class TelemedicineViewModel extends StateNotifier<TelemedicineState> {
  final TelemedicineUseCase telemedicineUseCase;
  RtcEngine? engine;

  TelemedicineViewModel({
    required this.telemedicineUseCase
  }) : super(TelemedicineState.initial());

  /// 1. Outgoing call started by Enrollee/Patient
  Future<void> startOutgoingCall({
    required String doctorId,
    required bool isVideo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step A: Request permissions
      await [Permission.microphone, if (isVideo) Permission.camera].request();

      // Step B: Call backend to get channel, UID, and token
      final response = await telemedicineUseCase.initiateCall(
        doctorId: doctorId,
        callType: isVideo ? 'video' : 'audio',
      );

      // Step C: Initialize Agora engine & join
      await _initAgoraAndJoin(
        appId: response.appId,
        channel: response.channel,
        token: response.token,
        uid: response.uid, // Use EXACT UID from backend
        isVideo: isVideo,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 2. Joining an existing channel (e.g. Doctor answering)
  Future<void> joinExistingCall({
    required String channel,
    required bool isVideo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await [Permission.microphone, if (isVideo) Permission.camera].request();

      final response = await telemedicineUseCase.generateToken(channel: channel);

      await _initAgoraAndJoin(
        appId: response.appId,
        channel: response.channel,
        token: response.token,
        uid: response.uid,
        isVideo: isVideo,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _initAgoraAndJoin({
    required String appId,
    required String channel,
    required String token,
    required int uid,
    required bool isVideo,
  }) async {
    engine = createAgoraRtcEngine();
    await engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _setupEventHandlers();

    if (isVideo) {
      await engine!.enableVideo();
      await engine!.startPreview();
    } else {
      await engine!.enableAudio();
    }

    // Join channel using Agora 6.x options
    await engine!.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: isVideo,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: isVideo,
      ),
    );
  }

  void _setupEventHandlers() {
    engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          state = state.copyWith(localUserJoined: true, isLoading: false);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          state = state.copyWith(remoteUid: remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          state = state.copyWith(remoteUid: null);
        },
        onError: (ErrorCodeType err, String msg) {
          state = state.copyWith(error: "Agora error [$err]: $msg");
        },
      ),
    );
  }

  void toggleMicrophone() async {
    final nextState = !state.microphoneEnabled;
    await engine?.muteLocalAudioStream(!nextState);
    state = state.copyWith(microphoneEnabled: nextState);
  }

  void toggleCamera() async {
    final nextState = !state.cameraEnabled;
    await engine?.muteLocalVideoStream(!nextState);
    state = state.copyWith(cameraEnabled: nextState);
  }

  void switchCamera() async {
    await engine?.switchCamera();
  }

  Future<void> leaveConsultation() async {
    await engine?.leaveChannel();
    await engine?.release();
    engine = null;
    state = TelemedicineState.initial();
  }
}