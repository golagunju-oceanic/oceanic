import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/audio_consultation_screen.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/chat_consultation_screen.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/video_consultation_screen.dart';
// import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_alert_dialog.dart';
import 'package:oceanic/presentation/widgets/telemedicine_scaffold.dart';

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({super.key});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  String? _selectedMode;
  final _symptomsController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _symptomsController.addListener(
      () => setState(() => _charCount = _symptomsController.text.length),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    switch (_selectedMode) {
      case 'Chat':
        _startChatConsultation();
        break;
      case 'Phone':
        _startPhoneConsultation();
        break;
      case 'Video':
        _startVideoConsultation();
        break;
    }
  }

  void _startChatConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConsultationScreen(
          // symptoms: _symptomsController.text,
        ),
      ),
    );
  }

  void _startPhoneConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioConsultationScreen(
          channelName: "consultation-room-1",
          // symptoms: _symptomsController.text,
        ),
      ),
    );
  }

  void _startVideoConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoConsultationScreen(
          channelName: "consultation-room-1",
          // symptoms: _symptomsController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TelemedicineScaffold(
      currentStep: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details for your Doctor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Describe why you're seeing a doctor",
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Symptoms Description',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$_charCount / 600',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.12),
                ),
              ),
              child: TextField(
                controller: _symptomsController,
                maxLines: 6,
                maxLength: 600,
                style: TextStyle(color: scheme.onSurface),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, color: scheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload File',
                      style: TextStyle(
                        color: scheme.primary.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: scheme.onPrimary, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Preferred Mode of Interaction',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInteractionMode(
                  'Chat',
                  Icons.chat_bubble_outline,
                  scheme,
                ),
                _buildInteractionMode(
                  'Phone',
                  Icons.phone_in_talk_outlined,
                  scheme,
                ),
                _buildInteractionMode(
                  'Video',
                  Icons.play_circle_outline,
                  scheme,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMode != null ? _onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  disabledBackgroundColor: scheme.onSurface.withValues(
                    alpha: 0.12,
                  ),
                  disabledForegroundColor: scheme.onSurface.withValues(
                    alpha: 0.38,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionMode(
    String label,
    IconData icon,
    ColorScheme scheme,
  ) {
    final selected = _selectedMode == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = label),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
