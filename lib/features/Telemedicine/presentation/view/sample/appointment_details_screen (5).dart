// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oceanic/features/Telemedicine/domain/entities/telemedicine_entities.dart';
// import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_booking_provider.dart';
// import 'package:oceanic/features/Telemedicine/presentation/screens/outgoing_call_screen%20(1)%20(3).dart';
// import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_ui.dart';

// /// Shared by the patient's appointment list. Server is authoritative for call eligibility.
// class TelemedicineAppointmentDetailsScreen extends ConsumerStatefulWidget {
//   const TelemedicineAppointmentDetailsScreen({
//     super.key,
//     required this.appointmentId,
//   });
//   final String appointmentId;

//   @override
//   ConsumerState<TelemedicineAppointmentDetailsScreen> createState() =>
//       _TelemedicineAppointmentDetailsScreenState();
// }

// class _TelemedicineAppointmentDetailsScreenState
//     extends ConsumerState<TelemedicineAppointmentDetailsScreen> {
//   Timer? clock;
//   bool joining = false;

//   @override
//   void initState() {
//     super.initState();
//     clock = Timer.periodic(const Duration(seconds: 15), (_) {
//       if (mounted) setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     clock?.cancel();
//     super.dispose();
//   }

//   Future<void> _startCall(TelemedicineAppointment appointment) async {
//     setState(() => joining = true);
//     try {
//       // The patient rings the doctor first. Agora starts only after the doctor
//       // accepts the incoming call through the call inbox.
//       await Navigator.of(context).push(
//         MaterialPageRoute<void>(
//           builder: (_) => OutgoingCallScreen(
//             appointmentId: appointment.id,
//             doctorName: 'Your doctor',
//           ),
//         ),
//       );
//       ref.invalidate(telemedicineAppointmentDetailsProvider(appointment.id));
//       ref.invalidate(myTelemedicineAppointmentsProvider);
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(readableTelemedicineError(error))),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => joining = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final details = ref.watch(
//       telemedicineAppointmentDetailsProvider(widget.appointmentId),
//     );
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Appointment details'),
//         actions: [
//           IconButton(
//             tooltip: 'Refresh',
//             onPressed: () => ref.invalidate(
//               telemedicineAppointmentDetailsProvider(widget.appointmentId),
//             ),
//             icon: const Icon(Icons.refresh_rounded),
//           ),
//         ],
//       ),
//       body: details.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, _) => TelemedicineErrorPanel(
//           error: error,
//           onRetry: () => ref.invalidate(
//             telemedicineAppointmentDetailsProvider(widget.appointmentId),
//           ),
//         ),
//         data: (apt) {
//           final now = DateTime.now().toUtc();
//           final eligible = apt.canRequestJoin && apt.inJoinWindow(now);
//           final status = apt.status;
//           String explanation;
//           if (status == 'PENDING') {
//             explanation =
//                 'Waiting for your doctor to confirm this appointment.';
//           } else if (status == 'CANCELLED' ||
//               status == 'MISSED' ||
//               status == 'COMPLETED') {
//             explanation =
//                 'This appointment is ${statusLabel(status)}. Calls are unavailable.';
//           } else if (now.isBefore(apt.joinOpensAt)) {
//             explanation =
//                 'You can join from ${TelemedicineTime.dateTime(apt.joinOpensAt)} (Lagos time).';
//           } else if (!now.isBefore(apt.joinClosesAt)) {
//             explanation = 'The consultation join window has closed.';
//           } else {
//             explanation =
//                 'Your doctor will receive an incoming call request. You will connect once they accept.';
//           }
//           return SafeArea(
//             child: ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: scheme.primaryContainer.withValues(alpha: 0.36),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundColor: scheme.primary.withValues(alpha: 0.15),
//                         child: Icon(
//                           apt.type == 'VIDEO'
//                               ? Icons.video_call_rounded
//                               : Icons.call_rounded,
//                           color: scheme.primary,
//                           size: 30,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         apt.type == 'VIDEO'
//                             ? 'Video consultation'
//                             : 'Audio consultation',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TelemedicineStatusChip(status: apt.status),
//                       const SizedBox(height: 14),
//                       Text(
//                         TelemedicineTime.dateTime(apt.appointmentDate),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${apt.durationMinutes} minutes • Lagos time',
//                         style: TextStyle(color: scheme.onSurfaceVariant),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 if (apt.reason?.isNotEmpty == true) ...[
//                   Text(
//                     'Reason for consultation',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(apt.reason!),
//                   const SizedBox(height: 24),
//                 ],
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: scheme.surfaceContainerLow,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline_rounded, color: scheme.primary),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           explanation,
//                           style: const TextStyle(fontSize: 13),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 FilledButton.icon(
//                   style: FilledButton.styleFrom(
//                     minimumSize: const Size.fromHeight(52),
//                   ),
//                   onPressed: eligible && !joining ? () => _startCall(apt) : null,
//                   icon: joining
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : Icon(
//                           apt.type == 'VIDEO'
//                               ? Icons.videocam_rounded
//                               : Icons.call_rounded,
//                         ),
//                   label: Text(joining ? 'Calling...' : 'Call doctor'),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Appointment ID: ${apt.id}',
//                   style: TextStyle(
//                     color: scheme.onSurfaceVariant,
//                     fontSize: 11,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
