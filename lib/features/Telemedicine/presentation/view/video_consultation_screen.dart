import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_provider.dart';
import 'package:oceanic/features/Telemedicine/presentation/state/telemedicine_state.dart';
import 'package:oceanic/features/Telemedicine/presentation/viewmodel/telemedicine_viewmodel.dart';

class VideoConsultationScreen extends ConsumerStatefulWidget {
  /// Provide either doctorId (to initiate call) OR channelName (to join existing call)
  final String? doctorId;
  final String? channelName;
  final String doctorName;

  const VideoConsultationScreen({
    super.key,
    this.doctorId,
    this.channelName,
    this.doctorName = "Doctor",
  }) : assert(
          doctorId != null || channelName != null,
          'Either doctorId or channelName must be provided',
        );

  @override
  ConsumerState<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState
    extends ConsumerState<VideoConsultationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(telemedicineProvider.notifier);

      if (widget.doctorId != null) {
        // Enrollee starting the call
        vm.startOutgoingCall(
          doctorId: widget.doctorId!,
          isVideo: true,
        );
      } else if (widget.channelName != null) {
        // Joining existing call
        vm.joinExistingCall(
          channel: widget.channelName!,
          isVideo: true,
        );
      }
    });
  }

  @override
  void dispose() {
    ref.read(telemedicineProvider.notifier).leaveConsultation();
    super.dispose();
  }

  void _onDoctorDisconnected() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Call ended by doctor")),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(telemedicineProvider);
    final vm = ref.read(telemedicineProvider.notifier);

    // Listen for doctor leaving
    ref.listen<TelemedicineState>(telemedicineProvider, (prev, next) {
      if (prev?.remoteUid != null && next.remoteUid == null) {
        _onDoctorDisconnected();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await vm.leaveConsultation();
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Remote Video (Full Screen)
            _buildRemoteVideo(state, vm),

            // 2. Doctor Name & Status Bar (Top Left)
            Positioned(
              top: 50,
              left: 20,
              child: SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.remoteUid != null
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.remoteUid != null
                            ? widget.doctorName
                            : "Connecting...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Local Video Preview (Floating PIP, Top Right)
            Positioned(
              top: 50,
              right: 16,
              child: SafeArea(
                child: _buildLocalVideo(state, vm),
              ),
            ),

            // 4. Loading Overlay
            if (state.isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // 5. Error Message Overlay
            if (state.error != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),

            // 6. Action Control Bar (Bottom)
            Positioned(
              bottom: 36,
              left: 20,
              right: 20,
              child: SafeArea(
                child: _buildControls(vm, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo(TelemedicineState state, TelemedicineViewModel vm) {
    if (!state.localUserJoined || vm.engine == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.remoteUid == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              "Waiting for ${widget.doctorName}...",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final channelId = widget.channelName ?? state.channel ?? "";

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: vm.engine!,
        canvas: VideoCanvas(uid: state.remoteUid),
        connection: RtcConnection(channelId: channelId),
      ),
    );
  }

  Widget _buildLocalVideo(TelemedicineState state, TelemedicineViewModel vm) {
    if (!state.localUserJoined || vm.engine == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        height: 160,
        color: Colors.grey[900],
        child: state.cameraEnabled
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: vm.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : const Center(
                child: Icon(Icons.videocam_off, color: Colors.white54, size: 32),
              ),
      ),
    );
  }

  Widget _buildControls(TelemedicineViewModel vm, TelemedicineState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Toggle Mic
          _circleButton(
            icon: state.microphoneEnabled ? Icons.mic : Icons.mic_off,
            color: state.microphoneEnabled ? Colors.white24 : Colors.redAccent,
            onTap: vm.toggleMicrophone,
          ),

          // Toggle Camera
          _circleButton(
            icon: state.cameraEnabled ? Icons.videocam : Icons.videocam_off,
            color: state.cameraEnabled ? Colors.white24 : Colors.redAccent,
            onTap: vm.toggleCamera,
          ),

          // Switch Front/Back Camera
          _circleButton(
            icon: Icons.cameraswitch,
            color: Colors.white24,
            onTap: state.cameraEnabled ? vm.switchCamera : () {},
          ),

          // End Call
          _circleButton(
            color: Colors.red,
            icon: Icons.call_end,
            onTap: () async {
              await vm.leaveConsultation();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
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
        radius: 26,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}