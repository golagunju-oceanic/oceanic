import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exception.dart';

import '../models/agora_token_response.dart';
import '../models/generate_token_request.dart';

class TelemedicineRemoteDataSource {
  final ApiClient apiClient;

  TelemedicineRemoteDataSource(this.apiClient);

  Future<AgoraTokenResponse> generateToken(
    GenerateTokenRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        '/telemedicine/token',
        body: request.toJson(),
      );

      return AgoraTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException.fromDio(e);
    }
  }
}