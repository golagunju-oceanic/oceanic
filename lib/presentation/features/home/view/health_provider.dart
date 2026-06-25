import 'package:flutter/material.dart';

class HealthProvider extends StatefulWidget {
  const HealthProvider({super.key});

  @override
  State<HealthProvider> createState() => _HealthProviderState();
}

class _HealthProviderState extends State<HealthProvider> {
  final _searchController = TextEditingController();
  bool _showOutsideNetwork = false;
  String _searchQuery = '';

  final List<Map<String, String>> _allProviders = [];

  List<Map<String, String>> get _filteredProviders {
    if (_searchQuery.isEmpty) return _allProviders;
    return _allProviders
        .where(
          (p) => p['name']!.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) => setState(() => _searchQuery = value);

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

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Network Provider'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Network Provider',
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
            Expanded(child: _buildProviderList(scheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
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
          activeColor: scheme.primary,
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

  Widget _buildProviderList(ColorScheme scheme) {
    if (_filteredProviders.isEmpty) {
      return Center(
        child: Text(
          'No Available Providers',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredProviders.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.08)),
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            backgroundColor: scheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.local_hospital_outlined, color: scheme.primary),
          ),
          title: Text(
            provider['name'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: scheme.onSurface,
            ),
          ),
          subtitle: Text(
            provider['address'] ?? '',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: scheme.onSurface.withValues(alpha: 0.4),
          ),
          onTap: () {},
        );
      },
    );
  }
}
