
import 'package:oceanic/features/health_provider/data/model/provider_model.dart';
import 'package:oceanic/features/health_provider/data/repository/provider_repository.dart';

import '../../data/datasource/provider_remote_datasource.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  const ProviderRepositoryImpl(this._remoteDatasource);

  final ProviderRemoteDatasource _remoteDatasource;

  @override
  Future<List<ProviderModel>> getProviders({String? search}) {
    return _remoteDatasource.getProviders(search: search);
  }
}
