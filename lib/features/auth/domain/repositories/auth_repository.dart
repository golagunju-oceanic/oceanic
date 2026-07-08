import 'package:oceanic/features/auth/data/models/login_request.dart';
import 'package:oceanic/features/auth/data/models/login_response.dart';
import 'package:oceanic/features/auth/data/models/register_request.dart';
import 'package:oceanic/features/auth/data/models/user_models.dart';

abstract class AuthRepository {
  Future<LoginResponse> register(RegisterRequest request);

  Future<LoginResponse> login(LoginRequest request);

  Future<UserModel> me();

  Future<void> forgotPassword(String memberId);

  Future<void> resetPassword({
    required String token,
    required String password,
  });
}