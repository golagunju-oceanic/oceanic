import 'package:dio/dio.dart';
import 'package:oceanic/core/network/network_exception.dart';
import 'package:oceanic/features/auth/data/models/login_request.dart';
import 'package:oceanic/features/auth/data/models/login_response.dart';
import 'package:oceanic/features/auth/data/models/register_request.dart';
import 'package:oceanic/features/auth/data/models/user_models.dart';

import '../../../../core/network/api_client.dart';


class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

Future<LoginResponse> register(
  RegisterRequest request,
) async {
  final response = await apiClient.post(
    '/auth/register',
    body: request.toJson(),
  );

  return LoginResponse.fromJson(response.data);
}
Future<LoginResponse> login(
  LoginRequest request,
) async {
  try{
  final response = await apiClient.post(
    '/auth/login',
    body: request.toJson(),
  );

  return LoginResponse.fromJson(response.data);} on DioException catch(e){
    throw NetworkException.fromDio(e);
  }
}
  Future<UserModel> me() async {
    final response = await apiClient.get('/auth/me');

    return UserModel.fromJson(response.data['data']);
  }

  Future<void> forgotPassword(String memberId) async {
    await apiClient.post('/auth/forgot-password', body: {"memberId": memberId});
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await apiClient.post(
      '/auth/reset-password',
      body: {"token": token, "password": password},
    );
  }
}
