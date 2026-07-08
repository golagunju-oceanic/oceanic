import 'package:oceanic/features/auth/data/models/user_models.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? token;
  final String? error;

  final bool isLoginView;

  final bool obscureLoginPassword;
  final bool obscureSignUpPassword;
  final bool obscureConfirmPassword;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
    this.isLoginView = true,
    this.obscureLoginPassword = true,
    this.obscureSignUpPassword = true,
    this.obscureConfirmPassword = true,
  });

  bool get isAuthenticated =>
      token != null && user != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? token,
    String? error,
    bool? isLoginView,
    bool? obscureLoginPassword,
    bool? obscureSignUpPassword,
    bool? obscureConfirmPassword,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
      isLoginView: isLoginView ?? this.isLoginView,
      obscureLoginPassword:
          obscureLoginPassword ??
          this.obscureLoginPassword,
      obscureSignUpPassword:
          obscureSignUpPassword ??
          this.obscureSignUpPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ??
          this.obscureConfirmPassword,
    );
  }
}