import 'package:flutter/material.dart';
import 'package:oceanic/firebase_auth/auth_services.dart';
import 'package:oceanic/presentation/features/home/view/home_screen.dart';
import 'package:oceanic/presentation/features/home/view/profile.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.pageifNotConnected});

  final Widget? pageifNotConnected;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authServices,
      builder: (context, authServices, child) {
        return StreamBuilder(
          stream: authServices.authStateChanges,

          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              widget = const ProfileScreen();
            } else {
              widget = pageifNotConnected ?? const HomeScreen();
            }
            return widget;
          },
        );
      },
    );
  }
}
