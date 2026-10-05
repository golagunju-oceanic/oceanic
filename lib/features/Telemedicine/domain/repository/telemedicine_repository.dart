// lib/features/Telemedicine/domain/repository/telemedicine_repository.dart

import '../../data/models/agora_token_response.dart';

abstract class TelemedicineRepository {
  Future<AgoraTokenResponse> generateToken({
    required String channel,
    String role,
  });

  Future<AgoraTokenResponse> initiateCall({
    required String doctorId,
    String callType,
  });
}