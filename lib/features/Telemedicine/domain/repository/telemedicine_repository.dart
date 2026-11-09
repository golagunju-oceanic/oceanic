import 'package:oceanic/features/Telemedicine/domain/entities/telemedicine_entities.dart';

abstract class TelemedicineRepository {
  Future<CallSessionEntity> ringDoctor(String appointmentId);
  Future<CallSessionEntity> getCallStatus(String callId);
  Future<CallSessionEntity?> checkIncomingCall();
  Future<CallSessionEntity> answerCall(String callId, {required bool accept});
  Future<AgoraConnectionCredentials> joinCallSession(String callId);
  Future<void> endCallSession(String callId);
}
