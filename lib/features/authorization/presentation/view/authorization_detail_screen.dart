import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:oceanic/features/authorization/presentation/provider/authorization_provider.dart';

class AuthorizationDetailScreen extends ConsumerWidget {
  final int authorizationId;

  const AuthorizationDetailScreen({super.key, required this.authorizationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authorizationAsync = ref.watch(
      authorizationDetailProvider(authorizationId),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: authorizationAsync.when(
          loading: () {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            );
          },

          error: (error, stackTrace) {
            return _buildErrorState(
              context: context,
              ref: ref,
              error: error.toString(),
              scheme: scheme,
            );
          },

          data: (authorization) {
            final status = authorization.status.toUpperCase();

            final statusColor = _statusColor(status, scheme);

            return Stack(
              children: [
                Positioned(
                  top: -100.h,
                  right: -90.w,
                  child: Container(
                    width: 240.r,
                    height: 240.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(
                        alpha: isDark ? 0.10 : 0.04,
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    _buildTopBar(
                      context: context,
                      scheme: scheme,
                      isDark: isDark,
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 50.h),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderCard(
                                  authorization: authorization,
                                  status: status,
                                  statusColor: statusColor,
                                  scheme: scheme,
                                  isDark: isDark,
                                ),

                                SizedBox(height: 24.h),

                                Text(
                                  'Authorized services',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                                ),

                                SizedBox(height: 5.h),

                                Text(
                                  'Services and treatments reviewed under this authorization',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    height: 1.4,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.52,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                if (authorization.lines.isEmpty)
                                  _buildUnderReviewCard(
                                    scheme: scheme,
                                    isDark: isDark,
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: authorization.lines.length,
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 12.h);
                                    },
                                    itemBuilder: (context, index) {
                                      final line = authorization.lines[index];

                                      return _buildServiceCard(
                                        service: line.service,
                                        status: line.status,
                                        reason: line.reason,
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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar({
    required BuildContext context,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(15.r),
              child: Container(
                width: 43.r,
                height: 43.r,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: scheme.onSurface.withValues(
                      alpha: isDark ? 0.09 : 0.055,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 21.r,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authorization Details',
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Treatment authorization information',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: scheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required dynamic authorization,
    required String status,
    required Color statusColor,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final diagnosis =
        authorization.diagnosis?.toString().trim().isNotEmpty == true
        ? authorization.diagnosis.toString()
        : 'Clinical Visit';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  _statusIcon(status),
                  size: 24.r,
                  color: statusColor,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorization.reference,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Divider(color: scheme.onSurface.withValues(alpha: 0.06)),

          SizedBox(height: 14.h),

          _buildInfoRow(
            icon: Icons.local_hospital_outlined,
            label: 'Hospital',
            value: authorization.hospital,
            scheme: scheme,
          ),

          SizedBox(height: 14.h),

          _buildInfoRow(
            icon: Icons.medical_information_outlined,
            label: 'Diagnosis',
            value: diagnosis,
            scheme: scheme,
          ),

          SizedBox(height: 14.h),

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(authorization.date),
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        SizedBox(width: 11.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: scheme.onSurface.withValues(alpha: 0.48),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String service,
    required String status,
    required String? reason,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final normalized = status.toUpperCase();

    final statusColor = _statusColor(normalized, scheme);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              _statusIcon(normalized),
              size: 20.r,
              color: statusColor,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),

                SizedBox(height: 7.h),

                Text(
                  normalized,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),

                if (reason != null && reason.trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.4,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderReviewCard({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_rounded, size: 34.r, color: scheme.primary),
          SizedBox(height: 12.h),
          Text(
            'Under review',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'The authorization is still being reviewed. Service details will appear here once a decision has been made.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required BuildContext context,
    required WidgetRef ref,
    required String error,
    required ColorScheme scheme,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48.r, color: scheme.error),

            SizedBox(height: 15.h),

            Text(
              'Unable to load authorization',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),

            SizedBox(height: 8.h),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: scheme.onSurface.withValues(alpha: 0.50),
              ),
            ),

            SizedBox(height: 18.h),

            ElevatedButton(
              onPressed: () {
                ref.invalidate(authorizationDetailProvider(authorizationId));
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date unavailable';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    return DateFormat('dd MMM yyyy').format(parsed);
  }

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
}
