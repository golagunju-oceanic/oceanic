import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';
import 'package:oceanic/features/doctor/presentation/screens/doctor_appointment_details_screen%20(3).dart';

import '../../domain/entities/doctor_patient.dart';
import '../../domain/entities/doctor_patient_records.dart';
import '../widgets/doctor_ui.dart';

class DoctorPatientDetailsScreen extends ConsumerWidget {
  const DoctorPatientDetailsScreen({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientValue = ref.watch(doctorPatientProvider(patientId));
    final historyValue = ref.watch(doctorPatientHistoryProvider(patientId));
    final allAppointmentsValue = ref.watch(doctorPatientAppointmentsProvider(patientId));
    return Scaffold(
      appBar: AppBar(title: const Text('Patient details'), actions: [
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () {
          ref.invalidate(doctorPatientProvider(patientId));
          ref.invalidate(doctorPatientHistoryProvider(patientId));
          ref.invalidate(doctorPatientAppointmentsProvider(patientId));
        }),
      ]),
      body: DoctorLoadView<DoctorPatient>(
        value: patientValue,
        onRetry: () => ref.invalidate(doctorPatientProvider(patientId)),
        builder: (patient) => ListView(padding: const EdgeInsets.all(16), children: [
          Card(elevation: 0, child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 26, child: Text(DoctorFormat.initials(patient.fullName))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(patient.fullName, style: Theme.of(context).textTheme.titleLarge),
                  Text(patient.memberId == null ? 'ID: ${patient.id}' : 'Member: ${patient.memberId}'),
                ])),
              ]),
              const Divider(height: 25),
              DoctorDetailRow('Email', patient.email),
              DoctorDetailRow('Phone', patient.phone),
              DoctorDetailRow('Gender', patient.gender),
              DoctorDetailRow('Date of birth', patient.dateOfBirth == null ? null : DoctorFormat.date(patient.dateOfBirth!)),
              DoctorDetailRow('Blood group', patient.bloodGroup),
              DoctorDetailRow('Genotype', patient.genotype),
              DoctorDetailRow('Existing condition', patient.preExistingCondition),
              DoctorDetailRow('Height', patient.height),
              DoctorDetailRow('Weight', patient.weight),
              DoctorDetailRow('Address', patient.address),
              DoctorDetailRow('City', patient.city),
              DoctorDetailRow('State', patient.stateOfResidence),
            ]),
          )),
          const SizedBox(height: 18),
          const DoctorSectionHeader('All appointments'),
          allAppointmentsValue.when(
            loading: () => const Padding(padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator())),
            error: (error, _) => DoctorEmptyState(
              icon: Icons.error_outline, message: DoctorFormat.error(error),
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(doctorPatientAppointmentsProvider(patientId)),
            ),
            data: (record) => record.appointments.isEmpty
                ? const Padding(padding: EdgeInsets.all(16), child: Text('No appointments yet'))
                : Column(children: [
                    for (final item in record.appointments)
                      Card(elevation: 0, child: ListTile(
                        title: Text(DoctorFormat.dateTime(item.appointmentDate)),
                        subtitle: Text(item.type ?? item.reason ?? 'Appointment'),
                        trailing: DoctorStatusChip(item.status),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => DoctorAppointmentDetailsScreen(appointmentId: item.id),
                        )),
                      )),
                  ]),
          ),
          const SizedBox(height: 18),
          const DoctorSectionHeader('Appointment outcome history'),
          // This is NOT a full medical/EHR timeline. The existing endpoint
          // returns appointment outcomes only.
          historyValue.when(
            loading: () => const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator())),
            error: (error, _) => DoctorEmptyState(
              icon: Icons.error_outline, message: DoctorFormat.error(error),
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(doctorPatientHistoryProvider(patientId)),
            ),
            data: (history) => _HistorySection(history: history),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});
  final DoctorPatientHistory history;

  @override
  Widget build(BuildContext context) {
    final summary = history.summary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        Chip(label: Text('Total ${summary.total}')),
        Chip(label: Text('Completed ${summary.completed}')),
        Chip(label: Text('Cancelled ${summary.cancelled}')),
        Chip(label: Text('Missed ${summary.missed}')),
      ]),
      const SizedBox(height: 8),
      if (history.history.isEmpty)
        const Padding(padding: EdgeInsets.all(18), child: Text('No finished appointments on record')),
      for (final item in history.history)
        Card(elevation: 0, child: ListTile(
          title: Text(DoctorFormat.dateTime(item.appointmentDate)),
          subtitle: Text(item.type ?? item.reason ?? 'Appointment'),
          trailing: DoctorStatusChip(item.status),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => DoctorAppointmentDetailsScreen(appointmentId: item.id),
          )),
        )),
    ]);
  }
}
