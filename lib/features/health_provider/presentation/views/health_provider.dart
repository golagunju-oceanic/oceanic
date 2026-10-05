import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/health_provider/presentation/provider/provider_provider.dart';
import 'package:oceanic/features/health_provider/presentation/state/provider_state.dart';
import 'package:oceanic/features/policy/presentation/provider/policy_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class HealthProvider extends ConsumerStatefulWidget {
  const HealthProvider({super.key});

  @override
  ConsumerState<HealthProvider> createState() => _HealthProviderState();
}

class _HealthProviderState extends ConsumerState<HealthProvider> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showOutsideNetwork = false;
  bool _filterMyPlanOnly = true; // Default to filtering by active user plan
  String? _selectedPlanVariant;
  String? _selectedTier;

  final List<String> _planVariants = [
    'My Active Plan',
    'Aqua Plan',
    'Teal Plan',
    'Cerulean Plan',
    'Admiral Plan',
    'All Plans',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(providerNotifierProvider.notifier).search(value);
  }

  // Check if provider is covered under member's plan variant
  bool _isCoveredUnderPlan(String? providerAddress, String? activePlan) {
    if (activePlan == null) return true;
    // Providers in network match active plan tiers
    return true;
  }

  void _openFilter(String activePlan) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Providers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // PLAN VARIANT SECTION
                Text(
                  'Filter by Plan Variant',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _planVariants.map((variant) {
                    final isSelected =
                        (_selectedPlanVariant ?? 'My Active Plan') == variant;
                    return ChoiceChip(
                      label: Text(
                        variant == 'My Active Plan'
                            ? 'My Plan ($activePlan)'
                            : variant,
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedPlanVariant = selected
                              ? variant
                              : 'My Active Plan';
                        });
                        setState(() {});
                      },
                      selectedColor: scheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? scheme.onPrimary
                            : scheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // NETWORK TIER SECTION
                Text(
                  'Provider Network Tier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      ['All Tiers', 'Tier 1', 'Tier 2', 'Tier 3', 'Tier 4'].map(
                        (tier) {
                          final isSelected =
                              (_selectedTier ?? 'All Tiers') == tier;
                          return ChoiceChip(
                            label: Text(tier),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedTier = selected ? tier : 'All Tiers';
                              });
                              setState(() {});
                            },
                            selectedColor: scheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurface.withValues(alpha: 0.8),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ).toList(),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedTier = 'All Tiers';
                            _selectedPlanVariant = 'My Active Plan';
                            _filterMyPlanOnly = true;
                          });
                          setState(() {
                            _selectedTier = 'All Tiers';
                            _selectedPlanVariant = 'My Active Plan';
                            _filterMyPlanOnly = true;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(providerNotifierProvider);
    final viewModel = ref.read(providerNotifierProvider.notifier);

    // Watch Active User Policy & Plan
    final policyState = ref.watch(policyProvider);
    final activeUserPlan =
        policyState.card?.planVariant.toUpperCase() ?? 'AQUA SINGLE';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 84), // Top margin for FloatingAppBar

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildSearchBar(scheme, activeUserPlan),
                      const SizedBox(height: 10),
                      _buildPlanFilterBanner(scheme, activeUserPlan),
                      const SizedBox(height: 8),
                      // _buildToggleCard(scheme),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: RefreshIndicator.adaptive(
                    onRefresh: viewModel.refresh,
                    child: _buildProviderList(scheme, state, activeUserPlan),
                  ),
                ),
              ],
            ),

            // Floating AppBar with Drawer Trigger
            FloatingAppBar(
              scrollController: _scrollController,
              text: "Health Providers",
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar(ColorScheme scheme, String activePlan) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search hospital, clinic, or location...',
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: scheme.onSurface.withValues(alpha: 0.5),
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: () => _openFilter(activePlan),
          icon: Icon(Icons.tune_rounded, color: scheme.primary, size: 22),
        ),
        filled: true,
        fillColor: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  // --- ACTIVE PLAN FILTER BANNER ---
  Widget _buildPlanFilterBanner(ColorScheme scheme, String activePlan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: scheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Coverage Plan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                Text(
                  activePlan,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // FilterChip(
          //   label: Text(_filterMyPlanOnly ? 'My Plan Only' : 'All Providers'),
          //   selected: _filterMyPlanOnly,
          //   onSelected: (selected) {
          //     setState(() => _filterMyPlanOnly = selected);
          //   },
          //   selectedColor: scheme.primary,
          //   labelStyle: TextStyle(
          //     fontSize: 11,
          //     fontWeight: FontWeight.bold,
          //     color: _filterMyPlanOnly
          //         ? scheme.onPrimary
          //         : scheme.onSurface.withValues(alpha: 0.8),
          //   ),
          // ),
        ],
      ),
    );
  }

  // --- NETWORK TOGGLE CARD ---
  Widget _buildToggleCard(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Show outside network',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: _showOutsideNetwork,
            onChanged: (v) => setState(() => _showOutsideNetwork = v),
            activeColor: scheme.primary,
          ),
        ],
      ),
    );
  }

  // --- PROVIDER LIST WITH PLAN VARIANT BADGES ---
  Widget _buildProviderList(
    ColorScheme scheme,
    ProviderState state,
    String activePlan,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.filteredProviders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_hospital_outlined,
                  size: 48,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "No providers found for $activePlan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Try enabling 'Show outside network' or searching a different area.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: state.filteredProviders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final provider = state.filteredProviders[index];
        final isCovered = _isCoveredUnderPlan(provider.address, activePlan);

        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  provider.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Plan Coverage Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isCovered
                                      ? const Color(
                                          0xFF28A745,
                                        ).withValues(alpha: 0.12)
                                      : Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCovered ? activePlan : 'Requires Upgrade',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCovered
                                        ? const Color(0xFF28A745)
                                        : Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (provider.address != null &&
                              provider.address!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    provider.address!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (provider.city != null &&
                              provider.city!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              provider.city!,
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
