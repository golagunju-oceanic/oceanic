import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/features/dashboard/data/models/recent_authorization.dart';
import 'package:oceanic/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class AuthorizationScreen extends ConsumerStatefulWidget {
  const AuthorizationScreen({super.key});
  @override
  ConsumerState<AuthorizationScreen> createState() =>
      _AuthorizationScreenState();
}

class _AuthorizationScreenState extends ConsumerState<AuthorizationScreen> {
  final ScrollController _scrollController = ScrollController();

  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _pickDateRange() async {
    final scheme = Theme.of(context).colorScheme;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: scheme),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      endDrawer: CustomDrawer(),
      appBar: AppBar(title: const Text('Authorization')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    width: 180.w,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: scheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18.r,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _selectedDateRange == null
                                ? 'Select dates'
                                : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: scheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final dashboard = ref.watch(dashboardProvider);

                return dashboard.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text(error.toString())),
                  data: (data) {
                    final authorizations = data.recentAuthorizations;

                    if (authorizations.isEmpty) {
                      return Column(
                        children: [
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

                          const Center(child: Text("No authorizations found")),
                        ],
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(dashboardProvider.notifier)
                          .refreshDashboard(),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: authorizations.length,
                        itemBuilder: (context, index) {
                          final auth = authorizations[index];

                          return _buildCard(auth, scheme);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(RecentAuthorization auth, ColorScheme scheme) {
    Color statusColor;
    switch (auth.status?.toUpperCase()) {
      case 'APPROVED':
        statusColor = const Color(0xFF28A745);
        break;
      case 'REJECTED':
        statusColor = scheme.error;
        break;
      default:
        statusColor = const Color(0xFFF5A623);
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: scheme.surfaceContainer,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              auth.service!,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Hospital: ${auth.hospital}',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Status: ${auth.status}',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Date: ${auth.createdAt}',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
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
