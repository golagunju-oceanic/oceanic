import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/domain/usecase/telemedicine_booking_usecase.dart';
import 'package:oceanic/features/Telemedicine/presentation/screens/incoming_call_screen%20(1)%20(3).dart';
import '../viewmodel/telemedicine_viewmodel.dart';

class CallInboxListener extends StatefulWidget {
  final Widget child;
  final TelemedicineUseCase useCase;
  final TelemedicineViewModel viewModel;

  const CallInboxListener({
    Key? key,
    required this.child,
    required this.useCase,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<CallInboxListener> createState() => _CallInboxListenerState();
}

class _CallInboxListenerState extends State<CallInboxListener> {
  Timer? _checkTimer;
  bool _isPromptShowing = false;

  @override
  void initState() {
    super.initState();
    // Poll for incoming calls every 4 seconds for online doctors
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
  }

  Future<void> _check() async {
    if (_isPromptShowing) return;
    try {
      final incoming = await widget.useCase.checkIncoming();
      if (incoming != null && incoming.status == 'RINGING') {
        _isPromptShowing = true;
        if (!mounted) return;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              viewModel: widget.viewModel,
              callId: incoming.callId,
              isVideo: incoming.callType == 'VIDEO',
            ),
          ),
        );
        _isPromptShowing = false;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
