import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';

import '../../domain/entities/doctor_profile.dart';
import '../widgets/doctor_ui.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(doctorProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(doctorProfileProvider),
          ),
        ],
      ),
      body: DoctorLoadView<DoctorProfile>(
        value: profile,
        onRetry: () => ref.invalidate(doctorProfileProvider),
        builder: (doctor) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 38,
              child: Text(
                DoctorFormat.initials(doctor.fullName),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                doctor.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                doctor.specialty ?? 'Doctor',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DoctorDetailRow('Doctor code', doctor.doctorCode),
                    DoctorDetailRow('Email', doctor.email),
                    DoctorDetailRow('Specialty', doctor.specialty),
                    DoctorDetailRow(
                      'Account status',
                      doctor.isActive ? 'Active' : 'Inactive',
                    ),
                    DoctorDetailRow(
                      'Telemedicine status',
                      DoctorFormat.status(doctor.telemedicineStatus),
                    ),
                    DoctorDetailRow(
                      'Password',
                      doctor.mustChangePassword
                          ? 'Change required'
                          : 'Up to date',
                    ),
                  ],
                ),
              ),
            ),
            if (doctor.mustChangePassword) ...[
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Your account requires a password change. Use your existing account settings flow.',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
