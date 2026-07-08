class UtilizationModel {
  final int totalClaims;
  final int totalAuthorizations;

  const UtilizationModel({
    required this.totalClaims,
    required this.totalAuthorizations,
  });

  factory UtilizationModel.fromJson(Map<String, dynamic> json) {
    return UtilizationModel(
      totalClaims: json["totalClaims"],
      totalAuthorizations: json["totalAuthorizations"],
    );
  }
}