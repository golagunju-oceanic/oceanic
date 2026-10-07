class AuthorizationItemModel {
  final int id;
  final String reference;
  final String? date;
  final String hospital;
  final String? diagnosis;
  final String status;

  const AuthorizationItemModel({
    required this.id,
    required this.reference,
    required this.date,
    required this.hospital,
    required this.diagnosis,
    required this.status,
  });

  factory AuthorizationItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuthorizationItemModel(
      id: json['id'] as int,
      reference: json['reference']?.toString() ?? '',
      date: json['date']?.toString(),
      hospital:
          json['hospital']?.toString() ??
          'Healthcare Facility',
      diagnosis: json['diagnosis']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}