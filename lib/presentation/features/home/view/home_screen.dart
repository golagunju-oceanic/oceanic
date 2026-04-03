import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/data/repositories/providers/user_provider.dart';
// import 'package:oceanic/presentation/features/auth/view/auth_screen.dart';
import 'package:oceanic/presentation/features/home/view/telemedicine.dart';
import 'package:oceanic/presentation/features/home/viewSample/auth_screen.dart';
import 'package:oceanic/presentation/widgets/bottom_nav_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBanner = 1;

  // final List<Map<String, String>> _banners = [
  //   {
  //     'title': 'Welcome to Oceanic',
  //     'subtitle': 'Our plans are designed to meet all segments of the society',
  //   },
  //   {
  //     'title': 'At Oceanic HMO',
  //     'subtitle':
  //         'We deliver exceptional, personalized healthcare services with empathy, integrity, and expertise improving lives and fostering a culture of wellness.',
  //   },
  //   {
  //     'title': 'Your Health Matters',
  //     'subtitle':
  //         'Access quality healthcare services at your fingertips, anytime.',
  //   },
  // ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.policy_outlined,
      'title': 'Policy Details',
      'subtitle': 'View your health policy',
      'color': Color(0xFF6B5CE7),
    },
    {
      'icon': Icons.assignment_outlined,
      'title': 'Authorizations',
      'subtitle': 'View your treatment details',
      'color': Color(0xFF6B5CE7),
    },
    {
      'icon': Icons.medical_information_outlined,
      'title': 'Health Records',
      'subtitle': 'View your health records',
      'color': Color(0xFFE57373),
    },
    {
      'icon': Icons.video_call_outlined,
      'title': 'Telemedicine',
      'subtitle': 'Virtual consultation with a Doctor',
      'color': Color(0xFF42A5F5),
    },
    {
      'icon': Icons.medication_outlined,
      'title': 'Medication Request',
      'subtitle': 'Request your medication',
      'color': Color(0xFF66BB6A),
    },
    {
      'icon': Icons.find_in_page_outlined,
      'title': 'Find a Provider',
      'subtitle': 'Locate healthcare providers',
      'color': Color(0xFFFFA726),
    },
  ];

  // void logout() async {
  //   await ref.read(authAsyncProvider.notifier).logout();
  //   if (!mounted) return;
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => const AuthScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authAsyncProvider);

    return Container(
      color: kNavyBlue,
      child: SafeArea(
        child: Scaffold(
          endDrawer: Drawer(),
          appBar: AppBar(
            backgroundColor: kNavyBlue,
            title: userAsync.when(
              loading: () => const Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              ),
              error: (_, __) => const Text(
                'Hello User',
                style: TextStyle(color: Colors.white),
              ),
              data: (user) => Text(
                // '',
                'Hello ${user?.username ?? 'User'}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              // IconButton(
              //   icon: const Icon(Icons.logout, color: Colors.white),
              //   onPressed: (){},
              // ),
            ],
          ),
          backgroundColor: Colors.white,
          body: userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (user) => Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Sustaining your peace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          // child: Stack(
                          //   children: [
                          //     PageView.builder(
                          //       itemCount: _banners.length,
                          //       onPageChanged: (i) =>
                          //           setState(() => _currentBanner = i),
                          //       itemBuilder: (_, i) =>
                          //           _buildBanner(_banners[i]),
                          //     ),
                          //     Positioned(
                          //       bottom: 8,
                          //       left: 0,
                          //       right: 0,
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: List.generate(
                          //           _banners.length,
                          //           (i) => Container(
                          //             margin: const EdgeInsets.symmetric(
                          //               horizontal: 3,
                          //             ),
                          //             width: _currentBanner == i ? 10 : 8,
                          //             height: _currentBanner == i ? 10 : 8,
                          //             decoration: BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               color: _currentBanner == i
                          //                   ? kNavyBlue
                          //                   : Colors.grey.shade400,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: _menuItems
                                .map((item) => _buildMenuItem(context, item))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(),
        ),
      ),
    );
  }

  // keep your existing _buildBanner and _buildMenuItem methods unchanged
  Widget _buildBanner(Map<String, String> banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blueGrey.shade300,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade400, Colors.blueGrey.shade600],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.public, color: kNavyBlue, size: 28),
            ),
          ),
          Positioned(
            left: 12,
            top: 30,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 230),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kAmber,
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

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          if (item['title'] == 'Telemedicine') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TelemedicineConsentScreen(),
              ),
            );
          }
        },
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.12),
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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          item['subtitle'] as String,
          style: const TextStyle(color: kTextGray, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: kTextGray),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
