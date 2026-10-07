import '../../data/models/authorization_detail_model.dart';
import '../../data/models/authorization_response_model.dart';

abstract class AuthorizationRepository {
  Future<AuthorizationResponseModel> getAuthorizations({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<AuthorizationDetailModel> getAuthorizationDetail(int authorizationId);
}
