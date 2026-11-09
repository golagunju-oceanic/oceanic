import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:oceanic/features/Telemedicine/domain/usecase/telemedicine_booking_usecase.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/telemedicine_state.dart';

class TelemedicineViewModel extends ChangeNotifier {
  final TelemedicineUseCase _useCase;

  TelemedicineViewModel(this._useCase);

  TelemedicineState _state = TelemedicineState();
  TelemedicineState get state => _state;

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  Timer? _pollingTimer;

  /// Patient starts ringing the doctor for a booked appointment
  Future<void> initiatePatientCall({
    required String appointmentId,
    required bool isVideo,
  }) async {
    _updateState(
      _state.copyWith(
        status: TelemedicineCallStatus.ringing,
        statusMessage: 'Ringing doctor...',
      ),
    );

    try {
      final session = await _useCase.ring(appointmentId);
      _updateState(_state.copyWith(callId: session.callId));

      if (session.status == 'ACCEPTED') {
        await _connectAgora(session.callId, isVideo);
      } else {
        _pollCallAcceptance(session.callId, isVideo);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Doctor answers or direct join when accepted
  Future<void> answerAndJoin({
    required String callId,
    required bool isVideo,
    bool isDoctor = false,
  }) async {
    _updateState(
      _state.copyWith(
        callId: callId,
        status: TelemedicineCallStatus.connecting,
        statusMessage: 'Connecting...',
      ),
    );

    try {
      if (isDoctor) {
        await _useCase.answer(callId, accept: true);
      }
      await _connectAgora(callId, isVideo);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _pollCallAcceptance(String callId, bool isVideo) {
    int attempts = 0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;
      if (attempts > 22) {
        // 45 seconds timeout
        timer.cancel();
        _setError('No answer from doctor. Please try again.');
        return;
      }

      try {
        final current = await _useCase.getStatus(callId);
        if (current.status == 'ACCEPTED') {
          timer.cancel();
          await _connectAgora(callId, isVideo);
        } else if (current.status == 'DECLINED' || current.status == 'MISSED') {
          timer.cancel();
          _setError('Doctor is currently unavailable.');
        }
      } catch (e) {
        timer.cancel();
        _setError('Connection lost while ringing.');
      }
    });
  }

  Future<void> _connectAgora(String callId, bool isVideo) async {
    _updateState(
      _state.copyWith(
        status: TelemedicineCallStatus.connecting,
        statusMessage: 'Entering room...',
      ),
    );

    // Request permissions
    await [Permission.microphone, if (isVideo) Permission.camera].request();

    try {
      final creds = await _useCase.join(callId);

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: creds.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _registerAgoraEvents();

      if (creds.isVideo) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
      }

      // CRITICAL: Must use creds.uid (1001 for doctor, 2001 for patient)
      await _engine!.joinChannel(
        token: creds.token,
        channelId: creds.channel,
        uid: creds.uid,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: creds.isVideo,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: creds.isVideo,
        ),
      );
    } catch (e) {
      _setError('Failed to connect Agora: $e');
    }
  }

  void _registerAgoraEvents() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _updateState(
            _state.copyWith(
              status: TelemedicineCallStatus.connected,
              isJoined: true,
              statusMessage: 'Connected. Waiting for other party...',
            ),
          );
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _updateState(
            _state.copyWith(
              remoteUid: remoteUid,
              statusMessage: 'In consultation',
            ),
          );
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              _updateState(
                _state.copyWith(
                  remoteUid: null,
                  statusMessage: 'The other party disconnected',
                ),
              );
            },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora Error: $err - $msg');
          if (err == ErrorCodeType.errInvalidToken ||
              err == ErrorCodeType.errTokenExpired) {
            _setError('Session token invalid or expired.');
          }
        },
      ),
    );
  }

  void toggleMute() {
    final newMute = !_state.isMuted;
    _engine?.muteLocalAudioStream(newMute);
    _updateState(_state.copyWith(isMuted: newMute));
  }

  void toggleVideo() {
    final newVideoDisabled = !_state.isVideoDisabled;
    _engine?.muteLocalVideoStream(newVideoDisabled);
    _updateState(_state.copyWith(isVideoDisabled: newVideoDisabled));
  }

  Future<void> endCall() async {
    _pollingTimer?.cancel();
    if (_state.callId != null) {
      try {
        await _useCase.end(_state.callId!);
      } catch (_) {}
    }
    await _disposeAgora();
    _updateState(
      _state.copyWith(
        status: TelemedicineCallStatus.callEnded,
        statusMessage: 'Call ended',
      ),
    );
  }

  Future<void> _disposeAgora() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    _engine = null;
  }

  void _updateState(TelemedicineState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String msg) {
    _updateState(
      _state.copyWith(
        status: TelemedicineCallStatus.error,
        errorMessage: msg,
        statusMessage: msg,
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _disposeAgora();
    super.dispose();
  }
}
