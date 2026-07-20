import '../../data/models/agora_token_response.dart';
import '../repository/telemedicine_repository.dart';

class GenerateTokenUseCase {
  final TelemedicineRepository repository;

  GenerateTokenUseCase(this.repository);

  Future<AgoraTokenResponse> call({
    required String channel,
    String role = 'publisher',
    
  }) {
    return repository.generateToken(
      channel: channel,
      role: role,
      
    );
  }
}