import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';

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

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Providers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text('More filter options coming soon.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavyBlue,
                  foregroundColor: Colors.white,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kNavyBlue,
        elevation: 1,
        title: const Text('Network Provider'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // _buildStatusBarSpacer(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildToggleRow(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildProviderList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Network Provider',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
          suffixIcon: GestureDetector(
            onTap: _openFilter,
            child: Icon(Icons.filter_alt, color: Colors.black87, size: 22),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
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
            borderSide: const BorderSide(color: kNavyBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        Switch(
          value: _showOutsideNetwork,
          onChanged: (v) => setState(() => _showOutsideNetwork = v),
          activeThumbColor: kNavyBlue,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        const SizedBox(width: 8),
        const Text(
          'Show providers outside my network',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildProviderList() {
    if (_filteredProviders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: _filteredProviders.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            backgroundColor: kNavyBlue.withValues(alpha: 0.1),
            child: const Icon(Icons.local_hospital_outlined, color: kNavyBlue),
          ),
          title: Text(
            provider['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            provider['address'] ?? '',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No Available Providers',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
