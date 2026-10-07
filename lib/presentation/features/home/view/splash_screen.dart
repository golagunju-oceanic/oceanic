import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/auth/presentations/screen/auth_screen.dart';
import 'package:oceanic/features/dashboard/presentation/pages/dashboard_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _setupAnimations() {
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _ringScale = Tween<double>(
      begin: 0.5,
      end: 1.6,
    ).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: Curves.easeOut,
      ),
    );

    _ringOpacity = Tween<double>(
      begin: 0.6,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: Curves.easeOut,
      ),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );
  }

  Future<void> _initializeApp() async {
    // Start the splash animations.
    _ringController.forward();

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    _logoController.forward();

    // Initialize authentication while splash is visible.
    await ref.read(authProvider.notifier).initialize();

    // Keep the splash visible long enough for the animation to be seen.
    await Future.delayed(
      const Duration(milliseconds: 1400),
    );

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      _goToHome();
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthScreen(),
      ),
    );
  }

  void _goToHome() {
    // Replace this with your actual HomeScreen.
    //
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );

    // TEMPORARY:
    _goToLogin();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _logoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              scheme.primary.withValues(
                alpha: isDark ? 0.10 : 0.05,
              ),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            //
            // TOP DECORATION
            //
            Positioned(
              top: -100.r,
              right: -90.r,
              child: Container(
                width: 280.r,
                height: 280.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scheme.primary.withValues(
                        alpha: isDark ? 0.16 : 0.10,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //
            // BOTTOM DECORATION
            //
            Positioned(
              bottom: -120.r,
              left: -100.r,
              child: Container(
                width: 320.r,
                height: 320.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scheme.secondary.withValues(
                        alpha: isDark ? 0.12 : 0.08,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //
            // MAIN LOGO
            //
            Center(
              child: SizedBox(
                width: 180.r,
                height: 180.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    //
                    // ANIMATED RING
                    //
                    AnimatedBuilder(
                      animation: _ringController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _ringOpacity.value,
                          child: Transform.scale(
                            scale: _ringScale.value,
                            child: Container(
                              width: 100.r,
                              height: 100.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: scheme.tertiary,
                                  width: 2.r,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    //
                    // LOGO
                    //
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              isDark
                                  ? 'assets/images/OHMLdark.png'
                                  : 'assets/images/OHML.png',
                              width: 145.r,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}