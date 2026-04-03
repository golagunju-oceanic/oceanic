import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/presentation/features/home/view/doctor_details_screen.dart';
import 'package:oceanic/presentation/widgets/octodoc_scaffold.dart';

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  int _selectedDayIndex = 3; // THU
  String? _selectedTime;

  final List<Map<String, String>> _days = [
    {'day': 'MON', 'date': '5'},
    {'day': 'TUE', 'date': '6'},
    {'day': 'WED', 'date': '7'},
    {'day': 'THU', 'date': '8'},
    {'day': 'FRI', 'date': '9'},
  ];

  final List<String> _times = [
    '12:00 PM',
    '12:15 PM',
    '12:30 PM',
    '12:45 PM',
    '01:00 PM',
    '01:15 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return OctodocScaffold(
      currentStep: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.chevron_left, color: Colors.grey),
                const Text(
                  'MAY 2025',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _days.length,
                (i) => GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedDayIndex == i ? kTeal : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedDayIndex == i
                            ? kTeal
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _days[i]['day']!,
                          style: TextStyle(
                            color: _selectedDayIndex == i
                                ? Colors.white
                                : Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _days[i]['date']!,
                          style: TextStyle(
                            color: _selectedDayIndex == i
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3.5,
              children: _times
                  .map(
                    (t) => GestureDetector(
                      onTap: () => setState(() => _selectedTime = t),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTime == t
                              ? kTeal.withOpacity(0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedTime == t
                                ? kTeal
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            t,
                            style: TextStyle(
                              color: _selectedTime == t
                                  ? kTeal
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTime != null
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DoctorDetailsScreen(),
                        ),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTime != null
                      ? kTeal
                      : kTeal.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
