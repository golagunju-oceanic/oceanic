import 'package:oceanic/features/doctor/data/datasource/doctor_remote_datasource%20(1).dart';
import 'package:oceanic/features/doctor/domain/entities/doctor_dashboard%20(1).dart';
import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';

import '../../domain/entities/doctor_appointment.dart';
import '../../domain/entities/doctor_availability.dart';
import '../../domain/entities/doctor_patient.dart';
import '../../domain/entities/doctor_patient_records.dart';
import '../../domain/entities/doctor_profile.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource _remote;
  const DoctorRepositoryImpl(this._remote);

  @override
  Future<DoctorProfile> getMyProfile() async =>
      (await _remote.getMyProfile()).toEntity();

  @override
  Future<String> updateTelemedicineStatus(String status) =>
      _remote.updateTelemedicineStatus(status);

  @override
  Future<DoctorDashboard> getDashboard() async =>
      (await _remote.getDashboard()).toEntity();

  @override
  Future<List<DoctorAvailability>> getAvailability() async =>
      (await _remote.getAvailability()).map((dto) => dto.toEntity()).toList();

  @override
  Future<DoctorAvailability> createAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async =>
      (await _remote.createAvailability(
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      )).toEntity();

  @override
  Future<DoctorAvailability> updateAvailability({
    required String availabilityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) async =>
      (await _remote.updateAvailability(
        availabilityId: availabilityId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        isActive: isActive,
      )).toEntity();

  @override
  Future<void> deleteAvailability(String availabilityId) =>
      _remote.deleteAvailability(availabilityId);

  @override
  Future<List<DoctorAppointment>> getAppointments() async =>
      (await _remote.getAppointments()).map((dto) => dto.toEntity()).toList();

  @override
  Future<List<DoctorAppointment>> getTodayAppointments() async =>
      (await _remote.getTodayAppointments()).map((dto) => dto.toEntity()).toList();

  @override
  Future<List<DoctorAppointment>> getUpcomingAppointments() async =>
      (await _remote.getUpcomingAppointments()).map((dto) => dto.toEntity()).toList();

  @override
  Future<DoctorAppointment> getAppointmentById(String appointmentId) async =>
      (await _remote.getAppointmentById(appointmentId)).toEntity();

  @override
  Future<DoctorAppointment> confirmAppointment(String appointmentId) async =>
      (await _remote.confirmAppointment(appointmentId)).toEntity();

  @override
  Future<DoctorAppointment> startAppointment(String appointmentId) async =>
      (await _remote.startAppointment(appointmentId)).toEntity();

  @override
  Future<DoctorAppointment> completeAppointment(String appointmentId) async =>
      (await _remote.completeAppointment(appointmentId)).toEntity();

  @override
  Future<DoctorAppointment> cancelAppointment(
    String appointmentId, {
    String? cancellationReason,
  }) async =>
      (await _remote.cancelAppointment(
        appointmentId,
        cancellationReason: cancellationReason,
      )).toEntity();

  @override
  Future<DoctorAppointment> markAppointmentMissed(String appointmentId) async =>
      (await _remote.markAppointmentMissed(appointmentId)).toEntity();

  @override
  Future<List<DoctorPatient>> getPatients() async =>
      (await _remote.getPatients()).map((dto) => dto.toEntity()).toList();

  @override
  Future<DoctorPatient> getPatientById(String patientId) async =>
      (await _remote.getPatientById(patientId)).toEntity();

  @override
  Future<DoctorPatientAppointments> getPatientAppointments(String patientId) async =>
      (await _remote.getPatientAppointments(patientId)).toEntity();

  @override
  Future<DoctorPatientHistory> getPatientHistory(String patientId) async =>
      (await _remote.getPatientHistory(patientId)).toEntity();
}
