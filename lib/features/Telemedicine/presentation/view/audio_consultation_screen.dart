import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_provider.dart';
import 'package:flutter/material.dart';

class AudioConsultationScreen extends ConsumerStatefulWidget {
  final String channelName;

  const AudioConsultationScreen({
    super.key,
    required this.channelName,
  });

  @override
  ConsumerState<AudioConsultationScreen> createState() =>
      _AudioConsultationScreenState();
}

class _AudioConsultationScreenState extends ConsumerState<AudioConsultationScreen>{

  @override
void initState() {
  super.initState();

  Future.microtask(() {
    ref.read(telemedicineProvider.notifier).joinAudioConsultation(
      channel: widget.channelName,
    );
  });
}

@override
Widget build(BuildContext context) {
  final state = ref.watch(telemedicineProvider);
  final vm = ref.read(telemedicineProvider.notifier);

  return Scaffold(
    appBar: AppBar(
      title: const Text("Audio Consultation"),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 55,
            child: Icon(
              Icons.person,
              size: 60,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            state.remoteUid == null
                ? "Waiting for doctor..."
                : "Connected",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (state.isLoading)
            const CircularProgressIndicator(),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
              ),
            ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: "mic",
                onPressed: vm.toggleMicrophone,
                child: Icon(
                  state.microphoneEnabled
                      ? Icons.mic
                      : Icons.mic_off,
                ),
              ),

              FloatingActionButton(
                heroTag: "hangup",
                backgroundColor: Colors.red,
                onPressed: () async {
                  await vm.leaveConsultation();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Icon(Icons.call_end),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}



}