import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/health_provider/domain/usecase/provider_usecase.dart';
import 'package:oceanic/features/health_provider/presentation/provider/provider_provider.dart';
import 'package:oceanic/features/health_provider/presentation/state/provider_state.dart';

// import '../../../../core/network/network_exception.dart';

class ProviderViewModel extends Notifier<ProviderState> {
  late final GetProvidersUseCase _getProvidersUseCase;

  @override
  ProviderState build() {
    _getProvidersUseCase = ref.read(getProvidersUseCaseProvider);

    Future.microtask(() async {
      print("Calling loadProviders...");
      await loadProviders();
    });

    return const ProviderState();
  }

  Future<void> loadProviders() async {
    try {
      print("1. Starting loadProviders");

      state = state.copyWith(isLoading: true, error: null);

      print("2. Calling use case");

      final providers = await _getProvidersUseCase();

      print("3. Returned from use case");
      print("Providers: ${providers.length}");

      state = state.copyWith(
        isLoading: false,
        providers: providers,
        filteredProviders: providers,
      );

      print("4. State updated");
    } catch (e, stack) {
      print("ERROR: $e");
      print(stack);

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Future<void> loadProviders() async {
  //   try {
  //     state = state.copyWith(isLoading: true, error: null);

  //     final providers = await _getProvidersUseCase();

  //     print("Loaded providers: ${providers.length}");

  //     state = state.copyWith(
  //       isLoading: false,
  //       providers: providers,
  //       filteredProviders: providers,
  //     );
  //     print("State providers: ${state.providers.length}");
  //     print("State filtered: ${state.filteredProviders.length}");
  //   } catch (e) {
  //     String message = "Something went wrong";

  //     if (e is NetworkException) {
  //       message = e.message;
  //     }

  //     state = state.copyWith(isLoading: false, error: message);
  //   }
  // }

  Future<void> refresh() async {
    await loadProviders();
  }

  void search(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: '',
        filteredProviders: state.providers,
      );

      return;
    }

    final filtered = state.providers.where((provider) {
      return provider.name.toLowerCase().contains(query) ||
          (provider.address ?? '').toLowerCase().contains(query) ||
          (provider.city ?? '').toLowerCase().contains(query) ||
          (provider.category ?? '').toLowerCase().contains(query);
    }).toList();

    state = state.copyWith(searchQuery: query, filteredProviders: filtered);
  }
}
