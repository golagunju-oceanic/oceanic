import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:oceanic/core/provider/core_provider.dart';
import 'package:oceanic/features/Telemedicine/data/datasource/remote_datasource.dart';
import 'package:oceanic/features/Telemedicine/data/repository/repository_impl.dart';
import 'package:oceanic/features/Telemedicine/domain/repository/telemedicine_repository.dart';
import 'package:oceanic/features/Telemedicine/domain/usecase/telemidicine_usecase.dart';
import 'package:oceanic/features/Telemedicine/presentation/state/telemedicine_state.dart';
import '../viewmodel/telemedicine_viewmodel.dart';


final telemedicineRemoteDatasourceProvider =
    Provider<TelemedicineRemoteDataSource>((ref) {
  return TelemedicineRemoteDataSource(
    ref.read(apiClientProvider),
  );
});

final telemedicineRepositoryProvider =
    Provider<TelemedicineRepository>((ref) {
  return TelemedicineRepositoryImpl(
    ref.read(
      telemedicineRemoteDatasourceProvider,
    ),
  );
});

final generateTokenUseCaseProvider =
    Provider((ref) {
  return GenerateTokenUseCase(
    ref.read(
      telemedicineRepositoryProvider,
    ),
  );
});

final telemedicineProvider = StateNotifierProvider<
    TelemedicineViewModel,
    TelemedicineState>((ref) {
  return TelemedicineViewModel(
    ref.read(generateTokenUseCaseProvider),
  );
});