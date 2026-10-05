import 'package:oceanic/features/medical-request/data/models/chorinc_medication_model.dart';

import '../../data/models/beneficiary_model.dart';

import '../../data/models/prescription_response_model.dart';

class MedicationState {
  final bool isLoading;
  final bool isSubmitting;

  final List<BeneficiaryModel> beneficiaries;
  final List<ChronicMedicationModel> chronicMedications;

  final BeneficiaryModel? selectedBeneficiary;

  final PrescriptionResponseModel? prescriptionResponse;

  final String? errorMessage;
  final String? successMessage;

  const MedicationState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.beneficiaries = const [],
    this.chronicMedications = const [],
    this.selectedBeneficiary,
    this.prescriptionResponse,
    this.errorMessage,
    this.successMessage,
  });

  MedicationState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<BeneficiaryModel>? beneficiaries,
    List<ChronicMedicationModel>? chronicMedications,
    BeneficiaryModel? selectedBeneficiary,
    PrescriptionResponseModel? prescriptionResponse,
    String? errorMessage,
    String? successMessage,
  }) {
    return MedicationState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting:
          isSubmitting ?? this.isSubmitting,
      beneficiaries:
          beneficiaries ?? this.beneficiaries,
      chronicMedications:
          chronicMedications ??
          this.chronicMedications,
      selectedBeneficiary:
          selectedBeneficiary ??
          this.selectedBeneficiary,
      prescriptionResponse:
          prescriptionResponse ??
          this.prescriptionResponse,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}