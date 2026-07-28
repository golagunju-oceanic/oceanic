import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/viewmodel/telemedicine_viewmodel.dart';

class AudioConsultationScreen extends ConsumerStatefulWidget {
  final String channelName;

  const AudioConsultationScreen({super.key, required this.channelName});

  @override
  ConsumerState<AudioConsultationScreen> createState() =>
      _AudioConsultationScreenState();
}

class _AudioConsultationScreenState
    extends ConsumerState<AudioConsultationScreen>
    with SingleTickerProviderStateMixin {
  late final TelemedicineViewModel _viewModel;
  late final AnimationController _pulseController;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _wasConnected = false;

  @override
  void initState() {
    super.initState();

    _viewModel = ref.read(telemedicineProvider.notifier);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    Future.microtask(() {
      _viewModel.joinAudioConsultation(
        uid: Random().nextInt(1000) * 1,
        channel: widget.channelName,
      );
    });
  }

  void _startTimerIfNeeded(bool connected) {
    if (connected && !_wasConnected) {
      _wasConnected = true;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _viewModel.leaveConsultation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(telemedicineProvider);
    final vm = ref.read(telemedicineProvider.notifier);
    final theme = Theme.of(context);
    final connected = state.remoteUid != null;

    _startTimerIfNeeded(connected);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              connected ? 'Consultation in progress' : 'Connecting',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            if (connected)
              Text(
                _formatDuration(_elapsed),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const Spacer(),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = connected
                    ? 1.0
                    : 1.0 + (_pulseController.value * 0.08);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 24,
                      spreadRadius: connected ? 0 : 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              connected ? 'Doctor connected' : 'Waiting for doctor',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: state.microphoneEnabled ? Icons.mic : Icons.mic_off,
                    label: state.microphoneEnabled ? 'Mute' : 'Unmute',
                    onPressed: vm.toggleMicrophone,
                    background: theme.colorScheme.surfaceContainerHighest,
                    foreground: theme.colorScheme.onSurface,
                  ),
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
              child: Icon(icon, color: foreground, size: size * 0.42),
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
