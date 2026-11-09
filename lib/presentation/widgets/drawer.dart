import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/features/auth/presentations/screen/auth_screen.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/features/home/view/Profile.dart';
import 'package:oceanic/presentation/features/home/view/settings.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authState = ref.watch(authProvider);

    final policyState = ref.watch(policyProvider);

    final user = authState.user;
    final card = policyState.card;

    final firstName = user?.firstName?.trim() ?? '';

    final lastName = user?.lastName?.trim() ?? '';

    final fullName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Oceanic Member';

    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : 'Oceanic Health';

    final plan = card?.planVariant.trim().isNotEmpty == true
        ? card!.planVariant.toUpperCase()
        : 'MEMBER';

    final photo = card?.photo;

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.88,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28.r)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            // ==================================================
            // MEMBER HEADER
            // ==================================================
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
              child: _buildDrawerHeader(
                context: context,
                scheme: scheme,
                fullName: fullName,
                email: email,
                plan: plan,
                photo: photo,
              ),
            ),

            SizedBox(height: 14.h),

            // ==================================================
            // MENU
            // ==================================================
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                children: [
                  _buildSectionTitle('MAIN MENU', scheme),

                  SizedBox(height: 5.h),

                  _buildDrawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile & Member Card',
                    subtitle: 'View your member profile',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.shield_outlined,
                    title: 'My Policy & Benefits',
                    subtitle: 'View plan details & limits',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Claims & Authorizations',
                    subtitle: 'Track approvals & refunds',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.local_hospital_outlined,
                    title: 'Find Healthcare Provider',
                    subtitle: 'Hospitals & clinics near you',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.video_camera_front_outlined,
                    title: 'Telemedicine Consult',
                    subtitle: 'Speak with a doctor online',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 12.h,
                    ),
                    child: Divider(
                      height: 1,
                      color: scheme.onSurface.withValues(alpha: 0.06),
                    ),
                  ),

                  _buildSectionTitle('SUPPORT & SETTINGS', scheme),

                  SizedBox(height: 5.h),

                  _buildDrawerItem(
                    icon: Icons.phone_in_talk_outlined,
                    title: 'Emergency Hotlines',
                    subtitle: '24/7 Oceanic helpdesk',
                    scheme: scheme,
                    isDark: isDark,
                    accentColor: scheme.secondary,
                    onTap: () {
                      Navigator.pop(context);

                      _showEmergencyBottomSheet(context, scheme, isDark);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQs & Support',
                    subtitle: 'Get help and answers',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Manage app preferences',
                    scheme: scheme,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // LOGOUT
            // ==================================================
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
              child: _buildLogoutTile(
                context: context,
                scheme: scheme,
                isDark: isDark,
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 13.h),
              child: Text(
                'Oceanic Health • v1.0.0',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withValues(alpha: 0.33),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildDrawerHeader({
    required BuildContext context,
    required ColorScheme scheme,
    required String fullName,
    required String email,
    required String plan,
    required String? photo,
  }) {
    final gradientEnd = Color.lerp(scheme.primary, scheme.secondary, 0.25)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 20.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ----------------------------------------------------
          // DECORATIVE CIRCLES
          // ----------------------------------------------------
          Positioned(
            right: -40.r,
            top: -50.r,
            child: Container(
              width: 145.r,
              height: 145.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 20.w,
            bottom: -35.h,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 105.r,
              color: Colors.white.withValues(alpha: 0.045),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(17.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 35.r,
                      height: 35.r,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: Text(
                        'Oceanic Health',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(30.r),
                        child: Container(
                          width: 31.r,
                          height: 31.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 17.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                Row(
                  children: [
                    _buildMemberAvatar(fullName: fullName, photo: photo),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.8.sp,
                              color: Colors.white.withValues(alpha: 0.70),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Text(
                              plan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8.7.sp,
                                letterSpacing: 0.3,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildMemberAvatar({
    required String fullName,
    required String? photo,
  }) {
    final initial = fullName.trim().isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : 'M';

    return Container(
      width: 55.r,
      height: 55.r,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
          width: 1.4.r,
        ),
      ),
      child: ClipOval(
        child: photo?.trim().isNotEmpty == true
            ? Image.network(
                photo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialAvatar(initial);
                },
              )
            : _buildInitialAvatar(initial),
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white.withValues(alpha: 0.14),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9.2.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: scheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required ColorScheme scheme,
    required bool isDark,
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final color = accentColor ?? scheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.13 : 0.075),
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Icon(icon, size: 19.r, color: color),
                ),

                SizedBox(width: 11.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.3.sp,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),

                      if (subtitle != null) ...[
                        SizedBox(height: 3.h),

                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.7.sp,
                            color: scheme.onSurface.withValues(alpha: 0.44),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 6.w),

                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.035),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 17.r,
                    color: scheme.onSurface.withValues(alpha: 0.27),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutTile({
    required BuildContext context,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        },
        borderRadius: BorderRadius.circular(17.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: scheme.error.withValues(alpha: isDark ? 0.10 : 0.055),
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: scheme.error.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 39.r,
                height: 39.r,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 18.r,
                  color: scheme.error,
                ),
              ),

              SizedBox(width: 11.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: scheme.error,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      'Sign out of your account',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: scheme.error.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_rounded,
                size: 17.r,
                color: scheme.error.withValues(alpha: 0.60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMERGENCY BOTTOM SHEET
  // ============================================================

  void _showEmergencyBottomSheet(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

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
                          Icons.phone_in_talk_outlined,
                          size: 21.r,
                          color: scheme.secondary,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Hotlines',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),

                            SizedBox(height: 3.h),

                            Text(
                              'Oceanic support contacts',
                              style: TextStyle(
                                fontSize: 10.8.sp,
                                color: scheme.onSurface.withValues(alpha: 0.48),
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: Icon(Icons.close_rounded, size: 20.r),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  _emergencyNumberTile(
                    title: '24/7 Call Center Desk',
                    contact: '02013300300',
                    icon: Icons.support_agent_rounded,
                    scheme: scheme,
                    isDark: isDark,
                  ),

                  SizedBox(height: 9.h),

                  _emergencyNumberTile(
                    title: 'Emergency Approvals',
                    contact: '02013300301',
                    icon: Icons.verified_user_outlined,
                    scheme: scheme,
                    isDark: isDark,
                  ),

                  SizedBox(height: 9.h),

                  _emergencyNumberTile(
                    title: 'Email Support',
                    contact: 'hmo@oceanichealthng.com',
                    icon: Icons.email_outlined,
                    scheme: scheme,
                    isDark: isDark,
                    showCallIcon: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emergencyNumberTile({
    required String title,
    required String contact,
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
    bool showCallIcon = true,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.r),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: isDark ? 0.045 : 0.025),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(icon, size: 19.r, color: scheme.primary),
          ),

          SizedBox(width: 11.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: scheme.onSurface.withValues(alpha: 0.48),
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  contact,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),

          if (showCallIcon)
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: scheme.secondary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.call_outlined,
                size: 17.r,
                color: scheme.secondary,
              ),
            ),
        ],
      ),
    );
  }
}
