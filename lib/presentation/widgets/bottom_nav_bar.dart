import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:oceanic/presentation/features/home/view/Profile.dart';
import 'package:oceanic/presentation/features/home/view/reimbursement.dart';

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
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomeScreen(),
            ReimbursementScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 75, // Increased height makes the floating circle bigger
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: kNavyBlue,
        buttonBackgroundColor: kNavyBlue,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: _selectedIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Reimburse',
            isSelected: _selectedIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isSelected: _selectedIndex == 2,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isSelected ? 30 : 25, // Slightly larger icon when selected
            color: kDarkTextOnPrimary,
          ),
          const SizedBox(height: 3),
          if (!isSelected)
            Text(
              label,
              style: TextStyle(
                color: kDarkTextOnPrimary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
