// import 'package:flutter/material.dart';
// import 'package:oceanic/core/constants/app_colors.dart';
// import 'package:oceanic/presentation/features/home/view/home_screen.dart';
// import 'package:oceanic/presentation/features/home/view/signup_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _isLoginTab = true;
//   bool _obscurePassword = true;
//   final _memberIdController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const SizedBox(height: 60),

//               Image.asset(
//                 'assets/images/OIP.webp',
//                 width: 100,
//                 height: 100,
//                 fit: BoxFit.cover,
//               ),
//               const SizedBox(height: 48),

//               Container(
//                 decoration: BoxDecoration(
//                   color: kLightGray,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() {
//                           _isLoginTab = false;
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SignupScreen(),
//                             ),
//                           );
//                         }),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: _isLoginTab ? Colors.transparent : kNavyBlue,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: Text(
//                             'Sign Up',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: _isLoginTab
//                                   ? Colors.black87
//                                   : Colors.white,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _isLoginTab = true),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: _isLoginTab ? kNavyBlue : Colors.transparent,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: Text(
//                             'Login',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: _isLoginTab
//                                   ? Colors.white
//                                   : Colors.black87,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//               // Member ID Field
//               _buildTextField(
//                 controller: _memberIdController,
//                 hint: 'Member ID',
//                 icon: Icons.person_outline,
//               ),
//               const SizedBox(height: 16),
//               // Password Field
//               _buildTextField(
//                 controller: _passwordController,
//                 hint: 'Password',
//                 icon: Icons.lock_outline,
//                 isPassword: true,
//                 obscure: _obscurePassword,
//                 onToggleObscure: () =>
//                     setState(() => _obscurePassword = !_obscurePassword),
//               ),
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   'Forgot your password?',
//                   style: TextStyle(
//                     color: kNavyBlue,
//                     fontStyle: FontStyle.italic,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // Login Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomeScreen()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kNavyBlue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     bool obscure = false,
//     VoidCallback? onToggleObscure,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kLightGray,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextField(
//         controller: controller,
//         obscureText: isPassword && obscure,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(color: kTextGray),
//           prefixIcon: Icon(icon, color: kTextGray),
//           suffixIcon: isPassword
//               ? IconButton(
//                   icon: Icon(
//                     obscure
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: kTextGray,
//                   ),
//                   onPressed: onToggleObscure,
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//       ),
//     );
//   }
// }
