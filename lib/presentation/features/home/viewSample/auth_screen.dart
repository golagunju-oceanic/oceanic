import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/core/utils/utils.dart';
import 'package:oceanic/data/repositories/providers/user_provider.dart';
import 'package:oceanic/presentation/features/home/view/home_screen.dart';
import 'package:oceanic/presentation/features/home/viewSample/forgot_password.dart';
import 'package:oceanic/presentation/features/home/viewmodel/auth_screen_provider.dart';
import 'package:oceanic/presentation/widgets/background_image.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController memberIdController = TextEditingController();
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

  void signUpUser() {
    if (memberIdController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(context, 'Please fill in all fields');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showSnackBar(context, 'Passwords do not match');
      return;
    }

    _isActionTriggered = true;
    ref
        .read(authAsyncProvider.notifier)
        .signUp(
          memberId: memberIdController.text.trim(),
          password: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        );
  }

  void loginUser() {
    if (memberIdController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(context, 'Please fill in all fields');
      return;
    }
    _isActionTriggered = true;
    ref
        .read(authAsyncProvider.notifier)
        .login(
          memberId: memberIdController.text.trim(),
          password: passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authAsyncProvider);
    final state = ref.watch(authProvider);
    final viewModel = ref.read(authProvider.notifier);

    ref.listen(authAsyncProvider, (previous, next) {
      // Show Error
      if (next.hasError) {
        _isActionTriggered = false; // Reset on error
        showSnackBar(context, next.error.toString());
        // print(next.stackTrace);
      }

      if (!next.isLoading && !next.hasError && _isActionTriggered) {
        _isActionTriggered = false;

        if (state.isLoginView) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          showSnackBar(context, 'Account created, proceed to login');

          passwordController.clear();
          memberIdController.clear();
          confirmPasswordController.clear();
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          BackgroundImage(),

          // Main Content Layer
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  // Image.asset(
                  //   'assets/images/logo.png',
                  //   height: 80,
                  //   fit: BoxFit.contain,
                  // ),
                  const SizedBox(height: 40),
                  _buildToggleButtonSwitch(state, viewModel),
                  const SizedBox(height: 40),

                  // Animated cross-fade between Sign Up and Login
                  AnimatedCrossFade(
                    firstChild: _buildSignUpForm(
                      authAsync: authAsync,
                      state: state,
                      viewModel: viewModel,
                      confirmPasswordController: confirmPasswordController,
                      memberIdController: memberIdController,
                      passwordController: passwordController,
                    ),
                    secondChild: _buildLoginForm(
                      authAsync: authAsync,
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
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(30),
                  ),
                ),
              ),
              onPressed: () => viewModel.setLoginView(true),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  'SIGN UP',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
    required AsyncValue<void> authAsync,
  }) {
    return Column(
      children: [
        CustomTextField(
          hint: 'Member ID',
          prefixIcon: Icons.person,
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
              fontSize: 10,
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
        const SizedBox(height: 20),

        // Verification Radio Buttons
        Text(
          'Receive verification code',
          style: TextStyle(
            color: kLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
        const SizedBox(height: 30),

        // Sign Up Button
        SizedBox(
          width: 150,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kLightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: authAsync is AsyncLoading ? null : signUpUser,
            child: authAsync is AsyncLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
    required AsyncValue<void> authAsync,
  }) {
    return Column(
      children: [
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
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Login & Fingerprint Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kLightPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: authAsync is AsyncLoading ? null : loginUser,
                child: authAsync is AsyncLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kLightPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.fingerprint, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),

        const SizedBox(height: 60),

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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF4A368C)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
