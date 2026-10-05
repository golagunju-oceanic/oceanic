import 'package:dio/dio.dart';
import 'package:oceanic/core/network/api_client.dart';
import 'package:oceanic/features/medical-request/data/models/chorinc_medication_model.dart';

import '../models/beneficiary_model.dart';
// import '../models/chronic_medication_model.dart';
import '../models/refill_request_model.dart';
import '../models/prescription_response_model.dart';

class MedicationRemoteDataSource {
  final ApiClient apiClient;

  MedicationRemoteDataSource(this.apiClient);

  /// GET beneficiaries
  Future<List<BeneficiaryModel>> getBeneficiaries() async {
    final response = await apiClient.get(
      '/medications/beneficiaries',
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => BeneficiaryModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// GET chronic medications
  Future<List<ChronicMedicationModel>>
      getChronicMedications(
    int beneficiaryId,
  ) async {
    final response = await apiClient.get(
      '/medications/beneficiaries/'
      '$beneficiaryId/chronic-meds',
    );

    final data =
        response.data['data'] as List<dynamic>;

    return data
        .map(
          (item) =>
              ChronicMedicationModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// POST refill request
  Future<dynamic> submitRefill(
    RefillRequestModel request,
  ) async {
    final response = await apiClient.post(
      '/medications/requests/refill',
      body: request.toJson(),
    );

    return response.data;
  }

  /// POST new prescription
  Future<PrescriptionResponseModel>
      submitPrescription({
    required int beneficiaryId,
    required String state,
    required String city,
    required String conditionOrIllness,
    required String additionalComments,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'beneficiary_id': beneficiaryId.toString(),
      'state': state,
      'city': city,
      'condition_or_illness': conditionOrIllness,
      'additional_comments': additionalComments,
      'prescription_file':
          await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await apiClient.post(
      '/medications/requests/new-prescription',
      body: formData,
    );

    return PrescriptionResponseModel.fromJson(
      response.data['data'],
    );
  }
}