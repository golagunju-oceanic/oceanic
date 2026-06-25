import 'package:flutter/material.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthRecord extends StatefulWidget {
  const HealthRecord({super.key});

  @override
  State<HealthRecord> createState() => _HealthRecordState();
}

class _HealthRecordState extends State<HealthRecord> {
  DateTimeRange? _selectedDateRange;

  void _pickDateRange() async {
    final scheme = Theme.of(context).colorScheme;
    final DateTimeRange? picked = await showDateRangePicker(
      barrierColor: scheme.primary.withValues(alpha: 0.5),
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
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

  final List<Map<String, dynamic>> healthRecords = [
    {
      'id': 'REC001',
      'type': 'Consultation',
      'title': 'General Checkup',
      'hospital': "St. Mary's Hospital",
      'doctor': 'Dr. John Doe',
      'date': '2026-04-12',
      'status': 'COMPLETED',
    },
    {
      'id': 'REC002',
      'type': 'Lab Test',
      'title': 'Blood Test',
      'hospital': 'HealthLab',
      'doctor': null,
      'date': '2026-04-10',
      'status': 'COMPLETED',
    },
    {
      'id': 'REC003',
      'type': 'Imaging',
      'title': 'MRI Scan',
      'hospital': 'City Clinic',
      'doctor': 'Dr. Sarah Kim',
      'date': '2026-04-05',
      'status': 'COMPLETED',
    },
    {
      'id': 'REC004',
      'type': 'Prescription',
      'title': 'Medication Refill',
      'hospital': 'Wellness Pharmacy',
      'doctor': 'Dr. Adams',
      'date': '2026-03-28',
      'status': 'ACTIVE',
    },
    {
      'id': 'REC005',
      'type': 'Surgery',
      'title': 'Appendectomy',
      'hospital': 'City Hospital',
      'doctor': 'Dr. Michael Lee',
      'date': '2026-03-15',
      'status': 'COMPLETED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      endDrawer: CustomDrawer(),
      appBar: AppBar(title: const Text('Health Record')),
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
            child: ListView.builder(
              itemCount: healthRecords.length,
              itemBuilder: (context, index) =>
                  _listItem(healthRecords[index], scheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItem(Map<String, dynamic> record, ColorScheme scheme) {
    final statusColor = _getStatusColor(record['status'], scheme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconColor(record['type']).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _getIcon(record['type']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${record['hospital']} • ${record['date']}",
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record['status'],
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF28A745);
      case 'ACTIVE':
        return scheme.primary;
      default:
        return scheme.onSurface.withValues(alpha: 0.4);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'Consultation':
        return Colors.blue;
      case 'Lab Test':
        return Colors.orange;
      case 'Imaging':
        return Colors.purple;
      case 'Prescription':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'Consultation':
        return const Icon(Icons.person, color: Colors.blue);
      case 'Lab Test':
        return const Icon(Icons.science, color: Colors.orange);
      case 'Imaging':
        return const Icon(Icons.image, color: Colors.purple);
      case 'Prescription':
        return const Icon(Icons.medication, color: Colors.green);
      default:
        return const Icon(Icons.medical_services, color: Colors.grey);
    }
  }
}
