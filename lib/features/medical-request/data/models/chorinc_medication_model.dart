class ChronicMedicationModel {
  final int? drugId;
  final String name;

  const ChronicMedicationModel({
    this.drugId,
    required this.name,
  });

  factory ChronicMedicationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChronicMedicationModel(
      drugId: json['drug_id'] as int? ??
          json['id'] as int?,
      name: json['name'] as String? ?? '',
    );
  }
}