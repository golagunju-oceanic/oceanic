class HealthRecordModel {
  final String id;
  final String type;
  final String title;
  final String hospital;
  final String? doctor;
  final String date;
  final String status;
  final String? notes;

  final String? source;
  final String? claimNo;
  final String? intakeNo;
  final String? claimStatus;
  final String? icdCode;
  final String? diagnosis;

  const HealthRecordModel({
    required this.id,
    required this.type,
    required this.title,
    required this.hospital,
    required this.doctor,
    required this.date,
    required this.status,
    required this.notes,
    required this.source,
    required this.claimNo,
    required this.intakeNo,
    required this.claimStatus,
    required this.icdCode,
    required this.diagnosis,
  });

  factory HealthRecordModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HealthRecordModel(
      id: json['id']?.toString() ?? '',

      type: json['type']?.toString() ?? 'Consultation',

      title: json['title']?.toString() ?? 'Medical Record',

      hospital:
          json['hospital']?.toString() ?? 'Unknown Provider',

      doctor: json['doctor']?.toString(),

      date: json['date']?.toString() ?? '',

      status:
          json['status']?.toString().toUpperCase() ??
          'COMPLETED',

      notes: json['notes']?.toString(),

      source: json['source']?.toString(),

      claimNo: json['claimNo']?.toString(),

      intakeNo: json['intakeNo']?.toString(),

      claimStatus: json['claimStatus']?.toString(),

      icdCode: json['icdCode']?.toString(),

      diagnosis: json['diagnosis']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'hospital': hospital,
      'doctor': doctor,
      'date': date,
      'status': status,
      'notes': notes,
      'source': source,
      'claimNo': claimNo,
      'intakeNo': intakeNo,
      'claimStatus': claimStatus,
      'icdCode': icdCode,
      'diagnosis': diagnosis,
    };
  }
}