import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/presentation/features/home/view/authorization_screen.dart';
import 'package:oceanic/presentation/features/home/view/health_provider.dart';
import 'package:oceanic/presentation/features/home/view/health_record.dart';
import 'package:oceanic/presentation/features/home/view/medical_request.dart';
import 'package:oceanic/presentation/features/home/view/policy_details.dart';
import 'package:oceanic/presentation/features/home/view/telemedicine.dart';
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
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBannerTimer());
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentBanner + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
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
      'title': 'Welcome to Oceanic',
      'subtitle': 'Our plans are designed to meet all segments of the society',
      'image': 'assets/images/banner1.jpg',
    },
    {
      'title': 'At Oceanic HMO',
      'subtitle':
          'We provide personalized, high-quality healthcare with empathy and integrity to improve lives and promote wellness',
      'image': 'assets/images/banner2.jpg',
    },
    {
      'title': 'Your Health Matters',
      'subtitle':
          'Access quality healthcare services at your fingertips, anytime.',
      'image': 'assets/images/banner3.jpg',
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.policy_outlined,
      'title': 'Policy Details',
      'subtitle': 'View your health policy',
      'color': Color(0xFF6B5CE7),
      'route': const PolicyDetailsScreen(),
    },
    {
      'icon': Icons.assignment_outlined,
      'title': 'Authorizations',
      'subtitle': 'View your treatment details',
      'color': Color(0xFF6B5CE7),
      'route': const AuthorizationScreen(),
    },
    {
      'icon': Icons.medical_information_outlined,
      'title': 'Health Records',
      'subtitle': 'View your health records',
      'color': Color(0xFFE57373),
      'route': const HealthRecord(),
    },
    {
      'icon': Icons.video_call_outlined,
      'title': 'Telemedicine',
      'subtitle': 'Virtual consultation with a Doctor',
      'color': Color(0xFF42A5F5),
      'route': const TelemedicineConsentScreen(),
    },
    {
      'icon': Icons.medication_outlined,
      'title': 'Medication Request',
      'subtitle': 'Request your medication',
      'color': Color(0xFF66BB6A),
      'route': const MedicalRequest(),
    },
    {
      'icon': Icons.find_in_page_outlined,
      'title': 'Find a Provider',
      'subtitle': 'Locate healthcare providers',
      'color': Color(0xFFFFA726),
      'route': const HealthProvider(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: scheme.primary,
      child: Column(
        children: [
          Container(color: scheme.surface, height: topPadding),
          Expanded(
            child: Scaffold(
              drawer: CustomDrawer(),
              backgroundColor: scheme.surface,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Sustaining your peace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.25,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _banners.length,
                                onPageChanged: (i) =>
                                    setState(() => _currentBanner = i),
                                itemBuilder: (_, i) => _buildBanner(
                                  _banners[i],
                                  screenHeight,
                                  scheme,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _banners.length,
                                    (i) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      width: _currentBanner == i ? 10 : 8,
                                      height: _currentBanner == i ? 10 : 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentBanner == i
                                            ? scheme.primary
                                            : scheme.onSurface.withValues(
                                                alpha: 0.3,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: _menuItems
                                .map(
                                  (item) =>
                                      _buildMenuItem(context, item, scheme),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  FloatingAppBar(
                    scrollController: _scrollController,
                    username: 'User',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(
    Map<String, String> banner,
    double screenHeight,
    ColorScheme scheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.surfaceContainerHighest,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: Image.asset(banner['image']!).image,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: screenHeight * 0.09,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 230),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.secondary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner['subtitle']!,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    Map<String, dynamic> item,
    ColorScheme scheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          final destination = item['route'] as Widget?;
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          }
        },
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: (item['color'] as Color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item['icon'] as IconData,
            color: item['color'] as Color,
            size: 26,
          ),
        ),
        title: Text(
          item['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          item['subtitle'] as String,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: scheme.onSurface.withValues(alpha: 0.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
