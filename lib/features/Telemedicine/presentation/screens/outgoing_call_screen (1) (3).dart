import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/screens/connected_call_screen%20(1).dart';
import '../viewmodel/telemedicine_viewmodel.dart';

class OutgoingCallScreen extends StatefulWidget {
  final TelemedicineViewModel viewModel;
  final String appointmentId;
  final bool isVideo;

  const OutgoingCallScreen({
    Key? key,
    required this.viewModel,
    required this.appointmentId,
    this.isVideo = true,
  }) : super(key: key);

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initiatePatientCall(
        appointmentId: widget.appointmentId,
        isVideo: widget.isVideo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectedCallScreen(
      viewModel: widget.viewModel,
      isVideo: widget.isVideo,
    );
  }
}