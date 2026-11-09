import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';

import '../entities/doctor_availability.dart';

class GetDoctorAvailabilityUseCase {
  final DoctorRepository repository;
  const GetDoctorAvailabilityUseCase(this.repository);
  Future<List<DoctorAvailability>> call() => repository.getAvailability();
}

class CreateDoctorAvailabilityUseCase {
  final DoctorRepository repository;
  const CreateDoctorAvailabilityUseCase(this.repository);

  Future<DoctorAvailability> call({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) => repository.createAvailability(
    dayOfWeek: dayOfWeek,
    startTime: startTime,
    endTime: endTime,
  );
}

class UpdateDoctorAvailabilityUseCase {
  final DoctorRepository repository;
  const UpdateDoctorAvailabilityUseCase(this.repository);

  Future<DoctorAvailability> call({
    required String availabilityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) => repository.updateAvailability(
    availabilityId: availabilityId,
    dayOfWeek: dayOfWeek,
    startTime: startTime,
    endTime: endTime,
    isActive: isActive,
  );
}

class DeleteDoctorAvailabilityUseCase {
  final DoctorRepository repository;
  const DeleteDoctorAvailabilityUseCase(this.repository);
  Future<void> call(String availabilityId) =>
      repository.deleteAvailability(availabilityId);
}
