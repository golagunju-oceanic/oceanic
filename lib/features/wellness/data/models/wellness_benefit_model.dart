
class WellnessBenefitsResponse {
  final WellnessMember member;
  final WellnessPlan plan;
  final List<WellnessBenefit> benefits;
  final List<String> warnings;
  final bool usageAvailable;

  const WellnessBenefitsResponse({
    required this.member,
    required this.plan,
    required this.benefits,
    required this.warnings,
    required this.usageAvailable,
  });

  factory WellnessBenefitsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['success'] != true) {
      throw FormatException(
        json['message']?.toString() ??
            'Unable to retrieve wellness benefits.',
      );
    }

    final rawData = json['data'];

    if (rawData is! Map) {
      throw const FormatException(
        'Invalid wellness response: data is missing.',
      );
    }

    final data = Map<String, dynamic>.from(rawData);

    final rawBenefits = data['benefits'];

    if (rawBenefits is! List) {
      throw const FormatException(
        'Invalid wellness response: benefits are missing.',
      );
    }

    return WellnessBenefitsResponse(
      member: WellnessMember.fromJson(
        Map<String, dynamic>.from(data['member'] as Map),
      ),
      plan: WellnessPlan.fromJson(
        Map<String, dynamic>.from(data['plan'] as Map),
      ),
      benefits: rawBenefits.map((item) {
        return WellnessBenefit.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList(),
      warnings: (data['warnings'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      usageAvailable: data['usageAvailable'] == true,
    );
  }
}

class WellnessMember {
  final String memberId;
  final String status;

  const WellnessMember({
    required this.memberId,
    required this.status,
  });

  factory WellnessMember.fromJson(
    Map<String, dynamic> json,
  ) {
    return WellnessMember(
      memberId: json['memberId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}

class WellnessPlan {
  final String planId;
  final String planName;
  final String policyOptionId;
  final String policyOptionName;
  final bool planActive;
  final bool policyActive;

  const WellnessPlan({
    required this.planId,
    required this.planName,
    required this.policyOptionId,
    required this.policyOptionName,
    required this.planActive,
    required this.policyActive,
  });

  factory WellnessPlan.fromJson(
    Map<String, dynamic> json,
  ) {
    return WellnessPlan(
      planId: json['planId']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      policyOptionId:
          json['policyOptionId']?.toString() ?? '',
      policyOptionName:
          json['policyOptionName']?.toString() ?? '',
      planActive: json['planActive'] == true,
      policyActive: json['policyActive'] == true,
    );
  }

  // Display CERULEAN rather than CERULEAN (FAMILY OF 6).
  String get displayName {
    final name = planName.trim().isNotEmpty
        ? planName.trim()
        : policyOptionName.trim();

    if (name.isEmpty) return 'Plan not available';

    return name.replaceFirst(
      RegExp(r'\s*\([^)]*\)\s*$'),
      '',
    ).trim();
  }
}

class WellnessBenefit {
  final String benefitId;
  final String name;
  final String? code;
  final String serviceType;
  final int? categoryId;
  final String coverageDescription;
  final String coverageStatus;
  final int? limitVisits;
  final String? limitAmount;
  final String? limitPeriod;
  final String? limitType;
  final bool isUnlimited;
  final bool requiresAuthorization;
  final String coverageSource;

  const WellnessBenefit({
    required this.benefitId,
    required this.name,
    required this.code,
    required this.serviceType,
    required this.categoryId,
    required this.coverageDescription,
    required this.coverageStatus,
    required this.limitVisits,
    required this.limitAmount,
    required this.limitPeriod,
    required this.limitType,
    required this.isUnlimited,
    required this.requiresAuthorization,
    required this.coverageSource,
  });

  factory WellnessBenefit.fromJson(
    Map<String, dynamic> json,
  ) {
    return WellnessBenefit(
      benefitId: json['benefitId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      serviceType: json['serviceType']?.toString() ?? '',
      categoryId: _parseInt(json['categoryId']),
      coverageDescription:
          json['coverageDescription']?.toString() ?? '',
      coverageStatus:
          json['coverageStatus']?.toString() ?? '',
      limitVisits: _parseInt(json['limitVisits']),
      limitAmount: json['limitAmount']?.toString(),
      limitPeriod: json['limitPeriod']?.toString(),
      limitType: json['limitType']?.toString(),
      isUnlimited: json['isUnlimited'] == true,
      requiresAuthorization:
          json['requiresAuthorization'] == true,
      coverageSource:
          json['coverageSource']?.toString() ?? '',
    );
  }

  bool get isCovered =>
      coverageStatus.toLowerCase() == 'covered';

  // The API currently categorizes "Gym Access or Swimming"
  // as "gym". Use the benefit name for a better UI label.
  String get displayName {
    final value = '$name ${code ?? ''}'.toLowerCase();

    if (value.contains('gym') && value.contains('swim')) {
      return 'Gym & Swimming';
    }

    return name;
  }

  bool get hasVisitLimit => limitVisits != null;

  bool get hasAmountLimit => limitAmount != null;

  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num && value == value.roundToDouble()) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}
