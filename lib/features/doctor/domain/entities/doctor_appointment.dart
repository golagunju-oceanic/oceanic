import 'doctor_patient.dart';

class DoctorAppointment {
  final String id;
  final String? doctorId;
  /// String because Prisma serializes the patient's BigInt ID as a string.
  final String patientId;
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
  final DoctorPatient? patient;

  const DoctorAppointment({
    required this.id,
    this.doctorId,
    required this.patientId,
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
    this.patient,
  });
}
