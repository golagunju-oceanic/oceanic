import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/features/health_provider/presentation/provider/provider_provider.dart';
import 'package:oceanic/features/health_provider/presentation/state/provider_state.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class HealthProvider extends ConsumerStatefulWidget {
  const HealthProvider({super.key});

  @override
  ConsumerState<HealthProvider> createState() => _HealthProviderState();
}

class _HealthProviderState extends ConsumerState<HealthProvider> {
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedPlanVariant;
  String? _selectedTier;

  final List<String> _planVariants = [
    'My Active Plan',
    'Aqua Plan',
    'Teal Plan',
    'Cerulean Plan',
    'Admiral Plan',
    'All Plans',
  ];

  final List<String> _tiers = [
    'All Tiers',
    'Tier 1',
    'Tier 2',
    'Tier 3',
    'Tier 4',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(providerNotifierProvider.notifier).search(value);
  }

  void _clearSearch() {
    _searchController.clear();

    ref.read(providerNotifierProvider.notifier).search('');

    setState(() {});
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _openFilter({required String activePlan}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    String tempPlan = _selectedPlanVariant ?? 'My Active Plan';

    String tempTier = _selectedTier ?? 'All Tiers';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filter Providers',
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: scheme.onSurface,
                                  ),
                                ),

                                SizedBox(height: 4.h),

                                Text(
                                  'Refine the provider directory',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.50,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                            },
                            icon: Icon(Icons.close_rounded, size: 21.r),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // ========================================
                      // PLAN
                      // ========================================
                      _buildFilterSectionTitle(
                        title: 'Plan Variant',
                        subtitle: 'Your active plan is $activePlan',
                        scheme: scheme,
                      ),

                      SizedBox(height: 12.h),

                      Wrap(
                        spacing: 8.w,
                        runSpacing: 9.h,
                        children: _planVariants.map((variant) {
                          final selected = tempPlan == variant;

                          final label = variant == 'My Active Plan'
                              ? 'My Plan ($activePlan)'
                              : variant;

                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) {
                              setModalState(() {
                                tempPlan = variant;
                              });
                            },
                            selectedColor: scheme.primary,
                            backgroundColor: scheme.surface,
                            side: BorderSide(
                              color: selected
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(
                                      alpha: isDark ? 0.10 : 0.06,
                                    ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 10.8.sp,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurface.withValues(alpha: 0.68),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 28.h),

                      // ========================================
                      // TIER
                      // ========================================
                      _buildFilterSectionTitle(
                        title: 'Network Tier',
                        subtitle: 'Choose a preferred provider tier',
                        scheme: scheme,
                      ),

                      SizedBox(height: 12.h),

                      Wrap(
                        spacing: 8.w,
                        runSpacing: 9.h,
                        children: _tiers.map((tier) {
                          final selected = tempTier == tier;

                          return ChoiceChip(
                            label: Text(tier),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) {
                              setModalState(() {
                                tempTier = tier;
                              });
                            },
                            selectedColor: scheme.primary,
                            backgroundColor: scheme.surface,
                            side: BorderSide(
                              color: selected
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(
                                      alpha: isDark ? 0.10 : 0.06,
                                    ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 10.8.sp,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurface.withValues(alpha: 0.68),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 30.h),

                      // ========================================
                      // BUTTONS
                      // ========================================
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempPlan = 'My Active Plan';

                                  tempTier = 'All Tiers';
                                });

                                setState(() {
                                  _selectedPlanVariant = 'My Active Plan';

                                  _selectedTier = 'All Tiers';
                                });

                                Navigator.pop(sheetContext);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50.h),
                                side: BorderSide(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPlanVariant = tempPlan;

                                  _selectedTier = tempTier;
                                });

                                Navigator.pop(sheetContext);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: Size(double.infinity, 50.h),
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final providerState = ref.watch(providerNotifierProvider);

    final viewModel = ref.read(providerNotifierProvider.notifier);

    final policyState = ref.watch(policyProvider);

    final activeUserPlan =
        policyState.card?.planVariant.trim().isNotEmpty == true
        ? policyState.card!.planVariant.toUpperCase()
        : 'PLAN NOT AVAILABLE';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND DECORATION
            // ==================================================
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
              top: 400.h,
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
            // PAGE
            // ==================================================
            Column(
              children: [
                _buildTopBar(scheme: scheme, isDark: isDark),

                Expanded(
                  child: RefreshIndicator.adaptive(
                    onRefresh: viewModel.refresh,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  20.w,
                                  8.h,
                                  20.w,
                                  100.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // =========================
                                    // HERO
                                    // =========================
                                    _buildHeroCard(
                                      activePlan: activeUserPlan,
                                      providerCount: providerState
                                          .filteredProviders
                                          .length,
                                      scheme: scheme,
                                      isDark: isDark,
                                    ),

                                    SizedBox(height: 28.h),

                                    // =========================
                                    // DIRECTORY
                                    // =========================
                                    _buildSectionHeader(
                                      title: 'Provider directory',
                                      subtitle:
                                          'Search hospitals, clinics and healthcare facilities',
                                      scheme: scheme,
                                    ),

                                    SizedBox(height: 14.h),

                                    // =========================
                                    // SEARCH
                                    // =========================
                                    _buildSearchBar(
                                      scheme: scheme,
                                      isDark: isDark,
                                      activePlan: activeUserPlan,
                                    ),

                                    SizedBox(height: 12.h),

                                    // =========================
                                    // PLAN
                                    // =========================
                                    _buildActivePlanCard(
                                      scheme: scheme,
                                      isDark: isDark,
                                      activePlan: activeUserPlan,
                                    ),

                                    if (_hasSelectedFilters) ...[
                                      SizedBox(height: 12.h),

                                      _buildSelectedFilters(scheme: scheme),
                                    ],

                                    SizedBox(height: 24.h),

                                    // =========================
                                    // RESULT TITLE
                                    // =========================
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _searchController.text
                                                    .trim()
                                                    .isEmpty
                                                ? 'Available providers'
                                                : 'Search results',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                        ),

                                        if (!providerState.isLoading)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 9.w,
                                              vertical: 5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: scheme.primary.withValues(
                                                alpha: 0.09,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                            ),
                                            child: Text(
                                              providerState
                                                  .filteredProviders
                                                  .length
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700,
                                                color: scheme.primary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    SizedBox(height: 12.h),

                                    // =========================
                                    // PROVIDERS
                                    // =========================
                                    _buildProviderContent(
                                      scheme: scheme,
                                      isDark: isDark,
                                      state: providerState,
                                      activePlan: activeUserPlan,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  bool get _hasSelectedFilters {
    final plan = _selectedPlanVariant ?? 'My Active Plan';

    final tier = _selectedTier ?? 'All Tiers';

    return plan != 'My Active Plan' || tier != 'All Tiers';
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
                  'Health Providers',
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
                  'Find care within your network',
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
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard({
    required String activePlan,
    required int providerCount,
    required ColorScheme scheme,
    required bool isDark,
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
            right: -45.r,
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
            right: 18.w,
            bottom: -35.h,
            child: Icon(
              Icons.local_hospital_rounded,
              size: 125.r,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.medical_services_outlined,
                        size: 24.r,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 14.r,
                            color: Colors.white,
                          ),

                          SizedBox(width: 5.w),

                          Text(
                            'My Network',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                Text(
                  'Find the right care,\ncloser to you.',
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.15,
                    letterSpacing: -0.45,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 9.h),

                Text(
                  'Explore hospitals and healthcare facilities available through the Oceanic provider network.',
                  style: TextStyle(
                    fontSize: 11.8.sp,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),

                SizedBox(height: 20.h),

                Container(
                  padding: EdgeInsets.all(13.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(17.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 39.r,
                        height: 39.r,
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

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Plan',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: Colors.white.withValues(alpha: 0.68),
                              ),
                            ),

                            SizedBox(height: 3.h),

                            Text(
                              activePlan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          '$providerCount found',
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
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
            fontSize: 11.8.sp,
            height: 1.35,
            color: scheme.onSurface.withValues(alpha: 0.52),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSectionTitle({
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),

        SizedBox(height: 3.h),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10.5.sp,
            color: scheme.onSurface.withValues(alpha: 0.48),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar({
    required ColorScheme scheme,
    required bool isDark,
    required String activePlan,
  }) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.025),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _onSearchChanged(value);

          setState(() {});
        },
        cursorColor: scheme.primary,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search hospital, clinic or location',
          hintStyle: TextStyle(
            fontSize: 11.8.sp,
            color: scheme.onSurface.withValues(alpha: 0.38),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.r,
            color: scheme.onSurface.withValues(alpha: 0.43),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.close_rounded, size: 18.r),
                ),

              IconButton(
                onPressed: () {
                  _openFilter(activePlan: activePlan);
                },
                icon: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 17.r,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVE PLAN
  // ============================================================

  Widget _buildActivePlanCard({
    required ColorScheme scheme,
    required bool isDark,
    required String activePlan,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.055),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: scheme.primary,
              size: 20.r,
            ),
          ),

          SizedBox(width: 11.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active coverage plan',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  activePlan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.verified_rounded, color: scheme.secondary, size: 20.r),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED FILTERS
  // ============================================================

  Widget _buildSelectedFilters({required ColorScheme scheme}) {
    final plan = _selectedPlanVariant ?? 'My Active Plan';

    final tier = _selectedTier ?? 'All Tiers';

    return SizedBox(
      height: 34.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (plan != 'My Active Plan')
            _buildFilterPill(
              label: plan,
              scheme: scheme,
              onRemove: () {
                setState(() {
                  _selectedPlanVariant = 'My Active Plan';
                });
              },
            ),

          if (plan != 'My Active Plan' && tier != 'All Tiers')
            SizedBox(width: 8.w),

          if (tier != 'All Tiers')
            _buildFilterPill(
              label: tier,
              scheme: scheme,
              onRemove: () {
                setState(() {
                  _selectedTier = 'All Tiers';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required ColorScheme scheme,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 11.w, right: 5.w),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),

          SizedBox(width: 3.w),

          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(30.r),
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Icon(
                Icons.close_rounded,
                size: 14.r,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROVIDER CONTENT
  // ============================================================

  Widget _buildProviderContent({
    required ColorScheme scheme,
    required bool isDark,
    required ProviderState state,
    required String activePlan,
  }) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 50.h),
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
      );
    }

    if (state.filteredProviders.isEmpty) {
      return _buildEmptyState(scheme: scheme, activePlan: activePlan);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.filteredProviders.length,
      separatorBuilder: (context, index) {
        return SizedBox(height: 12.h);
      },
      itemBuilder: (context, index) {
        final provider = state.filteredProviders[index];

        return _buildProviderCard(
          providerName: provider.name,
          address: provider.address,
          city: provider.city,
          activePlan: activePlan,
          scheme: scheme,
          isDark: isDark,
        );
      },
    );
  }

  // ============================================================
  // PROVIDER CARD
  // ============================================================

  Widget _buildProviderCard({
    required String providerName,
    required String? address,
    required String? city,
    required String activePlan,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Provider detail screen can be added here later.
        },
        borderRadius: BorderRadius.circular(22.r),
        child: Ink(
          padding: EdgeInsets.all(16.r),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 49.r,
                height: 49.r,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: scheme.primary,
                  size: 23.r,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            providerName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 11.r,
                                color: scheme.secondary,
                              ),

                              SizedBox(width: 4.w),

                              Text(
                                'Network',
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (address != null && address.trim().isNotEmpty) ...[
                      SizedBox(height: 8.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.r,
                            color: scheme.onSurface.withValues(alpha: 0.40),
                          ),

                          SizedBox(width: 5.w),

                          Expanded(
                            child: Text(
                              address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.8.sp,
                                height: 1.35,
                                color: scheme.onSurface.withValues(alpha: 0.53),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (city != null && city.trim().isNotEmpty) ...[
                      SizedBox(height: 7.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 5.w),

              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: scheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState({
    required ColorScheme scheme,
    required String activePlan,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_hospital_outlined,
              size: 29.r,
              color: scheme.primary,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'No providers found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            _searchController.text.trim().isNotEmpty
                ? 'Try a different hospital, clinic or location.'
                : 'No provider results are currently available for $activePlan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.52),
            ),
          ),

          if (_searchController.text.trim().isNotEmpty) ...[
            SizedBox(height: 16.h),

            TextButton(
              onPressed: _clearSearch,
              child: Text(
                'Clear search',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
