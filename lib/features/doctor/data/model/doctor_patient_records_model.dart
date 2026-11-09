import '../../domain/entities/doctor_patient_records.dart';
import 'doctor_appointment_summary_model.dart';
import 'doctor_json.dart';
import 'doctor_patient_model.dart';

class DoctorPatientAppointmentsModel {
  final Map<String, dynamic> json;
  const DoctorPatientAppointmentsModel._(this.json);

  factory DoctorPatientAppointmentsModel.fromJson(Map<String, dynamic> json) =>
      DoctorPatientAppointmentsModel._(json);

  DoctorPatientAppointments toEntity() => DoctorPatientAppointments(
        patient: DoctorPatientModel.fromJson(
          doctorJsonMap(json['patient'], context: 'patient appointments patient'),
        ).toEntity(),
        appointments:
            doctorJsonList(json['appointments'], context: 'patient appointments')
                .map((entry) => DoctorAppointmentSummaryModel.fromJson(entry).toEntity())
                .toList(),
      );
}

class DoctorPatientHistoryModel {
  final Map<String, dynamic> json;
  const DoctorPatientHistoryModel._(this.json);

  factory DoctorPatientHistoryModel.fromJson(Map<String, dynamic> json) =>
      DoctorPatientHistoryModel._(json);

  DoctorPatientHistory toEntity() {
    final summary = doctorJsonMap(json['summary'], context: 'patient history summary');
    return DoctorPatientHistory(
      patient: DoctorPatientModel.fromJson(
        doctorJsonMap(json['patient'], context: 'patient history patient'),
      ).toEntity(),
      summary: DoctorPatientHistorySummary(
        total: doctorInt(summary, 'total'),
        completed: doctorInt(summary, 'completed'),
        cancelled: doctorInt(summary, 'cancelled'),
        missed: doctorInt(summary, 'missed'),
      ),
      history: doctorJsonList(json['history'], context: 'patient history')
          .map((entry) => DoctorAppointmentSummaryModel.fromJson(entry).toEntity())
          .toList(),
    );
  }
}
