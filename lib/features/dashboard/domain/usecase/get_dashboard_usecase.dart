import 'package:oceanic/features/dashboard/data/repositories/dashboard_respiratory.dart';

import '../../data/models/dashboard_response.dart';


class GetDashboardUseCase {
  GetDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardResponse> call() {
    return _repository.getDashboard();
  }
}