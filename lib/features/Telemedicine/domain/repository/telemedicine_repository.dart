import '../../data/models/agora_token_response.dart';

abstract class TelemedicineRepository {
  Future<AgoraTokenResponse> generateToken({
    required String channel,
    String role,
  });
}