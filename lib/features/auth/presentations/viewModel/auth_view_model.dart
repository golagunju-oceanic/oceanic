import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oceanic/core/network/network_exception.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';

import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/me_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../state/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;
  late final MeUsecase meUseCase;
  late final ForgotPasswordUsecase forgotPasswordUseCase;
  late final ResetPasswordUseCase resetPasswordUseCase;
  late final FlutterSecureStorage storage;

  @override
  AuthState build() {
    loginUseCase = ref.read(loginUseCaseProvider);
    registerUseCase = ref.read(registerUseCaseProvider);
    meUseCase = ref.read(meUseCaseProvider);
    forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
    resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);

    storage = ref.read(secureStorageProvider);

    return const AuthState();
  }

  Future<void> login(LoginRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await loginUseCase(request);

      await storage.write(key: "token", value: response.token);
      final savedToken = await storage.read(key: "token");
      print("TOKEN SAVED: $savedToken");

      state = state.copyWith(
        isLoading: false,
        token: response.token,
        user: response.user,
      );
    } catch (e) {
      String message;

      if (e is NetworkException) {
        message = e.message;
      } else {
        message = "Something went wrong";
      }
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await registerUseCase(request);

      await storage.write(key: "token", value: response.token);

      state = state.copyWith(
        isLoading: false,
        token: response.token,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true);

      final user = await meUseCase();

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> forgotPassword(String memberId) async {
    try {
      state = state.copyWith(isLoading: true);

      await forgotPasswordUseCase(memberId);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      await resetPasswordUseCase(token: token, password: password);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');

    state = const AuthState();
  }

  void setLoginView(bool value) {
    state = state.copyWith(isLoginView: value);
  }

  void toggleLoginPassword() {
    state = state.copyWith(obscureLoginPassword: !state.obscureLoginPassword);
  }

  void toggleSignUpPassword() {
    state = state.copyWith(obscureSignUpPassword: !state.obscureSignUpPassword);
  }

  void toggleConfirmPassword() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  Future<void> initialize() async {
    final token = await storage.read(key: "token");

    if (token == null) return;

    try {
      final user = await meUseCase();

      state = state.copyWith(token: token, user: user);
    } catch (_) {
      await storage.delete(key: "token");
    }
  }
}
