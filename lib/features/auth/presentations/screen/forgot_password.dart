import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/presentation/features/home/viewmodel/auth_screen_provider.dart';

// class ForgotPasswordScreen extends ConsumerWidget {
//   const ForgotPasswordScreen({super.key});

//   final Color primaryPurple = const Color(0xFF4A368C);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(authProvider);
//     final viewModel = ref.read(authProvider.notifier);
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xff0065A9),
//                   const Color.fromARGB(171, 61, 170, 243),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             height: double.infinity,
//             width: double.infinity,
//           ),
//           Positioned(
//             top: 100,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: const AssetImage('assets/images/bg_img.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24.0,
//                 vertical: 20.0,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 100),

//                   const SizedBox(height: 60),

//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.9),
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Forgot Password',
//                           style: TextStyle(
//                             color: kNavyBlue,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 40),

//                         // Using the CustomTextField from your previous code
//                         const CustomTextField(
//                           hint: 'Member ID or Email',
//                           prefixIcon: Icons.person,
//                         ),

//                         const SizedBox(height: 24),
//                         Column(
//                           children: [
//                             Text(
//                               'Receive verification code via:',
//                               style: TextStyle(
//                                 color: kLightPrimary,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 RadioGroup<String>(
//                                   groupValue: state.verificationMethod,
//                                   onChanged: (val) =>
//                                       viewModel.setVerificationMethod(val!),
//                                   child: Row(
//                                     children: [
//                                       Radio<String>(
//                                         value: 'email',
//                                         activeColor: kLightPrimary,
//                                       ),
//                                       const Text(
//                                         'Email',
//                                         style: TextStyle(color: Colors.black87),
//                                       ),
//                                       const SizedBox(width: 20),
//                                       Radio<String>(
//                                         value: 'sms',
//                                         activeColor: kLightPrimary,
//                                       ),
//                                       const Text(
//                                         'SMS',
//                                         style: TextStyle(color: Colors.black87),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Submit Button
//                         SizedBox(
//                           width: double.infinity, // Full width button
//                           height: 50,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: kNavyBlue,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 2,
//                             ),
//                             onPressed: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                     'Reset link sent! Please check your email or SMS.',
//                                   ),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               'SEND RESET LINK',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<String>? autofillHints;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.onSurface.withValues(alpha: 0.06)
            : scheme.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        autofillHints: autofillHints,
        cursorColor: scheme.primary,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.2,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFF0F0FF) : const Color(0xFF1A1A3D),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: scheme.onSurface.withValues(alpha: 0.40),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Icon(prefixIcon, size: 21.r, color: scheme.primary),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 48.w),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 17.h,
          ),
        ),
      ),
    );
  }
}
