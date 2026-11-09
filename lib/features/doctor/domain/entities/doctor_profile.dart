class DoctorProfile {
  final String id;
  final String doctorCode;
  final String fullName;
  final String? email;
  final String? specialty;
  final bool isActive;
  /// Persistent availability used by the 24/7 telemedicine booking service.
  final String telemedicineStatus;
  final bool mustChangePassword;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoctorProfile({
    required this.id,
    required this.doctorCode,
    required this.fullName,
    this.email,
    this.specialty,
    required this.isActive,
    required this.telemedicineStatus,
    required this.mustChangePassword,
    this.createdAt,
    this.updatedAt,
  });

  bool get isTelemedicineOnline => telemedicineStatus == 'ONLINE';
}
