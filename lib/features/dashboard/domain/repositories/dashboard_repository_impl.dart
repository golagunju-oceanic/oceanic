import 'package:oceanic/features/dashboard/data/datasource/dashboard_remotea_datasorce.dart';
import 'package:oceanic/features/dashboard/data/models/dashboard_response.dart';
import 'package:oceanic/features/dashboard/data/repositories/dashboard_respiratory.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remoteDatasource);

  final DashboardRemoteDatasource _remoteDatasource;

  @override
  Future<DashboardResponse> getDashboard() async {
    return await _remoteDatasource.getDashboard();
  }
}
