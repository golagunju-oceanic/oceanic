import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../state/telemedicine_state.dart';
import '../viewmodel/telemedicine_viewmodel.dart';

class ConnectedCallScreen extends StatelessWidget {
  final TelemedicineViewModel viewModel;
  final bool isVideo;

  const ConnectedCallScreen({
    Key? key,
    required this.viewModel,
    this.isVideo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;

        if (state.status == TelemedicineCallStatus.callEnded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // 1. Remote View or Status Text
                if (isVideo &&
                    state.remoteUid != null &&
                    viewModel.engine != null)
                  AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: viewModel.engine!,
                      canvas: VideoCanvas(uid: state.remoteUid),
                      connection: const RtcConnection(channelId: ""),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.status == TelemedicineCallStatus.ringing ||
                              state.status == TelemedicineCallStatus.connecting)
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          const SizedBox(height: 16),
                          Text(
                            state.statusMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2. Local Preview Thumbnail (Top Right)
                if (isVideo &&
                    state.isJoined &&
                    !state.isVideoDisabled &&
                    viewModel.engine != null)
                  Positioned(
                    top: 20,
                    right: 20,
                    width: 110,
                    height: 155,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: viewModel.engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),

                // 3. Call Controls
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 32,
                        color: Colors.white,
                        icon: Icon(state.isMuted ? Icons.mic_off : Icons.mic),
                        onPressed: viewModel.toggleMute,
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.redAccent,
                        onPressed: viewModel.endCall,
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      if (isVideo)
                        IconButton(
                          iconSize: 32,
                          color: Colors.white,
                          icon: Icon(
                            state.isVideoDisabled
                                ? Icons.videocam_off
                                : Icons.videocam,
                          ),
                          onPressed: viewModel.toggleVideo,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
