import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/core/utils/utils.dart';
import 'package:oceanic/data/repositories/providers/user_provider.dart';
import 'package:oceanic/firebase_auth/auth_services.dart';
import 'package:oceanic/presentation/features/home/view/home_screen.dart';
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

  bool _isActionTriggered = false;

  @override
  void dispose() {
    passwordController.dispose();
    memberIdController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final AuthServices authServices = AuthServices();
  // Future<void> signUpUser() async {
  //   try {
  //     if (passwordController.text != confirmPasswordController.text) {
  //       showSnackBar(context, 'Passwords do not match');
  //       return;
  //     }

  //     await authServices.signUp(
  //       memberId: memberIdController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(e.message ?? 'An error occurred while signing up.'),
  //       ),
  //     );
  //   }

  //   // if (memberIdController.text.isEmpty ||
  //   //     passwordController.text.isEmpty ||
  //   //     usernameController.text.isEmpty ||
  //   //     confirmPasswordController.text.isEmpty) {
  //   //   showSnackBar(context, 'Please fill in all fields');
  //   //   return;
  //   // }
  //   // if (passwordController.text != confirmPasswordController.text) {
  //   //   showSnackBar(context, 'Passwords do not match');
  //   //   return;
  //   // }

  //   // _isActionTriggered = true;
  //   // ref
  //   //     .read(authAsyncProvider.notifier)
  //   //     .signUp(
  //   //       memberId: memberIdController.text.trim(),
  //   //       password: passwordController.text.trim(),
  //   //       confirmPassword: confirmPasswordController.text.trim(),
  //   //       username: usernameController.text.trim(),
  //   //     );
  // }
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
      if (mounted) {
        showSnackBar(context, 'Account created. Proceed to login.');
        // viewModel.setLoginView(true); // switch to login tab
      }
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
    // final authAsync = ref.watch(authAsyncProvider);
    final state = ref.watch(authProvider);
    final viewModel = ref.read(authProvider.notifier);

    // ref.listen(authAsyncProvider, (previous, next) {
    //   if (!_isActionTriggered) return;
    //   if (previous == null || !previous.isLoading) return;
    //   // Show Error
    //   if (next.hasError) {
    //     _isActionTriggered = false; // Reset on error
    //     showSnackBar(context, next.error.toString());
    //     print(next.stackTrace);
    //   }

    //   if (!next.isLoading && !next.hasError && _isActionTriggered) {
    //     _isActionTriggered = false;

    //     if (state.isLoginView) {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => const CustomBottomNavBar()),
    //       );
    //     } else {
    //       showSnackBar(context, 'Account created, proceed to login');

    //       passwordController.clear();
    //       memberIdController.clear();
    //       confirmPasswordController.clear();
    //     }
    //   }
    // });

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          BackgroundImage(),

          // Main Content Layer
          SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 70.h),

                  // Image.asset(
                  //   'assets/images/logo.png',
                  //   height: 80.h,
                  //   fit: BoxFit.contain,
                  // ),
                  _buildToggleButtonSwitch(state, viewModel),
                  SizedBox(height: 20.h),

                  // Animated cross-fade between Sign Up and Login
                  AnimatedCrossFade(
                    firstChild: _buildSignUpForm(
                      // authAsync: authAsync,
                      state: state,
                      viewModel: viewModel,
                      confirmPasswordController: confirmPasswordController,
                      memberIdController: memberIdController,
                      passwordController: passwordController,
                    ),
                    secondChild: _buildLoginForm(
                      // authAsync: authAsync,
                      state: state,
                      viewModel: viewModel,
                      context: context,
                      memberIdController: memberIdController,
                      passwordController: passwordController,
                    ),
                    crossFadeState: state.isLoginView
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  SizedBox(height: 20.h),
                  Image.asset(
                    'assets/images/atca.png',
                    height: 80.h,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtonSwitch(AuthState state, AuthViewModel viewModel) {
    return Container(
      width: 250.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // LOGIN BUTTON
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isLoginView
                    ? kNavyBlue
                    : Colors.transparent,
                foregroundColor: state.isLoginView ? Colors.white : kNavyBlue,
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

          // SIGN UP BUTTON
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !state.isLoginView
                    ? kNavyBlue
                    : Colors.transparent,
                foregroundColor: !state.isLoginView ? Colors.white : kNavyBlue,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(30),
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

  // --- SIGN UP VIEW ---
  Widget _buildSignUpForm({
    required AuthState state,
    required AuthViewModel viewModel,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController memberIdController,
    // required AsyncValue<void> authAsync,
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
              color: kLightPrimary,
            ),
            onPressed: viewModel.toggleSignUpPassword,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'The password must include at least one number\nand a uppercase letter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
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
              color: kLightPrimary,
            ),
            onPressed: viewModel.toggleConfirmPassword,
          ),
        ),
        SizedBox(height: 10.h),

        // Verification Radio Buttons
        Text(
          'Receive verification code',
          style: TextStyle(
            color: kLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: 'email',
              groupValue: state.verificationMethod,
              activeColor: kLightPrimary,
              onChanged: (val) => viewModel.setVerificationMethod(val!),
            ),
            const Text('Email', style: TextStyle(color: Colors.black87)),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'sms',
              groupValue: state.verificationMethod,
              activeColor: kLightPrimary,
              onChanged: (val) => viewModel.setVerificationMethod(val!),
            ),
            const Text('SMS', style: TextStyle(color: Colors.black87)),
          ],
        ),
        SizedBox(height: 10.h),

        // Sign Up Button
        SizedBox(
          width: 150.w,
          height: 30.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kLightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            onPressed: signUpUser,
            child:
                // authAsync is AsyncLoading
                //     ? const CircularProgressIndicator(color: Colors.white)
                // :
                Text(
                  'SIGN UP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
          ),
        ),
      ],
    );
  }

  // --- LOGIN VIEW ---
  Widget _buildLoginForm({
    required AuthState state,
    required AuthViewModel viewModel,
    required BuildContext context,
    required TextEditingController passwordController,
    required TextEditingController memberIdController,
    // required AsyncValue<void> authAsync,
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
              color: kLightPrimary,
            ),
            onPressed: viewModel.toggleLoginPassword,
          ),
        ),

        // Forgot Password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: Text(
              'Forgot your password',
              style: TextStyle(
                color: kLightPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Login & Fingerprint Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100.w,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kLightPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed:
                    //  authAsync is AsyncLoading ? null :
                    loginUser,
                child:
                    //  authAsync is AsyncLoading
                    //     ? const CircularProgressIndicator(color: Colors.white)
                    //     :
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 16),

            // Fingerprint Button
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: kLightPrimary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IconButton(
                icon: const Icon(Icons.fingerprint, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),

        SizedBox(height: 60.h),

        // Footer Logo (ATCA PLANS)
        // Column(
        //   children: [
        //     Icon(
        //       Icons.all_inclusive,
        //       color: Colors.pinkAccent.shade200,
        //       size: 40,
        //     ), // Placeholder icon
        //     Text(
        //       'ATCA',
        //       style: TextStyle(
        //         color: Colors.pinkAccent.shade200,
        //         fontSize: 24,
        //         fontWeight: FontWeight.bold,
        //         letterSpacing: 2,
        //       ),
        //     ),
        //     const Text(
        //       'PLANS',
        //       style: TextStyle(
        //         color: Color(0xFF4A368C),
        //         fontWeight: FontWeight.bold,
        //         letterSpacing: 4,
        //       ),
        //     ),
        //     const Text(
        //       "Everyone's covered",
        //       style: TextStyle(
        //         color: Color(0xFF4A368C),
        //         fontSize: 10,
        //         fontStyle: FontStyle.italic,
        //       ),
        //     ),
        //   ],
        // ),
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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
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
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF4A368C)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }
}
