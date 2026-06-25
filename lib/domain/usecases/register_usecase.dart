import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthUser> call({
    required String memberId,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) {
    return repository.register(
      memberId: memberId,
      password: password,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}