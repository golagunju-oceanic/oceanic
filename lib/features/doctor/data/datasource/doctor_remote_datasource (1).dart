import 'package:dio/dio.dart';
import 'package:oceanic/features/doctor/data/model/doctor_appointment_model.dart';
import 'package:oceanic/features/doctor/data/model/doctor_availability_model.dart';
import 'package:oceanic/features/doctor/data/model/doctor_dashboard_model.dart';
import 'package:oceanic/features/doctor/data/model/doctor_json.dart';
import 'package:oceanic/features/doctor/data/model/doctor_patient_model.dart';
import 'package:oceanic/features/doctor/data/model/doctor_patient_records_model.dart';
import 'package:oceanic/features/doctor/data/model/doctor_profile_model.dart';

/// All methods use the same configured Dio (baseUrl, JWT, interceptors) as login.
/// If baseUrl is https://host/api, the default paths produce /api/doctor/...
abstract class DoctorRemoteDataSource {
  Future<DoctorProfileModel> getMyProfile();
  Future<String> updateTelemedicineStatus(String status);
  Future<DoctorDashboardModel> getDashboard();

  Future<List<DoctorAvailabilityModel>> getAvailability();
  Future<DoctorAvailabilityModel> createAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  });
  Future<DoctorAvailabilityModel> updateAvailability({
    required String availabilityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  });
  Future<void> deleteAvailability(String availabilityId);

  Future<List<DoctorAppointmentModel>> getAppointments();
  Future<List<DoctorAppointmentModel>> getTodayAppointments();
  Future<List<DoctorAppointmentModel>> getUpcomingAppointments();
  Future<DoctorAppointmentModel> getAppointmentById(String appointmentId);
  Future<DoctorAppointmentModel> confirmAppointment(String appointmentId);
  Future<DoctorAppointmentModel> startAppointment(String appointmentId);
  Future<DoctorAppointmentModel> completeAppointment(String appointmentId);
  Future<DoctorAppointmentModel> cancelAppointment(
    String appointmentId, {
    String? cancellationReason,
  });
  Future<DoctorAppointmentModel> markAppointmentMissed(String appointmentId);

  Future<List<DoctorPatientModel>> getPatients();
  Future<DoctorPatientModel> getPatientById(String patientId);
  Future<DoctorPatientAppointmentsModel> getPatientAppointments(
    String patientId,
  );
  Future<DoctorPatientHistoryModel> getPatientHistory(String patientId);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final Dio _dio;
  final String _routePrefix;

  /// Supply your existing authenticated Dio; never create an unauthenticated
  /// Dio() here or add a second `/api` to an existing `/api` baseUrl.
  DoctorRemoteDataSourceImpl(this._dio, {String routePrefix = '/doctor'})
    : _routePrefix = routePrefix.endsWith('/')
          ? routePrefix.substring(0, routePrefix.length - 1)
          : routePrefix;

  String _url(String suffix) => '$_routePrefix$suffix';
  String _id(String id) => Uri.encodeComponent(id);
  Map<String, dynamic> _object(dynamic body, String context) =>
      doctorJsonMap(unwrapDoctorData(body), context: context);
  List<Map<String, dynamic>> _list(dynamic body, String context) =>
      doctorJsonList(unwrapDoctorData(body), context: context);

  @override
  Future<DoctorProfileModel> getMyProfile() async {
    final response = await _dio.get<dynamic>(_url('/me'));
    return DoctorProfileModel.fromJson(
      _object(response.data, 'doctor profile'),
    );
  }

  @override
  Future<String> updateTelemedicineStatus(String status) async {
    if (status != 'ONLINE' && status != 'OFFLINE') {
      throw ArgumentError.value(status, 'status', 'Must be ONLINE or OFFLINE');
    }
    final response = await _dio.patch<dynamic>(
      _url('/me/telemedicine-status'),
      data: {'status': status},
    );
    final data = _object(response.data, 'updated telemedicine status');
    final updatedStatus = requireDoctorString(
      data,
      'telemedicineStatus',
    ).toUpperCase();
    if (updatedStatus != 'ONLINE' && updatedStatus != 'OFFLINE') {
      throw const FormatException('Invalid telemedicine status in response');
    }
    return updatedStatus;
  }

  @override
  Future<DoctorDashboardModel> getDashboard() async {
    final response = await _dio.get<dynamic>(_url('/dashboard'));
    return DoctorDashboardModel.fromJson(
      _object(response.data, 'doctor dashboard'),
    );
  }

  @override
  Future<List<DoctorAvailabilityModel>> getAvailability() async {
    final response = await _dio.get<dynamic>(_url('/availability'));
    return _list(
      response.data,
      'availability',
    ).map(DoctorAvailabilityModel.fromJson).toList();
  }

  @override
  Future<DoctorAvailabilityModel> createAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _dio.post<dynamic>(
      _url('/availability'),
      data: {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      },
    );
    return DoctorAvailabilityModel.fromJson(
      _object(response.data, 'new availability'),
    );
  }

  @override
  Future<DoctorAvailabilityModel> updateAvailability({
    required String availabilityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) async {
    final changes = <String, dynamic>{
      if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (isActive != null) 'isActive': isActive,
    };
    if (changes.isEmpty) {
      throw ArgumentError('At least one availability field must be provided');
    }
    final response = await _dio.patch<dynamic>(
      _url('/availability/${_id(availabilityId)}'),
      data: changes,
    );
    return DoctorAvailabilityModel.fromJson(
      _object(response.data, 'updated availability'),
    );
  }

  @override
  Future<void> deleteAvailability(String availabilityId) async {
    // Backend returns {"message": "Availability deleted successfully"}, no data.
    await _dio.delete<dynamic>(_url('/availability/${_id(availabilityId)}'));
  }

  Future<List<DoctorAppointmentModel>> _getAppointmentList(String path) async {
    final response = await _dio.get<dynamic>(_url(path));
    return _list(
      response.data,
      'appointments',
    ).map(DoctorAppointmentModel.fromJson).toList();
  }

  @override
  Future<List<DoctorAppointmentModel>> getAppointments() =>
      _getAppointmentList('/appointments');

  @override
  Future<List<DoctorAppointmentModel>> getTodayAppointments() =>
      _getAppointmentList('/appointments/today');

  @override
  Future<List<DoctorAppointmentModel>> getUpcomingAppointments() =>
      _getAppointmentList('/appointments/upcoming');

  @override
  Future<DoctorAppointmentModel> getAppointmentById(
    String appointmentId,
  ) async {
    final response = await _dio.get<dynamic>(
      _url('/appointments/${_id(appointmentId)}'),
    );
    return DoctorAppointmentModel.fromJson(
      _object(response.data, 'appointment detail'),
    );
  }

  Future<DoctorAppointmentModel> _changeAppointment(
    String appointmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.patch<dynamic>(
      _url('/appointments/${_id(appointmentId)}/$action'),
      data: body,
    );
    return DoctorAppointmentModel.fromJson(
      _object(response.data, 'appointment action'),
    );
  }

  @override
  Future<DoctorAppointmentModel> confirmAppointment(String appointmentId) =>
      _changeAppointment(appointmentId, 'confirm');

  @override
  Future<DoctorAppointmentModel> startAppointment(String appointmentId) =>
      _changeAppointment(appointmentId, 'start');

  @override
  Future<DoctorAppointmentModel> completeAppointment(String appointmentId) =>
      _changeAppointment(appointmentId, 'complete');

  @override
  Future<DoctorAppointmentModel> cancelAppointment(
    String appointmentId, {
    String? cancellationReason,
  }) => _changeAppointment(
    appointmentId,
    'cancel',
    body: {
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    },
  );

  @override
  Future<DoctorAppointmentModel> markAppointmentMissed(String appointmentId) =>
      _changeAppointment(appointmentId, 'missed');

  @override
  Future<List<DoctorPatientModel>> getPatients() async {
    final response = await _dio.get<dynamic>(_url('/patients'));
    return _list(
      response.data,
      'patients',
    ).map(DoctorPatientModel.fromJson).toList();
  }

  @override
  Future<DoctorPatientModel> getPatientById(String patientId) async {
    final response = await _dio.get<dynamic>(
      _url('/patients/${_id(patientId)}'),
    );
    return DoctorPatientModel.fromJson(
      _object(response.data, 'patient detail'),
    );
  }

  @override
  Future<DoctorPatientAppointmentsModel> getPatientAppointments(
    String patientId,
  ) async {
    final response = await _dio.get<dynamic>(
      _url('/patients/${_id(patientId)}/appointments'),
    );
    return DoctorPatientAppointmentsModel.fromJson(
      _object(response.data, 'patient appointment response'),
    );
  }

  @override
  Future<DoctorPatientHistoryModel> getPatientHistory(String patientId) async {
    final response = await _dio.get<dynamic>(
      _url('/patients/${_id(patientId)}/history'),
    );
    return DoctorPatientHistoryModel.fromJson(
      _object(response.data, 'patient history response'),
    );
  }
}
