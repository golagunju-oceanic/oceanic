import 'package:oceanic/features/health_provider/data/model/provider_model.dart';

import 'package:oceanic/features/health_provider/data/repository/provider_repository.dart';

class GetProvidersUseCase {
  const GetProvidersUseCase(this._repository);

  final ProviderRepository _repository;

  Future<List<ProviderModel>> call({String? search}) {
    return _repository.getProviders(search: search);
  }
}
