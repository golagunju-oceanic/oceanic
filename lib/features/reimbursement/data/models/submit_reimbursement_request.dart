class SubmitReimbursementRequest {
  final String reimbursementCode;
  final double amount;
  final String accountNumber;
  final String bankName;
  final String accountName;
  final String? enrolleeNotes;
  final String documentPath;
  final List<ReimbursementItemRequest> items;

  SubmitReimbursementRequest({
    required this.reimbursementCode,
    required this.amount,
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    this.enrolleeNotes,
    required this.documentPath,
    required this.items,
  });
}

class ReimbursementItemRequest {
  final String? itemType;
  final String? serviceDate;
  final String? description;
  final int? quantity;
  final double? unitPrice;
  final int? service;
  final int? drug;

  ReimbursementItemRequest({
    required this.itemType,
    required this.serviceDate,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.service,
    this.drug,
  });

  Map<String, dynamic> toJson() {
    return {
      if (itemType != null && itemType!.isNotEmpty) 'item_type': itemType,

      if (serviceDate != null && serviceDate!.isNotEmpty)
        'service_date': serviceDate,

      if (description != null && description!.isNotEmpty)
        'description': description,

      if (quantity != null) 'quantity': quantity,

       if (unitPrice != null)
      'unit_price':
          unitPrice! % 1 == 0
              ? unitPrice!.toInt().toString()
              : unitPrice.toString(),

      if (service != null) 'service': service,

      if (drug != null) 'drug': drug,
    };
  }
}
//   static String _formatNumber(double value) {
//     if (value == value.truncateToDouble()) {
//       return value.toInt().toString();
//     }

//     return value.toString();
//   }
// }
