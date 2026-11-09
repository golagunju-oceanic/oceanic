import 'package:oceanic/features/doctor/domain/entities/doctor_dashboard%20(1).dart';

import '../entities/doctor_appointment.dart';
import '../entities/doctor_availability.dart';
import '../entities/doctor_patient.dart';
import '../entities/doctor_patient_records.dart';
import '../entities/doctor_profile.dart';

/// Domain contract; the authenticated doctor is derived from the JWT server-side.
abstract class DoctorRepository {
  Future<DoctorProfile> getMyProfile();
  Future<String> updateTelemedicineStatus(String status);
  Future<DoctorDashboard> getDashboard();

  Future<List<DoctorAvailability>> getAvailability();
  Future<DoctorAvailability> createAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  });
  Future<DoctorAvailability> updateAvailability({
    required String availabilityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  });
  Future<void> deleteAvailability(String availabilityId);

  Future<List<DoctorAppointment>> getAppointments();
  Future<List<DoctorAppointment>> getTodayAppointments();
  Future<List<DoctorAppointment>> getUpcomingAppointments();
  Future<DoctorAppointment> getAppointmentById(String appointmentId);
  Future<DoctorAppointment> confirmAppointment(String appointmentId);
  Future<DoctorAppointment> startAppointment(String appointmentId);
  Future<DoctorAppointment> completeAppointment(String appointmentId);
  Future<DoctorAppointment> cancelAppointment(
    String appointmentId, {
    String? cancellationReason,
  });
  Future<DoctorAppointment> markAppointmentMissed(String appointmentId);

  Future<List<DoctorPatient>> getPatients();
  Future<DoctorPatient> getPatientById(String patientId);
  Future<DoctorPatientAppointments> getPatientAppointments(String patientId);
  Future<DoctorPatientHistory> getPatientHistory(String patientId);
}
