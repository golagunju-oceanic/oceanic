class MemberCardModel {
  final String memberId;
  final String fullName;
  final String planVariant;
  final String? planName;
  final String status;

  final String? gender;
  final String? bloodGroup;
  final String? genotype;

  final String photo;
  final String? photoUrl;

  const MemberCardModel({
    required this.memberId,
    required this.fullName,
    required this.planVariant,
    required this.status,
    this.planName,
    this.gender,
    this.bloodGroup,
    this.genotype,
    required this.photo,
    this.photoUrl,
  });

  factory MemberCardModel.fromJson(Map<String, dynamic> json) {
    return MemberCardModel(
      memberId: json['memberId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      planVariant: json['planVariant']?.toString() ?? '',
      planName: json['planName']?.toString(),
      status: json['status']?.toString() ?? '',
      gender: json['gender']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      genotype: json['genotype']?.toString(),
      photo: json['photo']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  String get displayPlanName {
    final name = planName?.trim() ?? '';

    if (name.isEmpty) {
      return 'Plan not available';
    }

    final familyPattern = RegExp(
      r'\s*(?:[-–—]\s*)?\(?\s*(?:family|plan)\s+of\s+\d+\s*\)?\s*$',
      caseSensitive: false,
    );

    switch (name) {
      case final String value when familyPattern.hasMatch(value):
        return value.replaceFirst(familyPattern, '').trim().toUpperCase();

      default:
        return name.toUpperCase();
    }
  }

  String? get displayPhotoUrl {
    if (photoUrl?.trim().isNotEmpty == true) {
      return photoUrl;
    }

    if (photo.trim().isEmpty) return null;

    if (photo.startsWith('https://') || photo.startsWith('http://')) {
      return photo;
    }

    final cleanPath = photo
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^media/', caseSensitive: false), '');

    return 'https://staging.oceanichealth.com/media/$cleanPath';
  }
}
