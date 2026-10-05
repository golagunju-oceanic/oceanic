import 'package:oceanic/features/medical-request/data/datasource/medication_remote_data_source.dart';
import 'package:oceanic/features/medical-request/data/models/chorinc_medication_model.dart';
import 'package:oceanic/features/medical-request/domain/repository/medication_repository.dart';
import '../models/beneficiary_model.dart';

import '../models/prescription_response_model.dart';
import '../models/refill_request_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;

  MedicationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BeneficiaryModel>> getBeneficiaries() {
    return remoteDataSource.getBeneficiaries();
  }

  @override
  Future<List<ChronicMedicationModel>> getChronicMedications(
    int beneficiaryId,
  ) {
    return remoteDataSource.getChronicMedications(beneficiaryId);
  }

  @override
  Future<dynamic> submitRefill(RefillRequestModel request) {
    return remoteDataSource.submitRefill(request);
  }

  @override
  Future<PrescriptionResponseModel> submitPrescription({
    required int beneficiaryId,
    required String state,
    required String city,
    required String conditionOrIllness,
    String additionalComments = '',
    required String filePath,
    required String fileName,
  }) {
    return remoteDataSource.submitPrescription(
      beneficiaryId: beneficiaryId,
      state: state,
      city: city,
      conditionOrIllness: conditionOrIllness,
      additionalComments: additionalComments,
      fileName: fileName,
      filePath: filePath,

      // filePath: filePath,
      // fileName: fileName,
    );
  }
}
