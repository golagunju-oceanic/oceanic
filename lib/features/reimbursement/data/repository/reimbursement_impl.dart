import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_request.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_response.dart';
import '../../domain/repository/reimbursement_repository.dart';
import '../datasource/reimbursement_datasource.dart';

class ReimbursementRepositoryImpl implements ReimbursementRepository {
  final ReimbursementRemoteDataSource remoteDataSource;

  ReimbursementRepositoryImpl(this.remoteDataSource);

  @override
  Future<SubmitReimbursementResponse> submitReimbursement(
    SubmitReimbursementRequest request,
  ) async {
    return await remoteDataSource.submitReimbursement(request);
  }
}
