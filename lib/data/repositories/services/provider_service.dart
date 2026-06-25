import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oceanic/core/utils/constants.dart';
import 'package:oceanic/data/models/provider_model.dart';

class ProviderRepository {
  Future<List<Providers>> getProviders({String? search}) async {
    final uri = Uri.parse(
      '${Constants.uri}/providers',
    ).replace(queryParameters: search != null ? {'search': search} : null);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['data'] as List).map((e) => Providers.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch providers');
  }
}
