import 'package:oceanic/features/Telemedicine/data/datasource/remote_datasource.dart';
import 'package:oceanic/features/Telemedicine/data/models/agora_token_response.dart';
import 'package:oceanic/features/Telemedicine/data/models/generate_token_request.dart';
import 'package:oceanic/features/Telemedicine/domain/repository/telemedicine_repository.dart';

class TelemedicineRepositoryImpl implements TelemedicineRepository {
  final TelemedicineRemoteDataSource remoteDataSource;

  TelemedicineRepositoryImpl(this.remoteDataSource);

  @override
  Future<AgoraTokenResponse> generateToken({
    required String channel,
    String role = 'publisher',
   
  }) {
    return remoteDataSource.generateToken(
      GenerateTokenRequest(
        channel: channel,
        role: role,
       
      ),
    );
  }
}