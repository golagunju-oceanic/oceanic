
import 'package:oceanic/features/auth/data/models/user_models.dart';
import 'package:oceanic/features/auth/domain/repositories/auth_repository.dart';

class MeUsecase {
final AuthRepository repository;
MeUsecase(this.repository);
  
  Future<UserModel> call(){
    return repository.me();
  }
}