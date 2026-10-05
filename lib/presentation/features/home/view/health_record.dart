import 'package:flutter/material.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class HealthRecord extends StatefulWidget {
  const HealthRecord({super.key});

  @override
  State<HealthRecord> createState() => _HealthRecordState();
}

class _HealthRecordState extends State<HealthRecord> {
  DateTimeRange? _selectedDateRange; 
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _categories = [
    'All',
    'Consultation',
    'Lab Test',
    'Imaging',
    'Prescription',
    'Surgery',
  ];

  final List<Map<String, dynamic>> _healthRecords = [
    {
      'id': 'REC-001',
      'type': 'Consultation',
      'title': 'General Checkup',
      'hospital': "St. Mary's Hospital",
      'doctor': 'Dr. John Doe',
      'date': '2026-04-12',
      'status': 'COMPLETED',
      'notes': 'Routine annual medical checkup. Vital signs normal.',
    },
    {
      'id': 'REC-002',
      'type': 'Lab Test',
      'title': 'Full Blood Count (FBC)',
      'hospital': 'HealthLab Diagnostics',
      'doctor': 'Dr. Alan Vance',
      'date': '2026-04-10',
      'status': 'COMPLETED',
      'notes': 'Hemoglobin, WBC, and Platelet levels within optimal range.',
    },
    {
      'id': 'REC-003',
      'type': 'Imaging',
      'title': 'Brain MRI Scan',
      'hospital': 'City Imaging Clinic',
      'doctor': 'Dr. Sarah Kim',
      'date': '2026-04-05',
      'status': 'COMPLETED',
      'notes': 'No significant abnormalities detected in brain parenchyma.',
    },
    {
      'id': 'REC-004',
      'type': 'Prescription',
      'title': 'Medication Refill',
      'hospital': 'Wellness Pharmacy',
      'doctor': 'Dr. Adams',
      'date': '2026-03-28',
      'status': 'ACTIVE',
      'notes': '30-day refill for antihypertensive treatment.',
    },
    {
      'id': 'REC-005',
      'type': 'Surgery',
      'title': 'Laparoscopic Appendectomy',
      'hospital': 'City General Hospital',
      'doctor': 'Dr. Michael Lee',
      'date': '2026-03-15',
      'status': 'COMPLETED',
      'notes': 'Uncomplicated procedure. Post-operative recovery smooth.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- FILTERING LOGIC ---
  List<Map<String, dynamic>> get _filteredRecords {
    return _healthRecords.where((record) {
      // 1. Category Filter
      if (_selectedCategory != 'All' && record['type'] != _selectedCategory) {
        return false;
      }

      // 2. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (record['title'] as String).toLowerCase();
        final hospital = (record['hospital'] as String).toLowerCase();
        final doctor = (record['doctor'] as String? ?? '').toLowerCase();

        if (!title.contains(query) &&
            !hospital.contains(query) &&
            !doctor.contains(query)) {
          return false;
        }
      }

      // 3. Date Range Filter
      if (_selectedDateRange != null) {
        final recordDate = DateTime.tryParse(record['date']);
        if (recordDate == null) return false;

        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
        );

        if (recordDate.isBefore(start) || recordDate.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _pickDateRange() async {
    final scheme = Theme.of(context).colorScheme;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: scheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedCategory = 'All';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final recordsList = _filteredRecords;

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
                // Search & Date Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildSearchBar(scheme),
                      const SizedBox(height: 10),
                      _buildDateFilterTile(scheme),
                      const SizedBox(height: 10),
                      _buildCategoryChips(scheme),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Results Counter & Reset Button
                if (_selectedDateRange != null ||
                    _selectedCategory != 'All' ||
                    _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${recordsList.length} record(s)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: _resetFilters,
                          child: Text(
                            'Reset All Filters',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 4),

                // Records List View
                Expanded(
                  child: recordsList.isEmpty
                      ? _buildEmptyState(scheme)
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: recordsList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildRecordCard(recordsList[index], scheme);
                          },
                        ),
                ),
              ],
            ),

            // Floating Header
            FloatingAppBar(
              scrollController: _scrollController,
              text: 'Health Records',
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar(ColorScheme scheme) {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search doctor, hospital, or record title...',
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: scheme.onSurface.withValues(alpha: 0.5),
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  // --- DATE RANGE PICKER TILE ---
  Widget _buildDateFilterTile(ColorScheme scheme) {
    final isFiltered = _selectedDateRange != null;

    return InkWell(
      onTap: _pickDateRange,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isFiltered
              ? scheme.primary.withValues(alpha: 0.08)
              : (scheme.surfaceContainerLow ?? scheme.surfaceContainer),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFiltered
                ? scheme.primary.withValues(alpha: 0.4)
                : scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: isFiltered
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isFiltered
                    ? '${_formatDate(_selectedDateRange!.start)}  ➔  ${_formatDate(_selectedDateRange!.end)}'
                    : 'Filter by date range',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isFiltered ? FontWeight.bold : FontWeight.normal,
                  color: isFiltered
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (isFiltered)
              GestureDetector(
                onTap: () => setState(() => _selectedDateRange = null),
                child: Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: scheme.primary,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  // --- CATEGORY FILTER CHIPS ---
  Widget _buildCategoryChips(ColorScheme scheme) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: scheme.primary,
              backgroundColor:
                  scheme.surfaceContainerLow ?? scheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(
                color: isSelected
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: 0.3),
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? scheme.onPrimary
                    : scheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  // --- RECORD LIST CARD ---
  Widget _buildRecordCard(Map<String, dynamic> record, ColorScheme scheme) {
    final statusColor = _getStatusColor(record['status'], scheme);
    final typeColor = _getIconColor(record['type']);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showRecordDetailsModal(record, scheme),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _getIcon(record['type']),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              record['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              record['status'],
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record['hospital'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            record['date'],
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (record['doctor'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              record['doctor'],
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
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
  }

  // --- RECORD DETAILS MODAL SHEET ---
  void _showRecordDetailsModal(
    Map<String, dynamic> record,
    ColorScheme scheme,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record['title'],
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
            const Divider(),
            const SizedBox(height: 12),
            _modalDetailRow('Record ID', record['id'], scheme),
            _modalDetailRow('Category', record['type'], scheme),
            _modalDetailRow('Facility', record['hospital'], scheme),
            _modalDetailRow('Doctor', record['doctor'] ?? 'N/A', scheme),
            _modalDetailRow('Date', record['date'], scheme),
            _modalDetailRow('Status', record['status'], scheme),
            if (record['notes'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Clinical Notes:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record['notes'],
                  style: TextStyle(fontSize: 13, color: scheme.onSurface),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _modalDetailRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 48,
            color: scheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No matching health records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or date range filters.',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  // --- COLOR & ICON HELPERS ---
  Color _getStatusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF28A745);
      case 'ACTIVE':
        return scheme.primary;
      default:
        return scheme.onSurface.withValues(alpha: 0.5);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'Consultation':
        return const Color(0xFF0284C7);
      case 'Lab Test':
        return const Color(0xFFD97706);
      case 'Imaging':
        return const Color(0xFF9333EA);
      case 'Prescription':
        return const Color(0xFF16A34A);
      case 'Surgery':
        return const Color(0xFFE11D48);
      default:
        return Colors.grey;
    }
  }

  Icon _getIcon(String type) {
    final color = _getIconColor(type);
    switch (type) {
      case 'Consultation':
        return Icon(Icons.person_outline_rounded, color: color, size: 22);
      case 'Lab Test':
        return Icon(Icons.science_outlined, color: color, size: 22);
      case 'Imaging':
        return Icon(Icons.image_outlined, color: color, size: 22);
      case 'Prescription':
        return Icon(Icons.medication_outlined, color: color, size: 22);
      case 'Surgery':
        return Icon(Icons.local_hospital_outlined, color: color, size: 22);
      default:
        return Icon(Icons.medical_services_outlined, color: color, size: 22);
    }
  }
}
