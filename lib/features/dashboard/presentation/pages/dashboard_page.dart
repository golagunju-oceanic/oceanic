import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/features/Telemedicine/data/datasource/call_notification_service.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/doctor_selection_screen.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/health_provider/presentation/views/health_provider.dart';
import 'package:oceanic/features/medical-request/presentation/view/medical_request.dart';
import 'package:oceanic/features/policy/presentation/view/policy_details.dart';
import 'package:oceanic/main.dart';
import 'package:oceanic/features/authorization/presentation/view/authorization_screen.dart';
import 'package:oceanic/presentation/features/home/view/health_record.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  late final PageController _pageController;

  Timer? _bannerTimer;

  int _currentBanner = 0;

  // ============================================================
  // BANNERS
  // ============================================================

  final List<Map<String, String>> _banners = [
    {
      'title': 'Sustaining Your Peace',
      'subtitle': 'Comprehensive health coverage tailored to fit your life.',
      'image': 'assets/images/banner1.jpg',
    },
    {
      'title': 'Personalized Care Always',
      'subtitle': 'High-quality healthcare with empathy, trust, and integrity.',
      'image': 'assets/images/banner2.jpg',
    },
    {
      'title': 'Your Health Matters',
      'subtitle': 'Access quality medical services wherever you are.',
      'image': 'assets/images/banner3.jpg',
    },
  ];

  // ============================================================
  // SERVICES
  // ============================================================

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.shield_outlined,
      'title': 'Policy Details',
      'subtitle': 'View your health benefits',
      'route': const PolicyDetailsScreen(),
    },
    {
      'icon': Icons.assignment_turned_in_outlined,
      'title': 'Authorizations',
      'subtitle': 'Track treatment approvals',
      'route': const AuthorizationScreen(),
    },
    {
      'icon': Icons.folder_shared_outlined,
      'title': 'Health Records',
      'subtitle': 'Medical history & reports',
      'route': const HealthRecord(),
    },
    {
      'icon': Icons.video_camera_front_outlined,
      'title': 'Telemedicine',
      'subtitle': 'Consult a doctor online',
      'route': const DoctorSelectionScreen(),
    },
    {
      'icon': Icons.medication_liquid_outlined,
      'title': 'Medication',
      'subtitle': 'Request prescribed drugs',
      'route': const MedicalRequest(),
    },
    {
      'icon': Icons.local_hospital_outlined,
      'title': 'Find a Provider',
      'subtitle': 'Locate healthcare providers',
      'route': const HealthProvider(),
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.92);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBannerTimer();
    });

    _initDoctorSocket();
  }

  // ============================================================
  // DOCTOR SOCKET
  // ============================================================

  void _initDoctorSocket() {
    final user = ref.read(authProvider).user;

    if (user != null && user.role.toUpperCase() == 'DOCTOR') {
      CallNotificationService.initDoctorSocket(
        baseUrl: 'https://oceanic-mobile-backend-1.onrender.com',
        doctorId: user.doctorId as int,
        navigatorKey: navigatorKey,
      );
    }
  }

  // ============================================================
  // BANNER TIMER
  // ============================================================

  void _startBannerTimer() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;

      final nextPage = (_currentBanner + 1) % _banners.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigateTo(Widget destination) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authState = ref.watch(authProvider);
    final user = authState.user;

    final rawName = user?.lastName ?? '';

    final displayName = rawName.trim().isEmpty ? 'Member' : rawName.trim();

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ==================================================
            // SUBTLE BACKGROUND DECORATIONS
            // ==================================================
            Positioned(
              top: -90.h,
              right: -80.w,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(
                    alpha: isDark ? 0.10 : 0.045,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 220.h,
              left: -100.w,
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(
                    alpha: isDark ? 0.07 : 0.035,
                  ),
                ),
              ),
            ),

            // ==================================================
            // DASHBOARD CONTENT
            // ==================================================
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 110.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ================================
                            // HEADER
                            // ================================
                            _buildHeader(
                              scheme: scheme,
                              isDark: isDark,
                              displayName: displayName,
                              initial: initial,
                            ),

                            SizedBox(height: 22.h),

                            // ================================
                            // PRIMARY HERO CARD
                            // ================================
                            _buildHeroCard(scheme: scheme, isDark: isDark),

                            SizedBox(height: 18.h),

                            // ================================
                            // QUICK ACCESS
                            // ================================
                            _buildQuickAccess(scheme: scheme, isDark: isDark),

                            SizedBox(height: 30.h),

                            // ================================
                            // HEALTH HIGHLIGHTS
                            // ================================
                            _buildSectionTitle(
                              title: 'Health Highlights',
                              subtitle: 'Updates and useful health information',
                              scheme: scheme,
                            ),

                            SizedBox(height: 14.h),

                            _buildBannerSlider(scheme: scheme, isDark: isDark),

                            SizedBox(height: 30.h),

                            // ================================
                            // SERVICES
                            // ================================
                            _buildSectionTitle(
                              title: 'Services',
                              subtitle: 'Everything you need, in one place',
                              scheme: scheme,
                            ),

                            SizedBox(height: 14.h),

                            _buildServicesGrid(scheme: scheme, isDark: isDark),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required ColorScheme scheme,
    required bool isDark,
    required String displayName,
    required String initial,
  }) {
    return Row(
      children: [
        // ------------------------------------------------------
        // PROFILE / DRAWER
        // ------------------------------------------------------
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            borderRadius: BorderRadius.circular(50.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46.r,
                    height: 46.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary,
                          Color.lerp(scheme.primary, scheme.secondary, 0.38)!,
                        ],
                      ),
                    ),
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 17.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 11.w),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Row(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150.w),
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),

                          SizedBox(width: 3.w),

                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19.r,
                            color: scheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const Spacer(),

        // ------------------------------------------------------
        // SEARCH
        // ------------------------------------------------------
        _buildHeaderButton(
          icon: Icons.search_rounded,
          scheme: scheme,
          isDark: isDark,
          onTap: () {},
        ),

        SizedBox(width: 9.w),

        // ------------------------------------------------------
        // MENU
        // ------------------------------------------------------
        _buildHeaderButton(
          icon: Icons.menu_rounded,
          scheme: scheme,
          isDark: isDark,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 43.r,
          height: 43.r,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.055),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Icon(icon, size: 21.r, color: scheme.onSurface),
        ),
      ),
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard({required ColorScheme scheme, required bool isDark}) {
    final secondGradientColor = Color.lerp(
      scheme.primary,
      scheme.secondary,
      isDark ? 0.20 : 0.28,
    )!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, secondGradientColor],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.17 : 0.22),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ----------------------------------------------------
          // DECORATION
          // ----------------------------------------------------
          Positioned(
            top: -55.r,
            right: -40.r,
            child: Container(
              width: 160.r,
              height: 160.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 22.w,
            bottom: -28.h,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 120.r,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),

          // ----------------------------------------------------
          // CONTENT
          // ----------------------------------------------------
          Padding(
            padding: EdgeInsets.all(21.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            size: 14.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Oceanic Health',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Container(
                      width: 39.r,
                      height: 39.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        size: 20.r,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 21.h),

                Text(
                  'Your health,\none place.',
                  style: TextStyle(
                    fontSize: 25.sp,
                    height: 1.12,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 9.h),

                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 255.w),
                  child: Text(
                    'Access your plan, medical records, providers and virtual care whenever you need them.',
                    style: TextStyle(
                      fontSize: 12.2.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  height: 43.h,
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateTo(const PolicyDetailsScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.white,
                      foregroundColor: scheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View my policy',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 7.w),
                        Icon(Icons.arrow_forward_rounded, size: 17.r),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACCESS
  // ============================================================

  Widget _buildQuickAccess({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(23.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              icon: Icons.video_camera_front_outlined,
              label: 'Telemedicine',
              color: scheme.primary,
              onTap: () {
                _navigateTo(const DoctorSelectionScreen());
              },
            ),
          ),

          _buildVerticalDivider(scheme),

          Expanded(
            child: _buildQuickAction(
              icon: Icons.local_hospital_outlined,
              label: 'Provider',
              color: scheme.secondary,
              onTap: () {
                _navigateTo(const HealthProvider());
              },
            ),
          ),

          _buildVerticalDivider(scheme),

          Expanded(
            child: _buildQuickAction(
              icon: Icons.folder_shared_outlined,
              label: 'Records',
              color: scheme.tertiary,
              onTap: () {
                _navigateTo(const HealthRecord());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: Column(
            children: [
              Container(
                width: 43.r,
                height: 43.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, size: 21.r, color: color),
              ),

              SizedBox(height: 8.h),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.7.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(ColorScheme scheme) {
    return Container(
      height: 55.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      color: scheme.onSurface.withValues(alpha: 0.07),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required ColorScheme scheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.15,
            letterSpacing: -0.25,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.8.sp,
            height: 1.35,
            fontWeight: FontWeight.w400,
            color: scheme.onSurface.withValues(alpha: 0.52),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BANNER
  // ============================================================

  Widget _buildBannerSlider({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBanner = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: _buildBannerCard(
                  banner: _banners[index],
                  isDark: isDark,
                ),
              );
            },
          ),
        ),

        SizedBox(height: 11.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final selected = _currentBanner == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: selected ? 20.w : 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.15),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard({
    required Map<String, String> banner,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.13 : 0.07),
            blurRadius: 18.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(banner['image']!, fit: BoxFit.cover),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black.withValues(alpha: 0.80),
                  Colors.black.withValues(alpha: 0.30),
                  Colors.transparent,
                ],
                stops: const [0, 0.60, 1],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(17.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner['title']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.2,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 5.h),

                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 260.w),
                  child: Text(
                    banner['subtitle']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.3.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SERVICES GRID
  // ============================================================

  Widget _buildServicesGrid({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _menuItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13.w,
        mainAxisSpacing: 13.h,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        return _buildServiceCard(
          item: _menuItems[index],
          index: index,
          scheme: scheme,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildServiceCard({
    required Map<String, dynamic> item,
    required int index,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final color = _serviceColor(index, scheme);

    final destination = item['route'] as Widget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: () {
          _navigateTo(destination);
        },
        child: Ink(
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------
              // ICON ROW
              // ----------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 45.r,
                    height: 45.r,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 22.r,
                      color: color,
                    ),
                  ),

                  Container(
                    width: 29.r,
                    height: 29.r,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.045),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16.r,
                      color: scheme.onSurface.withValues(alpha: 0.40),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ----------------------------------------------
              // TITLE
              // ----------------------------------------------
              Text(
                item['title'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  color: scheme.onSurface,
                ),
              ),

              SizedBox(height: 5.h),

              // ----------------------------------------------
              // SUBTITLE
              // ----------------------------------------------
              Text(
                item['subtitle'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.8.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: scheme.onSurface.withValues(alpha: 0.52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE COLORS
  // ============================================================

  Color _serviceColor(int index, ColorScheme scheme) {
    switch (index % 6) {
      case 0:
        return scheme.primary;

      case 1:
        return scheme.secondary;

      case 2:
        return scheme.tertiary;

      case 3:
        return Color.lerp(scheme.primary, scheme.secondary, 0.50)!;

      case 4:
        return Color.lerp(scheme.secondary, scheme.tertiary, 0.35)!;

      case 5:
      default:
        return Color.lerp(scheme.primary, scheme.tertiary, 0.30)!;
    }
  }
}
