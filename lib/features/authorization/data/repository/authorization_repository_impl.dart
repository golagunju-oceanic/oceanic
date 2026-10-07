import '../../domain/repository/authorization_repository.dart';
import '../datasource/authorization_remote_datasource.dart';
import '../models/authorization_detail_model.dart';
import '../models/authorization_response_model.dart';

class AuthorizationRepositoryImpl implements AuthorizationRepository {
  final AuthorizationRemoteDataSource remoteDataSource;

  AuthorizationRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthorizationResponseModel> getAuthorizations({
    String? status,
    int limit = 20,
    int offset = 0,
  }) {
    return remoteDataSource.getAuthorizations(
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<AuthorizationDetailModel> getAuthorizationDetail(int authorizationId) {
    return remoteDataSource.getAuthorizationDetail(authorizationId);
  }
}
