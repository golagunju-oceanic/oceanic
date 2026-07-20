import 'package:oceanic/features/health_provider/data/model/provider_model.dart';

import '../../../../core/network/api_client.dart';

class ProviderRemoteDatasource {
  const ProviderRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderModel>> getProviders({String? search}) async {
    final response = await _apiClient.get("/providers");
    return (response.data["data"] as List)
        .map((e) => ProviderModel.fromJson(e))
        .toList();
  }
}
