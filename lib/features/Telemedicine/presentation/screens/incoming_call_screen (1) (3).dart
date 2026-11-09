import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/screens/connected_call_screen%20(1).dart';
import '../viewmodel/telemedicine_viewmodel.dart';

class IncomingCallScreen extends StatelessWidget {
  final TelemedicineViewModel viewModel;
  final String callId;
  final bool isVideo;

  const IncomingCallScreen({
    super.key,
    required this.viewModel,
    required this.callId,
    this.isVideo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Incoming Consultation",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isVideo ? "Video Consultation" : "Audio Consultation",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "decline",
                    backgroundColor: Colors.red,
                    onPressed: () {
                      viewModel.endCall();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: "accept",
                    backgroundColor: Colors.green,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ConnectedCallScreen(
                            viewModel: viewModel,
                            isVideo: isVideo,
                          ),
                        ),
                      );
                      viewModel.answerAndJoin(
                        callId: callId,
                        isVideo: isVideo,
                        isDoctor: true,
                      );
                    },
                    child: const Icon(Icons.call, color: Colors.white),
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
