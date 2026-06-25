import 'package:dio/dio.dart';
import 'package:oceanic/data/models/user_model.dart';


class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<AuthUserModel> register({
    required String memberId,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    final response = await dio.post(
      'https://oceanic-mobile-backend.onrender.com/api/auth/register',
      data: {
        'memberId': memberId,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      },
    );
    return AuthUserModel.fromJson(response.data);
  }
}