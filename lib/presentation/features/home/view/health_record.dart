import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:oceanic/presentation/widgets/drawer.dart';

class HealthRecord extends StatefulWidget {
  const HealthRecord({super.key});

  @override
  State<HealthRecord> createState() => _HealthRecordState();
}

class _HealthRecordState extends State<HealthRecord> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _searchController = TextEditingController();

  DateTimeRange? _selectedDateRange;

  String _selectedCategory = 'All';

  String _searchQuery = '';

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> _categories = [
    'All',
    'Consultation',
    'Lab Test',
    'Imaging',
    'Prescription',
    'Surgery',
  ];

  // ============================================================
  // RECORDS
  // CURRENTLY STATIC SAMPLE DATA
  // ============================================================

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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTERING
  // ============================================================

  List<Map<String, dynamic>> get _filteredRecords {
    return _healthRecords.where((record) {
      // --------------------------------------------------------
      // CATEGORY
      // --------------------------------------------------------

      if (_selectedCategory != 'All' && record['type'] != _selectedCategory) {
        return false;
      }

      // --------------------------------------------------------
      // SEARCH
      // --------------------------------------------------------

      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();

        final title = (record['title'] as String? ?? '').toLowerCase();

        final hospital = (record['hospital'] as String? ?? '').toLowerCase();

        final doctor = (record['doctor'] as String? ?? '').toLowerCase();

        if (!title.contains(query) &&
            !hospital.contains(query) &&
            !doctor.contains(query)) {
          return false;
        }
      }

      // --------------------------------------------------------
      // DATE
      // --------------------------------------------------------

      if (_selectedDateRange != null) {
        final recordDate = DateTime.tryParse(record['date'].toString());

        if (recordDate == null) {
          return false;
        }

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

  bool get _hasActiveFilters {
    return _selectedDateRange != null ||
        _selectedCategory != 'All' ||
        _searchQuery.trim().isNotEmpty;
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDateRange() async {
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

    if (picked != null && mounted) {
      setState(() {
        _selectedDateRange = picked;
      });
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatRecordDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return DateFormat('dd MMM yyyy').format(date);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final records = _filteredRecords;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND DECORATION
            // ==================================================
            Positioned(
              top: -90.h,
              right: -80.w,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.04),
                ),
              ),
            ),

            Positioned(
              top: 380.h,
              left: -100.w,
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(
                    alpha: isDark ? 0.07 : 0.03,
                  ),
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================
            Column(
              children: [
                _buildTopBar(scheme: scheme, isDark: isDark),

                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                8.h,
                                20.w,
                                100.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ===========================
                                  // HERO
                                  // ===========================
                                  _buildOverviewCard(
                                    scheme: scheme,
                                    isDark: isDark,
                                  ),

                                  SizedBox(height: 28.h),

                                  // ===========================
                                  // SEARCH / FILTER TITLE
                                  // ===========================
                                  _buildSectionHeader(
                                    title: 'Medical history',
                                    subtitle:
                                        'Search and filter your health records',
                                    scheme: scheme,
                                  ),

                                  SizedBox(height: 14.h),

                                  // ===========================
                                  // SEARCH
                                  // ===========================
                                  _buildSearchBar(
                                    scheme: scheme,
                                    isDark: isDark,
                                  ),

                                  SizedBox(height: 12.h),

                                  // ===========================
                                  // DATE
                                  // ===========================
                                  _buildDateFilter(
                                    scheme: scheme,
                                    isDark: isDark,
                                  ),

                                  SizedBox(height: 15.h),

                                  // ===========================
                                  // CATEGORY CHIPS
                                  // ===========================
                                  _buildCategoryChips(
                                    scheme: scheme,
                                    isDark: isDark,
                                  ),

                                  SizedBox(height: 22.h),

                                  // ===========================
                                  // RESULTS
                                  // ===========================
                                  Row(
                                    children: [
                                      Text(
                                        _hasActiveFilters
                                            ? 'Filtered records'
                                            : 'Recent records',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: scheme.onSurface,
                                        ),
                                      ),

                                      SizedBox(width: 7.w),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withValues(
                                            alpha: 0.09,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                        ),
                                        child: Text(
                                          records.length.toString(),
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.primary,
                                          ),
                                        ),
                                      ),

                                      const Spacer(),

                                      if (_hasActiveFilters)
                                        TextButton(
                                          onPressed: _resetFilters,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Reset filters',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  SizedBox(height: 12.h),

                                  // ===========================
                                  // LIST
                                  // ===========================
                                  if (records.isEmpty)
                                    _buildEmptyState(scheme: scheme)
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: records.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 12.h);
                                      },
                                      itemBuilder: (context, index) {
                                        return _buildRecordCard(
                                          record: records[index],
                                          scheme: scheme,
                                          isDark: isDark,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar({required ColorScheme scheme, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          _buildTopButton(
            icon: Icons.arrow_back_rounded,
            scheme: scheme,
            isDark: isDark,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Records',
                  style: TextStyle(
                    fontSize: 20.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  'Your medical history',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),

          _buildTopButton(
            icon: Icons.menu_rounded,
            scheme: scheme,
            isDark: isDark,
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          width: 43.r,
          height: 43.r,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Icon(icon, size: 21.r, color: scheme.onSurface),
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewCard({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final completed = _healthRecords
        .where((record) => record['status'] == 'COMPLETED')
        .length;

    final active = _healthRecords
        .where((record) => record['status'] == 'ACTIVE')
        .length;

    final gradientEnd = Color.lerp(scheme.primary, scheme.secondary, 0.28)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.22),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45.r,
            top: -55.r,
            child: Container(
              width: 175.r,
              height: 175.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 18.w,
            bottom: -35.h,
            child: Icon(
              Icons.folder_shared_rounded,
              size: 125.r,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.medical_information_outlined,
                        size: 24.r,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        '${_healthRecords.length} records',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 21.h),

                Text(
                  'Your health history,\norganized.',
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.15,
                    letterSpacing: -0.45,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 9.h),

                Text(
                  'Review consultations, tests, prescriptions, imaging and other medical records.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildOverviewStat(
                        value: completed.toString(),
                        label: 'Completed',
                        icon: Icons.check_rounded,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: _buildOverviewStat(
                        value: active.toString(),
                        label: 'Active',
                        icon: Icons.schedule_rounded,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: _buildOverviewStat(
                        value: _categories.length.subtractOne().toString(),
                        label: 'Categories',
                        icon: Icons.category_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.r, color: Colors.white.withValues(alpha: 0.76)),

          SizedBox(height: 8.h),

          Text(
            value,
            style: TextStyle(
              fontSize: 19.sp,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.2.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required ColorScheme scheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.25,
            color: scheme.onSurface,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.8.sp,
            height: 1.35,
            color: scheme.onSurface.withValues(alpha: 0.52),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar({required ColorScheme scheme, required bool isDark}) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.025),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        cursorColor: scheme.primary,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search records, hospital or doctor',
          hintStyle: TextStyle(
            fontSize: 11.8.sp,
            color: scheme.onSurface.withValues(alpha: 0.38),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.r,
            color: scheme.onSurface.withValues(alpha: 0.43),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  icon: Icon(Icons.close_rounded, size: 18.r),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FILTER
  // ============================================================

  Widget _buildDateFilter({required ColorScheme scheme, required bool isDark}) {
    final selected = _selectedDateRange != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickDateRange,
        borderRadius: BorderRadius.circular(17.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.07)
                : scheme.surface,
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.25)
                  : scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 39.r,
                height: 39.r,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 19.r,
                  color: scheme.primary,
                ),
              ),

              SizedBox(width: 11.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date range',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface.withValues(alpha: 0.46),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      selected
                          ? '${_formatDate(_selectedDateRange!.start)} - '
                                '${_formatDate(_selectedDateRange!.end)}'
                          : 'Filter records by date',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.8.sp,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                  },
                  icon: Icon(Icons.close_rounded, size: 18.r),
                )
              else
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  size: 20.r,
                  color: scheme.onSurface.withValues(alpha: 0.35),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY CHIPS
  // ============================================================

  Widget _buildCategoryChips({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) {
          return SizedBox(width: 8.w);
        },
        itemBuilder: (context, index) {
          final category = _categories[index];

          final selected = _selectedCategory == category;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
            showCheckmark: false,
            selectedColor: scheme.primary,
            backgroundColor: scheme.surface,
            side: BorderSide(
              color: selected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            labelStyle: TextStyle(
              fontSize: 10.8.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: 0.65),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // RECORD CARD
  // ============================================================

  Widget _buildRecordCard({
    required Map<String, dynamic> record,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final type = record['type'].toString();

    final status = record['status'].toString();

    final typeColor = _getTypeColor(type, scheme);

    final statusColor = _getStatusColor(status, scheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: () {
          _showRecordDetailsModal(record);
        },
        child: Ink(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.07 : 0.03),
                blurRadius: 15.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47.r,
                height: 47.r,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(_getTypeIcon(type), size: 22.r, color: typeColor),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record['title'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        _buildStatusChip(status: status, color: statusColor),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: 14.r,
                          color: scheme.onSurface.withValues(alpha: 0.40),
                        ),

                        SizedBox(width: 5.w),

                        Expanded(
                          child: Text(
                            record['hospital'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.8.sp,
                              color: scheme.onSurface.withValues(alpha: 0.54),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14.r,
                          color: scheme.primary,
                        ),

                        SizedBox(width: 5.w),

                        Expanded(
                          child: Text(
                            record['doctor']?.toString() ?? 'Not available',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.8.sp,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        Text(
                          _formatRecordDate(record['date'].toString()),
                          style: TextStyle(
                            fontSize: 9.8.sp,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withValues(alpha: 0.44),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 5.w),

              Icon(
                Icons.chevron_right_rounded,
                size: 19.r,
                color: scheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({required String status, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8.3.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS BOTTOM SHEET
  // ============================================================

  void _showRecordDetailsModal(Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final type = record['type'].toString();

    final typeColor = _getTypeColor(type, scheme);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --------------------------------------------
                  // HANDLE
                  // --------------------------------------------
                  Center(
                    child: Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // --------------------------------------------
                  // HEADER
                  // --------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(
                          _getTypeIcon(type),
                          color: typeColor,
                          size: 23.r,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record['title'].toString(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close_rounded, size: 21.r),
                      ),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  // --------------------------------------------
                  // DETAILS
                  // --------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? scheme.onSurface.withValues(alpha: 0.035)
                          : scheme.primary.withValues(alpha: 0.025),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: scheme.onSurface.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          label: 'Record ID',
                          value: record['id'].toString(),
                          scheme: scheme,
                        ),

                        _detailDivider(scheme),

                        _buildDetailRow(
                          label: 'Facility',
                          value: record['hospital'].toString(),
                          scheme: scheme,
                        ),

                        _detailDivider(scheme),

                        _buildDetailRow(
                          label: 'Doctor',
                          value:
                              record['doctor']?.toString() ?? 'Not available',
                          scheme: scheme,
                        ),

                        _detailDivider(scheme),

                        _buildDetailRow(
                          label: 'Date',
                          value: _formatRecordDate(record['date'].toString()),
                          scheme: scheme,
                        ),

                        _detailDivider(scheme),

                        _buildDetailRow(
                          label: 'Status',
                          value: record['status'].toString(),
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),

                  if (record['notes'] != null &&
                      record['notes'].toString().trim().isNotEmpty) ...[
                    SizedBox(height: 22.h),

                    Text(
                      'Clinical notes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.055),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        record['notes'].toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.55,
                          color: scheme.onSurface.withValues(alpha: 0.70),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: scheme.onSurface.withValues(alpha: 0.48),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailDivider(ColorScheme scheme) {
    return Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.055));
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState({required ColorScheme scheme}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 38.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        children: [
          Container(
            width: 62.r,
            height: 62.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_off_outlined,
              size: 28.r,
              color: scheme.primary,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'No records found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            'Try changing your search, category or date filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.52),
            ),
          ),

          SizedBox(height: 16.h),

          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset filters',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLORS
  // ============================================================

  Color _getStatusColor(String status, ColorScheme scheme) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF16A34A);

      case 'ACTIVE':
        return scheme.primary;

      default:
        return scheme.onSurface.withValues(alpha: 0.50);
    }
  }

  Color _getTypeColor(String type, ColorScheme scheme) {
    switch (type) {
      case 'Consultation':
        return scheme.primary;

      case 'Lab Test':
        return const Color(0xFFD97706);

      case 'Imaging':
        return const Color(0xFF9333EA);

      case 'Prescription':
        return const Color(0xFF16A34A);

      case 'Surgery':
        return const Color(0xFFE11D48);

      default:
        return scheme.secondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Consultation':
        return Icons.person_outline_rounded;

      case 'Lab Test':
        return Icons.science_outlined;

      case 'Imaging':
        return Icons.image_outlined;

      case 'Prescription':
        return Icons.medication_outlined;

      case 'Surgery':
        return Icons.local_hospital_outlined;

      default:
        return Icons.medical_services_outlined;
    }
  }
}

// ===============================================================
// SMALL HELPER
// ===============================================================

extension IntMinusOne on int {
  int subtractOne() {
    return this > 0 ? this - 1 : 0;
  }
}
