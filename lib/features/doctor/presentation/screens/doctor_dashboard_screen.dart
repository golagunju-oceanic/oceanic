import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/domain/entities/doctor_dashboard%20(1).dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';
import 'package:oceanic/features/doctor/presentation/screens/doctor_appointment_details_screen%20(3).dart';

import '../widgets/doctor_ui.dart';
import 'doctor_patient_details_screen.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(doctorDashboardProvider);
    try {
      await ref.read(doctorDashboardProvider.future);
    } catch (_) {
      // The provider renders its own retry/error state.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(doctorDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor dashboard'), actions: [
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(doctorDashboardProvider)),
      ]),
      body: DoctorLoadView<DoctorDashboard>(
        value: dashboard,
        onRetry: () => ref.invalidate(doctorDashboardProvider),
        builder: (data) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Welcome, ${data.doctor.fullName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(data.doctor.specialty ?? 'Your practice overview',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 22),
            LayoutBuilder(builder: (context, constraints) {
              final half = (constraints.maxWidth - 10) / 2;
              return Wrap(spacing: 10, runSpacing: 10, children: [
                SizedBox(width: half, child: DoctorStatCard(label: "Today's appointments",
                    count: data.stats.todayAppointments, icon: Icons.today_outlined)),
                SizedBox(width: half, child: DoctorStatCard(label: 'Upcoming appointments',
                    count: data.stats.upcomingAppointments, icon: Icons.upcoming_outlined)),
                SizedBox(width: half, child: DoctorStatCard(label: 'Total patients',
                    count: data.stats.totalPatients, icon: Icons.people_outline)),
                SizedBox(width: half, child: DoctorStatCard(label: 'Completed appointments',
                    count: data.stats.completedAppointments, icon: Icons.task_alt_outlined)),
              ]);
            }),
            const SizedBox(height: 20),
            DoctorSectionHeader("Today's appointments", action: 'See all',
                onAction: () => onOpenTab(1)),
            if (data.appointments.isEmpty)
              const ListTile(title: Text('No appointments scheduled for today')),
            for (final appointment in data.appointments)
              DoctorAppointmentCard(
                appointment: appointment,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => DoctorAppointmentDetailsScreen(appointmentId: appointment.id),
                )),
              ),
            const SizedBox(height: 12),
            DoctorSectionHeader('Upcoming appointments', action: 'See all',
                onAction: () => onOpenTab(1)),
            if (data.upcomingAppointments.isEmpty)
              const ListTile(title: Text('No upcoming appointments')),
            for (final appointment in data.upcomingAppointments)
              DoctorAppointmentCard(
                appointment: appointment,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => DoctorAppointmentDetailsScreen(appointmentId: appointment.id),
                )),
              ),
            const SizedBox(height: 12),
            DoctorSectionHeader('Patients', action: 'View patients', onAction: () => onOpenTab(2)),
            if (data.patients.isEmpty)
              const ListTile(title: Text('No patients yet')),
            for (final patient in data.patients)
              DoctorPatientCard(
                patient: patient,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => DoctorPatientDetailsScreen(patientId: patient.id),
                )),
              ),
            const SizedBox(height: 12),
            _TelemedicineAvailabilityCard(
              isOnline: data.doctor.isTelemedicineOnline,
              isSaving: ref.watch(doctorTelemedicineStatusActionsProvider).isLoading,
              onChanged: (online) async {
                try {
                  await ref.read(doctorTelemedicineStatusActionsProvider.notifier)
                      .setStatus(online ? 'ONLINE' : 'OFFLINE');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(online
                        ? 'You are now available for telemedicine bookings and calls.'
                        : 'You are now offline. New bookings and incoming calls are disabled.')),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(DoctorFormat.error(error))),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}


class _TelemedicineAvailabilityCard extends StatelessWidget {
  const _TelemedicineAvailabilityCard({
    required this.isOnline,
    required this.isSaving,
    required this.onChanged,
  });

  final bool isOnline;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isOnline ? const Color(0xFF159B78) : colors.onSurfaceVariant;

    return Card(
      elevation: 0,
      color: isOnline
          ? const Color(0xFF159B78).withValues(alpha: .08)
          : colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: isOnline,
              onChanged: isSaving ? null : onChanged,
              secondary: Icon(
                isOnline ? Icons.wifi_tethering_rounded : Icons.wifi_off_rounded,
                color: accent,
                size: 28,
              ),
              title: Text(
                isOnline ? 'You are ONLINE' : 'You are OFFLINE',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(isOnline
                  ? 'Patients can book appointments and call you.'
                  : 'New bookings and incoming calls are disabled.'),
            ),
            if (isSaving) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
