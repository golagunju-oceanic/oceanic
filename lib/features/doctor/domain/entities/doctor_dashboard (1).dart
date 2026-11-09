import 'doctor_appointment.dart';
import 'doctor_availability.dart';
import 'doctor_patient.dart';
import 'doctor_profile.dart';

class DoctorDashboardStats {
  final int totalAppointments;
  final int todayAppointments;
  final int upcomingAppointments;
  final int totalPatients;
  final int pendingAppointments;
  final int confirmedAppointments;
  final int inProgressAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int missedAppointments;

  const DoctorDashboardStats({
    required this.totalAppointments,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.totalPatients,
    required this.pendingAppointments,
    required this.confirmedAppointments,
    required this.inProgressAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.missedAppointments,
  });
}

class DoctorDashboard {
  final DoctorProfile doctor;
  final List<DoctorAvailability> availability;
  /// Up to 10 entries in the API's dashboard preview, not all appointments.
  final List<DoctorAppointment> appointments;
  /// Up to 5 entries from tomorrow onwards, in the dashboard preview.
  final List<DoctorAppointment> upcomingAppointments;
  /// Up to 5 preview entries, not the doctor's complete patient list.
  final List<DoctorPatient> patients;
  final DoctorDashboardStats stats;

  const DoctorDashboard({
    required this.doctor,
    required this.availability,
    required this.appointments,
    required this.upcomingAppointments,
    required this.patients,
    required this.stats,
  });
}
