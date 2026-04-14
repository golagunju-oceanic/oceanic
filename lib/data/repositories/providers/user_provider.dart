import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/data/models/user_model.dart';
import 'package:oceanic/data/repositories/services/auth_service.dart';
import 'package:oceanic/data/repositories/services/storage_service.dart';

class UserProvider extends AsyncNotifier<UserModel?> {
  AuthService authService = AuthService();

  @override
  // Future<UserModel?> build() async => Future.value();
  Future<UserModel?> build() async {
    final token = await StorageService.getToken();
    if (token == null) return null;
    return await authService.getProfile(token);
  }

  Future<void> signUp({
    required String memberId,
    required String password,
    required String confirmPassword,
    required String username,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      authService.signUp(
        memberId: memberId,
        password: password,
        confirmPassword: confirmPassword,
        username: username,
      );
    });
  }

  Future<void> login({
    required String memberId,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = await authService.login(
        memberId: memberId,
        password: password,
      );
      await StorageService.saveToken(token);
      return await authService.getProfile(token);
    });
  }
}

final authAsyncProvider = AsyncNotifierProvider<UserProvider, UserModel?>(() {
  return UserProvider();
});
