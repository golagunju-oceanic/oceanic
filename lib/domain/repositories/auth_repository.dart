import 'package:oceanic/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> register({
    required String memberId,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  });
}
