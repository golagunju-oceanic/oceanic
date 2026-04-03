import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: kNavyBlue,
      buttonBackgroundColor: kNavyBlue,
      index: index,
      height: MediaQuery.of(context).size.height * 0.05,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 800),
      items: <Widget>[
        Icon(Icons.add, size: 30, color: kDarkTextOnPrimary),
        Icon(Icons.list, size: 30, color: kDarkTextOnPrimary),
        Icon(Icons.compare_arrows, size: 30, color: kDarkTextOnPrimary),
      ],
      onTap: (index) {
        setState(() {
          this.index = index;
        });
      },
    );
  }
}
