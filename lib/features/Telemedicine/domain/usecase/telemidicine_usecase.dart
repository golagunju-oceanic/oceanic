import '../../data/models/agora_token_response.dart';
import '../repository/telemedicine_repository.dart';

class TelemedicineUseCase {
  final TelemedicineRepository repository;

  TelemedicineUseCase(this.repository);

  Future<AgoraTokenResponse> generateToken({
    required String channel,
    String role = 'publisher',
  }) {
    return repository.generateToken(channel: channel, role: role);
  }

  Future<AgoraTokenResponse> initiateCall({
    required String doctorId,
    String callType = 'video',
  }) {
    return repository.initiateCall(doctorId: doctorId, callType: callType);
  }
}