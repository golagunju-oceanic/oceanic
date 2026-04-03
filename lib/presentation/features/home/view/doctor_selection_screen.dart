import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/presentation/features/home/view/date_selction_screen.dart';
import 'package:oceanic/presentation/widgets/octodoc_scaffold.dart';

class DoctorSelectionScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return OctodocScaffold(
      currentStep: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Doctor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            ..._doctors.map(
              (doc) => _DoctorCard(
                doctor: doc,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DateSelectionScreen()),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
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
                    color: Colors.grey.shade300,
                  ),
                  child: const Icon(Icons.person, size: 36, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        doctor['role'],
                        style: const TextStyle(color: kTextGray, fontSize: 13),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${doctor['rating']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: kTeal, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              doctor['clinic'],
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              doctor['address'],
              style: const TextStyle(color: kTextGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}