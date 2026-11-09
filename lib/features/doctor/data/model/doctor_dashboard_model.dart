import 'package:oceanic/features/doctor/domain/entities/doctor_dashboard%20(1).dart';

import 'doctor_appointment_model.dart';
import 'doctor_availability_model.dart';
import 'doctor_json.dart';
import 'doctor_patient_model.dart';
import 'doctor_profile_model.dart';

class DoctorDashboardModel {
  final Map<String, dynamic> json;
  const DoctorDashboardModel._(this.json);

  factory DoctorDashboardModel.fromJson(Map<String, dynamic> json) =>
      DoctorDashboardModel._(json);

  DoctorDashboard toEntity() {
    final stats = doctorJsonMap(json['stats'], context: 'dashboard stats');
    return DoctorDashboard(
      doctor: DoctorProfileModel.fromJson(
        doctorJsonMap(json['doctor'], context: 'dashboard doctor'),
      ).toEntity(),
      availability:
          doctorJsonList(
                json['availability'],
                context: 'dashboard availability',
              )
              .map(
                (entry) => DoctorAvailabilityModel.fromJson(entry).toEntity(),
              )
              .toList(),
      appointments:
          doctorJsonList(json['appointments'], context: 'today preview')
              .map((entry) => DoctorAppointmentModel.fromJson(entry).toEntity())
              .toList(),
      upcomingAppointments:
          doctorJsonList(
                json['upcomingAppointments'],
                context: 'upcoming preview',
              )
              .map((entry) => DoctorAppointmentModel.fromJson(entry).toEntity())
              .toList(),
      patients: doctorJsonList(
        json['patients'],
        context: 'dashboard patients',
      ).map((entry) => DoctorPatientModel.fromJson(entry).toEntity()).toList(),
      stats: DoctorDashboardStats(
        totalAppointments: doctorInt(stats, 'totalAppointments'),
        todayAppointments: doctorInt(stats, 'todayAppointments'),
        upcomingAppointments: doctorInt(stats, 'upcomingAppointments'),
        totalPatients: doctorInt(stats, 'totalPatients'),
        pendingAppointments: doctorInt(stats, 'pendingAppointments'),
        confirmedAppointments: doctorInt(stats, 'confirmedAppointments'),
        inProgressAppointments: doctorInt(stats, 'inProgressAppointments'),
        completedAppointments: doctorInt(stats, 'completedAppointments'),
        cancelledAppointments: doctorInt(stats, 'cancelledAppointments'),
        missedAppointments: doctorInt(stats, 'missedAppointments'),
      ),
    );
  }
}
