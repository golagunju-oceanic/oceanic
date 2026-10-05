import 'package:oceanic/features/medical-request/data/models/chorinc_medication_model.dart';

import '../../data/models/beneficiary_model.dart';

import '../../data/models/refill_request_model.dart';
import '../../data/models/prescription_response_model.dart';

abstract class MedicationRepository {
  Future<List<BeneficiaryModel>>
      getBeneficiaries();

  Future<List<ChronicMedicationModel>>
      getChronicMedications(
    int beneficiaryId,
  );

  Future<dynamic> submitRefill(
    RefillRequestModel request,
  );

  Future<PrescriptionResponseModel>
      submitPrescription({
    required int beneficiaryId,
    required String state,
    required String city,
    required String conditionOrIllness,
    String additionalComments,
    required String filePath,
    required String fileName,
  });
}