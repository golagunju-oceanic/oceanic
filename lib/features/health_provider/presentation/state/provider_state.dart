import '../../data/model/provider_model.dart';

class ProviderState {
  final bool isLoading;
  final String? error;

  final List<ProviderModel> providers;
  final List<ProviderModel> filteredProviders;

  final String searchQuery;

  const ProviderState({
    this.isLoading = false,
    this.error,
    this.providers = const [],
    this.filteredProviders = const [],
    this.searchQuery = '',
  });

  ProviderState copyWith({
    bool? isLoading,
    String? error,
    List<ProviderModel>? providers,
    List<ProviderModel>? filteredProviders,
    String? searchQuery,
  }) {
    return ProviderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      providers: providers ?? this.providers,
      filteredProviders:
          filteredProviders ?? this.filteredProviders,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}