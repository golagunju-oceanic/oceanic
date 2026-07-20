import 'package:oceanic/features/health_provider/data/model/provider_model.dart';

abstract class ProviderRepository {
  Future<List<ProviderModel>> getProviders({
    String? search,
  });
}