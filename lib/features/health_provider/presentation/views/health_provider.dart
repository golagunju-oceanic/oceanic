import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/health_provider/presentation/provider/provider_provider.dart';
import 'package:oceanic/features/health_provider/presentation/state/provider_state.dart';

class HealthProvider extends ConsumerStatefulWidget {
  const HealthProvider({super.key});

  @override
  ConsumerState<HealthProvider> createState() => _HealthProviderState();
}

class _HealthProviderState extends ConsumerState<HealthProvider> {
  final _searchController = TextEditingController();
  bool _showOutsideNetwork = false;
  // String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(providerNotifierProvider.notifier).search(value);
  }

  void _openFilter() {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Providers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'More filter options coming soon.',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(providerNotifierProvider);
    final viewModel = ref.read(providerNotifierProvider.notifier);
    // print("UI Providers: ${state.filteredProviders.length}");
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Health Care Provider'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Health Care Provider',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(scheme),
            const SizedBox(height: 20),
            _buildToggleRow(scheme),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: _buildProviderList(scheme, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => _onSearchChanged(value),
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.4),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurface.withValues(alpha: 0.5),
          size: 22,
        ),
        suffixIcon: GestureDetector(
          onTap: _openFilter,
          child: Icon(
            Icons.filter_alt,
            color: scheme.onSurface.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildToggleRow(ColorScheme scheme) {
    return Row(
      children: [
        Switch(
          value: _showOutsideNetwork,
          onChanged: (v) => setState(() => _showOutsideNetwork = v),
          activeThumbColor: scheme.primary,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        const SizedBox(width: 8),
        Text(
          'Show providers outside my network',
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderList(ColorScheme scheme, ProviderState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredProviders.isEmpty) {
      return Center(
        child: Text(
          "No providers found",
          style: TextStyle(
            fontSize: 15,
            color: scheme.onSurface.withValues(alpha: .6),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.filteredProviders.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: scheme.onSurface.withValues(alpha: .08)),
      itemBuilder: (context, index) {
        final provider = state.filteredProviders[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),

          leading: CircleAvatar(
            backgroundColor: scheme.primary.withValues(alpha: .1),
            child: Icon(Icons.local_hospital_outlined, color: scheme.primary),
          ),

          title: Text(
            provider.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.address != null) Text(provider.address!),

              if (provider.city != null)
                Text(
                  provider.city!,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: .6),
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          trailing: const Icon(Icons.chevron_right),

          onTap: () {},
        );
      },
    );
  }
}
