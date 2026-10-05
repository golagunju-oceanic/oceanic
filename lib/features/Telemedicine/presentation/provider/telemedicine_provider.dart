import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:oceanic/core/provider/core_provider.dart';
import 'package:oceanic/features/Telemedicine/data/datasource/remote_datasource.dart';
import 'package:oceanic/features/Telemedicine/data/repository/repository_impl.dart';
import 'package:oceanic/features/Telemedicine/domain/repository/telemedicine_repository.dart';
import 'package:oceanic/features/Telemedicine/domain/usecase/telemidicine_usecase.dart';
import 'package:oceanic/features/Telemedicine/presentation/state/telemedicine_state.dart';
import '../viewmodel/telemedicine_viewmodel.dart';

// 1. Data Source
final telemedicineRemoteDatasourceProvider =
    Provider<TelemedicineRemoteDataSource>((ref) {
  return TelemedicineRemoteDataSource(
    ref.read(apiClientProvider),
  );
});

// 2. Repository
final telemedicineRepositoryProvider =
    Provider<TelemedicineRepository>((ref) {
  return TelemedicineRepositoryImpl(
    ref.read(telemedicineRemoteDatasourceProvider),
  );
});

// 3. Single UseCase Provider
final telemedicineUseCaseProvider =
    Provider<TelemedicineUseCase>((ref) {
  return TelemedicineUseCase(
    ref.read(telemedicineRepositoryProvider),
  );
});

// 4. View Model Provider
final telemedicineProvider =
    StateNotifierProvider<TelemedicineViewModel, TelemedicineState>((ref) {
  return TelemedicineViewModel(
    telemedicineUseCase: ref.read(telemedicineUseCaseProvider),
  );
});