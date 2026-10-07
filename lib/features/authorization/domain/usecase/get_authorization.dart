import '../../data/models/authorization_response_model.dart';
import '../repository/authorization_repository.dart';

class GetAuthorizations {
  final AuthorizationRepository repository;

  GetAuthorizations(this.repository);

  Future<AuthorizationResponseModel> call({
    String? status,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.getAuthorizations(
      status: status,
      limit: limit,
      offset: offset,
    );
  }
}