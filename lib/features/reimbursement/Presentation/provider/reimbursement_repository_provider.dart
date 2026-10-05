import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/reimbursement_datasource.dart';
import '../../data/repository/reimbursement_impl.dart';
import '../../domain/repository/reimbursement_repository.dart';
import 'package:oceanic/core/provider/core_provider.dart';

final reimbursementRemoteDataSourceProvider =
    Provider<ReimbursementRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return ReimbursementRemoteDataSource(apiClient);
});

final reimbursementRepositoryProvider =
    Provider<ReimbursementRepository>((ref) {
  final remoteDataSource =
      ref.read(reimbursementRemoteDataSourceProvider);

  return ReimbursementRepositoryImpl(remoteDataSource);
});