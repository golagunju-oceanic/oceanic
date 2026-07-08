
import 'package:oceanic/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:oceanic/features/auth/data/models/login_request.dart';
import 'package:oceanic/features/auth/data/models/login_response.dart';
import 'package:oceanic/features/auth/data/models/register_request.dart';
import 'package:oceanic/features/auth/data/models/user_models.dart';
import 'package:oceanic/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<LoginResponse> login(
    LoginRequest request,
  ) {
    return remote.login(request);
  }

  @override
  Future<LoginResponse> register(
    RegisterRequest request,
  ) {
    return remote.register(request);
  }

  @override
  Future<UserModel> me() {
    return remote.me();
  }

  @override
  Future<void> forgotPassword(
    String memberId,
  ) {
    return remote.forgotPassword(memberId);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) {
    return remote.resetPassword(
      token: token,
      password: password,
    );
  }
}