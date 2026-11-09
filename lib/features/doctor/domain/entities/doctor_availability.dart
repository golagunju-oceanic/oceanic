/// dayOfWeek follows the backend: 0 = Sunday, ... 6 = Saturday.
class DoctorAvailability {
  final String id;
  final String doctorId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoctorAvailability({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
}
