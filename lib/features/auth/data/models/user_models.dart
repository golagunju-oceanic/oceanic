import 'plan_model.dart';

class UserModel {
  final String id;
  final String role;

  // Member-only fields
  final String? memberId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? profilePictureUrl;
  final PlanModel? plan;

  // Doctor-only fields
  final String? doctorId;
  final String? fullName;
  final String? specialty;

  const UserModel({
    required this.id,
    required this.role,
    this.memberId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.profilePictureUrl,
    this.plan,
    this.doctorId,
    this.fullName,
    this.specialty,
  });

  bool get isDoctor => role == "doctor";
  bool get isMember => role == "member";

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final planData = json['plan'];

    return UserModel(
      id: json['id'].toString(),
      role: json['role']?.toString() ?? '',
      memberId: json['memberId']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),

      plan: planData is Map
          ? PlanModel.fromJson(Map<String, dynamic>.from(planData))
          : null,

      doctorId: json['doctorId']?.toString(),
      fullName: json['fullName']?.toString(),
      specialty: json['specialty']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'memberId': memberId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'profilePictureUrl': profilePictureUrl,
      'plan': plan?.toJson(),
      'doctorId': doctorId,
      'fullName': fullName,
      'specialty': specialty,
    };
  }

  /// Display name regardless of role
  String get displayName {
    if (isDoctor) {
      return fullName ?? '';
    }

    return [
      firstName,
      lastName,
    ].whereType<String>().where((name) => name.isNotEmpty).join(' ');
  }

  /// Convenient access to the enrollee's plan name
  String get planName => plan?.name ?? 'No plan assigned';

  /// Convenient access to the enrollee's hospital tier
  String get hospitalTier {
    final tier = plan?.hospitalTier;

    if (tier == null || tier.trim().isEmpty) {
      return 'Not specified';
    }

    return tier;
  }

  /// Whether the enrollee has an image URL
  bool get hasProfilePicture =>
      profilePictureUrl != null && profilePictureUrl!.trim().isNotEmpty;
}
