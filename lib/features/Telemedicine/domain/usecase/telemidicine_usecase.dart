import '../entities/telemedicine_entities.dart';
import '../repository/telemedicine_repository.dart';

class TelemedicineUseCase {
  final TelemedicineRepository _repository;

  TelemedicineUseCase(this._repository);

  Future<CallSessionEntity> ring(String appointmentId) =>
      _repository.ringDoctor(appointmentId);

  Future<CallSessionEntity> getStatus(String callId) =>
      _repository.getCallStatus(callId);

  Future<CallSessionEntity?> checkIncoming() =>
      _repository.checkIncomingCall();

  Future<CallSessionEntity> answer(String callId, {required bool accept}) =>
      _repository.answerCall(callId, accept: accept);

  Future<AgoraConnectionCredentials> join(String callId) =>
      _repository.joinCallSession(callId);

  Future<void> end(String callId) =>
      _repository.endCallSession(callId);
}