import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_alert_dialog.dart';
import 'package:oceanic/presentation/features/home/view/doctor_selection_screen.dart';

class TelemedicineConsentScreen extends StatefulWidget {
  const TelemedicineConsentScreen({super.key});

  @override
  State<TelemedicineConsentScreen> createState() =>
      _TelemedicineConsentScreenState();
}

class _TelemedicineConsentScreenState extends State<TelemedicineConsentScreen> {
  bool _agreed = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final agreed = await TelemedicineAlertDialog()
          .showTelemedicineConsentDialog(context);

      if (!agreed && mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          Container(
            color: scheme.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.onPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Icon(Icons.arrow_back, color: scheme.onPrimary),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.onPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(Icons.menu, color: scheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telemedicine',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dear valued customer,',
                    style: TextStyle(fontSize: 15, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We will share some of your data with OctoDoc to provide you with Telemedicine services. We have taken all necessary steps to ensure your privacy and security.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The data we share includes your Name, Gender, Phone Numbers, Email, DOB and enrollee/member ID.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreed,
                        activeColor: scheme.primary,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Please give us permission to do so by ticking the checkbox. Thank you!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreed
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoctorSelectionScreen(),
                              ),
                            )
                          : null,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
