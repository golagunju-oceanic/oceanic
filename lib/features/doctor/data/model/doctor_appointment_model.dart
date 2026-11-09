import '../../domain/entities/doctor_appointment.dart';
import 'doctor_json.dart';
import 'doctor_patient_model.dart';

class DoctorAppointmentModel {
  final Map<String, dynamic> json;
  const DoctorAppointmentModel._(this.json);

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) =>
      DoctorAppointmentModel._(json);

  DoctorAppointment toEntity() {
    final patient = json['patient'];
    return DoctorAppointment(
      id: requireDoctorString(json, 'id'),
      doctorId: doctorString(json, 'doctorId'),
      patientId: requireDoctorString(json, 'patientId'),
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
      patient: patient == null
          ? null
          : DoctorPatientModel.fromJson(
              doctorJsonMap(patient, context: 'appointment patient'),
            ).toEntity(),
    );
  }
}
