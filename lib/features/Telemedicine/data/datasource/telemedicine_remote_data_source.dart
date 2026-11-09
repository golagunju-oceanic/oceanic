
import 'package:oceanic/core/network/api_client.dart';

import '../models/agora_token_response.dart';
import '../models/telemedicine_model.dart';

abstract class TelemedicineRemoteDataSource {
  Future<CallSessionModel> ringDoctor(String appointmentId);
  Future<CallSessionModel> getCallStatus(String callId);
  Future<CallSessionModel?> getIncomingDoctorCall();
  Future<CallSessionModel> acceptCall(String callId);
  Future<CallSessionModel> declineCall(String callId);
  Future<AgoraTokenResponse> joinCall(String callId);
  Future<void> endCall(String callId);
}

class TelemedicineRemoteDataSourceImpl implements TelemedicineRemoteDataSource {
  final ApiClient _client;

  TelemedicineRemoteDataSourceImpl(this._client);

  @override
  Future<CallSessionModel> ringDoctor(String appointmentId) async {
    final response = await _client.post(
      '/telemedicine/calls/appointments/$appointmentId/ring',
    );
    return CallSessionModel.fromJson(response.data['data']);
  }

  @override
  Future<CallSessionModel> getCallStatus(String callId) async {
    final response = await _client.get('/telemedicine/calls/$callId');
    return CallSessionModel.fromJson(response.data['data']);
  }

  @override
  Future<CallSessionModel?> getIncomingDoctorCall() async {
    final response = await _client.get('/telemedicine/calls/incoming');
    if (response.data['data'] == null) return null;
    return CallSessionModel.fromJson(response.data['data']);
  }

  @override
  Future<CallSessionModel> acceptCall(String callId) async {
    final response = await _client.post('/telemedicine/calls/$callId/accept');
    return CallSessionModel.fromJson(response.data['data']);
  }

  @override
  Future<CallSessionModel> declineCall(String callId) async {
    final response = await _client.post('/telemedicine/calls/$callId/decline');
    return CallSessionModel.fromJson(response.data['data']);
  }

  @override
  Future<AgoraTokenResponse> joinCall(String callId) async {
    final response = await _client.post('/telemedicine/calls/$callId/join');
    return AgoraTokenResponse.fromJson(response.data['data']);
  }

  @override
  Future<void> endCall(String callId) async {
    await _client.post('/telemedicine/calls/$callId/end');
  }
}