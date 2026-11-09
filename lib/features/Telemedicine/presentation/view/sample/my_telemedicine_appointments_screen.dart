// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oceanic/features/Telemedicine/domain/entities/telemedicine_entities.dart';
// import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_booking_provider.dart';
// import 'package:oceanic/features/Telemedicine/presentation/screens/appointment_details_screen%20(3).dart';
// import 'package:oceanic/features/Telemedicine/presentation/view/sample/available_doctors_screen%20(2).dart';
// import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_ui.dart';

// class MyTelemedicineAppointmentsScreen extends ConsumerWidget {
//   const MyTelemedicineAppointmentsScreen({super.key, this.newAppointmentId});
//   final String? newAppointmentId;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final scheme = Theme.of(context).colorScheme;
//     final value = ref.watch(myTelemedicineAppointmentsProvider);
//     final doctorsAsync = ref.watch(availableTelemedicineDoctorsProvider);
//     final doctors = doctorsAsync.asData?.value ?? <TelemedicineDoctor>[];

//     String nameFor(String uuid) {
//       for (final doctor in doctors) {
//         if (doctor.id == uuid) return doctor.fullName;
//       }
//       return 'Your doctor';
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('My consultations')),
//       body: RefreshIndicator.adaptive(
//         onRefresh: () async {
//           ref.invalidate(myTelemedicineAppointmentsProvider);
//           ref.invalidate(availableTelemedicineDoctorsProvider);
//           try { await ref.read(myTelemedicineAppointmentsProvider.future); } catch (_) {}
//         },
//         child: value.when(
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (error, _) => TelemedicineErrorPanel(
//             error: error, onRetry: () => ref.invalidate(myTelemedicineAppointmentsProvider),
//           ),
//           data: (appointments) {
//             if (appointments.isEmpty) {
//               return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
//                 const SizedBox(height: 110),
//                 const TelemedicineEmptyPanel(icon: Icons.event_available_outlined,
//                   title: 'No appointments yet', subtitle: 'Choose a doctor to schedule your first consultation.'),
//                 const SizedBox(height: 10),
//                 Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: FilledButton(
//                   onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AvailableDoctorsScreen())),
//                   child: const Text('Find doctors'),
//                 )),
//               ]);
//             }
//             final sorted = [...appointments]..sort((a,b) => b.appointmentDate.compareTo(a.appointmentDate));
//             return ListView.separated(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: const EdgeInsets.all(18),
//               itemCount: sorted.length + 1,
//               separatorBuilder: (_, _) => const SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 if (index == 0) return Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: Row(children: [
//                     Expanded(child: Text('Your appointments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
//                     IconButton(tooltip: 'Book another', onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AvailableDoctorsScreen())), icon: Icon(Icons.add_circle_outline, color: scheme.primary)),
//                   ]),
//                 );
//                 final apt = sorted[index-1];
//                 final fresh = apt.id == newAppointmentId;
//                 return Card(
//                   elevation: 0,
//                   color: fresh ? scheme.primaryContainer.withValues(alpha: 0.40) : scheme.surfaceContainerLow,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(18),
//                     onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => TelemedicineAppointmentDetailsScreen(appointmentId: apt.id))),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Row(children: [
//                           Icon(apt.type == 'VIDEO' ? Icons.videocam_rounded : Icons.call_rounded, color: scheme.primary),
//                           const SizedBox(width: 10),
//                           Expanded(child: Text(nameFor(apt.doctorId), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
//                           TelemedicineStatusChip(status: apt.status),
//                         ]),
//                         const SizedBox(height: 12),
//                         Text(TelemedicineTime.dateTime(apt.appointmentDate), style: const TextStyle(fontWeight: FontWeight.w700)),
//                         const SizedBox(height: 5),
//                         Text('${apt.durationMinutes} min • ${apt.type == 'VIDEO' ? 'Video' : 'Audio'} consultation', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
//                         const SizedBox(height: 6),
//                         Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                           Text('View details', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
//                           Icon(Icons.chevron_right_rounded, color: scheme.primary),
//                         ]),
//                       ]),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
