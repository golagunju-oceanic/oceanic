import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/health_provider/domain/repository/provider_repository_impl.dart';
import 'package:oceanic/features/health_provider/domain/usecase/provider_usecase.dart';
import 'package:oceanic/features/health_provider/presentation/state/provider_state.dart';

import '../../../../core/provider/core_provider.dart';

import '../../data/datasource/provider_remote_datasource.dart';


import '../viewmodel/provider_view_model.dart';

final providerRemoteDatasourceProvider =
    Provider(
  (ref) => ProviderRemoteDatasource(
    ref.read(apiClientProvider),
  ),
);

final providerRepositoryProvider =
    Provider(
  (ref) => ProviderRepositoryImpl(
    ref.read(providerRemoteDatasourceProvider),
  ),
);

final getProvidersUseCaseProvider =
    Provider(
  (ref) => GetProvidersUseCase(
    ref.read(providerRepositoryProvider),
  ),
);

final providerNotifierProvider =
    NotifierProvider<
        ProviderViewModel,
        ProviderState>(
  ProviderViewModel.new,
);