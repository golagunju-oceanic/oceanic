import '../../../../core/network/api_client.dart';
import '../models/authorization_detail_model.dart';
import '../models/authorization_response_model.dart';

class AuthorizationRemoteDataSource {
  final ApiClient apiClient;

  AuthorizationRemoteDataSource(this.apiClient);

  Future<AuthorizationResponseModel> getAuthorizations({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await apiClient.get(
      '/authorization',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return AuthorizationResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AuthorizationDetailModel> getAuthorizationDetail(
    int authorizationId,
  ) async {
    final response = await apiClient.get('/authorization/$authorizationId');

    return AuthorizationDetailModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}
