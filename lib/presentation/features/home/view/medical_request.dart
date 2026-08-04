import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/data/models/states.dart';
import 'package:oceanic/features/auth/presentations/provider/auth_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class MedicalRequest extends ConsumerStatefulWidget {
  const MedicalRequest({super.key});

  @override
  ConsumerState<MedicalRequest> createState() => _MedicalRequestState();
}

class _MedicalRequestState extends ConsumerState<MedicalRequest> {
  int _selectedTabIndex = 0; // 0: Refill, 1: New Prescription

  String? _selectedState;
  String? _selectedCity;
  String? _selectedBeneficiary;

  final States _states = States();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> get _nigerianStates =>
      _states.states.map((s) => s['name'] as String).toList();

  List<String> _citiesFor(String? stateName) {
    if (stateName == null) return [];
    final stateData = _states.states.firstWhere(
      (s) => s['name'] == stateName,
      orElse: () => {'cities': <String>[]},
    );
    return List<String>.from(stateData['cities'] as List);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey, // Scaffold Key connected
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 84), // Spacing for FloatingAppBar
                // Segmented Tab Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSegmentedControl(scheme),
                ),

                const SizedBox(height: 12),

                // Form Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedTabIndex == 0
                        ? _buildRequestRefillForm(scheme)
                        : _buildNewPrescriptionForm(scheme),
                  ),
                ),
              ],
            ),

            // Fixed Drawer & FloatingAppBar
            FloatingAppBar(
              scrollController: _scrollController,
              text: "Medical Request",
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB SELECTOR ---
  Widget _buildSegmentedControl(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: "Request Refill",
              isSelected: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
              scheme: scheme,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: "New Prescription",
              isSelected: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? scheme.onPrimary
                : scheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  // --- NEW PRESCRIPTION FORM ---
  Widget _buildNewPrescriptionForm(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormLabel('Prescription Document / Photo', scheme),
          const SizedBox(height: 8),

          // File Upload Selector Button
          InkWell(
            onTap: _showUploadModal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: scheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Upload Prescription File or Photo',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildFormLabel('State', scheme),
          const SizedBox(height: 8),
          _buildSelectorTile(
            text: _selectedState ?? 'Select State',
            icon: Icons.map_outlined,
            isSet: _selectedState != null,
            scheme: scheme,
            onTap: () => _showSearchSheet(
              title: 'Search State',
              items: _nigerianStates,
              onSelected: (val) {
                setState(() {
                  _selectedState = val;
                  _selectedCity = null;
                });
              },
            ),
          ),

          const SizedBox(height: 20),
          _buildFormLabel('City / Location', scheme),
          const SizedBox(height: 8),
          _buildSelectorTile(
            text: _selectedCity ?? 'Select City',
            icon: Icons.location_on_outlined,
            isSet: _selectedCity != null,
            scheme: scheme,
            onTap: _selectedState == null
                ? null
                : () => _showSearchSheet(
                    title: 'Search City',
                    items: _citiesFor(_selectedState),
                    onSelected: (val) => setState(() => _selectedCity = val),
                  ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFormLabel('Condition / Illness', scheme),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_outline, color: scheme.primary),
              ),
            ],
          ),
          Text(
            'Kindly specify the illness or medical condition you require medication for.',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 20),
          _buildFormLabel('Additional Comments', scheme),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            style: TextStyle(color: scheme.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Enter any extra instructions or notes for the pharmacist...',
              hintStyle: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              filled: true,
              fillColor: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
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
          ),

          const SizedBox(height: 28),
          _buildSubmitButton('Submit Prescription Request', scheme),

          const SizedBox(height: 20),
          _buildContactFooter(scheme),
        ],
      ),
    );
  }

  // --- REQUEST REFILL FORM ---
  Widget _buildRequestRefillForm(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormLabel('Select Beneficiary', scheme),
          const SizedBox(height: 8),
          _buildDropdownContainer(
            scheme: scheme,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedBeneficiary,
                dropdownColor: scheme.surface,
                hint: Text(
                  'Choose beneficiary',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
                items:
                    [
                          'Self (John Doe)',
                          'Jane Doe (Spouse)',
                          'Junior Doe (Child)',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedBeneficiary = v),
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildFormLabel('Select State', scheme),
          const SizedBox(height: 8),
          _buildSelectorTile(
            text: _selectedState ?? 'Select State',
            icon: Icons.map_outlined,
            isSet: _selectedState != null,
            scheme: scheme,
            onTap: () => _showSearchSheet(
              title: 'Search State',
              items: _nigerianStates,
              onSelected: (val) {
                setState(() {
                  _selectedState = val;
                  _selectedCity = null;
                });
              },
            ),
          ),

          const SizedBox(height: 20),
          _buildFormLabel('Select City', scheme),
          const SizedBox(height: 8),
          _buildSelectorTile(
            text: _selectedCity ?? 'Select City',
            icon: Icons.location_on_outlined,
            isSet: _selectedCity != null,
            scheme: scheme,
            onTap: _selectedState == null
                ? null
                : () => _showSearchSheet(
                    title: 'Search City',
                    items: _citiesFor(_selectedState),
                    onSelected: (val) => setState(() => _selectedCity = val),
                  ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFormLabel('Prescribed Medications', scheme),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: scheme.onPrimary, size: 18),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No prescribed medications selected.\nTap the + button to add medications.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.45),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          _buildSubmitButton('Submit Refill Request', scheme),

          const SizedBox(height: 20),
          _buildContactFooter(scheme),
        ],
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---

  Widget _buildFormLabel(String title, ColorScheme scheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    );
  }

  Widget _buildDropdownContainer({
    required Widget child,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _buildSelectorTile({
    required String text,
    required IconData icon,
    required bool isSet,
    required ColorScheme scheme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSet
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                  color: isSet
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String label, ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContactFooter(ColorScheme scheme) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "Need help with your request? Contact ",
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          children: [
            TextSpan(
              text: '02013300300',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' or email '),
            TextSpan(
              text: 'pbm@oceanichealthng.com',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODALS ---

  void _showUploadModal() {
    final scheme = Theme.of(context).colorScheme;
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
            Text(
              'Upload Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _uploadTile(Icons.camera_alt_outlined, 'Take a photo', scheme),
            _uploadTile(
              Icons.photo_library_outlined,
              'Select from gallery',
              scheme,
            ),
            _uploadTile(
              Icons.folder_open_outlined,
              'Select from files',
              scheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadTile(IconData icon, String text, ColorScheme scheme) {
    return ListTile(
      onTap: () => Navigator.pop(context),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: scheme.primary, size: 20),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
    );
  }

  void _showSearchSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        List<String> filtered = List.from(items);
        return StatefulBuilder(
          builder: (context, setModalState) {
            final scheme = Theme.of(context).colorScheme;
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        filtered = items
                            .where(
                              (e) =>
                                  e.toLowerCase().contains(val.toLowerCase()),
                            )
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor:
                          scheme.surfaceContainerLow ?? scheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filtered[index]),
                        onTap: () {
                          onSelected(filtered[index]);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
