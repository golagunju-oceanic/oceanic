import 'package:flutter/material.dart';

class TelemedicineAlertDialog {
  Future<bool> showTelemedicineConsentDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Telemedicine Consultation"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "To provide a secure video consultation, Oceanic Health requires access to:",
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.videocam_outlined),
                  SizedBox(width: 8),
                  Expanded(child: Text("Your camera")),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.mic_outlined),
                  SizedBox(width: 8),
                  Expanded(child: Text("Your microphone")),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Your audio and video are used only during your consultation with your healthcare provider. Oceanic Health does not record or store your consultation unless you are informed and have provided consent.",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Not Now"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
