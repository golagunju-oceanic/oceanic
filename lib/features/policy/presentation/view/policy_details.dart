import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:oceanic/features/policy/data/models/dependant_model.dart';
import 'package:oceanic/features/policy/data/models/member_card_model.dart';
import 'package:oceanic/features/policy/data/models/policy_model.dart';
import 'package:oceanic/features/policy/data/models/utilization_model.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class PolicyDetailsScreen extends ConsumerStatefulWidget {
  const PolicyDetailsScreen({super.key});

  @override
  ConsumerState<PolicyDetailsScreen> createState() =>
      _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _beneficiariesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(policyProvider);

    // =========================================================
    // LOADING
    // =========================================================

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
        ),
      );
    }

    // =========================================================
    // ERROR
    // =========================================================

    if (state.error != null) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const CustomDrawer(),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(scheme: scheme, isDark: isDark),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64.r,
                          height: 64.r,
                          decoration: BoxDecoration(
                            color: scheme.error.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 30.r,
                            color: scheme.error,
                          ),
                        ),

                        SizedBox(height: 18.h),

                        Text(
                          'Unable to load policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            height: 1.5,
                            color: scheme.onSurface.withValues(alpha: 0.56),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final policy = state.policy;
    final utilization = state.utilization;
    final dependants = state.dependants;
    final card = state.card;

    // =========================================================
    // PAGE
    // =========================================================

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // -------------------------------------------------
            // BACKGROUND DECORATION
            // -------------------------------------------------
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
              top: 330.h,
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

            // -------------------------------------------------
            // CONTENT
            // -------------------------------------------------
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
                            // =================================
                            // MEMBER CARD
                            // =================================
                            if (card != null)
                              _buildMemberCard(
                                card: card,
                                scheme: scheme,
                                isDark: isDark,
                              ),

                            if (card != null) SizedBox(height: 28.h),

                            // =================================
                            // UTILIZATION
                            // =================================
                            if (utilization != null) ...[
                              _buildSectionHeader(
                                title: 'Your activity',
                                subtitle:
                                    'A quick look at your health plan usage',
                                scheme: scheme,
                              ),

                              SizedBox(height: 14.h),

                              _buildUtilizationCards(
                                utilization: utilization,
                                scheme: scheme,
                                isDark: isDark,
                              ),

                              SizedBox(height: 30.h),
                            ],

                            // =================================
                            // POLICY INFORMATION
                            // =================================
                            if (policy != null) ...[
                              _buildSectionHeader(
                                title: 'Policy information',
                                subtitle:
                                    'Your membership and coverage details',
                                scheme: scheme,
                              ),

                              SizedBox(height: 14.h),

                              _buildPolicyInformation(
                                policy: policy,
                                scheme: scheme,
                                isDark: isDark,
                              ),

                              SizedBox(height: 30.h),
                            ],

                            // =================================
                            // BENEFICIARIES
                            // =================================
                            _buildSectionHeader(
                              title: 'Beneficiaries',
                              subtitle:
                                  '${dependants.length} ${dependants.length == 1 ? 'person' : 'people'} linked to your plan',
                              scheme: scheme,
                            ),

                            SizedBox(height: 14.h),

                            _buildBeneficiariesCard(
                              dependants: dependants,
                              scheme: scheme,
                              isDark: isDark,
                            ),
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

  // ===========================================================
  // TOP BAR
  // ===========================================================

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
                  'Policy Details',
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
                  'Membership & coverage',
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

  // ===========================================================
  // MEMBER CARD
  // ===========================================================

  Widget _buildMemberCard({
    required MemberCardModel card,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final secondGradient = Color.lerp(scheme.primary, scheme.secondary, 0.28)!;

    final statusIsActive = card.status.toLowerCase() == 'active';

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, secondGradient],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.23),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ---------------------------------------------------
          // DECORATION
          // ---------------------------------------------------
          Positioned(
            right: -45.r,
            top: -55.r,
            child: Container(
              width: 175.r,
              height: 175.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 18.w,
            bottom: -35.h,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 130.r,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),

          // ---------------------------------------------------
          // CARD CONTENT
          // ---------------------------------------------------
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMemberAvatar(card),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEMBER',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 9.5.sp,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            card.fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              height: 1.15,
                              letterSpacing: -0.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 5.h),

                          Text(
                            'ID: ${card.memberId}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusIsActive
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.orange.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 5.w),

                          Text(
                            card.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.14),
                ),

                SizedBox(height: 17.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildMemberInfo(
                        title: 'Plan',
                        value: card.planVariant.isEmpty
                            ? 'Not set'
                            : card.planVariant.toUpperCase(),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: _buildMemberInfo(
                        title: 'Gender',
                        value: card.gender?.trim().isNotEmpty == true
                            ? card.gender!
                            : 'Not set',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildMemberInfo(
                        title: 'Blood group',
                        value: card.bloodGroup?.trim().isNotEmpty == true
                            ? card.bloodGroup!
                            : 'Not set',
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: _buildMemberInfo(
                        title: 'Genotype',
                        value: card.genotype?.trim().isNotEmpty == true
                            ? card.genotype!
                            : 'Not set',
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

  Widget _buildMemberAvatar(MemberCardModel card) {
    return Container(
      width: 58.r,
      height: 58.r,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.80),
          width: 1.5.r,
        ),
      ),
      child: ClipOval(
        child: card.photo.trim().isNotEmpty
            ? Image.network(
                card.photo,
                width: 54.r,
                height: 54.r,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _memberAvatarFallback();
                },
              )
            : _memberAvatarFallback(),
      ),
    );
  }

  Widget _memberAvatarFallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.15),
      child: Icon(
        Icons.person_outline_rounded,
        size: 29.r,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMemberInfo({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 9.8.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // SECTION HEADER
  // ===========================================================

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

  // ===========================================================
  // UTILIZATION
  // ===========================================================

  Widget _buildUtilizationCards({
    required UtilizationModel utilization,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildUsageCard(
            title: 'Total Claims',
            value: utilization.totalClaims.toString(),
            icon: Icons.receipt_long_outlined,
            color: scheme.primary,
            scheme: scheme,
            isDark: isDark,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: _buildUsageCard(
            title: 'Authorizations',
            value: utilization.totalAuthorizations.toString(),
            icon: Icons.verified_user_outlined,
            color: scheme.secondary,
            scheme: scheme,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, size: 21.r, color: color),
              ),

              Icon(
                Icons.trending_up_rounded,
                size: 17.r,
                color: scheme.onSurface.withValues(alpha: 0.26),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.8.sp,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // POLICY INFORMATION
  // ===========================================================

  Widget _buildPolicyInformation({
    required PolicyModel policy,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(23.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 17.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPolicyRow(
            icon: Icons.person_outline_rounded,
            label: 'Policy holder',
            value: '${policy.firstName} ${policy.lastName}',
            scheme: scheme,
          ),

          _buildDivider(scheme),

          _buildPolicyRow(
            icon: Icons.badge_outlined,
            label: 'Member ID',
            value: policy.memberId,
            scheme: scheme,
          ),

          _buildDivider(scheme),

          _buildPolicyRow(
            icon: Icons.layers_outlined,
            label: 'Network tier',
            value: 'TIER 1',
            scheme: scheme,
          ),

          _buildDivider(scheme),

          _buildPolicyStatusRow(status: policy.status, scheme: scheme),

          _buildDivider(scheme),

          _buildPolicyRow(
            icon: Icons.calendar_month_outlined,
            label: 'Date joined',
            value: DateFormat('dd MMM yyyy').format(policy.dateJoined),
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 37.r,
            height: 37.r,
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
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyStatusRow({
    required String status,
    required ColorScheme scheme,
  }) {
    final isActive = status.toLowerCase() == 'active';

    final statusColor = isActive
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 37.r,
            height: 37.r,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.verified_outlined,
              size: 18.r,
              color: statusColor,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),

                SizedBox(width: 5.w),

                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.8.sp,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: scheme.onSurface.withValues(alpha: 0.055),
    );
  }

  // ===========================================================
  // BENEFICIARIES
  // ===========================================================

  Widget _buildBeneficiariesCard({
    required List<DependantModel> dependants,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(23.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 17.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(23.r),
              onTap: () {
                setState(() {
                  _beneficiariesExpanded = !_beneficiariesExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(16.r),
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
                        Icons.people_outline_rounded,
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
                            dependants.isEmpty
                                ? 'No beneficiaries'
                                : '${dependants.length} ${dependants.length == 1 ? 'Beneficiary' : 'Beneficiaries'}',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Text(
                            dependants.isEmpty
                                ? 'No dependants have been added'
                                : 'View members linked to this policy',
                            style: TextStyle(
                              fontSize: 10.8.sp,
                              color: scheme.onSurface.withValues(alpha: 0.50),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (dependants.isNotEmpty)
                      AnimatedRotation(
                        turns: _beneficiariesExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withValues(alpha: 0.045),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20.r,
                            color: scheme.onSurface.withValues(alpha: 0.50),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          if (dependants.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: _beneficiariesExpanded
                  ? Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildDivider(scheme),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
                          child: _buildDependants(
                            dependants: dependants,
                            scheme: scheme,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildDependants({
    required List<DependantModel> dependants,
    required ColorScheme scheme,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dependants.length,
      separatorBuilder: (context, index) {
        return _buildDivider(scheme);
      },
      itemBuilder: (context, index) {
        final dependant = dependants[index];

        final name = dependant.fullName.trim();

        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dependant.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      dependant.relationship,
                      style: TextStyle(
                        fontSize: 10.8.sp,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurface.withValues(alpha: 0.52),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.person_outline_rounded,
                size: 18.r,
                color: scheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        );
      },
    );
  }
}
