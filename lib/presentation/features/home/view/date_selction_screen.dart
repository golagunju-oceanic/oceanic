import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:oceanic/presentation/features/home/view/doctor_details_screen.dart';
import 'package:oceanic/presentation/widgets/telemedicine_scaffold.dart';

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  String? _selectedTime;

  final List<String> _times = [
    '12:00 PM',
    '12:15 PM',
    '12:30 PM',
    '12:45 PM',
    '01:00 PM',
    '01:15 PM',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = now;
  }

  List<DateTime> get _weekDays {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TelemedicineScaffold(
      currentStep: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: Icon(
                    Icons.chevron_left,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: Icon(
                    Icons.chevron_right,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekDays.map((date) {
                final selected = DateUtils.isSameDay(date, _selectedDate);
                final isPast = date.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                );

                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () => setState(() {
                          _selectedDate = date;
                          _selectedTime = null;
                        }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary
                          : scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? scheme.secondary
                            : scheme.onSurface.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Opacity(
                      opacity: isPast ? 0.35 : 1.0,
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE').format(date).toUpperCase(),
                            style: TextStyle(
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            Divider(color: scheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 8),
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface,
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
              children: _times.map((t) {
                final selected = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary.withValues(alpha: 0.15)
                          : scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        t,
                        style: TextStyle(
                          color: selected ? scheme.primary : scheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTime != null
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailsScreen(),
                        ),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  disabledBackgroundColor: scheme.onSurface.withValues(
                    alpha: 0.12,
                  ),
                  disabledForegroundColor: scheme.onSurface.withValues(
                    alpha: 0.38,
                  ),
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
