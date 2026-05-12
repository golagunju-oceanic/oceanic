import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/presentation/features/home/viewSample/auth_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _textController;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringScale = Tween<double>(
      begin: 0.4,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ringController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Detect current theme mode ──────────────────────────────
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Dynamic colors based on theme ─────────────────────────
    final bgGradientColors = isDark
        ? const [Color(0xFF0A0A0F), Color(0xFF0D1B2A), Color(0xFF0A0A0F)]
        : const [Color(0xFFF0F4FF), Color(0xFFE8F4F8), Color(0xFFF0F4FF)];

    final accentPrimary = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF2D2D8E);

    final accentSecondary = isDark
        ? const Color(0xFF7C4DFF)
        : const Color(0xFF3CC8C8);

    final ringColor = isDark
        ? const Color(0xFFFFD900)
        : const Color(0xFFF5A623);

    final taglineColor = isDark
        ? const Color(0xFF607D8B)
        : const Color(0xFF9E9E9E);

    final topGlowOpacity = isDark ? 0.08 : 0.12;
    final bottomGlowOpacity = isDark ? 0.07 : 0.10;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradientColors,
          ),
        ),
        child: Stack(
          children: [
            // Background glow — top right
            Positioned(
              top: -80.r,
              right: -80.r,
              child: Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentPrimary.withValues(alpha: topGlowOpacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Background glow — bottom left
            Positioned(
              bottom: -100.r,
              left: -60.r,
              child: Container(
                width: 300.r,
                height: 300.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentSecondary.withValues(alpha: bottomGlowOpacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160.r,
                    height: 160.r,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _ringController,
                          builder: (_, _) => Opacity(
                            opacity: _ringOpacity.value,
                            child: Transform.scale(
                              scale: _ringScale.value,
                              child: Container(
                                width: 100.r,
                                height: 100.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ringColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Logo circle
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (_, _) => Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: SizedBox(
                                width: 500.r,
                                height: 500.r,
                                child: Image.asset('assets/images/OIP.webp'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

  
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [accentPrimary, accentSecondary],
                        ).createShader(bounds),
                        child: const Text(
                          'OCEANIC HEALTH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                 10.verticalSpace,

                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Access quality healthcare services',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: taglineColor,
                        letterSpacing: 3.r,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
