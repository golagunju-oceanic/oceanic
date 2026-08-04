import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/health_provider/presentation/views/health_provider.dart';
import 'package:oceanic/features/policy/presentation/view/policy_details.dart';
import 'package:oceanic/presentation/features/home/view/authorization_screen.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/doctor_selection_screen.dart';
import 'package:oceanic/presentation/features/home/view/health_record.dart';
import 'package:oceanic/presentation/features/home/view/medical_request.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBanner = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBannerTimer());
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentBanner + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      'subtitle': 'Access world-class medical services at your fingertips.',
      'image': 'assets/images/banner3.jpg',
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.shield_outlined,
      'title': 'Policy Details',
      'subtitle': 'View active benefits',
      'color': const Color(0xFF4F46E5),
      'route': const PolicyDetailsScreen(),
    },
    {
      'icon': Icons.assignment_turned_in_outlined,
      'title': 'Authorizations',
      'subtitle': 'Track treatment approvals',
      'color': const Color(0xFF0EA5E9),
      'route': const AuthorizationScreen(),
    },
    {
      'icon': Icons.folder_shared_outlined,
      'title': 'Health Records',
      'subtitle': 'Medical history & reports',
      'color': const Color(0xFFE11D48),
      'route': const HealthRecord(),
    },
    {
      'icon': Icons.video_camera_front_outlined,
      'title': 'Telemedicine',
      'subtitle': 'Consult doctor online',
      'color': const Color(0xFF0284C7),
      'route': const DoctorSelectionScreen(),
    },
    {
      'icon': Icons.medication_liquid_outlined,
      'title': 'Medication Request',
      'subtitle': 'Order prescribed drugs',
      'color': const Color(0xFF16A34A),
      'route': const MedicalRequest(),
    },
    {
      'icon': Icons.local_hospital_outlined,
      'title': 'Find a Provider',
      'subtitle': 'Locate nearby hospitals',
      'color': const Color(0xFFD97706),
      'route': const HealthProvider(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 88, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Subheader
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Welcome back, ${user?.lastName ?? "Member"} ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),

                  // Modern Banner Slider
                  _buildBannerSlider(scheme),

                  const SizedBox(height: 24),

                  // Section Title
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 14),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  // Action Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _menuItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.98,
                        ),
                    itemBuilder: (context, index) {
                      return _buildGridMenuItem(
                        context,
                        _menuItems[index],
                        scheme,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Floating App Bar with Drawer Trigger
            FloatingAppBar(
              scrollController: _scrollController,
              text: "Oceanic Health",
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- CAROUSEL BANNER ---
  Widget _buildBannerSlider(ColorScheme scheme) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemBuilder: (_, i) => _buildBannerCard(_banners[i], scheme),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBanner == i ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentBanner == i
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(Map<String, String> banner, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(banner['image']!, fit: BoxFit.cover),
          ),
          // Gradient Vignette Mask
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  banner['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner['subtitle']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- GRID MENU ITEM ---
  Widget _buildGridMenuItem(
    BuildContext context,
    Map<String, dynamic> item,
    ColorScheme scheme,
  ) {
    final Color itemColor = item['color'] as Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final destination = item['route'] as Widget?;
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow ?? scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: itemColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: itemColor,
                      size: 24,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: scheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['subtitle'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.2,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
