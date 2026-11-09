// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oceanic/features/Telemedicine/domain/entities/telemedicine_entities.dart';
// import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_booking_provider.dart';
// import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_ui.dart';
// import 'my_telemedicine_appointments_screen.dart';

// class BookTelemedicineAppointmentScreen extends ConsumerStatefulWidget {
//   const BookTelemedicineAppointmentScreen({super.key, required this.doctor});
//   final TelemedicineDoctor doctor;

//   @override
//   ConsumerState<BookTelemedicineAppointmentScreen> createState() => _BookTelemedicineAppointmentScreenState();
// }

// class _BookTelemedicineAppointmentScreenState extends ConsumerState<BookTelemedicineAppointmentScreen> {
//   late DateTime selectedDate;
//   TelemedicineSlot? selectedSlot;
//   String type = 'VIDEO';
//   final reason = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Start with today; the API returns every available 30-minute slot 24/7.
//     selectedDate = TelemedicineTime.todayLagos();
//   }

//   @override
//   void dispose() {
//     reason.dispose();
//     super.dispose();
//   }

//   DoctorSlotQuery get query => DoctorSlotQuery(widget.doctor.bookingId, selectedDate.year, selectedDate.month, selectedDate.day);

//   Future<void> _pickDate() async {
//     final today = TelemedicineTime.todayLagos();
//     final chosen = await showDatePicker(
//       context: context,
//       firstDate: today,
//       lastDate: today.add(const Duration(days: 30)),
//       initialDate: selectedDate,
//       helpText: 'Select consultation date (Lagos time)',
//     );
//     if (chosen != null && mounted) setState(() {
//       selectedDate = chosen;
//       selectedSlot = null;
//     });
//   }

//   Future<void> _book() async {
//     final slot = selectedSlot;
//     if (slot == null) return;
//     if (!widget.doctor.canBook) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('This doctor is offline and is not accepting bookings.'),
//         ),
//       );
//       return;
//     }
//     try {
//       final booked = await ref.read(telemedicineBookingActionsProvider.notifier).book(
//         doctor: widget.doctor,
//         slot: slot,
//         type: type,
//         reason: reason.text.trim(),
//       );
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Appointment requested. Your doctor will confirm it.'),
//       ));
//       Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
//         builder: (_) => MyTelemedicineAppointmentsScreen(newAppointmentId: booked.id),
//       ));
//     } catch (error) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(readableTelemedicineError(error))));
//       ref.invalidate(telemedicineSlotsProvider(query)); // re-fetch after a conflict
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final slots = ref.watch(telemedicineSlotsProvider(query));
//     final booking = ref.watch(telemedicineBookingActionsProvider);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Book consultation')),
//       body: SafeArea(child: ListView(
//         padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
//         children: [
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(20)),
//             child: Row(children: [
//               Icon(Icons.health_and_safety_rounded, color: scheme.primary, size: 34),
//               const SizedBox(width: 12),
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text(widget.doctor.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
//                 Text(widget.doctor.specialty ?? 'Medical consultation', style: TextStyle(color: scheme.onSurfaceVariant)),
//                 Text(widget.doctor.bookingId, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
//               ])),
//             ]),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
//             decoration: BoxDecoration(
//               color: widget.doctor.canBook
//                   ? const Color(0xFF22A06B).withValues(alpha: .10)
//                   : scheme.errorContainer,
//               borderRadius: BorderRadius.circular(13),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   widget.doctor.canBook
//                       ? Icons.check_circle_outline_rounded
//                       : Icons.pause_circle_outline_rounded,
//                   color: widget.doctor.canBook
//                       ? const Color(0xFF22A06B)
//                       : scheme.error,
//                   size: 19,
//                 ),
//                 const SizedBox(width: 9),
//                 Expanded(
//                   child: Text(
//                     widget.doctor.canBook
//                         ? 'Online now · Appointments can be booked 24/7.'
//                         : 'This doctor is offline and cannot receive new bookings.',
//                     style: TextStyle(
//                       color: widget.doctor.canBook
//                           ? const Color(0xFF22A06B)
//                           : scheme.onErrorContainer,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text('1. Select a date', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
//           const SizedBox(height: 10),
//           OutlinedButton.icon(
//             onPressed: booking.isLoading ? null : _pickDate,
//             icon: const Icon(Icons.calendar_today_rounded),
//             label: Text(TelemedicineTime.calendarDate(selectedDate)),
//           ),
//           const SizedBox(height: 18),
//           Text('2. Select a 30-minute time slot (Lagos)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
//           const SizedBox(height: 12),
//           slots.when(
//             loading: () => const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator())),
//             error: (err, _) => TelemedicineErrorPanel(error: err, onRetry: () => ref.invalidate(telemedicineSlotsProvider(query))),
//             data: (available) {
//               if (available.isEmpty) return const TelemedicineEmptyPanel(
//                 icon: Icons.event_busy_rounded,
//                 title: 'No slots on this date',
//                 subtitle: 'Choose a different day or another doctor.',
//               );
//               return Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: available.map((slot) {
//                   final isSelected = selectedSlot?.startAtIso == slot.startAtIso;
//                   return ChoiceChip(
//                     selected: isSelected,
//                     label: Text(TelemedicineTime.time(slot.startAt)),
//                     onSelected: booking.isLoading ? null : (_) => setState(() => selectedSlot = slot),
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//           const SizedBox(height: 22),
//           Text('3. Consultation method', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
//           const SizedBox(height: 10),
//           SegmentedButton<String>(
//             segments: const [
//               ButtonSegment(value: 'VIDEO', label: Text('Video'), icon: Icon(Icons.videocam_rounded)),
//               ButtonSegment(value: 'AUDIO', label: Text('Audio'), icon: Icon(Icons.call_rounded)),
//             ],
//             selected: {type},
//             onSelectionChanged: booking.isLoading ? null : (set) => setState(() => type = set.first),
//           ),
//           const SizedBox(height: 20),
//           Text('Reason for consultation (optional)', style: Theme.of(context).textTheme.titleSmall),
//           const SizedBox(height: 8),
//           TextField(
//             controller: reason,
//             maxLength: 500,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: 'Briefly describe what you need help with',
//               filled: true,
//               fillColor: scheme.surfaceContainerLow,
//               border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(16)),
//             ),
//           ),
//           const SizedBox(height: 18),
//           Text('Appointments are requested first and confirmed by the doctor before calls can start.',
//             style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
//           const SizedBox(height: 14),
//           FilledButton.icon(
//             onPressed: selectedSlot == null || booking.isLoading || !widget.doctor.canBook ? null : _book,
//             icon: booking.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle_outline_rounded),
//             label: Text(booking.isLoading ? 'Booking...' : 'Request appointment'),
//             style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
//           ),
//         ],
//       )),
//     );
//   }
// }
