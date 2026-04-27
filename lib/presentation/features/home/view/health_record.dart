import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
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
    final DateTimeRange? picked = await showDateRangePicker(
      barrierColor: kNavyBlue.withValues(alpha: 0.5),
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
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

  final List<Map<String, dynamic>> healthRecords = [
    {
      "id": "REC001",
      "type": "Consultation",
      "title": "General Checkup",
      "hospital": "St. Mary's Hospital",
      "doctor": "Dr. John Doe",
      "date": "2026-04-12",
      "status": "COMPLETED",
    },
    {
      "id": "REC002",
      "type": "Lab Test",
      "title": "Blood Test",
      "hospital": "HealthLab",
      "doctor": null,
      "date": "2026-04-10",
      "status": "COMPLETED",
    },
    {
      "id": "REC003",
      "type": "Imaging",
      "title": "MRI Scan",
      "hospital": "City Clinic",
      "doctor": "Dr. Sarah Kim",
      "date": "2026-04-05",
      "status": "COMPLETED",
    },
    {
      "id": "REC004",
      "type": "Prescription",
      "title": "Medication Refill",
      "hospital": "Wellness Pharmacy",
      "doctor": "Dr. Adams",
      "date": "2026-03-28",
      "status": "ACTIVE",
    },
    {
      "id": "REC005",
      "type": "Surgery",
      "title": "Appendectomy",
      "hospital": "City Hospital",
      "doctor": "Dr. Michael Lee",
      "date": "2026-03-15",
      "status": "COMPLETED",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: CustomDrawer(),
      appBar: AppBar(title: const Text('Health Record')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: AbsorbPointer(
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
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => listItem(healthRecords[index]),
              itemCount: healthRecords.length,
            ),
          ),
        ],
      ),
    );
  }
}

Widget listItem(Map<String, dynamic> record) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        // 🔹 Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _getIcon(record['type']),
        ),

        const SizedBox(width: 12),

        // 🔹 Main Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                record['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              // Hospital + Date
              Text(
                "${record['hospital']} • ${record['date']}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),

        // 🔹 Status Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(record['status']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            record['status'],
            style: TextStyle(
              color: _getStatusColor(record['status']),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case "COMPLETED":
      return Colors.green;
    case "ACTIVE":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Icon _getIcon(String type) {
  switch (type) {
    case "Consultation":
      return const Icon(Icons.person, color: Colors.blue);
    case "Lab Test":
      return const Icon(Icons.science, color: Colors.orange);
    case "Imaging":
      return const Icon(Icons.image, color: Colors.purple);
    case "Prescription":
      return const Icon(Icons.medication, color: Colors.green);
    default:
      return const Icon(Icons.medical_services, color: Colors.grey);
  }
}
