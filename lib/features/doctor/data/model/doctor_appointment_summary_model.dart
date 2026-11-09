import '../../domain/entities/doctor_appointment_summary.dart';
import 'doctor_json.dart';

class DoctorAppointmentSummaryModel {
  final Map<String, dynamic> json;
  const DoctorAppointmentSummaryModel._(this.json);

  factory DoctorAppointmentSummaryModel.fromJson(Map<String, dynamic> json) =>
      DoctorAppointmentSummaryModel._(json);

  DoctorAppointmentSummary toEntity() => DoctorAppointmentSummary(
        id: requireDoctorString(json, 'id'),
        appointmentDate: requireDoctorDate(json, 'appointmentDate'),
        status: requireDoctorString(json, 'status'),
        type: doctorString(json, 'type'),
        reason: doctorString(json, 'reason'),
        notes: doctorString(json, 'notes'),
        durationMinutes: doctorNullableInt(json, 'durationMinutes'),
        startedAt: doctorDate(json, 'startedAt'),
        completedAt: doctorDate(json, 'completedAt'),
        cancelledAt: doctorDate(json, 'cancelledAt'),
        cancellationReason: doctorString(json, 'cancellationReason'),
        createdAt: doctorDate(json, 'createdAt'),
        updatedAt: doctorDate(json, 'updatedAt'),
      );
}
