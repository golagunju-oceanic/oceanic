/// Appointment subset returned inside patient details/history.
/// Unlike full appointment objects, these records need not include a patientId.
class DoctorAppointmentSummary {
  final String id;
  final DateTime appointmentDate;
  final String status;
  final String? type;
  final String? reason;
  final String? notes;
  final int? durationMinutes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoctorAppointmentSummary({
    required this.id,
    required this.appointmentDate,
    required this.status,
    this.type,
    this.reason,
    this.notes,
    this.durationMinutes,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
  });
}
