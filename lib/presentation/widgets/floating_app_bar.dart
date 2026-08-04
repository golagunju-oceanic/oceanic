import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';

class FloatingAppBar extends StatefulWidget {
  final ScrollController scrollController;
  final String text;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  const FloatingAppBar({
    required this.scrollController,
    required this.text,
    this.onMenuTap,
    this.onProfileTap,
    super.key,
  });

  @override
  State<FloatingAppBar> createState() => _FloatingAppBarState();
}

class _FloatingAppBarState extends State<FloatingAppBar> {
  double _offset = 0;

  bool get _isScrolled => _offset > 15;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted && widget.scrollController.hasClients) {
      setState(() => _offset = widget.scrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isScrolled ? 10 : 0,
            sigmaY: _isScrolled ? 10 : 0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 64,
            decoration: BoxDecoration(
              color: _isScrolled
                  ? kNavyBlue.withValues(alpha: 0.92)
                  : Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isScrolled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isScrolled ? 0.18 : 0.06,
                  ),
                  blurRadius: _isScrolled ? 24 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onMenuTap,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: _isScrolled ? Colors.white : kNavyBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _isScrolled
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      child: Text(
                        widget.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onProfileTap ?? () {},
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? Colors.white.withValues(alpha: 0.15)
                            : kNavyBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: _isScrolled ? Colors.white : kNavyBlue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
