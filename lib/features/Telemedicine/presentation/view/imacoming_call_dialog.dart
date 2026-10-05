import 'package:flutter/material.dart';
import 'video_consultation_screen.dart';
import 'audio_consultation_screen.dart';

class IncomingCallDialog extends StatelessWidget {
  final String channelName;
  final String callerName;
  final String callType; // 'video' or 'audio'

  const IncomingCallDialog({
    super.key,
    required this.channelName,
    required this.callerName,
    required this.callType,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = callType == 'video';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                isVideo ? Icons.videocam : Icons.phone,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Incoming ${isVideo ? 'Video' : 'Audio'} Call",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              callerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.call_end),
                  label: const Text("Decline"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                // Accept Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(isVideo ? Icons.videocam : Icons.call),
                  label: const Text("Accept"),
                  onPressed: () {
                    Navigator.pop(context); // close dialog

                    // Navigate to the Call Screen
                    if (isVideo) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoConsultationScreen(
                            channelName: channelName,
                            doctorName: callerName,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AudioConsultationScreen(
                            channelName: channelName,
                            doctorName: callerName,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}