import 'package:dio/dio.dart';
import 'package:oceanic/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/data/datasource/doctor_remote_datasource%20(1).dart';
import 'package:oceanic/features/doctor/data/repositories/doctor_repository_impl%20(3).dart';
import 'package:oceanic/features/doctor/domain/entities/doctor_dashboard%20(1).dart';
import 'package:oceanic/features/doctor/domain/repositories/doctor_repository%20(2).dart';
import '../../domain/entities/doctor_appointment.dart';
import '../../domain/entities/doctor_availability.dart';
import '../../domain/entities/doctor_patient.dart';
import '../../domain/entities/doctor_patient_records.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/usecases/doctor_appointment_usecases.dart';
import '../../domain/usecases/doctor_availability_usecases.dart';
import '../../domain/usecases/doctor_dashboard_usecases.dart';
import '../../domain/usecases/doctor_patient_usecases.dart';
import '../../domain/usecases/doctor_profile_usecases.dart';

/// Reuse the app's existing Dio instance so the doctor's JWT interceptor
/// and configured API base URL are preserved.
final doctorDioProvider = Provider<Dio>((ref) => ref.watch(dioProvider));

final doctorRemoteDataSourceProvider = Provider<DoctorRemoteDataSource>((ref) {
  // If Dio baseUrl is the host root instead of /api, supply
  // routePrefix: '/api/doctor' below.
  return DoctorRemoteDataSourceImpl(ref.watch(doctorDioProvider));
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl(ref.watch(doctorRemoteDataSourceProvider));
});

final getDoctorProfileUseCaseProvider = Provider((ref) =>
    GetMyDoctorProfileUseCase(ref.watch(doctorRepositoryProvider)));
final updateDoctorTelemedicineStatusUseCaseProvider = Provider((ref) =>
    UpdateDoctorTelemedicineStatusUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorDashboardUseCaseProvider = Provider((ref) =>
    GetDoctorDashboardUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorAvailabilityUseCaseProvider = Provider((ref) =>
    GetDoctorAvailabilityUseCase(ref.watch(doctorRepositoryProvider)));
final createDoctorAvailabilityUseCaseProvider = Provider((ref) =>
    CreateDoctorAvailabilityUseCase(ref.watch(doctorRepositoryProvider)));
final updateDoctorAvailabilityUseCaseProvider = Provider((ref) =>
    UpdateDoctorAvailabilityUseCase(ref.watch(doctorRepositoryProvider)));
final deleteDoctorAvailabilityUseCaseProvider = Provider((ref) =>
    DeleteDoctorAvailabilityUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorAppointmentsUseCaseProvider = Provider((ref) =>
    GetDoctorAppointmentsUseCase(ref.watch(doctorRepositoryProvider)));
final getTodayDoctorAppointmentsUseCaseProvider = Provider((ref) =>
    GetTodayDoctorAppointmentsUseCase(ref.watch(doctorRepositoryProvider)));
final getUpcomingDoctorAppointmentsUseCaseProvider = Provider((ref) =>
    GetUpcomingDoctorAppointmentsUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorAppointmentByIdUseCaseProvider = Provider((ref) =>
    GetDoctorAppointmentByIdUseCase(ref.watch(doctorRepositoryProvider)));
final confirmDoctorAppointmentUseCaseProvider = Provider((ref) =>
    ConfirmDoctorAppointmentUseCase(ref.watch(doctorRepositoryProvider)));
final startDoctorAppointmentUseCaseProvider = Provider((ref) =>
    StartDoctorAppointmentUseCase(ref.watch(doctorRepositoryProvider)));
final completeDoctorAppointmentUseCaseProvider = Provider((ref) =>
    CompleteDoctorAppointmentUseCase(ref.watch(doctorRepositoryProvider)));
final cancelDoctorAppointmentUseCaseProvider = Provider((ref) =>
    CancelDoctorAppointmentUseCase(ref.watch(doctorRepositoryProvider)));
final markDoctorAppointmentMissedUseCaseProvider = Provider((ref) =>
    MarkDoctorAppointmentMissedUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorPatientsUseCaseProvider = Provider((ref) =>
    GetDoctorPatientsUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorPatientByIdUseCaseProvider = Provider((ref) =>
    GetDoctorPatientByIdUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorPatientAppointmentsUseCaseProvider = Provider((ref) =>
    GetDoctorPatientAppointmentsUseCase(ref.watch(doctorRepositoryProvider)));
final getDoctorPatientHistoryUseCaseProvider = Provider((ref) =>
    GetDoctorPatientHistoryUseCase(ref.watch(doctorRepositoryProvider)));

final doctorProfileProvider = FutureProvider.autoDispose<DoctorProfile>((ref) =>
    ref.watch(getDoctorProfileUseCaseProvider)());
final doctorDashboardProvider = FutureProvider.autoDispose<DoctorDashboard>((ref) =>
    ref.watch(getDoctorDashboardUseCaseProvider)());
final doctorAvailabilityProvider = FutureProvider.autoDispose<List<DoctorAvailability>>((ref) =>
    ref.watch(getDoctorAvailabilityUseCaseProvider)());
final doctorAppointmentsProvider = FutureProvider.autoDispose<List<DoctorAppointment>>((ref) =>
    ref.watch(getDoctorAppointmentsUseCaseProvider)());
final doctorTodayAppointmentsProvider = FutureProvider.autoDispose<List<DoctorAppointment>>((ref) =>
    ref.watch(getTodayDoctorAppointmentsUseCaseProvider)());
final doctorUpcomingAppointmentsProvider = FutureProvider.autoDispose<List<DoctorAppointment>>((ref) =>
    ref.watch(getUpcomingDoctorAppointmentsUseCaseProvider)());
final doctorAppointmentProvider = FutureProvider.autoDispose.family<DoctorAppointment, String>(
    (ref, id) => ref.watch(getDoctorAppointmentByIdUseCaseProvider)(id));
final doctorPatientsProvider = FutureProvider.autoDispose<List<DoctorPatient>>((ref) =>
    ref.watch(getDoctorPatientsUseCaseProvider)());
final doctorPatientProvider = FutureProvider.autoDispose.family<DoctorPatient, String>(
    (ref, id) => ref.watch(getDoctorPatientByIdUseCaseProvider)(id));
final doctorPatientAppointmentsProvider =
    FutureProvider.autoDispose.family<DoctorPatientAppointments, String>(
        (ref, id) => ref.watch(getDoctorPatientAppointmentsUseCaseProvider)(id));
final doctorPatientHistoryProvider =
    FutureProvider.autoDispose.family<DoctorPatientHistory, String>(
        (ref, id) => ref.watch(getDoctorPatientHistoryUseCaseProvider)(id));

/// Updates the doctor's persistent ONLINE/OFFLINE telemedicine state.
/// Successful changes refresh both profile and dashboard data from the API.
class DoctorTelemedicineStatusActions extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> setStatus(String status) async {
    if (status != 'ONLINE' && status != 'OFFLINE') {
      throw ArgumentError.value(status, 'status', 'Must be ONLINE or OFFLINE');
    }
    if (state.isLoading) return;

    state = const AsyncLoading<void>();
    try {
      await ref.read(updateDoctorTelemedicineStatusUseCaseProvider)(status);
      ref.invalidate(doctorProfileProvider);
      ref.invalidate(doctorDashboardProvider);
      state = const AsyncData<void>(null);
    } catch (error, stack) {
      state = AsyncError<void>(error, stack);
      Error.throwWithStackTrace(error, stack);
    }
  }
}

final doctorTelemedicineStatusActionsProvider =
    NotifierProvider<DoctorTelemedicineStatusActions, AsyncValue<void>>(
  DoctorTelemedicineStatusActions.new,
);

/// Keep writes separate from GET providers. A successful write invalidates
/// affected read caches, so any mounted doctor screens automatically refetch.
class DoctorAppointmentActions extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> _run(String id, Future<DoctorAppointment> Function() mutation) async {
    if (state.isLoading) throw StateError('An appointment change is already in progress');
    state = const AsyncLoading<void>();
    try {
      final updated = await mutation();
      ref.invalidate(doctorDashboardProvider);
      ref.invalidate(doctorAppointmentsProvider);
      ref.invalidate(doctorTodayAppointmentsProvider);
      ref.invalidate(doctorUpcomingAppointmentsProvider);
      ref.invalidate(doctorAppointmentProvider(id));
      ref.invalidate(doctorPatientsProvider);
      ref.invalidate(doctorPatientProvider(updated.patientId));
      ref.invalidate(doctorPatientAppointmentsProvider(updated.patientId));
      ref.invalidate(doctorPatientHistoryProvider(updated.patientId));
      state = const AsyncData<void>(null);
    } catch (error, stack) {
      state = AsyncError<void>(error, stack);
      Error.throwWithStackTrace(error, stack);
    }
  }

  Future<void> confirm(String id) => _run(id, () => ref.read(confirmDoctorAppointmentUseCaseProvider)(id));
  Future<void> start(String id) => _run(id, () => ref.read(startDoctorAppointmentUseCaseProvider)(id));
  Future<void> complete(String id) => _run(id, () => ref.read(completeDoctorAppointmentUseCaseProvider)(id));
  Future<void> markMissed(String id) => _run(id, () => ref.read(markDoctorAppointmentMissedUseCaseProvider)(id));
  Future<void> cancel(String id, {String? reason}) => _run(
      id, () => ref.read(cancelDoctorAppointmentUseCaseProvider)(id, cancellationReason: reason));
}

final doctorAppointmentActionsProvider =
    NotifierProvider<DoctorAppointmentActions, AsyncValue<void>>(
        DoctorAppointmentActions.new);

class DoctorAvailabilityActions extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> _run(Future<void> Function() mutation) async {
    if (state.isLoading) throw StateError('An availability change is already in progress');
    state = const AsyncLoading<void>();
    try {
      await mutation();
      ref.invalidate(doctorAvailabilityProvider);
      ref.invalidate(doctorDashboardProvider);
      state = const AsyncData<void>(null);
    } catch (error, stack) {
      state = AsyncError<void>(error, stack);
      Error.throwWithStackTrace(error, stack);
    }
  }

  Future<void> create({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) => _run(() async {
        await ref.read(createDoctorAvailabilityUseCaseProvider)(
          dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime);
      });

  Future<void> update({
    required String availabilityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) => _run(() async {
        await ref.read(updateDoctorAvailabilityUseCaseProvider)(
          availabilityId: availabilityId,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
          isActive: isActive,
        );
      });

  Future<void> delete(String id) => _run(() =>
      ref.read(deleteDoctorAvailabilityUseCaseProvider)(id));
}

final doctorAvailabilityActionsProvider =
    NotifierProvider<DoctorAvailabilityActions, AsyncValue<void>>(
        DoctorAvailabilityActions.new);
