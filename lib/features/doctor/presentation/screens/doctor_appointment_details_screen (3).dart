import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';

import '../../domain/entities/doctor_appointment.dart';
import '../widgets/doctor_ui.dart';
import 'doctor_patient_details_screen.dart';

class DoctorAppointmentDetailsScreen extends ConsumerStatefulWidget {
  const DoctorAppointmentDetailsScreen({super.key, required this.appointmentId});
  final String appointmentId;
  @override
  ConsumerState<DoctorAppointmentDetailsScreen> createState() => _DoctorAppointmentDetailsScreenState();
}

class _DoctorAppointmentDetailsScreenState extends ConsumerState<DoctorAppointmentDetailsScreen> {
  Future<void> _perform(Future<void> Function() action, String message) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DoctorFormat.error(error))));
    }
  }

  Future<void> _cancel() async {
    String enteredReason = '';
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: TextField(
          onChanged: (value) => enteredReason = value,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)', border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(context, enteredReason.trim()),
              child: const Text('Cancel appointment')),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    await _perform(() => ref.read(doctorAppointmentActionsProvider.notifier)
        .cancel(widget.appointmentId, reason: reason.isEmpty ? null : reason),
        'Appointment cancelled');
  }

  Future<void> _missed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as missed?'),
        content: const Text('This action records that the patient missed the appointment.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Mark missed')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _perform(() => ref.read(doctorAppointmentActionsProvider.notifier)
        .markMissed(widget.appointmentId), 'Appointment marked as missed');
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(doctorAppointmentProvider(widget.appointmentId));
    final isSaving = ref.watch(doctorAppointmentActionsProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment details'), actions: [
        IconButton(tooltip: 'Refresh', onPressed: () => ref.invalidate(
            doctorAppointmentProvider(widget.appointmentId)), icon: const Icon(Icons.refresh)),
      ]),
      body: DoctorLoadView<DoctorAppointment>(
        value: value,
        onRetry: () => ref.invalidate(doctorAppointmentProvider(widget.appointmentId)),
        builder: (appointment) => ListView(padding: const EdgeInsets.all(16), children: [
          Card(elevation: 0, child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Appointment', style: Theme.of(context).textTheme.titleLarge)),
                DoctorStatusChip(appointment.status),
              ]),
              const Divider(height: 24),
              DoctorDetailRow('Date & time', DoctorFormat.dateTime(appointment.appointmentDate)),
              DoctorDetailRow('Type', appointment.type),
              DoctorDetailRow('Reason', appointment.reason),
              DoctorDetailRow('Duration', appointment.durationMinutes == null ? null : '${appointment.durationMinutes} mins'),
              DoctorDetailRow('Notes', appointment.notes),
              DoctorDetailRow('Cancelled reason', appointment.cancellationReason),
              if (appointment.startedAt != null)
                DoctorDetailRow('Started', DoctorFormat.dateTime(appointment.startedAt!)),
              if (appointment.completedAt != null)
                DoctorDetailRow('Completed', DoctorFormat.dateTime(appointment.completedAt!)),
            ]),
          )),
          const SizedBox(height: 16),
          Card(elevation: 0, child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(appointment.patient?.fullName.isNotEmpty == true
                ? appointment.patient!.fullName : 'Patient details'),
            subtitle: Text('Patient ID: ${appointment.patientId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => DoctorPatientDetailsScreen(patientId: appointment.patientId),
            )),
          )),
          const SizedBox(height: 20),
          if (isSaving) const LinearProgressIndicator(),
          if (appointment.status == 'PENDING') ...[
            FilledButton.icon(
              onPressed: isSaving ? null : () => _perform(
                () => ref.read(doctorAppointmentActionsProvider.notifier).confirm(widget.appointmentId),
                'Appointment confirmed'),
              icon: const Icon(Icons.check), label: const Text('Confirm appointment')),
          ],
          if (appointment.status == 'CONFIRMED')
            FilledButton.icon(
              onPressed: isSaving ? null : () => _perform(
                () => ref.read(doctorAppointmentActionsProvider.notifier).start(widget.appointmentId),
                'Appointment started'),
              icon: const Icon(Icons.play_arrow), label: const Text('Start appointment')),
          if (appointment.status == 'IN_PROGRESS')
            FilledButton.icon(
              onPressed: isSaving ? null : () => _perform(
                () => ref.read(doctorAppointmentActionsProvider.notifier).complete(widget.appointmentId),
                'Appointment completed'),
              icon: const Icon(Icons.done_all), label: const Text('Complete appointment')),
          if (appointment.status == 'PENDING' || appointment.status == 'CONFIRMED') ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: isSaving ? null : _missed,
                icon: const Icon(Icons.person_off_outlined), label: const Text('Mark missed')),
            OutlinedButton.icon(onPressed: isSaving ? null : _cancel,
                icon: const Icon(Icons.cancel_outlined), label: const Text('Cancel appointment')),
          ],
          const SizedBox(height: 14),
        ]),
      ),
    );
  }
}
