import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/features/reimbursement/Presentation/provider/reimbursement_repository_provider.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_request.dart';

import '../state/reimbursement_state.dart';
import '../../domain/repository/reimbursement_repository.dart';

class ReimbursementViewModel extends Notifier<ReimbursementState> {
  late final ReimbursementRepository repository;

  @override
  ReimbursementState build() {
    repository = ref.read(reimbursementRepositoryProvider);

    return const ReimbursementState();
  }

  Future<void> submitReimbursement(SubmitReimbursementRequest request) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      final response = await repository.submitReimbursement(request);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}
