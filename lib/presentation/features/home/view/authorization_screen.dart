import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/data/repositories/providers/user_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class AuthorizationScreen extends ConsumerStatefulWidget {
  const AuthorizationScreen({super.key});
  @override
  ConsumerState<AuthorizationScreen> createState() =>
      _AuthorizationScreenState();
  // ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _AuthorizationScreenState extends ConsumerState<AuthorizationScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> authorizations = [
    {
      "id": "AUTH001",
      "service": "MRI Scan",
      "hospital": "St. Mary's Hospital",
      "status": "PENDING",
      "date": "2026-04-12",
    },
    {
      "id": "AUTH002",
      "service": "Surgery",
      "hospital": "City Clinic",
      "status": "APPROVED",
      "date": "2026-04-05",
    },
    {
      "id": "AUTH003",
      "service": "Blood Test",
      "hospital": "HealthLab",
      "status": "REJECTED",
      "date": "2026-04-02",
    },
  ];
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTimeRange? _selectedDateRange;
  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F3A8A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authAsyncProvider);
    return Scaffold(
      endDrawer: CustomDrawer(),
      appBar: AppBar(
        // height: 10,
        title: const Text('Authorization'),
      ),
      body: userAsync.when(
        data: (user) => Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        margin: EdgeInsets.only(left: 20.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        width: 180.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18.r),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _selectedDateRange == null
                                    ? 'Select dates'
                                    : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                                style: TextStyle(fontSize: 11.sp),
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
                        backgroundColor: const Color(0xFF3F3A8A),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Search",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) =>
                        _card(authorizations, index),
                    itemCount: authorizations.length,
                  ),
                ),
              ],
            ),
            // FloatingAppBar(
            //   scrollController: _scrollController,
            //   username: user?.username ?? 'User',
            // ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

// card for each authorization request
Widget? _card(List<Map<String, dynamic>> authorizations, int index) {
  final auth = authorizations[index];
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    elevation: 3,
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            auth['service'],
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text('Hospital: ${auth['hospital']}'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                // padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: auth['status'] == 'APPROVED'
                      ? Colors.green
                      : auth['status'] == 'REJECTED'
                      ? Colors.red
                      : Colors.yellow,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: SizedBox(width: 10.w, height: 10.h),
              ),
              SizedBox(width: 10.w),
              Text('Status: ${auth['status']}'),
            ],
          ),
          SizedBox(height: 8.h),
          Text('Date: ${auth['date']}'),
        ],
      ),
    ),
  );
}
