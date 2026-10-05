class ApiConstants {
  ApiConstants._();

  /// Android Emulator
  // static const baseUrl = "http://10.0.2.2:3000/api";

  /// iOS Simulator
  // static const baseUrl = "http://localhost:3000/api";

  /// Physical Device
  // static const baseUrl = "http://192.168.1.100:3000/api";

  /// Production

  static const baseUrl = "https://oceanic-mobile-backend-1.onrender.com/api";

  static const login = "/api/auth/login";

  static const register = "/auth/register";

  static const me = "/api/auth/me";

  static const forgotPassword = "/api/auth/forgot-password";

  static const resetPassword = "/api/auth/reset-password";
}
