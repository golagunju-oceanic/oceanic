import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/data/repositories/services/auth_service.dart';
import 'package:oceanic/firebase_auth/auth_services.dart';
import 'package:oceanic/presentation/features/home/viewSample/auth_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 45, 45, 142),
                  kNavyBlue,
                  Color.fromARGB(199, 45, 45, 142),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // color: Color.fromARGB(199, 45, 45, 142),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Logout'),
            onTap: () {
              // Implement logout functionality
              AuthServices().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
