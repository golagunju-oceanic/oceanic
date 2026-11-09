import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:oceanic/core/network/network_exception.dart';
import 'package:oceanic/core/services/notification_device_service.dart';

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

  late final NotificationDeviceService notificationDeviceService;

  @override
  AuthState build() {
    loginUseCase = ref.read(loginUseCaseProvider);
    registerUseCase = ref.read(registerUseCaseProvider);
    meUseCase = ref.read(meUseCaseProvider);

    forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);

    resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);

    storage = ref.read(secureStorageProvider);

    notificationDeviceService = ref.read(notificationDeviceServiceProvider);

    return const AuthState();
  }

  // =====================================================
  // START NOTIFICATION REGISTRATION AFTER AUTHENTICATION
  // =====================================================

  void _registerAuthenticatedDevice() {
    final user = state.user;
    final token = state.token;

    if (user == null || token == null || token.isEmpty) {
      return;
    }

    // The current Node.js notification endpoints
    // are available to enrollees only.
    if (user.role.toLowerCase() != 'member') {
      return;
    }

    final memberId = user.memberId?.trim();

    if (memberId == null || memberId.isEmpty) {
      return;
    }

    // This is deliberately non-blocking.
    // FCM failures must not prevent login.
    unawaited(
      notificationDeviceService.start(memberId: memberId).catchError((
        Object error,
      ) {
        debugPrint('Notification registration could not start: $error');
      }),
    );
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> login(LoginRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await loginUseCase(request);

      // The JWT must be saved before making
      // authenticated notification requests.
      await storage.write(key: 'token', value: response.token);

      state = state.copyWith(
        token: response.token,
        user: response.user,
        isLoading: false,
        error: null,
      );

      // Existing profile loading behaviour.
      await loadProfile();

      // Register the device after authentication.
      _registerAuthenticatedDevice();
    } catch (e) {
      final message = e is NetworkException
          ? e.message
          : 'Something went wrong during login';

      state = state.copyWith(isLoading: false, error: message);
    }
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<void> register(RegisterRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await registerUseCase(request);

      await storage.write(key: 'token', value: response.token);

      state = state.copyWith(
        token: response.token,
        user: response.user,
        isLoading: false,
        error: null,
      );

      await loadProfile();

      _registerAuthenticatedDevice();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is NetworkException ? e.message : e.toString(),
      );
    }
  }

  // =====================================================
  // LOAD FULL PROFILE
  // =====================================================

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await meUseCase();

      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is NetworkException ? e.message : 'Unable to load profile',
      );
    }
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<void> forgotPassword(String memberId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await forgotPasswordUseCase(memberId);

      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await resetPasswordUseCase(token: token, password: password);

      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    try {
      // Unregister while the JWT is still available.
      // A timeout prevents an unavailable backend
      // from keeping the user stuck on logout.
      await notificationDeviceService.stop().timeout(
        const Duration(seconds: 5),
      );
    } catch (error) {
      debugPrint('Unable to unregister FCM device: $error');
    } finally {
      // Always clear authentication locally.
      await storage.delete(key: 'token');

      state = const AuthState();
    }
  }

  // =====================================================
  // AUTH UI CONTROLS
  // =====================================================

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

  // =====================================================
  // RESTORE EXISTING SESSION
  // =====================================================

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(token: token);

      final user = await meUseCase();

      state = state.copyWith(
        token: token,
        user: user,
        isLoading: false,
        error: null,
      );

      // Register automatically on app reopening.
      _registerAuthenticatedDevice();
    } catch (e) {
      // Preserve the JWT if this was a temporary
      // network or profile-loading failure.
      state = state.copyWith(
        isLoading: false,
        error: e is NetworkException
            ? e.message
            : 'Unable to restore your profile',
      );
    }
  }
}
