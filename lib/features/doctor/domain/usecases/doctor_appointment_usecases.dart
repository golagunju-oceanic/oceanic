import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';

import '../entities/doctor_appointment.dart';

class GetDoctorAppointmentsUseCase {
  final DoctorRepository repository;
  const GetDoctorAppointmentsUseCase(this.repository);
  Future<List<DoctorAppointment>> call() => repository.getAppointments();
}

class GetTodayDoctorAppointmentsUseCase {
  final DoctorRepository repository;
  const GetTodayDoctorAppointmentsUseCase(this.repository);
  Future<List<DoctorAppointment>> call() => repository.getTodayAppointments();
}

class GetUpcomingDoctorAppointmentsUseCase {
  final DoctorRepository repository;
  const GetUpcomingDoctorAppointmentsUseCase(this.repository);
  Future<List<DoctorAppointment>> call() => repository.getUpcomingAppointments();
}

class GetDoctorAppointmentByIdUseCase {
  final DoctorRepository repository;
  const GetDoctorAppointmentByIdUseCase(this.repository);
  Future<DoctorAppointment> call(String appointmentId) =>
      repository.getAppointmentById(appointmentId);
}

class ConfirmDoctorAppointmentUseCase {
  final DoctorRepository repository;
  const ConfirmDoctorAppointmentUseCase(this.repository);
  Future<DoctorAppointment> call(String appointmentId) =>
      repository.confirmAppointment(appointmentId);
}

class StartDoctorAppointmentUseCase {
  final DoctorRepository repository;
  const StartDoctorAppointmentUseCase(this.repository);
  Future<DoctorAppointment> call(String appointmentId) =>
      repository.startAppointment(appointmentId);
}

class CompleteDoctorAppointmentUseCase {
  final DoctorRepository repository;
  const CompleteDoctorAppointmentUseCase(this.repository);
  Future<DoctorAppointment> call(String appointmentId) =>
      repository.completeAppointment(appointmentId);
}

class CancelDoctorAppointmentUseCase {
  final DoctorRepository repository;
  const CancelDoctorAppointmentUseCase(this.repository);
  Future<DoctorAppointment> call(
    String appointmentId, {
    String? cancellationReason,
  }) => repository.cancelAppointment(
        appointmentId,
        cancellationReason: cancellationReason,
      );
}

class MarkDoctorAppointmentMissedUseCase {
  final DoctorRepository repository;
  const MarkDoctorAppointmentMissedUseCase(this.repository);
  Future<DoctorAppointment> call(String appointmentId) =>
      repository.markAppointmentMissed(appointmentId);
}
