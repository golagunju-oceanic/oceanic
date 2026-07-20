import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/state/telemedicine_state.dart';
import 'package:oceanic/features/Telemedicine/presentation/viewmodel/telemedicine_viewmodel.dart';
import '../provider/telemedicine_provider.dart';

class VideoConsultationScreen extends ConsumerStatefulWidget {
  const VideoConsultationScreen({super.key, required this.channelName});

  final String channelName;

  @override
  ConsumerState<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState
    extends ConsumerState<VideoConsultationScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      debugPrint("Channel: '${widget.channelName}'");

      ref
          .read(telemedicineProvider.notifier)
          .joinConsultation(channel: widget.channelName, uid: 1);
    });
  }

  @override
  void dispose() {
    ref.read(telemedicineProvider.notifier).leaveConsultation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(telemedicineProvider);
    final vm = ref.read(telemedicineProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildRemoteVideo(state, vm),

          Positioned(top: 60, right: 16, child: _buildLocalVideo(state, vm)),

          if (state.isLoading) const Center(child: CircularProgressIndicator()),

          if (state.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildControls(vm, state),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo(TelemedicineState state, vm) {
    if (!state.localUserJoined) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.remoteUid == null) {
      return const Center(
        child: Text(
          "Waiting for doctor...",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: vm.engine,
        canvas: VideoCanvas(uid: state.remoteUid),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  Widget _buildLocalVideo(TelemedicineState state, TelemedicineViewModel vm) {
    if (!state.localUserJoined) {
      return const SizedBox();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 120,
        height: 180,
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: vm.engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(TelemedicineViewModel vm, TelemedicineState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleButton(
          icon: state.microphoneEnabled ? Icons.mic : Icons.mic_off,
          onTap: vm.toggleMicrophone,
        ),
        _circleButton(
          icon: state.cameraEnabled ? Icons.videocam : Icons.videocam_off,
          onTap: vm.toggleCamera,
        ),
        _circleButton(icon: Icons.cameraswitch, onTap: vm.switchCamera),
        _circleButton(
          color: Colors.red,
          icon: Icons.call_end,
          onTap: () async {
            await vm.leaveConsultation();

            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white24,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
