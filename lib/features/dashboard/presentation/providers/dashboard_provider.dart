import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/features/dashboard/data/datasource/dashboard_remotea_datasorce.dart';
import 'package:oceanic/features/dashboard/data/models/dashboard_response.dart';

import 'package:oceanic/features/dashboard/domain/repositories/dashboard_repository_impl.dart';

import 'package:oceanic/features/dashboard/domain/usecase/get_dashboard_usecase.dart';
import 'package:oceanic/features/dashboard/presentation/viewmodel/dashboard_viewmodel.dart';

import '../../../../core/provider/core_provider.dart';

final dashboardRemoteDatasourceProvider = Provider(
  (ref) => DashboardRemoteDatasource(ref.read(apiClientProvider)),
);

final dashboardRepositoryProvider = Provider(
  (ref) => DashboardRepositoryImpl(ref.read(dashboardRemoteDatasourceProvider)),
);

final getDashboardUseCaseProvider = Provider(
  (ref) => GetDashboardUseCase(ref.read(dashboardRepositoryProvider)),
);

final dashboardProvider =
    AsyncNotifierProvider<
        DashboardViewModel,
        DashboardResponse>(
  DashboardViewModel.new,
);