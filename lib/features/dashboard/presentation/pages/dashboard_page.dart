import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:oceanic/presentation/features/home/view/authorization_screen.dart';
import 'package:oceanic/presentation/features/home/view/health_provider.dart';
import 'package:oceanic/presentation/features/home/view/health_record.dart';
import 'package:oceanic/presentation/features/home/view/medical_request.dart';
import 'package:oceanic/features/policy/presentation/view/policy_details.dart';
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
    final authState = ref.watch(authProvider);

    final user = authState.user;
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
                        Consumer(
                          builder: (context, ref, child) {
                            final dashboard = ref.watch(dashboardProvider);

                            return dashboard.when(
                              loading: () => const SizedBox(),
                              error: (error, stackTrace) {
                                debugPrint(error.toString());
                                debugPrint(stackTrace.toString());

                                return Center(child: Text(error.toString()));
                              },
                              data: (data) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data.member.fullName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Member ID: ${data.member.memberId}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildStat(
                                              "Pending",
                                              data.authorizations.pending,
                                              Colors.orange,
                                            ),
                                            _buildStat(
                                              "Approved",
                                              data.authorizations.approved,
                                              Colors.green,
                                            ),
                                            _buildStat(
                                              "Rejected",
                                              data.authorizations.rejected,
                                              Colors.red,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _menuItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.95,
                                ),
                            itemBuilder: (context, index) {
                              return _buildGridMenuItem(
                                context,
                                _menuItems[index],
                                scheme,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  FloatingAppBar(
                    scrollController: _scrollController,
                    username: user?.firstName ?? "User",
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

  Widget _buildGridMenuItem(
    BuildContext context,
    Map<String, dynamic> item,
    ColorScheme scheme,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        final destination = item['route'] as Widget?;

        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: .15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(item['icon'], color: item['color'], size: 30),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStat(String title, int value, Color color) {
  return Column(
    children: [
      Text(
        value.toString(),
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(color: Colors.white70)),
    ],
  );
}
