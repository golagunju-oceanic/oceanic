// import 'dart:async';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oceanic/features/Telemedicine/domain/entities/telemedicine_entities.dart';
// import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_booking_provider.dart';
// import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_ui.dart';
// import 'package:permission_handler/permission_handler.dart';



// /// Shared by the patient's and doctor's appointment details screens.
// /// Credentials MUST come from POST /telemedicine/appointments/:id/join.
// /// Do not pass a channel, Agora UID, or token created in Flutter.
// class AppointmentCallScreen extends ConsumerStatefulWidget {
//   const AppointmentCallScreen({
//     super.key,
//     required this.session,
//     this.participantLabel = 'Other participant',
//   });

//   final TelemedicineAgoraSession session;
//   final String participantLabel;

//   @override
//   ConsumerState<AppointmentCallScreen> createState() =>
//       _AppointmentCallScreenState();
// }

// class _AppointmentCallScreenState extends ConsumerState<AppointmentCallScreen>
//     with WidgetsBindingObserver {
//   static const _navy = Color(0xFF101A36);
//   static const _teal = Color(0xFF55C7BB);

//   RtcEngine? _engine;
//   late TelemedicineAgoraSession _session;
//   Timer? _endTimer;
//   Timer? _renewTimer;
//   Timer? _clockTimer;

//   int? _remoteUid;
//   DateTime? _connectedAt;
//   bool _joined = false;
//   bool _micOn = true;
//   bool _cameraOn = false;
//   bool _speakerOn = true;
//   bool _renewing = false;
//   bool _closing = false;
//   String? _error;

//   bool get _isVideo => _session.isVideo;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _session = widget.session;
//     _cameraOn = _session.isVideo;
//     // Audio calls default to the earpiece, video calls to the loudspeaker.
//     _speakerOn = _session.isVideo;
//     _scheduleEnd();
//     _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted && !_closing) setState(() {});
//     });
//     unawaited(_connect());
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed && !_closing) {
//       if (!DateTime.now().toUtc().isBefore(_session.callEndsAt)) {
//         unawaited(_hangUp());
//       }
//     }
//   }

//   void _scheduleEnd() {
//     _endTimer?.cancel();
//     final remaining = _session.callEndsAt.difference(DateTime.now().toUtc());
//     if (remaining <= Duration.zero) {
//       // Avoid popping during initState/build.
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) unawaited(_hangUp());
//       });
//     } else {
//       _endTimer = Timer(remaining, () => unawaited(_hangUp()));
//     }
//   }

//   void _scheduleRenewal() {
//     _renewTimer?.cancel();
//     if (_session.expiresIn <= 90 || _closing) return;
//     _renewTimer = Timer(
//       Duration(seconds: _session.expiresIn - 60),
//       () => unawaited(_renewToken()),
//     );
//   }

//   Future<void> _connect() async {
//     try {
//       if (!DateTime.now().toUtc().isBefore(_session.callEndsAt)) {
//         throw StateError('The scheduled consultation has ended.');
//       }

//       final microphone = await Permission.microphone.request();
//       if (!microphone.isGranted) {
//         throw StateError('Please allow microphone access to make this call.');
//       }
//       if (_isVideo) {
//         final camera = await Permission.camera.request();
//         if (!camera.isGranted) {
//           throw StateError('Please allow camera access for a video consultation.');
//         }
//       }
//       if (!mounted || _closing) return;

//       final rtc = createAgoraRtcEngine();
//       _engine = rtc;
//       await rtc.initialize(RtcEngineContext(
//         appId: _session.appId,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ));
//       if (!mounted || _closing) return;

//       rtc.registerEventHandler(RtcEngineEventHandler(
//         onJoinChannelSuccess: (_, __) {
//           if (!mounted || _closing) return;
//           setState(() {
//             _joined = true;
//             _connectedAt ??= DateTime.now();
//           });
//           unawaited(rtc.setEnableSpeakerphone(_speakerOn));
//         },
//         onUserJoined: (_, remoteUid, __) {
//           if (mounted && !_closing) setState(() => _remoteUid = remoteUid);
//         },
//         onUserOffline: (_, remoteUid, __) {
//           if (mounted && !_closing && _remoteUid == remoteUid) {
//             setState(() => _remoteUid = null);
//           }
//         },
//         onTokenPrivilegeWillExpire: (_, __) => unawaited(_renewToken()),
//         onError: (code, message) {
//           if (mounted && !_closing) {
//             setState(() => _error = 'Agora connection error ($code): $message');
//           }
//         },
//       ));

//       await rtc.enableAudio();
//       if (_isVideo) {
//         await rtc.enableVideo();
//         await rtc.startPreview();
//       }
//       if (!mounted || _closing) return;

//       await rtc.joinChannel(
//         token: _session.token,
//         channelId: _session.channel,
//         uid: _session.uid,
//         options: ChannelMediaOptions(
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//           publishMicrophoneTrack: true,
//           publishCameraTrack: _isVideo,
//           autoSubscribeAudio: true,
//           autoSubscribeVideo: _isVideo,
//         ),
//       );
//       _scheduleRenewal();
//     } catch (cause) {
//       if (mounted && !_closing) {
//         setState(() => _error = readableTelemedicineError(cause));
//       }
//     }
//   }

//   Future<void> _renewToken() async {
//     if (_renewing || _closing || !mounted) return;
//     _renewing = true;
//     try {
//       // Both roles use this same authenticated endpoint. The JWT determines
//       // whether the caller is the doctor or patient; the backend checks access.
//       final next = await ref.read(joinTelemedicineAppointmentUseCaseProvider)(
//         _session.appointmentId,
//       );
//       if (next.appId != _session.appId ||
//           next.channel != _session.channel ||
//           next.uid != _session.uid ||
//           next.appointmentType != _session.appointmentType) {
//         throw StateError('Consultation identity changed. Please rejoin.');
//       }
//       if (!mounted || _closing) return;
//       await _engine?.renewToken(next.token);
//       _session = next;
//       _scheduleEnd();
//       _scheduleRenewal();
//     } catch (cause) {
//       if (mounted && !_closing) {
//         setState(() => _error = readableTelemedicineError(cause));
//         // Do not keep an apparently active clinical call when authorization
//         // can no longer be renewed. Existing RTC tokens may outlive this UI.
//         await _hangUp();
//       }
//     } finally {
//       _renewing = false;
//     }
//   }

//   Future<void> _toggleMic() async {
//     final next = !_micOn;
//     try {
//       await _engine?.muteLocalAudioStream(!next);
//       if (mounted) setState(() => _micOn = next);
//     } catch (cause) {
//       _report(cause);
//     }
//   }

//   Future<void> _toggleCamera() async {
//     if (!_isVideo) return;
//     final next = !_cameraOn;
//     try {
//       await _engine?.muteLocalVideoStream(!next);
//       if (mounted) setState(() => _cameraOn = next);
//     } catch (cause) {
//       _report(cause);
//     }
//   }

//   Future<void> _switchCamera() async {
//     if (!_isVideo) return;
//     try {
//       await _engine?.switchCamera();
//     } catch (cause) {
//       _report(cause);
//     }
//   }

//   Future<void> _toggleSpeaker() async {
//     final next = !_speakerOn;
//     try {
//       await _engine?.setEnableSpeakerphone(next);
//       if (mounted) setState(() => _speakerOn = next);
//     } catch (cause) {
//       _report(cause);
//     }
//   }

//   void _report(Object error) {
//     if (mounted && !_closing) {
//       setState(() => _error = readableTelemedicineError(error));
//     }
//   }

//   Future<void> _hangUp() async {
//     if (_closing) return;
//     _closing = true;
//     _endTimer?.cancel();
//     _renewTimer?.cancel();
//     _clockTimer?.cancel();
//     final rtc = _engine;
//     _engine = null;
//     if (rtc != null) {
//       try {
//         await rtc.leaveChannel();
//       } catch (_) {}
//       try {
//         await rtc.release();
//       } catch (_) {}
//     }
//     if (mounted) Navigator.of(context).pop();
//     // Hang up ends this participant's media session, not the clinical
//     // appointment. The doctor completes the appointment separately.
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _endTimer?.cancel();
//     _renewTimer?.cancel();
//     _clockTimer?.cancel();
//     final rtc = _engine;
//     _engine = null;
//     if (rtc != null) {
//       unawaited(() async {
//         try {
//           await rtc.leaveChannel();
//         } catch (_) {}
//         try {
//           await rtc.release();
//         } catch (_) {}
//       }());
//     }
//     super.dispose();
//   }

//   String _elapsed() {
//     if (_connectedAt == null) return '00:00';
//     final seconds = DateTime.now().difference(_connectedAt!).inSeconds;
//     final minutes = seconds ~/ 60;
//     final remainder = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
//   }

//   Widget _pill(String label, IconData icon) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha: 0.10),
//           borderRadius: BorderRadius.circular(40),
//         ),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon, color: _teal, size: 14),
//           const SizedBox(width: 6),
//           Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
//         ]),
//       );

//   Widget _participantPlaceholder({required bool video}) => Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Container(
//             width: video ? 88 : 140,
//             height: video ? 88 : 140,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: _teal.withValues(alpha: .10),
//               border: Border.all(color: _teal.withValues(alpha: .35), width: 2),
//             ),
//             child: Icon(
//               video ? Icons.person_rounded : Icons.headset_mic_rounded,
//               color: _teal,
//               size: video ? 48 : 72,
//             ),
//           ),
//           const SizedBox(height: 22),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               widget.participantLabel,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             !_joined
//                 ? 'Connecting to consultation…'
//                 : _remoteUid == null
//                     ? 'Waiting for the other participant…'
//                     : video
//                         ? 'Camera is not available'
//                         : 'Audio call connected',
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white70, fontSize: 13),
//           ),
//         ]),
//       );

//   Widget _control({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool selected = false,
//     bool isEnd = false,
//   }) => Column(mainAxisSize: MainAxisSize.min, children: [
//         IconButton.filled(
//           onPressed: _closing ? null : onTap,
//           icon: Icon(icon, size: 23),
//           style: IconButton.styleFrom(
//             backgroundColor: isEnd
//                 ? const Color(0xFFE54D61)
//                 : selected
//                     ? _teal
//                     : Colors.white.withValues(alpha: .14),
//             foregroundColor: selected ? _navy : Colors.white,
//             disabledBackgroundColor: Colors.white24,
//             minimumSize: const Size(52, 52),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
//       ]);

//   @override
//   Widget build(BuildContext context) {
//     final rtc = _engine;
//     final isVideo = _isVideo;
//     final hasRemote = _remoteUid != null && rtc != null;
//     // Back navigation also triggers dispose(), which releases Agora media.
//     return PopScope(
//       canPop: true,
//       child: Scaffold(
//         backgroundColor: _navy,
//         body: SafeArea(
//           child: Column(children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
//               child: Row(children: [
//                 Icon(isVideo ? Icons.videocam_rounded : Icons.call_rounded,
//                     color: _teal, size: 23),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(isVideo ? 'Video consultation' : 'Audio consultation',
//                         style: const TextStyle(color: Colors.white,
//                             fontSize: 17, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 3),
//                     const Text('Oceanic Tele-Health',
//                         style: TextStyle(color: Colors.white60, fontSize: 11)),
//                   ]),
//                 ),
//                 _pill(_joined ? _elapsed() : 'Connecting', Icons.lock_outline_rounded),
//               ]),
//             ),
//             Expanded(
//               child: Stack(children: [
//                 Positioned.fill(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(22),
//                     child: isVideo && hasRemote
//                         ? AgoraVideoView(
//                             controller: VideoViewController.remote(
//                               rtcEngine: rtc,
//                               canvas: VideoCanvas(uid: _remoteUid),
//                               connection: RtcConnection(channelId: _session.channel),
//                             ),
//                           )
//                         : _participantPlaceholder(video: isVideo),
//                   ),
//                 ),
//                 if (isVideo && rtc != null && _joined)
//                   Positioned(
//                     right: 18,
//                     top: 22,
//                     width: 112,
//                     height: 156,
//                     child: Container(
//                       clipBehavior: Clip.antiAlias,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF263451),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.white24),
//                       ),
//                       child: _cameraOn
//                           ? AgoraVideoView(
//                               controller: VideoViewController(
//                                 rtcEngine: rtc,
//                                 canvas: const VideoCanvas(uid: 0),
//                               ),
//                             )
//                           : const Icon(Icons.videocam_off_rounded,
//                               color: Colors.white70, size: 34),
//                     ),
//                   ),
//                 if (_error != null)
//                   Positioned(
//                     top: isVideo ? 190 : 8,
//                     left: 14,
//                     right: 14,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF713744),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(children: [
//                         const Icon(Icons.warning_amber_rounded,
//                             color: Colors.white, size: 20),
//                         const SizedBox(width: 8),
//                         Expanded(child: Text(_error!,
//                             style: const TextStyle(color: Colors.white, fontSize: 12))),
//                         IconButton(onPressed: () => unawaited(_hangUp()),
//                             icon: const Icon(Icons.close, color: Colors.white, size: 18)),
//                       ]),
//                     ),
//                   ),
//               ]),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
//               child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//                 _control(
//                   icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
//                   label: _micOn ? 'Mute' : 'Unmute',
//                   onTap: () => unawaited(_toggleMic()),
//                   selected: !_micOn,
//                 ),
//                 if (isVideo) ...[
//                   _control(
//                     icon: _cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
//                     label: _cameraOn ? 'Video off' : 'Video on',
//                     onTap: () => unawaited(_toggleCamera()),
//                     selected: !_cameraOn,
//                   ),
//                   _control(
//                     icon: Icons.cameraswitch_rounded,
//                     label: 'Flip',
//                     onTap: () => unawaited(_switchCamera()),
//                   ),
//                 ],
//                 _control(
//                   icon: _speakerOn ? Icons.volume_up_rounded : Icons.hearing_rounded,
//                   label: _speakerOn ? 'Speaker' : 'Earpiece',
//                   onTap: () => unawaited(_toggleSpeaker()),
//                   selected: _speakerOn,
//                 ),
//                 _control(
//                   icon: Icons.call_end_rounded,
//                   label: 'End',
//                   isEnd: true,
//                   onTap: () => unawaited(_hangUp()),
//                 ),
//               ]),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }
