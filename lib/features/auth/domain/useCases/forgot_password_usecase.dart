import 'package:oceanic/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  Future<void> call(String memberId) {
    return repository.forgotPassword(memberId);
  }
}
