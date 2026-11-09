import '../../domain/entities/doctor_availability.dart';
import 'doctor_json.dart';

class DoctorAvailabilityModel {
  final Map<String, dynamic> json;
  const DoctorAvailabilityModel._(this.json);

  factory DoctorAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      DoctorAvailabilityModel._(json);

  DoctorAvailability toEntity() => DoctorAvailability(
        id: requireDoctorString(json, 'id'),
        doctorId: requireDoctorString(json, 'doctorId'),
        dayOfWeek: doctorInt(json, 'dayOfWeek'),
        startTime: requireDoctorString(json, 'startTime'),
        endTime: requireDoctorString(json, 'endTime'),
        isActive: doctorBool(json, 'isActive', fallback: true),
        createdAt: doctorDate(json, 'createdAt'),
        updatedAt: doctorDate(json, 'updatedAt'),
      );
}
