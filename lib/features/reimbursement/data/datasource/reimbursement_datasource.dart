import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:oceanic/core/network/api_client.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_request.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_response.dart';

class ReimbursementRemoteDataSource {
  final ApiClient apiClient;

  ReimbursementRemoteDataSource(this.apiClient);

  Future<SubmitReimbursementResponse> submitReimbursement(
    SubmitReimbursementRequest request,
  ) async {
    final itemsJson = jsonEncode(
      request.items.map((item) => item.toJson()).toList(),
    );

    print('========== REIMBURSEMENT ==========');
    print('reimbursement_code: "${request.reimbursementCode}"');
    print('trimmed reimbursement_code: "${request.reimbursementCode.trim()}"');
    print(
      'reimbursement_code length: ${request.reimbursementCode.trim().length}',
    );
    print('amount: ${request.amount}');
    print('account_number: ${request.accountNumber}');
    print('bank_name: ${request.bankName}');
    print('account_name: ${request.accountName}');
    print('enrollee_notes: ${request.enrolleeNotes}');
    print('document_path: ${request.documentPath}');
    print('items: $itemsJson');
    print('===================================');

    final formData = FormData.fromMap({
      'reimbursement_code': request.reimbursementCode.trim(),

      // Avoid sending 50000.0 if Postman sends 50000
      'amount': request.amount % 1 == 0
          ? request.amount.toInt().toString()
          : request.amount.toString(),

      'account_number': request.accountNumber.trim(),
      'bank_name': request.bankName.trim(),
      'account_name': request.accountName.trim(),

      if (request.enrolleeNotes != null &&
          request.enrolleeNotes!.trim().isNotEmpty)
        'enrollee_notes': request.enrolleeNotes!.trim(),

      'items': itemsJson,

      'documents': await MultipartFile.fromFile(
        request.documentPath,
        filename: request.documentPath.split('/').last,
      ),
    });

    // Log actual FormData fields
    print('========== FORM DATA ==========');

    for (final field in formData.fields) {
      print('${field.key}: "${field.value}"');
    }

    for (final file in formData.files) {
      print(
        '${file.key}: '
        'filename=${file.value.filename}, '
        'length=${file.value.length}',
      );
    }

    print('===============================');

    final response = await apiClient.postFormData(
      '/reimbursement/submit',
      body: formData,
    );

    return SubmitReimbursementResponse.fromJson(response.data);
  }
}
