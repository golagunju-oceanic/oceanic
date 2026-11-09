import '../../domain/entities/telemedicine_entities.dart';
import '../../domain/repository/telemedicine_repository.dart';
import '../datasource/telemedicine_remote_data_source.dart';

class TelemedicineRepositoryImpl implements TelemedicineRepository {
  final TelemedicineRemoteDataSource _remoteDataSource;

  TelemedicineRepositoryImpl(this._remoteDataSource);

  @override
  Future<CallSessionEntity> ringDoctor(String appointmentId) async {
    final model = await _remoteDataSource.ringDoctor(appointmentId);
    return CallSessionEntity(
      callId: model.id,
      appointmentId: model.appointmentId,
      status: model.status,
      callType: model.type ?? 'VIDEO',
    );
  }

  @override
  Future<CallSessionEntity> getCallStatus(String callId) async {
    final model = await _remoteDataSource.getCallStatus(callId);
    return CallSessionEntity(
      callId: model.id,
      appointmentId: model.appointmentId,
      status: model.status,
      callType: model.type ?? 'VIDEO',
    );
  }

  @override
  Future<CallSessionEntity?> checkIncomingCall() async {
    final model = await _remoteDataSource.getIncomingDoctorCall();
    if (model == null) return null;
    return CallSessionEntity(
      callId: model.id,
      appointmentId: model.appointmentId,
      status: model.status,
      callType: model.type ?? 'VIDEO',
    );
  }

  @override
  Future<CallSessionEntity> answerCall(
    String callId, {
    required bool accept,
  }) async {
    final model = accept
        ? await _remoteDataSource.acceptCall(callId)
        : await _remoteDataSource.declineCall(callId);
    return CallSessionEntity(
      callId: model.id,
      appointmentId: model.appointmentId,
      status: model.status,
      callType: model.type ?? 'VIDEO',
    );
  }

  @override
  Future<AgoraConnectionCredentials> joinCallSession(String callId) async {
    final tokenData = await _remoteDataSource.joinCall(callId);
    return AgoraConnectionCredentials(
      appId: tokenData.appId,
      token: tokenData.token,
      channel: tokenData.channel,
      uid: tokenData.uid,
      isVideo: tokenData.appointmentType.toUpperCase() == 'VIDEO',
    );
  }

  @override
  Future<void> endCallSession(String callId) =>
      _remoteDataSource.endCall(callId);
}
