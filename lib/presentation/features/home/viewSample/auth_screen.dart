import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/utils/utils.dart';
import 'package:oceanic/firebase_auth/auth_services.dart';
import 'package:oceanic/presentation/features/home/viewSample/forgot_password.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/presentation/features/home/viewmodel/auth_screen_provider.dart';
import 'package:oceanic/presentation/widgets/background_image.dart';
import 'package:oceanic/presentation/widgets/bottom_nav_bar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController memberIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthServices authServices = AuthServices();

  @override
  void dispose() {
    passwordController.dispose();
    memberIdController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> signUpUser() async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        showSnackBar(context, 'Passwords do not match');
        return;
      }
      await authServices.signUp(
        memberId: memberIdController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) showSnackBar(context, 'Account created. Proceed to login.');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign up failed.')));
      }
    }
  }

  Future<void> loginUser() async {
    try {
      await authServices.signIn(
        memberId: memberIdController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomBottomNavBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign in failed.')));
      }
    }
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
          hint: 'Full Name',
          prefixIcon: Icons.person,
          controller: usernameController,
        ),
        CustomTextField(
          hint: 'Member ID',
          prefixIcon: Icons.numbers,
          controller: memberIdController,
        ),
        CustomTextField(
          controller: passwordController,
          hint: 'New Password',
          prefixIcon: Icons.lock,
          obscureText: state.obscureSignUpPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureSignUpPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: scheme.primary,
            ),
            onPressed: viewModel.toggleSignUpPassword,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'The password must include at least one number\nand a uppercase letter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10.sp,
            ),
          ),
        ),
        CustomTextField(
          controller: confirmPasswordController,
          hint: 'Confirm Password',
          prefixIcon: Icons.lock,
          obscureText: state.obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: scheme.primary,
            ),
            onPressed: viewModel.toggleConfirmPassword,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Receive verification code',
          style: TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadioGroup<String>(
              groupValue: state.verificationMethod,
              onChanged: (val) => viewModel.setVerificationMethod(val!),
              child: Row(
                children: [
                  Radio<String>(value: 'email', activeColor: scheme.primary),
                  Text('Email', style: TextStyle(color: scheme.onSurface)),
                  const SizedBox(width: 20),
                  Radio<String>(value: 'sms', activeColor: scheme.primary),
                ],
              ),
            ),
            Text('SMS', style: TextStyle(color: scheme.onSurface)),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 150.w,
          height: 30.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            onPressed: signUpUser,
            child: Text(
              'SIGN UP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
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
        SizedBox(height: 20.h),
        CustomTextField(
          hint: 'Member ID',
          prefixIcon: Icons.person,
          controller: memberIdController,
        ),
        CustomTextField(
          controller: passwordController,
          hint: 'Password',
          prefixIcon: Icons.lock,
          obscureText: state.obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureLoginPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: scheme.primary,
            ),
            onPressed: viewModel.toggleLoginPassword,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: Text(
              'Forgot your password',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100.w,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: loginUser,
                child: const Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IconButton(
                icon: Icon(Icons.fingerprint, color: scheme.onPrimary),
                onPressed: () {},
              ),
            ),
          ],
        ),
        SizedBox(height: 60.h),
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
