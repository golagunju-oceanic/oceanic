import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  final List<_BottomNavItem> _items = const [
    _BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _BottomNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Reimburse',
    ),
    _BottomNavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // Allows the page background to continue behind
      // the floating navigation dock.
      extendBody: true,

      body: IndexedStack(
        index: _selectedIndex,
        children: const [HomeScreen(), ReimbursementScreen(), ProfileScreen()],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.09),
                blurRadius: 24.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              return Expanded(
                child: _buildNavItem(
                  item: _items[index],
                  index: index,
                  scheme: scheme,
                  isDark: isDark,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _BottomNavItem item,
    required int index,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_selectedIndex == index) {
            return;
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(18.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withValues(alpha: isDark ? 0.18 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: isSelected ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: isSelected ? 19.r : 20.r,
                  color: isSelected
                      ? scheme.onPrimary
                      : scheme.onSurface.withValues(alpha: 0.48),
                ),
              ),

              SizedBox(height: 3.h),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 9.6.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.48),
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
