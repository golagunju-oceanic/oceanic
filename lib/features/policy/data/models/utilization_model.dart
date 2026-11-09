
class UtilizationModel {
  final int totalClaims;
  final int totalAuthorizations;

  const UtilizationModel({
    required this.totalClaims,
    required this.totalAuthorizations,
  });

  factory UtilizationModel.fromJson(Map<String, dynamic> json) {
    return UtilizationModel(
      totalClaims: _parseInt(json['totalClaims']),
      totalAuthorizations: _parseInt(json['totalAuthorizations']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
