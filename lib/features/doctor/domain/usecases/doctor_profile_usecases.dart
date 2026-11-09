import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';

import '../entities/doctor_profile.dart';

class GetMyDoctorProfileUseCase {
  final DoctorRepository repository;
  const GetMyDoctorProfileUseCase(this.repository);

  Future<DoctorProfile> call() => repository.getMyProfile();
}


/// Changes the authenticated doctor's persistent telemedicine availability.
class UpdateDoctorTelemedicineStatusUseCase {
  final DoctorRepository repository;
  const UpdateDoctorTelemedicineStatusUseCase(this.repository);

  Future<String> call(String status) =>
      repository.updateTelemedicineStatus(status);
}
