import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_response.dart';

class ReimbursementState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final SubmitReimbursementResponse? response;

  const ReimbursementState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.response,
  });

  ReimbursementState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    SubmitReimbursementResponse? response,
  }) {
    return ReimbursementState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      response: response ?? this.response,
    );
  }
}
