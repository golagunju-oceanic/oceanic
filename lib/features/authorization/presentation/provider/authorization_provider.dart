import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/provider/core_provider.dart';

import '../../data/datasource/authorization_remote_datasource.dart';
import '../../data/models/authorization_detail_model.dart';
import '../../data/models/authorization_response_model.dart';
import '../../data/repository/authorization_repository_impl.dart';
import '../../domain/repository/authorization_repository.dart';
import '../../domain/usecase/get_authorization_details.dart';
import '../../domain/usecase/get_authorization.dart';

final authorizationRemoteDataSourceProvider =
    Provider<AuthorizationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AuthorizationRemoteDataSource(apiClient);
});

final authorizationRepositoryProvider =
    Provider<AuthorizationRepository>((ref) {
  final remoteDataSource = ref.watch(
    authorizationRemoteDataSourceProvider,
  );

  return AuthorizationRepositoryImpl(
    remoteDataSource,
  );
});

final getAuthorizationsProvider =
    Provider<GetAuthorizations>((ref) {
  return GetAuthorizations(
    ref.watch(authorizationRepositoryProvider),
  );
});

final getAuthorizationDetailUseCaseProvider =
    Provider<GetAuthorizationDetail>((ref) {
  return GetAuthorizationDetail(
    ref.watch(authorizationRepositoryProvider),
  );
});

final authorizationListProvider =
    FutureProvider<AuthorizationResponseModel>((ref) {
  final getAuthorizations = ref.watch(
    getAuthorizationsProvider,
  );

  return getAuthorizations();
});

final authorizationDetailProvider =
    FutureProvider.family<
        AuthorizationDetailModel,
        int>((ref, authorizationId) {
  final getDetail = ref.watch(
    getAuthorizationDetailUseCaseProvider,
  );

  return getDetail(authorizationId);
});