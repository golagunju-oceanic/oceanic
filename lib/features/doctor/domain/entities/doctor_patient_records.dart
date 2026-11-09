import 'doctor_appointment_summary.dart';
import 'doctor_patient.dart';

class DoctorPatientAppointments {
  final DoctorPatient patient;
  final List<DoctorAppointmentSummary> appointments;

  const DoctorPatientAppointments({
    required this.patient,
    required this.appointments,
  });
}

class DoctorPatientHistorySummary {
  final int total;
  final int completed;
  final int cancelled;
  final int missed;

  const DoctorPatientHistorySummary({
    required this.total,
    required this.completed,
    required this.cancelled,
    required this.missed,
  });
}

/// This endpoint is appointment history, not a full clinical/EHR history.
class DoctorPatientHistory {
  final DoctorPatient patient;
  final DoctorPatientHistorySummary summary;
  final List<DoctorAppointmentSummary> history;

  const DoctorPatientHistory({
    required this.patient,
    required this.summary,
    required this.history,
  });
}
