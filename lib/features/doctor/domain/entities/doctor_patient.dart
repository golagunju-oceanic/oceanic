import 'doctor_appointment_summary.dart';

class DoctorPatient {
  /// String because the database enrollee primary key is a BigInt in Prisma.
  final String id;
  final String? memberId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? maidenName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? maritalStatus;
  final String? email;
  final String? phone;
  /// Raw path from ERP, not necessarily an absolute image URL.
  final String? photo;
  final String? bloodGroup;
  final String? genotype;
  final String? preExistingCondition;
  final String? address;
  final String? city;
  final String? stateOfResidence;
  /// Decimal values are represented as strings to preserve precision.
  final String? height;
  final String? weight;
  final DoctorAppointmentSummary? latestAppointment;
  final List<DoctorAppointmentSummary> appointments;

  const DoctorPatient({
    required this.id,
    this.memberId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.maidenName,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.email,
    this.phone,
    this.photo,
    this.bloodGroup,
    this.genotype,
    this.preExistingCondition,
    this.address,
    this.city,
    this.stateOfResidence,
    this.height,
    this.weight,
    this.latestAppointment,
    this.appointments = const [],
  });

  String get fullName => [firstName, middleName, lastName]
      .whereType<String>()
      .where((part) => part.trim().isNotEmpty)
      .join(' ');
}
