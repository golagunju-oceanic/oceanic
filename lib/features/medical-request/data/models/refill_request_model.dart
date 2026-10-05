class RefillMedicationModel {
  final int? drugId;
  final String? customDrugName;
  final int quantity;
  final String dosage;

  const RefillMedicationModel({
    this.drugId,
    this.customDrugName,
    required this.quantity,
    required this.dosage,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'quantity': quantity,
      'dosage': dosage,
    };

    if (drugId != null) {
      json['drug_id'] = drugId;
    }

    if (customDrugName != null &&
        customDrugName!.trim().isNotEmpty) {
      json['custom_drug_name'] =
          customDrugName!.trim();
    }

    return json;
  }
}

class RefillRequestModel {
  final int beneficiaryId;
  final String state;
  final String city;
  final String deliveryAddress;
  final List<RefillMedicationModel> medications;

  const RefillRequestModel({
    required this.beneficiaryId,
    required this.state,
    required this.city,
    required this.deliveryAddress,
    required this.medications,
  });

  Map<String, dynamic> toJson() {
    return {
      'beneficiary_id': beneficiaryId,
      'state': state,
      'city': city,
      'delivery_address': deliveryAddress,
      'medications':
          medications.map((e) => e.toJson()).toList(),
    };
  }
}