
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoginView;
  final bool obscureLoginPassword;
  final bool obscureSignUpPassword;
  final bool obscureConfirmPassword;
  final String verificationMethod; // 'email' or 'sms'

  AuthState({
    this.isLoginView = false, // Starts on Sign Up as per the left image
    this.obscureLoginPassword = true,
    this.obscureSignUpPassword = true,
    this.obscureConfirmPassword = true,
    this.verificationMethod = 'email',
  });

  AuthState copyWith({
    bool? isLoginView,
    bool? obscureLoginPassword,
    bool? obscureSignUpPassword,
    bool? obscureConfirmPassword,
    String? verificationMethod,
  }) {
    return AuthState(
      isLoginView: isLoginView ?? this.isLoginView,
      obscureLoginPassword: obscureLoginPassword ?? this.obscureLoginPassword,
      obscureSignUpPassword: obscureSignUpPassword ?? this.obscureSignUpPassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      verificationMethod: verificationMethod ?? this.verificationMethod,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  void setLoginView(bool isLogin) {
    state = state.copyWith(isLoginView: isLogin);
  }

  void toggleLoginPassword() {
    state = state.copyWith(obscureLoginPassword: !state.obscureLoginPassword);
  }

  void toggleSignUpPassword() {
    state = state.copyWith(obscureSignUpPassword: !state.obscureSignUpPassword);
  }

  void toggleConfirmPassword() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  void setVerificationMethod(String method) {
    state = state.copyWith(verificationMethod: method);
  }
}

// The Riverpod provider for our ViewModel
final authProvider = NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);