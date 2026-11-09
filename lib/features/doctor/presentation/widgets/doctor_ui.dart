import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/doctor_appointment.dart';
import '../../domain/entities/doctor_patient.dart';

class DoctorFormat {
  static const weekdays = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  static String weekday(int day) => day >= 0 && day < weekdays.length
      ? weekdays[day]
      : 'Unknown day';

  static String status(String value) => value
      .toLowerCase()
      .split('_')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  static String date(DateTime value) =>
      DateFormat('EEE, d MMM yyyy').format(value.toLocal());

  static String dateTime(DateTime value) =>
      DateFormat('EEE, d MMM • h:mm a').format(value.toLocal());

  static String initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    final letters = parts.where((part) => part.isNotEmpty).take(2).map((part) => part[0].toUpperCase());
    return letters.isEmpty ? '?' : letters.join();
  }

  static String error(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['detail'] ?? data['error'];
        if (message is String && message.trim().isNotEmpty) return message;
      }
      if (error.response?.statusCode == 401) return 'Your session has expired. Please sign in again.';
      if (error.response?.statusCode == 403) return 'Doctor access is required.';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Unable to connect. Check your internet connection.';
      }
      return 'Request failed. Please try again.';
    }
    if (error is FormatException) return 'The server returned unexpected data.';
    return 'Something went wrong. Please try again.';
  }
}

class DoctorLoadView<T> extends StatelessWidget {
  const DoctorLoadView({super.key, required this.value, required this.builder, required this.onRetry});
  final AsyncValue<T> value;
  final Widget Function(T) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => value.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DoctorEmptyState(
          icon: Icons.cloud_off_outlined,
          message: DoctorFormat.error(error),
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
        data: builder,
      );
}

class DoctorEmptyState extends StatelessWidget {
  const DoctorEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );
}

class DoctorSectionHeader extends StatelessWidget {
  const DoctorSectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      );
}

class DoctorStatusChip extends StatelessWidget {
  const DoctorStatusChip(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color color;
    switch (status) {
      case 'COMPLETED':
      case 'CONFIRMED':
        color = Colors.green.shade700;
        break;
      case 'CANCELLED':
      case 'MISSED':
        color = scheme.error;
        break;
      case 'PENDING':
        color = Colors.orange.shade800;
        break;
      case 'IN_PROGRESS':
        color = scheme.primary;
        break;
      default:
        color = scheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(DoctorFormat.status(status),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class DoctorStatCard extends StatelessWidget {
  const DoctorStatCard({super.key, required this.label, required this.count, required this.icon});
  final String label;
  final int count;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: scheme.primary),
            const SizedBox(height: 12),
            Text('$count', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class DoctorAppointmentCard extends StatelessWidget {
  const DoctorAppointmentCard({super.key, required this.appointment, required this.onTap});
  final DoctorAppointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final patient = appointment.patient;
    final name = patient == null || patient.fullName.isEmpty
        ? 'Patient #${appointment.patientId}'
        : patient.fullName;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(child: Text(DoctorFormat.initials(name))),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(DoctorFormat.dateTime(appointment.appointmentDate),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                )),
                const Icon(Icons.chevron_right),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                DoctorStatusChip(appointment.status),
                const SizedBox(width: 8),
                if ((appointment.type ?? '').trim().isNotEmpty)
                  Flexible(child: Text(appointment.type!, overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorPatientCard extends StatelessWidget {
  const DoctorPatientCard({super.key, required this.patient, required this.onTap});
  final DoctorPatient patient;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(child: Text(DoctorFormat.initials(patient.fullName))),
          title: Text(patient.fullName.isEmpty ? 'Unnamed patient' : patient.fullName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(patient.memberId == null ? 'Patient ID: ${patient.id}' : 'Member: ${patient.memberId}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class DoctorDetailRow extends StatelessWidget {
  const DoctorDetailRow(this.label, this.value, {super.key});
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 122, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(width: 8),
          Expanded(child: Text(value == null || value!.trim().isEmpty ? '—' : value!,
              style: const TextStyle(fontWeight: FontWeight.w500))),
        ]),
      );
}
