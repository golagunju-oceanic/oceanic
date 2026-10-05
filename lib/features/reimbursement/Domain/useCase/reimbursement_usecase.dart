import 'package:oceanic/features/reimbursement/Domain/Repository/reimbursement_repository.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_request.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_response.dart';

class SubmitReimbursement {
  final ReimbursementRepository repository;

  SubmitReimbursement(this.repository);

  Future<SubmitReimbursementResponse> call(SubmitReimbursementRequest request) {
    return repository.submitReimbursement(request);
  }
}
