import '../../domain/entities/doctor_profile.dart';
import 'doctor_json.dart';

class DoctorProfileModel {
  final Map<String, dynamic> json;
  const DoctorProfileModel._(this.json);

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) =>
      DoctorProfileModel._(json);

  DoctorProfile toEntity() {
    final telemedicineStatus =
        requireDoctorString(json, 'telemedicineStatus').toUpperCase();
    if (telemedicineStatus != 'ONLINE' && telemedicineStatus != 'OFFLINE') {
      throw const FormatException('Invalid doctor telemedicineStatus');
    }

    return DoctorProfile(
        id: requireDoctorString(json, 'id'),
        doctorCode: requireDoctorString(json, 'doctor_id'),
        fullName: requireDoctorString(json, 'fullName'),
        email: doctorString(json, 'email'),
        specialty: doctorString(json, 'specialty'),
        isActive: doctorBool(json, 'isActive'),
        telemedicineStatus: telemedicineStatus,
        mustChangePassword: doctorBool(json, 'must_change_password'),
        createdAt: doctorDate(json, 'createdAt'),
        updatedAt: doctorDate(json, 'updatedAt'),
      );
  }
}
