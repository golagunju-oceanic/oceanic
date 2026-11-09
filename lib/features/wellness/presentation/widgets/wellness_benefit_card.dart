import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/wellness_benefit_model.dart';

/// Read-only display of one benefit returned by GET /wellness/benefits.
/// Never guesses remaining sessions from text or a null limit.
class WellnessBenefitCard extends StatelessWidget {
  final WellnessBenefit benefit;

  const WellnessBenefitCard({super.key, required this.benefit});

  IconData get _icon {
    final label = '${benefit.name} ${benefit.code ?? ''}'.toLowerCase();
    if (label.contains('gym') && label.contains('swim')) {
      return Icons.sports_gymnastics_outlined;
    }
    if (label.contains('swim') || label.contains('pool')) {
      return Icons.pool_outlined;
    }
    if (label.contains('gym') || label.contains('fitness')) {
      return Icons.fitness_center_outlined;
    }
    if (label.contains('spa') || label.contains('massage')) {
      return Icons.spa_outlined;
    }
    return Icons.self_improvement_outlined;
  }

  String get _periodText {
    switch (benefit.limitPeriod?.trim().toLowerCase()) {
      case 'per_annum':
      case 'annually':
        return ' per year';
      case 'per_month':
      case 'monthly':
        return ' per month';
      case 'per_week':
      case 'weekly':
        return ' per week';
      default:
        return '';
    }
  }

  String get _statusLabel {
    if (benefit.isCovered) return 'Covered';
    switch (benefit.coverageStatus.toLowerCase().trim()) {
      case 'not_covered':
      case 'excluded':
      case 'uncovered':
        return 'Not covered';
      default:
        return 'Check coverage';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = benefit.isCovered
        ? const Color(0xFF16835D)
        : scheme.onSurfaceVariant;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.07 : 0.025),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
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
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(_icon, color: scheme.primary, size: 24.r),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    benefit.displayName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      benefit.isCovered
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 13.r,
                      color: statusColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.07)),
          SizedBox(height: 14.h),
          Text(
            'WHAT YOUR PLAN COVERS',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.48),
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            benefit.coverageDescription.trim().isNotEmpty
                ? benefit.coverageDescription.trim()
                : 'Additional coverage details are not available.',
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.55,
              color: scheme.onSurface.withValues(alpha: 0.77),
            ),
          ),
          if (benefit.isUnlimited || benefit.limitVisits != null) ...[
            SizedBox(height: 15.h),
            _DetailRow(
              icon: Icons.event_available_outlined,
              text: benefit.isUnlimited
                  ? 'Unlimited visits (as configured by your policy)'
                  : 'Visit allowance: ${benefit.limitVisits}$_periodText',
            ),
          ],
          if (benefit.limitAmount != null) ...[
            SizedBox(height: 10.h),
            _DetailRow(
              icon: Icons.account_balance_wallet_outlined,
              text: 'Amount allowance: ${benefit.limitAmount}',
            ),
          ],
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: isDark ? 0.09 : 0.045),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16.r,
                  color: scheme.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    benefit.coverageSource == 'policy_override'
                        ? 'Coverage from your assigned policy'
                        : 'Coverage from your health plan',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      fontSize: 10.7.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (benefit.requiresAuthorization) ...[
            SizedBox(height: 11.h),
            _DetailRow(
              icon: Icons.shield_outlined,
              text: 'Medical preauthorization is required by this benefit.',
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.r, color: scheme.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}
