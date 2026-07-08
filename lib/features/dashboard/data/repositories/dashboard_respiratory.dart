import '../../data/models/dashboard_response.dart';

abstract class DashboardRepository {
  Future<DashboardResponse> getDashboard();
}