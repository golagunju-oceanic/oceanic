import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:oceanic/features/Telemedicine/domain/usecase/telemidicine_usecase.dart';
import 'package:oceanic/features/Telemedicine/presentation/state/telemedicine_state.dart';
import 'package:permission_handler/permission_handler.dart';

class TelemedicineViewModel extends StateNotifier<TelemedicineState> {
  final GenerateTokenUseCase generateTokenUseCase;

  TelemedicineViewModel(this.generateTokenUseCase)
    : super(const TelemedicineState());

 RtcEngine? engine;

  Future<void> joinAudioConsultation({
    required String channel,
    required int uid,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      await Permission.microphone.request();

      final response = await generateTokenUseCase(channel: channel, uid: uid);

      engine = createAgoraRtcEngine();

      await engine?.initialize(
        RtcEngineContext(
          appId: response.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      engine?.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            state = state.copyWith(localUserJoined: true, isLoading: false);
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            state = state.copyWith(remoteUid: remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            state = state.copyWith(remoteUid: null);
          },
          onError: (err, msg) {
            state = state.copyWith(isLoading: false, error: msg);
          },
        ),
      );

      await engine?.enableAudio();

      await engine?.joinChannel(
        token: response.token,
        channelId: response.channel,
        uid: response.uid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          publishMicrophoneTrack: true,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> joinConsultation({
    required String channel,
    required int uid,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      await [Permission.microphone, Permission.camera].request();

      final response = await generateTokenUseCase(channel: channel, uid: Random().nextInt(1000) * 1);

      engine = createAgoraRtcEngine();

      await engine?.initialize(
        RtcEngineContext(
          appId: response.appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      engine?.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            state = state.copyWith(localUserJoined: true, isLoading: false);
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            state = state.copyWith(remoteUid: remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            state = state.copyWith(remoteUid: null);
          },
          onError: (err, msg) {
            state = state.copyWith(isLoading: false, error: msg);
          },
        ),
      );

      await engine?.enableVideo();

      await engine?.startPreview();

      await engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await engine?.joinChannel(
        token: response.token,
        channelId: response.channel,
        uid: response.uid,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> leaveConsultation() async {
    try {
    if (engine != null) {
      await engine?.leaveChannel();
      await engine?.release();
    }
  } catch (_) {}

  state = const TelemedicineState();
  }

  Future<void> toggleMicrophone() async {
    final enabled = !state.microphoneEnabled;

    await engine?.muteLocalAudioStream(!enabled);

    state = state.copyWith(microphoneEnabled: enabled);
  }

  Future<void> toggleCamera() async {
    final enabled = !state.cameraEnabled;

    await engine?.muteLocalVideoStream(!enabled);

    state = state.copyWith(cameraEnabled: enabled);
  }

  Future<void> switchCamera() async {
    await engine?.switchCamera();
  }
}
