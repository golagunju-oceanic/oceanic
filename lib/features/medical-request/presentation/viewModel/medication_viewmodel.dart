import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/beneficiary_model.dart';
import '../../data/models/refill_request_model.dart';
import '../provider/medication_provider.dart';
import '../state/medication_state.dart';

class MedicationViewModel
    extends Notifier<MedicationState> {
  @override
  MedicationState build() {
    return const MedicationState();
  }

  /// Get principal member + dependants
Future<void> getBeneficiaries() async {
  state = state.copyWith(
    isLoading: true,
    errorMessage: null,
  );

  try {
    final repository = ref.read(
      medicationRepositoryProvider,
    );

    final beneficiaries =
        await repository.getBeneficiaries();

    final BeneficiaryModel? enrollee =
        beneficiaries.isNotEmpty
            ? beneficiaries.first
            : null;

    state = state.copyWith(
      isLoading: false,
      beneficiaries: beneficiaries,
      selectedBeneficiary: enrollee,
      chronicMedications: const [],
    );

    if (enrollee != null &&
        enrollee.isChronicEligible) {
      await getChronicMedications(
        enrollee.id,
      );
    }
  } on DioException catch (error) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: _getErrorMessage(error),
    );
  } catch (error) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: error.toString(),
    );
  }
}
  /// Select beneficiary
  void selectBeneficiary(
    BeneficiaryModel beneficiary,
  ) {
    state = state.copyWith(
      selectedBeneficiary: beneficiary,
      chronicMedications: [],
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Get chronic medications
  Future<void> getChronicMedications(
    int beneficiaryId,
  ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final repository = ref.read(
        medicationRepositoryProvider,
      );

      final medications =
          await repository.getChronicMedications(
        beneficiaryId,
      );

      state = state.copyWith(
        isLoading: false,
        chronicMedications: medications,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(error),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// Submit refill request
  Future<bool> submitRefill(
    RefillRequestModel request,
  ) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = ref.read(
        medicationRepositoryProvider,
      );

      await repository.submitRefill(request);

      state = state.copyWith(
        isSubmitting: false,
        successMessage:
            'Refill request submitted successfully',
      );

      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _getErrorMessage(error),
      );

      return false;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }

  /// Submit new prescription
  Future<bool> submitPrescription({
    required int beneficiaryId,
    required String stateName,
    required String city,
    required String conditionOrIllness,
    required String additionalComments,
    required String prescriptionPath,
    required String prescriptionName,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = ref.read(
        medicationRepositoryProvider,
      );

      final result =
          await repository.submitPrescription(
        beneficiaryId: beneficiaryId,
        state: stateName,
        city: city,
        conditionOrIllness:
            conditionOrIllness,
        additionalComments:
            additionalComments,
        filePath:
            prescriptionPath,
       fileName:
            prescriptionName,
      );

      state = state.copyWith(
        isSubmitting: false,
        prescriptionResponse: result,
        successMessage:
            'Prescription submitted successfully',
      );

      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _getErrorMessage(error),
      );

      return false;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }

  String _getErrorMessage(
    DioException error,
  ) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final errorData = responseData['error'];

      // Example:
      // {
      //   "error": {
      //     "detail":
      //       "No active chronic profile..."
      //   }
      // }

      if (errorData is Map) {
        if (errorData['detail'] != null) {
          return errorData['detail'].toString();
        }

        // Example refill error
        final nonFieldErrors =
            errorData['non_field_errors'];

        if (nonFieldErrors is List &&
            nonFieldErrors.isNotEmpty) {
          return nonFieldErrors.first.toString();
        }
      }

      if (responseData['message'] != null) {
        return responseData['message']
            .toString();
      }
    }

    return 'Something went wrong. Please try again.';
  }

  void clearMessage() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}