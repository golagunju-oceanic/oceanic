// lib/features/Telemedicine/data/repository/telemedicine_repository_impl.dart

import '../datasource/remote_datasource.dart';
import '../models/agora_token_response.dart';
import '../models/generate_token_request.dart';
import '../models/initiate_call_request.dart';
import '../../domain/repository/telemedicine_repository.dart';

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

  @override
  Future<AgoraTokenResponse> initiateCall({
    required String doctorId,
    String callType = 'video',
  }) {
    return remoteDataSource.initiateCall(
      InitiateCallRequest(
        doctorId: doctorId,
        callType: callType,
      ),
    );
  }
}