import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_alert_dialog.dart';
import 'package:oceanic/presentation/features/home/view/date_selction_screen.dart';
import 'package:oceanic/presentation/widgets/telemedicine_scaffold.dart';

class DoctorSelectionScreen extends StatefulWidget {
  const DoctorSelectionScreen({super.key});

  static const List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Nkemjika Obi',
      'role': 'Doctor',
      'rating': 4.7,
      'clinic': 'Octodoc',
      'address': '350, Borno Way, Alagomeji, Yaba',
    },
    {
      'name': 'Dr. Ayodeji Faola',
      'role': 'Doctor',
      'rating': 4.2,
      'clinic': 'Octodoc',
      'address': '350, Borno Way, Alagomeji, Yaba',
    },
    {
      'name': 'Dr. Kelechi Igbokwe',
      'role': 'Doctor',
      'rating': 4.7,
      'clinic': 'Octodoc',
      'address': '350, Borno Way, Alagomeji, Yaba',
    },
  ];

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {


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

    return TelemedicineScaffold(
      currentStep: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Doctor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...DoctorSelectionScreen._doctors.map(
              (doc) => _DoctorCard(
                doctor: doc,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DateSelectionScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: scheme.onSurface.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: scheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        doctor['role'],
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${doctor['rating']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.favorite, color: scheme.primary, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              doctor['clinic'],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
            Text(
              doctor['address'],
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
