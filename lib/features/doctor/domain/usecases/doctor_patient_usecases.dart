import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';

import '../entities/doctor_patient.dart';
import '../entities/doctor_patient_records.dart';

class GetDoctorPatientsUseCase {
  final DoctorRepository repository;
  const GetDoctorPatientsUseCase(this.repository);
  Future<List<DoctorPatient>> call() => repository.getPatients();
}

class GetDoctorPatientByIdUseCase {
  final DoctorRepository repository;
  const GetDoctorPatientByIdUseCase(this.repository);
  Future<DoctorPatient> call(String patientId) =>
      repository.getPatientById(patientId);
}

class GetDoctorPatientAppointmentsUseCase {
  final DoctorRepository repository;
  const GetDoctorPatientAppointmentsUseCase(this.repository);
  Future<DoctorPatientAppointments> call(String patientId) =>
      repository.getPatientAppointments(patientId);
}

class GetDoctorPatientHistoryUseCase {
  final DoctorRepository repository;
  const GetDoctorPatientHistoryUseCase(this.repository);
  Future<DoctorPatientHistory> call(String patientId) =>
      repository.getPatientHistory(patientId);
}
