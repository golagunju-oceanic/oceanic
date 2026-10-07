class AuthorizationLineModel {
  final String service;
  final String status;
  final String? reason;

  const AuthorizationLineModel({
    required this.service,
    required this.status,
    required this.reason,
  });

  factory AuthorizationLineModel.fromJson(Map<String, dynamic> json) {
    return AuthorizationLineModel(
      service: json['service']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      reason: json['reason']?.toString(),
    );
  }
}

class AuthorizationDetailModel {
  final int id;
  final String reference;
  final String? date;
  final String hospital;
  final String? diagnosis;
  final String status;
  final List<AuthorizationLineModel> lines;

  const AuthorizationDetailModel({
    required this.id,
    required this.reference,
    required this.date,
    required this.hospital,
    required this.diagnosis,
    required this.status,
    required this.lines,
  });

  factory AuthorizationDetailModel.fromJson(Map<String, dynamic> json) {
    return AuthorizationDetailModel(
      id: json['id'] as int,
      reference: json['reference']?.toString() ?? '',
      date: json['date']?.toString(),
      hospital: json['hospital']?.toString() ?? 'Healthcare Facility',
      diagnosis: json['diagnosis']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map(
            (line) =>
                AuthorizationLineModel.fromJson(line as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
