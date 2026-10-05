import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/doctor_details_screen.dart';
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

  final Map<String, List<String>> _timeSlots = {
    'Morning': ['09:00 AM', '09:30 AM', '10:15 AM', '11:00 AM'],
    'Afternoon': ['12:00 PM', '12:30 PM', '01:15 PM', '02:00 PM'],
    'Evening': ['04:30 PM', '05:00 PM', '05:45 PM', '06:30 PM'],
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day); // Default to today
  }

  // Days in the focused month
  List<DateTime> get _daysInFocusedMonth {
    final lastDay = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    return List.generate(
      lastDay,
      (i) => DateTime(_focusedMonth.year, _focusedMonth.month, i + 1),
    );
  }

  // Restrict month navigation to current month and future
  bool get _canGoToPreviousMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    return _focusedMonth.isAfter(currentMonth);
  }

  void _changeMonth(int delta) {
    if (delta < 0 && !_canGoToPreviousMonth) return;

    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  // --- CHECK IF A TIME SLOT HAS PASSED FOR TODAY ---
  bool _isTimeSlotPast(String timeStr) {
    final now = DateTime.now();

    // Only validate past time if the selected date is TODAY
    if (!DateUtils.isSameDay(_selectedDate, now)) {
      return false; // Future dates have all time slots available
    }

    try {
      final parsedTime = DateFormat('hh:mm a').parse(timeStr);
      final slotDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      return slotDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return TelemedicineScaffold(
      currentStep: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Text(
              'Select Date & Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose an available slot for your video consultation.',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 16),

            // Month Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _canGoToPreviousMonth
                        ? () => _changeMonth(-1)
                        : null,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: _canGoToPreviousMonth
                          ? scheme.onSurface
                          : scheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      color: scheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Horizontal Date Strip (Disables Past Dates)
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _daysInFocusedMonth.length,
                itemBuilder: (context, index) {
                  final date = _daysInFocusedMonth[index];
                  final isSelected = DateUtils.isSameDay(date, _selectedDate);
                  final isPastDate = date.isBefore(today);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: isPastDate
                          ? null // Non-clickable if date has passed
                          : () => setState(() {
                              _selectedDate = date;
                              _selectedTime = null; // Reset time on date change
                            }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        decoration: BoxDecoration(
                          color: isPastDate
                              ? scheme.onSurface.withValues(alpha: 0.04)
                              : (isSelected
                                    ? scheme.primary
                                    : (scheme.surfaceContainerLow ??
                                          scheme.surfaceContainer)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPastDate
                                ? Colors.transparent
                                : (isSelected
                                      ? scheme.primary
                                      : scheme.outlineVariant.withValues(
                                          alpha: 0.3,
                                        )),
                          ),
                        ),
                        child: Opacity(
                          opacity: isPastDate ? 0.35 : 1.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(date).toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? scheme.onPrimary
                                      : scheme.onSurface.withValues(
                                          alpha: isPastDate ? 0.4 : 0.6,
                                        ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? scheme.onPrimary
                                      : (isPastDate
                                            ? scheme.onSurface.withValues(
                                                alpha: 0.4,
                                              )
                                            : scheme.onSurface),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 12),

            // Time Slots Section
            Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            ..._timeSlots.entries.map((session) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      session.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: session.value.map((time) {
                      final isSelected = _selectedTime == time;
                      final isTimePast = _isTimeSlotPast(
                        time,
                      ); // Checks if slot is in the past for today

                      return GestureDetector(
                        onTap: isTimePast
                            ? null // Non-clickable if time slot has passed today
                            : () => setState(() => _selectedTime = time),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isTimePast
                                ? scheme.onSurface.withValues(alpha: 0.04)
                                : (isSelected
                                      ? scheme.primary.withValues(alpha: 0.12)
                                      : (scheme.surfaceContainerLow ??
                                            scheme.surfaceContainer)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isTimePast
                                  ? Colors.transparent
                                  : (isSelected
                                        ? scheme.primary
                                        : scheme.outlineVariant.withValues(
                                            alpha: 0.3,
                                          )),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Opacity(
                            opacity: isTimePast
                                ? 0.35
                                : 1.0, // Reduced opacity for past slots
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isTimePast
                                    ? scheme.onSurface.withValues(alpha: 0.4)
                                    : (isSelected
                                          ? scheme.primary
                                          : scheme.onSurface),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                                decoration: isTimePast
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Live Booking Preview
            if (_selectedTime != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.video_call_rounded,
                      color: scheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Appointment',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)} at $_selectedTime',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedTime != null
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DoctorDetailsScreen(),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue to Doctor Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
