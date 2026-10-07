import '../../data/models/authorization_detail_model.dart';
import '../repository/authorization_repository.dart';

class GetAuthorizationDetail {
  final AuthorizationRepository repository;

  GetAuthorizationDetail(this.repository);

  Future<AuthorizationDetailModel> call(int authorizationId) {
    return repository.getAuthorizationDetail(authorizationId);
  }
}
