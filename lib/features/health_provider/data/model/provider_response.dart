import 'provider_model.dart';

class ProviderResponse {
  final List<ProviderModel> providers;

  const ProviderResponse({
    required this.providers,
  });

  factory ProviderResponse.fromJson(Map<String, dynamic> json) {
    return ProviderResponse(
      providers: (json["data"] as List)
          .map((e) => ProviderModel.fromJson(e))
          .toList(),
    );
  }
}