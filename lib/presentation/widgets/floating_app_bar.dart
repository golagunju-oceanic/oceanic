import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';

class FloatingAppBar extends StatefulWidget {
  final ScrollController scrollController;
  final String username;

  const FloatingAppBar({
    required this.scrollController,
    required this.username,
    // required this.navAction,
    super.key,
  });

  @override
  State<FloatingAppBar> createState() => _FloatingAppBarState();
}

class _FloatingAppBarState extends State<FloatingAppBar> {
  double _offset = 0;

  bool get _isScrolled => _offset > 10;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _offset = widget.scrollController.offset);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 70,
        decoration: BoxDecoration(
          color: _isScrolled ? kNavyBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isScrolled ? 0.2 : 0.08),
              blurRadius: _isScrolled ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: Icon(
                    Icons.menu_rounded,
                    color: _isScrolled ? Colors.white : kNavyBlue,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _isScrolled ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                  child: Text('Hello ${widget.username}'),
                ),
              ),
              // _FloatingNavAction(
              //   icon: Icons.notifications_none_rounded,
              //   isScrolled: _isScrolled,
              //   onTap: () {},
              //   badgeCount: 2,
              // ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isScrolled
                        ? Colors.white.withOpacity(0.15)
                        : kNavyBlue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _isScrolled ? Colors.white : kNavyBlue,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
