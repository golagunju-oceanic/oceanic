import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_request.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_response.dart';

abstract class ReimbursementRepository {
  Future<SubmitReimbursementResponse> submitReimbursement(
    SubmitReimbursementRequest request,
  );
}