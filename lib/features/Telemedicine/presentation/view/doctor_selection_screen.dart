import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/sample/available_doctors_screen%20(2).dart';

import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_alert_dialog.dart';
import 'package:oceanic/presentation/widgets/telemedicine_scaffold.dart';

/// Backwards-compatible entry point for existing app navigation.
///
/// The old screen contained a hard-coded doctor list. Keep its public class
/// name so existing routes continue to work, but send users into the live API
/// backed doctor directory after the existing consent step.
class DoctorSelectionScreen extends StatefulWidget {
  const DoctorSelectionScreen({super.key});

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  bool _openingDirectory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openLiveDirectory();
    });
  }

  Future<void> _openLiveDirectory() async {
    if (_openingDirectory || !mounted) return;
    _openingDirectory = true;

    final agreed = await TelemedicineAlertDialog()
        .showTelemedicineConsentDialog(context);

    if (!mounted) return;
    if (!agreed) {
      Navigator.of(context).pop();
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const AvailableDoctorsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TelemedicineScaffold(
      currentStep: 1,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
