// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oceanic/core/network/dio_provider.dart';
// import 'package:oceanic/features/Telemedicine/data/datasource/telemedicine_remote_data_source.dart';
// import 'package:oceanic/features/Telemedicine/data/repository/telemedicine_repository_impl.dart';
// import 'package:oceanic/features/Telemedicine/domain/repository/telemedicine_booking_repository.dart';
// import 'package:oceanic/features/Telemedicine/domain/usecase/telemedicine_booking_usecase.dart';


// import '../../domain/entities/telemedicine_entities.dart';

// // Uses the same configured Dio + Bearer-token interceptor as the rest of Oceanic.
// // If your actual provider symbol differs, change ONLY this integration point.
// final telemedicineBookingDioProvider = Provider<Dio>((ref) => ref.watch(dioProvider));

// final telemedicineBookingRemoteProvider = Provider<TelemedicineBookingRemoteDataSource>(
//   (ref) => TelemedicineBookingRemoteDataSource(ref.watch(telemedicineBookingDioProvider)),
// );

// final telemedicineBookingRepositoryProvider = Provider<TelemedicineBookingRepository>(
//   (ref) => TelemedicineBookingRepositoryImpl(ref.watch(telemedicineBookingRemoteProvider)),
// );

// final getAvailableDoctorsUseCaseProvider = Provider(
//   (ref) => GetAvailableDoctorsUseCase(ref.watch(telemedicineBookingRepositoryProvider)),
// );
// final getDoctorSlotsUseCaseProvider = Provider(
//   (ref) => GetDoctorSlotsUseCase(ref.watch(telemedicineBookingRepositoryProvider)),
// );
// final bookTelemedicineUseCaseProvider = Provider(
//   (ref) => BookTelemedicineAppointmentUseCase(ref.watch(telemedicineBookingRepositoryProvider)),
// );
// final getMyTelemedicineUseCaseProvider = Provider(
//   (ref) => GetMyTelemedicineAppointmentsUseCase(ref.watch(telemedicineBookingRepositoryProvider)),
// );
// final getTelemedicineAppointmentUseCaseProvider = Provider(
//   (ref) => GetTelemedicineAppointmentUseCase(ref.watch(telemedicineBookingRepositoryProvider)),
// );
// final joinTelemedicineAppointmentUseCaseProvider = Provider(
//   (ref) => JoinTelemedicineAppointmentUseCase(ref.watch(telemedicineBookingRepositoryProvider)),
// );

// final availableTelemedicineDoctorsProvider = FutureProvider.autoDispose<List<TelemedicineDoctor>>(
//   (ref) => ref.watch(getAvailableDoctorsUseCaseProvider)(),
// );

// /// Keyed by doctor code and Lagos calendar date, rather than a UTC timestamp.
// class DoctorSlotQuery {
//   const DoctorSlotQuery(this.doctorCode, this.year, this.month, this.day);
//   final String doctorCode;
//   final int year;
//   final int month;
//   final int day;

//   DateTime get lagosDate => DateTime(year, month, day);

//   @override
//   bool operator ==(Object other) => other is DoctorSlotQuery &&
//       other.doctorCode == doctorCode && other.year == year &&
//       other.month == month && other.day == day;
//   @override
//   int get hashCode => Object.hash(doctorCode, year, month, day);
// }

// final telemedicineSlotsProvider = FutureProvider.autoDispose.family<List<TelemedicineSlot>, DoctorSlotQuery>(
//   (ref, query) => ref.watch(getDoctorSlotsUseCaseProvider)(query.doctorCode, query.lagosDate),
// );

// final myTelemedicineAppointmentsProvider = FutureProvider.autoDispose<List<TelemedicineAppointment>>(
//   (ref) => ref.watch(getMyTelemedicineUseCaseProvider)(),
// );

// final telemedicineAppointmentDetailsProvider = FutureProvider.autoDispose.family<TelemedicineAppointment, String>(
//   (ref, id) => ref.watch(getTelemedicineAppointmentUseCaseProvider)(id),
// );

// class TelemedicineBookingActions extends Notifier<AsyncValue<void>> {
//   @override
//   AsyncValue<void> build() => const AsyncData<void>(null);

//   Future<TelemedicineAppointment> book({
//     required TelemedicineDoctor doctor,
//     required TelemedicineSlot slot,
//     required String type,
//     String? reason,
//   }) async {
//     if (state.isLoading) throw StateError('Booking already in progress');
//     state = const AsyncLoading<void>();
//     try {
//       final appointment = await ref.read(bookTelemedicineUseCaseProvider)(
//         doctorCode: doctor.bookingId,
//         slot: slot,
//         type: type,
//         reason: reason,
//       );
//       ref.invalidate(myTelemedicineAppointmentsProvider);
//       ref.invalidate(telemedicineSlotsProvider(DoctorSlotQuery(
//         doctor.bookingId,
//         slot.startAt.toUtc().add(const Duration(hours: 1)).year,
//         slot.startAt.toUtc().add(const Duration(hours: 1)).month,
//         slot.startAt.toUtc().add(const Duration(hours: 1)).day,
//       )));
//       state = const AsyncData<void>(null);
//       return appointment;
//     } catch (error, trace) {
//       state = AsyncError<void>(error, trace);
//       Error.throwWithStackTrace(error, trace);
//     }
//   }
// }

// final telemedicineBookingActionsProvider =
//     NotifierProvider<TelemedicineBookingActions, AsyncValue<void>>(
//   TelemedicineBookingActions.new,
// );
