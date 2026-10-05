import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/audio_consultation_screen.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/chat_consultation_screen.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/video_consultation_screen.dart';
import 'package:oceanic/presentation/widgets/telemedicine_scaffold.dart';

class UploadedMedicalFile {
  final String name;
  final String size;

  UploadedMedicalFile({required this.name, required this.size});
}

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({super.key});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  String? _selectedMode = 'Video'; // Non-nullable String
  final TextEditingController _symptomsController = TextEditingController();
  int _charCount = 0;

  final List<UploadedMedicalFile> _attachedFiles = [];
  final int _maxFiles = 3;

  final List<String> _quickSymptoms = [
    'Fever',
    'Headache',
    'Cough',
    'Stomach Pain',
    'Body Aches',
    'Fatigue',
    'Skin Rash',
  ];

  @override
  void initState() {
    super.initState();
    _symptomsController.addListener(() {
      if (mounted) {
        setState(() => _charCount = _symptomsController.text.length);
      }
    });
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _addQuickSymptom(String symptom) {
    final currentText = _symptomsController.text.trim();
    if (currentText.isEmpty) {
      _symptomsController.text = symptom;
    } else if (!currentText.contains(symptom)) {
      _symptomsController.text = '$currentText, $symptom';
    }
    _symptomsController.selection = TextSelection.fromPosition(
      TextPosition(offset: _symptomsController.text.length),
    );
  }

  void _simulateFileUpload() {
    if (_attachedFiles.length >= _maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum limit of 3 files reached.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _attachedFiles.add(
        UploadedMedicalFile(
          name: 'lab_report_0${_attachedFiles.length + 1}.pdf',
          size: '1.2 MB',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medical record attached successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeFile(int index) {
    setState(() => _attachedFiles.removeAt(index));
  }

  void _onConfirm() {
    final symptomsText = _symptomsController.text.trim();
    if (symptomsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please describe your symptoms before proceeding.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    switch (_selectedMode) {
      case 'Chat':
        _startChatConsultation(symptomsText);
        break;
      case 'Phone':
        _startPhoneConsultation(symptomsText);
        break;
      case 'Video':
      default:
        _startVideoConsultation(symptomsText);
        break;
    }
  }

  // Passing safe non-null parameters to all consultation routes
  void _startChatConsultation(String symptoms) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConsultationScreen(
          // channelName: "consultation-room-1",
          // symptoms: symptoms.isEmpty ? "General Consultation" : symptoms,
        ),
      ),
    );
  }

  void _startPhoneConsultation(String symptoms) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioConsultationScreen(
          channelName: "consultation-room-1",
          // symptoms: symptoms.isEmpty ? "General Consultation" : symptoms,
        ),
      ),
    );
  }

  void _startVideoConsultation(String symptoms) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoConsultationScreen(
          doctorId: "DOC-0002" ,
          channelName: "consultation-room-1",
          // symptoms: symptoms.isEmpty ? "General Consultation" : symptoms,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Safe Non-Null Color Fallbacks
    final cardBg =
        scheme.surfaceContainerLow ?? scheme.surfaceContainer ?? scheme.surface;
    final borderOutline = scheme.outlineVariant ?? scheme.outline;

    return TelemedicineScaffold(
      currentStep: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Consultation Notes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help the doctor prepare by describing your current health condition.',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Add Symptom Chips
            Text(
              'Quick Add Common Symptoms:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickSymptoms.map((symptom) {
                return InkWell(
                  onTap: () => _addQuickSymptom(symptom),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 12, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          symptom,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Symptoms Input Text Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Symptoms Description',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$_charCount / 600',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _symptomsController,
              maxLines: 5,
              maxLength: 600,
              style: TextStyle(color: scheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Type your symptoms, medical concerns, or how long you have felt unwell...',
                hintStyle: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
                counterText: '',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: borderOutline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Attach Reports
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attach Medical Reports (Optional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  '${_attachedFiles.length}/$_maxFiles',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: _simulateFileUpload,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: scheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Upload lab report or medical document',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(Icons.add_circle, color: scheme.primary, size: 20),
                  ],
                ),
              ),
            ),

            if (_attachedFiles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_attachedFiles.length, (index) {
                  final file = _attachedFiles[index];
                  return Chip(
                    backgroundColor: cardBg,
                    avatar: Icon(
                      Icons.insert_drive_file_outlined,
                      size: 16,
                      color: scheme.primary,
                    ),
                    label: Text(
                      '${file.name} (${file.size})',
                      style: TextStyle(fontSize: 11, color: scheme.onSurface),
                    ),
                    onDeleted: () => _removeFile(index),
                    deleteIconColor: scheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 24),

            // Mode Selector
            Text(
              'Select Consultation Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildModeCard(
                    title: 'Video Call',
                    subtitle: 'Face-to-face HD call',
                    modeKey: 'Video',
                    icon: Icons.videocam_rounded,
                    scheme: scheme,
                    cardBg: cardBg,
                    borderOutline: borderOutline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildModeCard(
                    title: 'Audio Call',
                    subtitle: 'Audio consultation',
                    modeKey: 'Phone',
                    icon: Icons.phone_in_talk_rounded,
                    scheme: scheme,
                    cardBg: cardBg,
                    borderOutline: borderOutline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildModeCard(
                    title: 'Live Chat',
                    subtitle: 'Instant messaging',
                    modeKey: 'Chat',
                    icon: Icons.chat_rounded,
                    scheme: scheme,
                    cardBg: cardBg,
                    borderOutline: borderOutline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Start $_selectedMode Consultation',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    String modeKey = 'Video',
    required IconData icon,
    required ColorScheme scheme,
    required Color cardBg,
    required Color borderOutline,
  }) {
    final bool isSelected = _selectedMode == modeKey;

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = modeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary.withValues(alpha: 0.1) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : borderOutline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? scheme.primary : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
