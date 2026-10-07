import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showCardFront = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final policyState = ref.watch(policyProvider);
    final user = authState.user;
    final card = policyState.card;
    final dependants = policyState.dependants;
    final firstName = user?.firstName?.trim() ?? '';
    final lastName = user?.lastName?.trim() ?? '';
    final fullName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Valued Member';
    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : 'Email not available';
    final memberId = card?.memberId ?? policyState.policy?.memberId ?? '--';
    final plan = card?.planVariant.trim().isNotEmpty == true
        ? card!.planVariant.toUpperCase()
        : 'PLAN NOT AVAILABLE';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -90.h,
              right: -80.w,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.04),
                ),
              ),
            ),

            Positioned(
              top: 420.h,
              left: -110.w,
              child: Container(
                width: 210.r,
                height: 210.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(
                    alpha: isDark ? 0.07 : 0.03,
                  ),
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================
            Column(
              children: [
                _buildTopBar(scheme: scheme, isDark: isDark),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileHero(
                              scheme: scheme,
                              isDark: isDark,
                              fullName: fullName,
                              email: email,
                              memberId: memberId,
                              plan: plan,
                              dependantCount: dependants.length,
                              photo: card?.photo,
                            ),

                            SizedBox(height: 30.h),

                            // ================================
                            // DIGITAL CARD HEADER
                            // ================================
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSectionHeader(
                                    title: 'Digital Member Card',
                                    subtitle: 'Your Oceanic membership card',
                                    scheme: scheme,
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                _buildCardToggle(
                                  scheme: scheme,
                                  isDark: isDark,
                                ),
                              ],
                            ),

                            SizedBox(height: 15.h),

                            // ================================
                            // DIGITAL CARD
                            // ================================
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.985,
                                      end: 1,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _showCardFront
                                  ? _buildCardFront(
                                      scheme: scheme,
                                      card: card,
                                      fullName: fullName,
                                      memberId: memberId,
                                      plan: plan,
                                    )
                                  : _buildCardBack(),
                            ),

                            SizedBox(height: 30.h),

                            // ================================
                            // ACCOUNT INFO
                            // ================================
                            _buildSectionHeader(
                              title: 'Account Information',
                              subtitle: 'Your membership details at a glance',
                              scheme: scheme,
                            ),

                            SizedBox(height: 14.h),

                            _buildAccountInfoCard(
                              scheme: scheme,
                              isDark: isDark,
                              fullName: fullName,
                              email: email,
                              memberId: memberId,
                              plan: plan,
                              dependantCount: dependants.length,
                            ),

                            SizedBox(height: 30.h),

                            // ================================
                            // SUPPORT
                            // ================================
                            _buildSectionHeader(
                              title: 'Help & Support',
                              subtitle:
                                  'We are available when you need assistance',
                              scheme: scheme,
                            ),

                            SizedBox(height: 14.h),

                            _buildSupportCard(scheme: scheme, isDark: isDark),
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
  // TOP BAR
  // ============================================================

  Widget _buildTopBar({required ColorScheme scheme, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          _buildTopButton(
            icon: Icons.arrow_back_rounded,
            scheme: scheme,
            isDark: isDark,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  'Account & membership',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),

          _buildTopButton(
            icon: Icons.menu_rounded,
            scheme: scheme,
            isDark: isDark,
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          width: 43.r,
          height: 43.r,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
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
  // PROFILE HERO
  // ============================================================

  Widget _buildProfileHero({
    required ColorScheme scheme,
    required bool isDark,
    required String fullName,
    required String email,
    required String memberId,
    required String plan,
    required int dependantCount,
    required String? photo,
  }) {
    final gradientEnd = Color.lerp(scheme.primary, scheme.secondary, 0.27)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.22),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55.r,
            right: -40.r,
            child: Container(
              width: 170.r,
              height: 170.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 16.w,
            bottom: -35.h,
            child: Icon(
              Icons.person_rounded,
              size: 130.r,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfilePhoto(photo: photo, fullName: fullName),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEMBER PROFILE',
                            style: TextStyle(
                              fontSize: 9.2.sp,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.68),
                            ),
                          ),

                          SizedBox(height: 5.h),

                          Text(
                            fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19.sp,
                              height: 1.15,
                              letterSpacing: -0.3,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 5.h),

                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.8.sp,
                              color: Colors.white.withValues(alpha: 0.76),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        size: 19.r,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 22.h),

                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.13),
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildHeroStat(
                        label: 'Member ID',
                        value: memberId,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: _buildHeroStat(label: 'Plan', value: plan),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                _buildHeroStat(
                  label: 'Beneficiaries',
                  value:
                      '$dependantCount ${dependantCount == 1 ? 'beneficiary' : 'beneficiaries'}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto({
    required String? photo,
    required String fullName,
  }) {
    final initial = fullName.trim().isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : 'M';

    return Container(
      width: 64.r,
      height: 64.r,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 1.5.r,
        ),
      ),
      child: ClipOval(
        child: photo?.trim().isNotEmpty == true
            ? Image.network(
                photo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildProfileInitial(initial);
                },
              )
            : _buildProfileInitial(initial),
      ),
    );
  }

  Widget _buildProfileInitial(String initial) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white.withValues(alpha: 0.13),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeroStat({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.3.sp,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
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
            fontWeight: FontWeight.w800,
            letterSpacing: -0.25,
            color: scheme.onSurface,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.5.sp,
            height: 1.35,
            color: scheme.onSurface.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FRONT / BACK TOGGLE
  // ============================================================

  Widget _buildCardToggle({required ColorScheme scheme, required bool isDark}) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCardSideButton(
            title: 'Front',
            isSelected: _showCardFront,
            scheme: scheme,
            onTap: () {
              setState(() {
                _showCardFront = true;
              });
            },
          ),

          _buildCardSideButton(
            title: 'Back',
            isSelected: !_showCardFront,
            scheme: scheme,
            onTap: () {
              setState(() {
                _showCardFront = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardSideButton({
    required String title,
    required bool isSelected,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIGITAL CARD FRONT
  // ============================================================

  Widget _buildCardFront({
    required ColorScheme scheme,
    required dynamic card,
    required String fullName,
    required String memberId,
    required String plan,
  }) {
    const cardBrand = Color(0xFF2C2F7A);

    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(18.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------
                // LEFT SIDE
                // ---------------------------------------------
                SizedBox(
                  width: 93.w,
                  child: Column(
                    children: [
                      Container(
                        width: 88.w,
                        height: 104.h,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F8),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE4E6EE)),
                        ),
                        child: card?.photo?.trim().isNotEmpty == true
                            ? Image.network(
                                card.photo,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person_outline_rounded,
                                    size: 45.r,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person_outline_rounded,
                                size: 45.r,
                                color: Colors.grey.shade400,
                              ),
                      ),

                      SizedBox(height: 11.h),

                      Image.asset(
                        'assets/images/logo.png',
                        height: 28.h,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: 5.h),

                      Text(
                        'OCEANIC HEALTH\nMANAGEMENT LTD.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 7.7.sp,
                          height: 1.3,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w800,
                          color: cardBrand,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 18.w),

                // ---------------------------------------------
                // RIGHT SIDE
                // ---------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoField(label: 'FULL NAME', value: fullName),

                      SizedBox(height: 10.h),

                      _buildInfoField(label: 'I.D NUMBER', value: memberId),

                      SizedBox(height: 10.h),

                      _buildInfoField(label: 'PLAN', value: plan),

                      SizedBox(height: 10.h),

                      _buildInfoField(label: 'VALIDITY', value: '--'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 6.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2C2F7A),
                  Color(0xFF00B4D8),
                  Color(0xFFF5A623),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C2F7A),
            letterSpacing: 0.7,
          ),
        ),

        SizedBox(height: 4.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2F7A),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            value.trim().isEmpty ? '--' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIGITAL CARD BACK
  // ============================================================

  Widget _buildCardBack() {
    const cardBrand = Color(0xFF2C2F7A);
    const cardText = Color(0xFF45475A);

    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: cardBrand.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_outlined,
              color: cardBrand,
              size: 23.r,
            ),
          ),

          SizedBox(height: 13.h),

          Text(
            'TERMS & EMERGENCY INFORMATION',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w800,
              color: cardBrand,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            'The bearer of this card has subscribed to Oceanic Health Management Limited healthcare plan. It entitles the bearer to receive medical care from chosen primary healthcare providers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.3.sp, height: 1.55, color: cardText),
          ),

          SizedBox(height: 15.h),

          Divider(color: Colors.grey.shade200),

          SizedBox(height: 10.h),

          _buildCardContactRow(icon: Icons.call_outlined, text: '02013300300'),

          SizedBox(height: 9.h),

          _buildCardContactRow(
            icon: Icons.email_outlined,
            text: 'hmo@oceanichealthng.com',
          ),

          SizedBox(height: 9.h),

          _buildCardContactRow(
            icon: Icons.language_rounded,
            text: 'oceanichealth.com',
          ),

          SizedBox(height: 15.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: cardBrand.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              'If found, please return to:\n266, Murtala Muhammed Way, Alagomeji, Yaba, Lagos State.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.4.sp,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContactRow({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15.r, color: const Color(0xFF2C2F7A)),

        SizedBox(width: 7.w),

        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF45475A),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACCOUNT INFORMATION
  // ============================================================

  Widget _buildAccountInfoCard({
    required ColorScheme scheme,
    required bool isDark,
    required String fullName,
    required String email,
    required String memberId,
    required String plan,
    required int dependantCount,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.07 : 0.03),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAccountRow(
            icon: Icons.person_outline_rounded,
            label: 'Full name',
            value: fullName,
            scheme: scheme,
          ),

          _divider(scheme),

          _buildAccountRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
            scheme: scheme,
          ),

          _divider(scheme),

          _buildAccountRow(
            icon: Icons.badge_outlined,
            label: 'Member ID',
            value: memberId,
            scheme: scheme,
          ),

          _divider(scheme),

          _buildAccountRow(
            icon: Icons.health_and_safety_outlined,
            label: 'Plan',
            value: plan,
            scheme: scheme,
          ),

          _divider(scheme),

          _buildAccountRow(
            icon: Icons.people_outline_rounded,
            label: 'Beneficiaries',
            value: dependantCount.toString(),
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 18.r, color: scheme.primary),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.52),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.8.sp,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme scheme) {
    return Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.055));
  }

  // ============================================================
  // SUPPORT
  // ============================================================

  Widget _buildSupportCard({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.07 : 0.03),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45.r,
                height: 45.r,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.headset_mic_outlined,
                  size: 22.r,
                  color: scheme.secondary,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Care',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      'Emergency care, authorizations & enquiries',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: scheme.onSurface.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                _buildSupportRow(
                  icon: Icons.call_outlined,
                  label: '24/7 Call Center',
                  value: '02013300300',
                  scheme: scheme,
                ),

                SizedBox(height: 12.h),

                _buildSupportRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'hmo@oceanichealthng.com',
                  scheme: scheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17.r, color: scheme.primary),

        SizedBox(width: 9.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  color: scheme.onSurface.withValues(alpha: 0.48),
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
