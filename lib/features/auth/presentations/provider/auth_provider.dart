import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oceanic/core/provider/core_provider.dart';
import 'package:oceanic/core/services/notification_device_service.dart';
import 'package:oceanic/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:oceanic/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:oceanic/features/auth/presentations/viewModel/auth_view_model.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/me_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

import '../state/auth_state.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.read(apiClientProvider)),
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);

final meUseCaseProvider = Provider(
  (ref) => MeUsecase(ref.read(authRepositoryProvider)),
);

final forgotPasswordUseCaseProvider = Provider(
  (ref) => ForgotPasswordUsecase(ref.read(authRepositoryProvider)),
);

final resetPasswordUseCaseProvider = Provider(
  (ref) => ResetPasswordUseCase(ref.read(authRepositoryProvider)),
);

final notificationDeviceServiceProvider = Provider<NotificationDeviceService>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);

  final service = NotificationDeviceService(
    registerDevice: (token, platform) async {
      await apiClient.post(
        '/notifications/devices',
        body: {'fcmToken': token, 'platform': platform},
      );
    },

    unregisterDevice: (token) async {
      await apiClient.deleteWithBody(
        '/notifications/devices',
        body: {'fcmToken': token},
      );
    },
  );

  ref.onDispose(service.dispose);

  return service;
});

final authProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
