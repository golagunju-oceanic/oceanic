import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calendar/time display for Africa/Lagos (UTC+01:00; no daylight saving).
/// Never use this local display time to construct a booking POST body.
class TelemedicineTime {
  const TelemedicineTime._();
  static DateTime lagos(DateTime utc) => utc.toUtc().add(const Duration(hours: 1));
  static DateTime todayLagos() {
    final now = lagos(DateTime.now());
    return DateTime(now.year, now.month, now.day);
  }
  static String date(DateTime instant) => DateFormat('EEE, d MMM yyyy').format(lagos(instant));
  static String time(DateTime instant) => DateFormat('h:mm a').format(lagos(instant));
  static String dateTime(DateTime instant) => DateFormat('EEE, d MMM • h:mm a').format(lagos(instant));
  static String calendarDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);
}

String readableTelemedicineError(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map && body['message'] != null) return body['message'].toString();
    switch (error.response?.statusCode) {
      case 401: return 'Your session has expired. Please sign in again.';
      case 403: return 'You are not allowed to perform this action yet.';
      case 404: return 'The requested doctor or appointment was not found.';
      case 409: return 'This slot is no longer available. Refresh and select another.';
    }
    return 'Unable to connect to telemedicine. Please check your connection.';
  }
  if (error is FormatException) return 'Unexpected telemedicine response. Please update or retry.';
  if (error is StateError) return error.message;
  return 'Something went wrong. Please try again.';
}

Color statusColor(String status, ColorScheme scheme) => switch (status) {
  'CONFIRMED' => const Color(0xFF0E8877),
  'PENDING' => const Color(0xFFCA820B),
  'IN_PROGRESS' => scheme.primary,
  'COMPLETED' => const Color(0xFF237D68),
  'CANCELLED' || 'MISSED' => scheme.error,
  _ => scheme.onSurfaceVariant,
};

String statusLabel(String value) => value.toLowerCase().split('_').map(
  (s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1),
).join(' ');

class TelemedicineStatusChip extends StatelessWidget {
  const TelemedicineStatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = statusColor(status, scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(30)),
      child: Text(statusLabel(status), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class TelemedicineErrorPanel extends StatelessWidget {
  const TelemedicineErrorPanel({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(readableTelemedicineError(error), textAlign: TextAlign.center),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
      ]),
    ),
  );
}

class TelemedicineEmptyPanel extends StatelessWidget {
  const TelemedicineEmptyPanel({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    ),
  );
}
