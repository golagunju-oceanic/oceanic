import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/presentation/features/home/view/Profile.dart';
import 'package:oceanic/presentation/features/home/view/home_screen.dart';
import 'package:oceanic/presentation/features/home/view/telemedicine.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});
  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          TelemedicineConsentScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: kNavyBlue,
        buttonBackgroundColor: kNavyBlue,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home_outlined, size: 30, color: kDarkTextOnPrimary),
          Icon(Icons.video_call_outlined, size: 30, color: kDarkTextOnPrimary),
          Icon(Icons.person_outline, size: 30, color: kDarkTextOnPrimary),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
