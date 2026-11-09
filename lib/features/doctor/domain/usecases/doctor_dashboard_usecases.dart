import 'package:oceanic/features/doctor/domain/entities/doctor_dashboard%20(1).dart';
import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';


class GetDoctorDashboardUseCase {
  final DoctorRepository repository;
  const GetDoctorDashboardUseCase(this.repository);

  Future<DoctorDashboard> call() => repository.getDashboard();
}
