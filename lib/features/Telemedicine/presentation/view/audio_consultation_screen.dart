import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_provider.dart';
import 'package:oceanic/features/Telemedicine/presentation/state/telemedicine_state.dart';

class AudioConsultationScreen extends ConsumerStatefulWidget {
  /// Pass either channelName (if joining an existing call) OR doctorId (if initiating)
  final String? channelName;
  final String? doctorId;
  final String doctorName;
  final String? doctorPhotoUrl;

  const AudioConsultationScreen({
    super.key,
    this.channelName,
    this.doctorId,
    this.doctorName = "Doctor",
    this.doctorPhotoUrl,
  }) : assert(
         channelName != null || doctorId != null,
         'Either channelName or doctorId must be provided',
       );

  @override
  ConsumerState<AudioConsultationScreen> createState() =>
      _AudioConsultationScreenState();
}

class _AudioConsultationScreenState
    extends ConsumerState<AudioConsultationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _speakerOn = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize call safely after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(telemedicineProvider.notifier);

      if (widget.doctorId != null) {
        // Enrollee initiating call to doctor
        vm.startOutgoingCall(doctorId: widget.doctorId!, isVideo: false);
      } else if (widget.channelName != null) {
        // Joining existing call channel
        vm.joinExistingCall(channel: widget.channelName!, isVideo: false);
      }
    });
  }

  void _onConnected() {
    _pulseController.stop();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  void _onDisconnected() {
    _timer?.cancel();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Call ended")));
      Navigator.of(context).pop();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    // Leave Agora channel and release hardware
    ref.read(telemedicineProvider.notifier).leaveConsultation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(telemedicineProvider);
    final vm = ref.read(telemedicineProvider.notifier);
    final theme = Theme.of(context);
    final isConnected = state.remoteUid != null;

    // Listen to connection changes without triggering rebuild loops
    ref.listen<TelemedicineState>(telemedicineProvider, (prev, next) {
      // Remote user joined
      if (prev?.remoteUid == null && next.remoteUid != null) {
        _onConnected();
      }
      // Remote user left after being connected
      if (prev?.remoteUid != null && next.remoteUid == null) {
        _onDisconnected();
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
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 30),
            onPressed: () async {
              await vm.leaveConsultation();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                isConnected ? 'Consultation in progress' : 'Connecting...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isConnected ? _formatDuration(_elapsed) : "Ringing",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isConnected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),

              // Pulsing Avatar
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = isConnected
                      ? 1.0
                      : 1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 28,
                        spreadRadius: isConnected ? 0 : 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.doctorPhotoUrl != null
                        ? Image.network(
                            widget.doctorPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 80),
                          )
                        : Icon(
                            Icons.person,
                            size: 80,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                widget.doctorName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isConnected ? "Connected" : "Waiting for response...",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),
              if (state.isLoading)
                const CircularProgressIndicator()
              else if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),

              const Spacer(flex: 2),

              // Control Buttons Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute / Unmute
                    _ControlButton(
                      icon: state.microphoneEnabled ? Icons.mic : Icons.mic_off,
                      label: state.microphoneEnabled ? 'Mute' : 'Unmute',
                      onPressed: vm.toggleMicrophone,
                      background: state.microphoneEnabled
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.errorContainer,
                      foreground: state.microphoneEnabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onErrorContainer,
                    ),

                    // Speakerphone toggle
                    _ControlButton(
                      icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                      label: _speakerOn ? 'Speaker' : 'Earpiece',
                      onPressed: () {
                        setState(() => _speakerOn = !_speakerOn);
                        vm.engine?.setEnableSpeakerphone(_speakerOn);
                      },
                      background: _speakerOn
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      foreground: _speakerOn
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),

                    // End Call
                    _ControlButton(
                      icon: Icons.call_end,
                      label: 'End',
                      onPressed: () async {
                        await vm.leaveConsultation();
                        if (context.mounted) Navigator.pop(context);
                      },
                      background: theme.colorScheme.error,
                      foreground: theme.colorScheme.onError,
                      size: 68,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: foreground, size: size * 0.44),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
