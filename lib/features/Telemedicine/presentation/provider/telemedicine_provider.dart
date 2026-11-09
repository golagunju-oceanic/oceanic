import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Adjust these imports to match your project paths:
import 'package:oceanic/core/network/api_client.dart'; // your ApiClient file
import 'package:oceanic/features/Telemedicine/data/datasource/telemedicine_remote_data_source.dart';
import 'package:oceanic/features/Telemedicine/data/repository/repository_impl.dart';

import 'package:oceanic/features/Telemedicine/domain/usecase/telemedicine_booking_usecase.dart';

import 'package:oceanic/features/Telemedicine/presentation/viewmodel/telemedicine_viewmodel.dart';

// 1. ApiClient Provider (or use your existing dio/api provider if you already have one)
final telemedicineApiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://oceanic-mobile-backend-1.onrender.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  return ApiClient(dio);
});

// 2. Remote DataSource Provider
final telemedicineRemoteDataSourceProvider =
    Provider<TelemedicineRemoteDataSource>((ref) {
      final client = ref.watch(telemedicineApiClientProvider);
      return TelemedicineRemoteDataSourceImpl(client);
    });

// 3. Repository Provider
final telemedicineRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(telemedicineRemoteDataSourceProvider);
  return TelemedicineRepositoryImpl(remoteDataSource);
});

// 4. UseCase Provider
final telemedicineUseCaseProvider = Provider<TelemedicineUseCase>((ref) {
  final repository = ref.watch(telemedicineRepositoryProvider);
  return TelemedicineUseCase(repository);
});

// 5. The ViewModel Provider used by CallNotificationService & screens
final telemedicineViewModelProvider =
    ChangeNotifierProvider<TelemedicineViewModel>((ref) {
      final useCase = ref.watch(telemedicineUseCaseProvider);
      return TelemedicineViewModel(useCase);
    });
