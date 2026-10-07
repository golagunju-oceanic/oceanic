import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:oceanic/features/authorization/data/models/authorization_item_model.dart';
import 'package:oceanic/features/authorization/presentation/provider/authorization_provider.dart';
import 'package:oceanic/features/authorization/presentation/view/authorization_detail_screen.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class AuthorizationScreen extends ConsumerStatefulWidget {
  const AuthorizationScreen({super.key});

  @override
  ConsumerState<AuthorizationScreen> createState() =>
      _AuthorizationScreenState();
}

class _AuthorizationScreenState extends ConsumerState<AuthorizationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTimeRange? _selectedDateRange;

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDateRange() async {
    final scheme = Theme.of(context).colorScheme;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: scheme),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _authorizationDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date unavailable';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    return DateFormat('dd MMM yyyy').format(parsed);
  }

  List<AuthorizationItemModel> _filterAuthorizations(
    List<AuthorizationItemModel> authorizations,
  ) {
    if (_selectedDateRange == null) {
      return authorizations;
    }

    final start = DateTime(
      _selectedDateRange!.start.year,
      _selectedDateRange!.start.month,
      _selectedDateRange!.start.day,
    );

    final end = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
      23,
      59,
      59,
    );

    return authorizations.where((authorization) {
      if (authorization.date == null) {
        return false;
      }

      final date = DateTime.tryParse(authorization.date!);

      if (date == null) {
        return false;
      }

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF16A34A);

      case 'REDUCED':
        return const Color(0xFFF59E0B);

      case 'REJECTED':
        return scheme.error;

      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_outline_rounded;

      case 'REDUCED':
        return Icons.remove_circle_outline_rounded;

      case 'REJECTED':
        return Icons.cancel_outlined;

      default:
        return Icons.schedule_rounded;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authorizationsAsync = ref.watch(authorizationListProvider);

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
              top: 350.h,
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
                  child: authorizationsAsync.when(
                    loading: () {
                      return Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(scheme.primary),
                        ),
                      );
                    },

                    error: (error, stackTrace) {
                      return _buildErrorState(
                        error: error.toString(),
                        scheme: scheme,
                      );
                    },

                    data: (response) {
                      final authorizations = response.results;

                      final filtered = _filterAuthorizations(authorizations);

                      final approved = authorizations
                          .where(
                            (item) => item.status.toUpperCase() == 'APPROVED',
                          )
                          .length;

                      final reduced = authorizations
                          .where(
                            (item) => item.status.toUpperCase() == 'REDUCED',
                          )
                          .length;

                      final rejected = authorizations
                          .where(
                            (item) => item.status.toUpperCase() == 'REJECTED',
                          )
                          .length;

                      final pending = authorizations.where((item) {
                        final status = item.status.toUpperCase();

                        return status != 'APPROVED' &&
                            status != 'REDUCED' &&
                            status != 'REJECTED';
                      }).length;

                      return RefreshIndicator(
                        color: scheme.primary,
                        onRefresh: () async {
                          ref.invalidate(authorizationListProvider);

                          await ref.read(authorizationListProvider.future);
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 560,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      20.w,
                                      8.h,
                                      20.w,
                                      100.h,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // =======================
                                        // OVERVIEW
                                        // =======================
                                        _buildOverviewCard(
                                          total: response.count,
                                          pending: pending,
                                          approved: approved,
                                          reduced: reduced,
                                          rejected: rejected,
                                          scheme: scheme,
                                          isDark: isDark,
                                        ),

                                        SizedBox(height: 28.h),

                                        // =======================
                                        // HEADER
                                        // =======================
                                        _buildSectionHeader(
                                          title: 'Authorizations',
                                          subtitle:
                                              'Track treatment approvals and requests',
                                          scheme: scheme,
                                        ),

                                        SizedBox(height: 14.h),

                                        // =======================
                                        // FILTER
                                        // =======================
                                        _buildDateFilter(
                                          scheme: scheme,
                                          isDark: isDark,
                                        ),

                                        SizedBox(height: 20.h),

                                        // =======================
                                        // RESULT COUNT
                                        // =======================
                                        Row(
                                          children: [
                                            Text(
                                              _selectedDateRange == null
                                                  ? 'Recent requests'
                                                  : 'Filtered results',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w700,
                                                color: scheme.onSurface,
                                              ),
                                            ),
                                            SizedBox(width: 7.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: scheme.primary
                                                    .withValues(alpha: 0.09),
                                                borderRadius:
                                                    BorderRadius.circular(30.r),
                                              ),
                                              child: Text(
                                                filtered.length.toString(),
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

                                        // =======================
                                        // LIST
                                        // =======================
                                        if (filtered.isEmpty)
                                          _buildEmptyState(
                                            scheme: scheme,
                                            isFiltered:
                                                _selectedDateRange != null,
                                          )
                                        else
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: filtered.length,
                                            separatorBuilder: (context, index) {
                                              return SizedBox(height: 12.h);
                                            },
                                            itemBuilder: (context, index) {
                                              return _buildAuthorizationCard(
                                                authorization: filtered[index],
                                                scheme: scheme,
                                                isDark: isDark,
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                  'Authorizations',
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
                  'Approvals & treatment requests',
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
  // OVERVIEW CARD
  // ============================================================

  Widget _buildOverviewCard({
    required int total,
    required int pending,
    required int approved,
    required int reduced,
    required int rejected,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final gradientEnd = Color.lerp(scheme.primary, scheme.secondary, 0.28)!;

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
            right: -45.r,
            top: -55.r,
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
            bottom: -30.h,
            child: Icon(
              Icons.verified_user_rounded,
              size: 120.r,
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
                        Icons.assignment_turned_in_outlined,
                        size: 24.r,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authorization History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$total total authorization${total == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  'Authorization overview',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryStat(
                        value: approved,
                        label: 'Approved',
                        color: const Color(0xFF7EE2A8),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildSummaryStat(
                        value: reduced,
                        label: 'Reduced',
                        color: const Color(0xFFFFC857),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildSummaryStat(
                        value: rejected,
                        label: 'Rejected',
                        color: const Color(0xFFFF8A8A),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildSummaryStat(
                        value: pending,
                        label: 'Pending',
                        color: Colors.white70,
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

  Widget _buildSummaryStat({
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: Colors.white.withValues(alpha: 0.73),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 19.sp,
              height: 1,
              fontWeight: FontWeight.w800,
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
            color: scheme.onSurface.withValues(alpha: 0.52),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE FILTER
  // ============================================================

  Widget _buildDateFilter({required ColorScheme scheme, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.07 : 0.03),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 20.r,
              color: scheme.primary,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: InkWell(
              onTap: _pickDateRange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by date',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.50),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _selectedDateRange == null
                        ? 'Select a date range'
                        : '${_formatDate(_selectedDateRange!.start)} - '
                              '${_formatDate(_selectedDateRange!.end)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedDateRange != null)
            IconButton(
              onPressed: _clearDateFilter,
              icon: Icon(Icons.close_rounded, size: 19.r),
              color: scheme.onSurface.withValues(alpha: 0.45),
            )
          else
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 21.r,
              color: scheme.onSurface.withValues(alpha: 0.38),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // AUTHORIZATION CARD
  // ============================================================

  Widget _buildAuthorizationCard({
    required AuthorizationItemModel authorization,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final status = authorization.status.toUpperCase();

    final statusColor = _statusColor(status, scheme);

    final statusIcon = _statusIcon(status);

    final diagnosis = authorization.diagnosis?.trim().isNotEmpty == true
        ? authorization.diagnosis!
        : 'Clinical Visit';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AuthorizationDetailScreen(authorizationId: authorization.id),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Icon(statusIcon, size: 22.r, color: statusColor),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorization.reference,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          diagnosis,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.3,
                            color: scheme.onSurface.withValues(alpha: 0.53),
                          ),
                        ),

                        SizedBox(height: 7.h),

                        Row(
                          children: [
                            Icon(
                              Icons.local_hospital_outlined,
                              size: 14.r,
                              color: scheme.onSurface.withValues(alpha: 0.42),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Text(
                                authorization.hospital,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.53,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  _buildStatusChip(status: status, color: statusColor),
                ],
              ),

              SizedBox(height: 15.h),

              Divider(
                height: 1,
                color: scheme.onSurface.withValues(alpha: 0.055),
              ),

              SizedBox(height: 13.h),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15.r,
                    color: scheme.onSurface.withValues(alpha: 0.42),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    _authorizationDate(authorization.date),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.53),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17.r,
                    color: scheme.onSurface.withValues(alpha: 0.27),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({required String status, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8.8.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({
    required ColorScheme scheme,
    required bool isFiltered,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 38.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        children: [
          Container(
            width: 62.r,
            height: 62.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_turned_in_outlined,
              size: 28.r,
              color: scheme.primary,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            isFiltered ? 'No results found' : 'No authorizations yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            isFiltered
                ? 'There are no authorization requests within the selected date range.'
                : 'Your treatment authorization requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.52),
            ),
          ),

          if (isFiltered) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: _clearDateFilter,
              child: Text(
                'Clear date filter',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState({
    required String error,
    required ColorScheme scheme,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 30.r,
                color: scheme.error,
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'Unable to load authorizations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.4,
                color: scheme.onSurface.withValues(alpha: 0.52),
              ),
            ),

            SizedBox(height: 18.h),

            ElevatedButton(
              onPressed: () {
                ref.invalidate(authorizationListProvider);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
