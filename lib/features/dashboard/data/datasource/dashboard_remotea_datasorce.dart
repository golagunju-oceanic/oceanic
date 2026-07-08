import '../../../../core/network/api_client.dart';
import '../models/dashboard_response.dart';

class DashboardRemoteDatasource {
  DashboardRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardResponse> getDashboard() async {
    final response = await _apiClient.get(
      "/dashboard",
    );

    return DashboardResponse.fromJson(
      response.data,
    );
  }
}