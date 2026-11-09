import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

import '../../data/models/wellness_benefit_model.dart';
import '../providers/wellness_provider.dart';
import '../widgets/wellness_benefit_card.dart';

/// Read-only wellness experience. Real provider bookings and access codes are
/// intentionally unavailable until provider approval and persistence are ready.
class WellnessScreen extends ConsumerStatefulWidget {
  const WellnessScreen({super.key});

  @override
  ConsumerState<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends ConsumerState<WellnessScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final wellnessState = ref.watch(wellnessBenefitsProvider);

    final user = ref.watch(authProvider).user;
    final memberName = [
      user?.firstName?.trim() ?? '',
      user?.lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');

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
              top: 340.h,
              left: -100.w,
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(
                    alpha: isDark ? 0.07 : 0.03,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildTopBar(scheme: scheme, isDark: isDark),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                  child: _buildSegmentedControl(scheme: scheme, isDark: isDark),
                ),
                Expanded(
                  child: wellnessState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    error: (error, stackTrace) =>
                        _buildErrorState(scheme: scheme, error: error),
                    data: (response) => RefreshIndicator(
                      onRefresh: () async {
                        try {
                          await ref.refresh(wellnessBenefitsProvider.future);
                        } catch (_) {
                          // The provider exposes the error state to the UI.
                        }
                      },
                      child: ListView(
                        key: ValueKey(_selectedTabIndex),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: _selectedTabIndex == 0
                                  ? _buildBenefitsContent(
                                      response: response,
                                      memberName: memberName,
                                      scheme: scheme,
                                      isDark: isDark,
                                    )
                                  : _buildProvidersContent(
                                      response: response,
                                      memberName: memberName,
                                      scheme: scheme,
                                      isDark: isDark,
                                    ),
                            ),
                          ),
                        ],
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

  Widget _buildTopBar({required ColorScheme scheme, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          _buildTopButton(
            icon: Icons.arrow_back_rounded,
            scheme: scheme,
            isDark: isDark,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness',
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
                  'Gym, swimming & spa benefits',
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
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
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

  Widget _buildSegmentedControl({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.025),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'My Benefits',
              icon: Icons.favorite_border_rounded,
              selected: _selectedTabIndex == 0,
              scheme: scheme,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Find Providers',
              icon: Icons.location_on_outlined,
              selected: _selectedTabIndex == 1,
              scheme: scheme,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool selected,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 5.w),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17.r,
                color: selected
                    ? scheme.onPrimary
                    : scheme.onSurface.withValues(alpha: 0.48),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.3.sp,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? scheme.onPrimary
                        : scheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsContent({
    required WellnessBenefitsResponse response,
    required String memberName,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroCard(
          scheme: scheme,
          icon: Icons.self_improvement_rounded,
          eyebrow: 'YOUR WELLNESS COVERAGE',
          title: 'A healthier you,\none day at a time.',
          description:
              'Explore the gym, swimming and spa services listed under your Oceanic health plan.',
        ),
        SizedBox(height: 26.h),
        _buildSectionTitle(
          title: 'Enrollee',
          subtitle: 'Wellness benefits are linked to your signed-in profile.',
          scheme: scheme,
        ),
        SizedBox(height: 12.h),
        _buildEnrolleeCard(
          response: response,
          memberName: memberName,
          scheme: scheme,
          isDark: isDark,
        ),
        SizedBox(height: 26.h),
        _buildSectionTitle(
          title: 'Your plan',
          subtitle: 'Coverage details from your current policy.',
          scheme: scheme,
        ),
        SizedBox(height: 12.h),
        _buildPlanCard(response.plan, scheme, isDark),
        if (!_isMemberAndPolicyActive(response)) ...[
          SizedBox(height: 12.h),
          _buildInfoCard(
            scheme: scheme,
            isDark: isDark,
            icon: Icons.warning_amber_rounded,
            title: 'Membership or policy needs review',
            description:
                'One or more membership, plan or policy statuses are not active. Please confirm your coverage with Oceanic.',
          ),
        ],
        if (response.warnings.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildInfoCard(
            scheme: scheme,
            isDark: isDark,
            icon: Icons.info_outline_rounded,
            title: 'Policy information',
            description: response.warnings.join('\n'),
          ),
        ],
        SizedBox(height: 27.h),
        Row(
          children: [
            Expanded(
              child: _buildSectionTitle(
                title: 'Wellness benefits',
                subtitle: 'Services included in your plan information.',
                scheme: scheme,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                '${response.benefits.length} benefits',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 13.h),
        if (response.benefits.isEmpty)
          _buildInfoCard(
            scheme: scheme,
            isDark: isDark,
            icon: Icons.spa_outlined,
            title: 'No wellness benefits found',
            description:
                'No wellness benefits are currently listed for your policy.',
          )
        else
          for (final benefit in response.benefits)
            WellnessBenefitCard(benefit: benefit),
        SizedBox(height: 6.h),
        if (!response.usageAvailable) ...[
          _buildInfoCard(
            scheme: scheme,
            isDark: isDark,
            icon: Icons.history_outlined,
            title: 'Visit balance is not available yet',
            description:
                'We can show your policy terms, but remaining sessions and attendance history are not available yet.',
          ),
          SizedBox(height: 12.h),
        ],
        _buildInfoCard(
          scheme: scheme,
          isDark: isDark,
          icon: Icons.lock_clock_outlined,
          title: 'Wellness access is being configured',
          description:
              'Approved provider listings and access codes are not ready yet. Your benefits are available to view.',
        ),
        SizedBox(height: 23.h),
        _buildRefreshHint(scheme),
      ],
    );
  }

  Widget _buildProvidersContent({
    required WellnessBenefitsResponse response,
    required String memberName,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroCard(
          scheme: scheme,
          icon: Icons.location_on_outlined,
          eyebrow: 'WELLNESS PROVIDERS',
          title: 'Your wellness,\ncloser to home.',
          description:
              'This is where approved gyms, swimming facilities and spas will appear once provider onboarding is complete.',
        ),
        SizedBox(height: 26.h),
        _buildSectionTitle(
          title: 'Enrollee',
          subtitle: 'Provider availability depends on your assigned plan.',
          scheme: scheme,
        ),
        SizedBox(height: 12.h),
        _buildEnrolleeCard(
          response: response,
          memberName: memberName,
          scheme: scheme,
          isDark: isDark,
        ),
        SizedBox(height: 26.h),
        _buildSectionTitle(
          title: 'Approved providers',
          subtitle: 'Provider directory integration is the next phase.',
          scheme: scheme,
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 27.h),
          decoration: _cardDecoration(scheme, isDark),
          child: Column(
            children: [
              Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_outlined,
                  color: scheme.primary,
                  size: 31.r,
                ),
              ),
              SizedBox(height: 17.h),
              Text(
                'Provider listings coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Oceanic is still configuring which providers are approved for each wellness benefit. No booking or access code can be issued here yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.8.sp,
                  height: 1.55,
                  color: scheme.onSurface.withValues(alpha: 0.56),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        _buildSectionTitle(
          title: 'What happens next?',
          subtitle: 'How future wellness access will work.',
          scheme: scheme,
        ),
        SizedBox(height: 13.h),
        _buildInfoCard(
          scheme: scheme,
          isDark: isDark,
          icon: Icons.verified_user_outlined,
          title: 'Coverage is checked first',
          description:
              'Your plan and the selected wellness benefit must be active and covered.',
        ),
        SizedBox(height: 10.h),
        _buildInfoCard(
          scheme: scheme,
          isDark: isDark,
          icon: Icons.approval_outlined,
          title: 'Only approved providers can be used',
          description:
              'A gym, swimming facility or spa must be approved for your specific benefit.',
        ),
        SizedBox(height: 10.h),
        _buildInfoCard(
          scheme: scheme,
          isDark: isDark,
          icon: Icons.qr_code_2_outlined,
          title: 'Access and attendance are coming later',
          description:
              'Issuing access codes and recording visits require additional backend setup.',
        ),
        SizedBox(height: 23.h),
        _buildRefreshHint(scheme),
      ],
    );
  }

  bool _isMemberAndPolicyActive(WellnessBenefitsResponse response) {
    return response.member.isActive &&
        response.plan.planActive &&
        response.plan.policyActive;
  }

  Widget _buildEnrolleeCard({
    required WellnessBenefitsResponse response,
    required String memberName,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final displayName = memberName.isNotEmpty ? memberName : 'Oceanic member';
    final firstLetter = displayName[0].toUpperCase();
    final active = response.member.isActive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.055),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              firstLetter,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: scheme.onPrimary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Member ID: ${response.member.memberId}',
                  style: TextStyle(
                    fontSize: 10.8.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            active ? Icons.verified_user_outlined : Icons.info_outline_rounded,
            color: active ? scheme.primary : scheme.error,
            size: 23.r,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(WellnessPlan plan, ColorScheme scheme, bool isDark) {
    final active = plan.planActive && plan.policyActive;
    return Container(
      padding: EdgeInsets.all(17.r),
      decoration: _cardDecoration(scheme, isDark),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: scheme.secondary,
              size: 23.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  active ? 'Active health policy' : 'Policy needs review',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            active ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: active ? const Color(0xFF16835D) : scheme.error,
            size: 22.r,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required ColorScheme scheme,
    required IconData icon,
    required String eyebrow,
    required String title,
    required String description,
  }) {
    final gradientEnd = Color.lerp(scheme.primary, scheme.secondary, 0.27)!;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.20),
            blurRadius: 25.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Stack(
        children: [
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
            right: 20.w,
            bottom: -30.h,
            child: Icon(
              icon,
              size: 110.r,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    eyebrow,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    height: 1.18,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 285.w),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.8.sp,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.82),
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
            fontSize: 17.sp,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.3.sp,
            height: 1.4,
            color: scheme.onSurface.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required ColorScheme scheme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: _cardDecoration(scheme, isDark),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39.r,
            height: 39.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 20.r, color: scheme.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.7.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.2.sp,
                    height: 1.5,
                    color: scheme.onSurface.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme scheme, bool isDark) {
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.025),
          blurRadius: 13.r,
          offset: Offset(0, 4.h),
        ),
      ],
    );
  }

  Widget _buildRefreshHint(ColorScheme scheme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe_down_rounded,
            size: 16.r,
            color: scheme.onSurface.withValues(alpha: 0.40),
          ),
          SizedBox(width: 7.w),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 10.8.sp,
              color: scheme.onSurface.withValues(alpha: 0.46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required ColorScheme scheme,
    required Object error,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: _cardDecoration(scheme, isDark),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 50.r,
                      color: scheme.error,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Unable to load wellness benefits',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        height: 1.5,
                        color: scheme.onSurface.withValues(alpha: 0.60),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(wellnessBenefitsProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
