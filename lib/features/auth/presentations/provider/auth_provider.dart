import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oceanic/core/provider/core_provider.dart';
import 'package:oceanic/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:oceanic/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:oceanic/features/auth/presentations/viewModel/auth_view_model.dart';


import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/me_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

import '../state/auth_state.dart';


final secureStorageProvider =
    Provider((ref) => const FlutterSecureStorage());

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(
    ref.read(apiClientProvider),
  ),
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
  ),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(
    ref.read(authRepositoryProvider),
  ),
);

final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(
    ref.read(authRepositoryProvider),
  ),
);

final meUseCaseProvider = Provider(
  (ref) => MeUsecase(
    ref.read(authRepositoryProvider),
  ),
);

final forgotPasswordUseCaseProvider = Provider(
  (ref) => ForgotPasswordUsecase(
    ref.read(authRepositoryProvider),
  ),
);

final resetPasswordUseCaseProvider = Provider(
  (ref) => ResetPasswordUseCase(
    ref.read(authRepositoryProvider),
  ),
);

final authProvider =
    NotifierProvider<AuthViewModel, AuthState>(
AuthViewModel.new,
);