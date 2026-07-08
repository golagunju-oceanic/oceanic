import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/core/utils/utils.dart';

import 'package:oceanic/features/auth/data/models/login_request.dart';
import 'package:oceanic/features/auth/data/models/register_request.dart';

import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/auth/presentations/screen/forgot_password.dart';
import 'package:oceanic/features/auth/presentations/state/auth_state.dart';
import 'package:oceanic/features/auth/presentations/viewModel/auth_view_model.dart';

import 'package:oceanic/presentation/widgets/background_image.dart';
import 'package:oceanic/presentation/widgets/bottom_nav_bar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  /// Register Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  /// Shared
  final memberIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    memberIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> registerUser() async {
    final viewModel = ref.read(authProvider.notifier);

    if (passwordController.text != confirmPasswordController.text) {
      showSnackBar(context, "Passwords do not match");
      return;
    }

    await viewModel.register(
      RegisterRequest(
        memberId: memberIdController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );

    final state = ref.read(authProvider);

    if (!mounted) return;

    if (state.error != null) {
      showSnackBar(context, state.error!);
      return;
    }

    showSnackBar(context, "Registration Successful");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomBottomNavBar()),
    );
  }

  Future<void> loginUser() async {
    final viewModel = ref.read(authProvider.notifier);

    await viewModel.login(
      LoginRequest(
        memberId: memberIdController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );

    final state = ref.read(authProvider);

    if (!mounted) return;

    if (state.error != null) {
      showSnackBar(context, state.error!);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomBottomNavBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(authProvider);
    final viewModel = ref.read(authProvider.notifier);
    final theme = Theme.of(context).brightness;
    return Scaffold(
      body: Stack(
        children: [
          BackgroundImage(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        height: 80.h,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(
                                'assets/images/full_bg.png',
                                fit: BoxFit.cover,
                                cacheWidth: 700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _buildToggleButtonSwitch(state, viewModel, scheme),
                      SizedBox(height: 20.h),
                      AnimatedCrossFade(
                        firstChild: _buildSignUpForm(
                          state: state,
                          viewModel: viewModel,
                          scheme: scheme,
                        ),
                        secondChild: _buildLoginForm(
                          state: state,
                          viewModel: viewModel,
                          scheme: scheme,
                        ),
                        crossFadeState: state.isLoginView
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 80.h, // explicit finite height
                        child: Image.asset(
                          'assets/images/atca.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtonSwitch(
    AuthState state,
    AuthViewModel viewModel,
    ColorScheme scheme,
  ) {
    return Container(
      width: 250.w,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isLoginView
                    ? scheme.primary
                    : Colors.transparent,
                foregroundColor: state.isLoginView
                    ? scheme.onPrimary
                    : scheme.primary,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(30.r),
                  ),
                ),
              ),
              onPressed: () => viewModel.setLoginView(true),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !state.isLoginView
                    ? scheme.primary
                    : Colors.transparent,
                foregroundColor: !state.isLoginView
                    ? scheme.onPrimary
                    : scheme.primary,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(30.r),
                  ),
                ),
              ),
              onPressed: () => viewModel.setLoginView(false),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm({
    required AuthState state,
    required AuthViewModel viewModel,
    required ColorScheme scheme,
  }) {
    return Column(
      children: [
        CustomTextField(
          hint: 'First Name',
          prefixIcon: Icons.person_outline,
          controller: firstNameController,
        ),

        CustomTextField(
          hint: 'Last Name',
          prefixIcon: Icons.person_outline,
          controller: lastNameController,
        ),

        CustomTextField(
          hint: 'Member ID',
          prefixIcon: Icons.badge_outlined,
          controller: memberIdController,
        ),

        CustomTextField(
          hint: 'Email Address',
          prefixIcon: Icons.email_outlined,
          controller: emailController,
        ),

        CustomTextField(
          hint: 'Phone Number',
          prefixIcon: Icons.phone_outlined,
          controller: phoneController,
        ),

        CustomTextField(
          controller: passwordController,
          hint: 'Password',
          prefixIcon: Icons.lock_outline,
          obscureText: state.obscureSignUpPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureSignUpPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: viewModel.toggleSignUpPassword,
          ),
        ),

        CustomTextField(
          controller: confirmPasswordController,
          hint: 'Confirm Password',
          prefixIcon: Icons.lock_outline,
          obscureText: state.obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: viewModel.toggleConfirmPassword,
          ),
        ),

        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),

        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: state.isLoading ? null : registerUser,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "CREATE ACCOUNT",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm({
    required AuthState state,
    required AuthViewModel viewModel,
    required ColorScheme scheme,
  }) {
    return Column(
      children: [
        CustomTextField(
          hint: 'Member ID',
          prefixIcon: Icons.badge_outlined,
          controller: memberIdController,
        ),

        CustomTextField(
          controller: passwordController,
          hint: 'Password',
          prefixIcon: Icons.lock_outline,
          obscureText: state.obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureLoginPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: viewModel.toggleLoginPassword,
          ),
        ),

        // if (state.error != null)
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 12),
        //     child: Text(
        //       state.error!,
        //       style: const TextStyle(color: Colors.red),
        //       textAlign: TextAlign.center,
        //     ),
        //   ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: const Text("Forgot Password?"),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : loginUser,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("LOGIN"),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.fingerprint, color: scheme.onPrimary),
                onPressed: () {},
              ),
            ),
          ],
        ),

        SizedBox(height: 40.h),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: 14.sp, color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
          prefixIcon: Icon(prefixIcon, color: scheme.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16.h),
        ),
      ),
    );
  }
}
