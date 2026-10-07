import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/core/utils/utils.dart';
import 'package:oceanic/features/auth/data/models/login_request.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/auth/presentations/screen/forgot_password.dart';
import 'package:oceanic/features/doctor/dashboard/presentation/doctor_dashboard.dart';
import 'package:oceanic/presentation/widgets/background_image.dart';
import 'package:oceanic/presentation/widgets/bottom_nav_bar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final memberIdController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    memberIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    final memberId = memberIdController.text.trim();
    final password = passwordController.text.trim();

    if (memberId.isEmpty) {
      showSnackBar(context, 'Please enter your Member ID');
      return;
    }

    if (password.isEmpty) {
      showSnackBar(context, 'Please enter your password');
      return;
    }

    final viewModel = ref.read(authProvider.notifier);

    await viewModel.login(
      LoginRequest(identifier: memberId, password: password),
    );

    final state = ref.read(authProvider);

    if (!mounted) return;

    if (state.error != null) {
      showSnackBar(context, state.error!);
      return;
    }

    final isDoctor = state.user?.isDoctor ?? false;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isDoctor
            ? const DoctorDashboardScreen()
            : const CustomBottomNavBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(authProvider);
    final viewModel = ref.read(authProvider.notifier);

    final outsideTitleColor = isDark
        ? const Color(0xFFF7F8FF)
        : const Color(0xFF0D1B3D);

    final outsideBodyColor = isDark
        ? const Color(0xFFD2D8E8)
        : const Color(0xFF16264A);

    final outsideSecondaryColor = isDark
        ? const Color(0xFFB9C2D8)
        : const Color(0xFF243557);

    final labelColor = isDark
        ? const Color(0xFFE6E9F2)
        : const Color(0xFF252A42);

    final hintColor = isDark
        ? const Color(0xFF7E89A8)
        : const Color(0xFF7D879B);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          //
          // YOUR EXISTING LIGHT / DARK BACKGROUND
          //
          const Positioned.fill(child: BackgroundImage()),

          //
          // VERY LIGHT OVERLAY
          // Keeps text readable without hiding your background.
          //
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: !isDark
                      ? [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.28),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.10),
                        ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Column(
                children: [
                  //
                  // LOGO
                  //
                  Center(
                    child: Image.asset(
                      isDark
                          ? 'assets/images/OHMLdark.png'
                          : 'assets/images/OHML.png',
                      width: 2500.w,
                      height: 100.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  //
                  // WELCOME TEXT
                  //
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.sp,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: outsideTitleColor,
                        shadows: isDark
                            ? null
                            : [
                                Shadow(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  blurRadius: 5.r,
                                ),
                              ],
                      ),
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sign in to continue to your Oceanic account.',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: outsideBodyColor,
                        shadows: isDark
                            ? null
                            : [
                                Shadow(
                                  color: Colors.white.withValues(alpha: 0.40),
                                  blurRadius: 4.r,
                                ),
                              ],
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  //
                  // LOGIN CARD
                  //
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 18.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF10182D).withValues(alpha: 0.90)
                          : Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: scheme.onSurface.withValues(
                          alpha: isDark ? 0.10 : 0.05,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.18 : 0.06,
                          ),
                          blurRadius: 18.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 3.h),

                        Text(
                          'Enter your account details below.',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: scheme.onSurface.withValues(alpha: 0.52),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        //
                        // MEMBER ID LABEL
                        //
                        Text(
                          'Member ID',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        CustomTextField(
                          hint: 'Enter your Member ID',
                          prefixIcon: Icons.badge_outlined,
                          controller: memberIdController,
                          textInputAction: TextInputAction.next,
                        ),

                        SizedBox(height: 12.h),

                        //
                        // PASSWORD LABEL
                        //
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        CustomTextField(
                          controller: passwordController,
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: state.obscureLoginPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!state.isLoading) {
                              loginUser();
                            }
                          },
                          suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              state.obscureLoginPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 19.r,
                              color: scheme.onSurface.withValues(alpha: 0.50),
                            ),
                            onPressed: viewModel.toggleLoginPassword,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        //
                        // FORGOT PASSWORD
                        //
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 5.h,
                                horizontal: 2.w,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (_) =>
                              //         const ForgotPasswordScreen(),
                              //   ),
                              // );
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 14.h),

                        //
                        // LOGIN BUTTON
                        //
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : loginUser,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              disabledBackgroundColor: scheme.primary
                                  .withValues(alpha: 0.50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: state.isLoading
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.r,
                                      color: scheme.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 7.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18.r,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  //
                  // SECURITY MESSAGE
                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.secondary.withValues(alpha: 0.15)
                              : const Color(0xFF0D1B3D).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 17.r,
                          color: isDark
                              ? scheme.secondary
                              : const Color(0xFF0D1B3D),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Flexible(
                        child: Text(
                          'Your information is securely protected',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            color: outsideSecondaryColor,
                            shadows: isDark
                                ? null
                                : [
                                    Shadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 4.r,
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  //
                  // ATCA
                  //
                  Image.asset(
                    'assets/images/atca.png',
                    width: 180.w,
                    height: 75.h,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
