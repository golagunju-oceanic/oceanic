import 'package:flutter/material.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/feedbsck_modal.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class ReimbursementScreen extends StatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  State<ReimbursementScreen> createState() => _ReimbursementScreenState();
}

class _ReimbursementScreenState extends State<ReimbursementScreen> {
  final _paFormKey = GlobalKey<FormState>();
  final _providerFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  final _providerNameController = TextEditingController();
  final _claimAmountController = TextEditingController();
  final _reimbursementCodeController = TextEditingController();
  final _paCodeController = TextEditingController();
  final _callCenterAgentController = TextEditingController();
  final _commentController = TextEditingController();

  int _currentStep =
      0; // 0: Notice/Intro, 1: PA Code, 2: Provider Details, 3: Documents, 4: Review

  String? _selectedClaimType;
  String? _selectedState;
  String? _selectedCity;
  DateTime? _incurredDate;

  final List<String> _uploadedFiles = [];
  final int _maxFiles = 5;

  final List<String> _claimTypes = [
    'Outpatient',
    'Inpatient',
    'Dental',
    'Optical',
    'Maternity',
  ];

  final List<String> _states = [
    'Lagos',
    'Abuja',
    'Rivers',
    'Kano',
    'Oyo',
    'Kaduna',
  ];

  final List<String> _cities = [
    'Ikeja',
    'Lekki',
    'Victoria Island',
    'Surulere',
    'Yaba',
  ];

  @override
  void dispose() {
    _providerNameController.dispose();
    _claimAmountController.dispose();
    _reimbursementCodeController.dispose();
    _paCodeController.dispose();
    _callCenterAgentController.dispose();
    _commentController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentStep == 1) {
      if (!_paFormKey.currentState!.validate()) return;
    } else if (_currentStep == 2) {
      if (!_providerFormKey.currentState!.validate()) return;
    }

    if (_currentStep < 4) {
      _goToPage(_currentStep + 1);
    }
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
    } else {
      _goToPage(_currentStep - 1);
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    FormFieldState<DateTime> state,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: scheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _incurredDate = picked);
      state.didChange(picked);
    }
  }

  void _simulateFileUpload() {
    if (_uploadedFiles.length < _maxFiles) {
      setState(() {
        _uploadedFiles.add('receipt_0${_uploadedFiles.length + 1}.pdf');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File attached successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() => _uploadedFiles.removeAt(index));
  }

  Future<void> _confirmAndSubmit() async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Submit Reimbursement?'),
        content: const Text(
          'Once submitted, this claim cannot be edited. Please confirm your details are accurate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Review Again'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm & Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _submit();
    }
  }

  void _submit() {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reimbursement submitted successfully'),
        backgroundColor: scheme.primary,
      ),
    );
    showHmoFeedbackModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 84), // Top Spacing for FloatingAppBar
                // Step Progress Indicator (Hidden on Intro Step 0)
                if (_currentStep > 0) _buildProgressBar(scheme),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildNoticeStep(
                        scheme,
                      ), // Step 0: Notice & PA Code Requirement
                      _buildPaCodeStep(scheme), // Step 1: PA Code Form
                      _buildProviderClaimStep(
                        scheme,
                      ), // Step 2: Provider & Claim Details
                      _buildDocumentsStep(
                        scheme,
                      ), // Step 3: Supporting Documents
                      _buildSummaryStep(scheme), // Step 4: Summary Review
                    ],
                  ),
                ),

                // Bottom Navigation Bar
                _buildBottomNav(scheme),
              ],
            ),

            // Floating Header Bar
            FloatingAppBar(
              scrollController: _scrollController,
              text: 'Request Reimbursement',
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 0: PREREQUISITE NOTICE SCREEN ---
  Widget _buildNoticeStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 56,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Important Requirement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please ensure you have obtained a Pre-Authorization (PA) Code from the Call Center before filling out this reimbursement form.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Call Center Quick Action Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.phone_in_talk_outlined,
                      color: scheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Don\'t have a PA Code yet?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Call our 24/7 Call Center desk to request your Pre-Authorization code before proceeding.',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.call, size: 18, color: scheme.primary),
                    label: Text(
                      'Call 02013300300',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: scheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Required Items Checklist
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What you\'ll need for this claim:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildChecklistItem('Valid PA Code & Representative Name', scheme),
          _buildChecklistItem('Reimbursement Reference Code', scheme),
          _buildChecklistItem(
            'Healthcare Provider Name & Claim Amount',
            scheme,
          ),
          _buildChecklistItem(
            'Receipts or Medical Prescriptions (Max 5MB)',
            scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: scheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: PA CODE & PRE-AUTH ---
  Widget _buildPaCodeStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _paFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Pre-Authorization & Codes',
              Icons.verified_user_outlined,
              scheme,
            ),
            _buildCardContainer(
              scheme,
              children: [
                _buildLabel('Pre-Authorization (PA) Code', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _paCodeController,
                  hint: 'e.g. PA-993821',
                  prefixIcon: Icons.key_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter PA code' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Issued By (Call Center Representative)', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _callCenterAgentController,
                  hint: 'Enter representative name',
                  prefixIcon: Icons.support_agent_outlined,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter representative name'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Reimbursement Code', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _reimbursementCodeController,
                  hint: 'Enter reimbursement reference code',
                  prefixIcon: Icons.qr_code_scanner_outlined,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter reimbursement code'
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: PROVIDER & CLAIM DETAILS ---
  Widget _buildProviderClaimStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _providerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Provider & Claim Details',
              Icons.local_hospital_outlined,
              scheme,
            ),
            _buildCardContainer(
              scheme,
              children: [
                _buildLabel('Claim Type', scheme),
                _buildDropdown(
                  scheme: scheme,
                  hint: 'Select Claim Type',
                  value: _selectedClaimType,
                  items: _claimTypes,
                  onChanged: (v) => setState(() => _selectedClaimType = v),
                  validator: (v) => v == null ? 'Select claim type' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Claim Incurred Date', scheme),
                _buildDateField(scheme),
                const SizedBox(height: 16),
                _buildLabel('Select State', scheme),
                _buildDropdown(
                  scheme: scheme,
                  hint: 'Select State',
                  value: _selectedState,
                  items: _states,
                  onChanged: (v) => setState(() {
                    _selectedState = v;
                    _selectedCity = null;
                  }),
                  validator: (v) => v == null ? 'Select a state' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Select City', scheme),
                _buildCityDropdown(scheme),
                const SizedBox(height: 16),
                _buildLabel('Healthcare Provider Name', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _providerNameController,
                  hint: 'Enter hospital or clinic name',
                  prefixIcon: Icons.apartment_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter provider name' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Claimed Amount (₦)', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _claimAmountController,
                  hint: '0.00',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter claim amount' : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 3: DOCUMENTS & NOTES ---
  Widget _buildDocumentsStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Supporting Documents & Notes',
            Icons.description_outlined,
            scheme,
          ),
          _buildCardContainer(
            scheme,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Upload Receipts / Prescriptions', scheme),
                  Text(
                    '${_uploadedFiles.length}/$_maxFiles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildUploadArea(scheme),
              if (_uploadedFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildUploadedFilesList(scheme),
              ],
              const SizedBox(height: 16),
              _buildLabel('Comments / Additional Notes', scheme),
              _buildTextField(
                scheme: scheme,
                controller: _commentController,
                hint: 'Provide supplementary medical or payment context...',
                prefixIcon: Icons.chat_bubble_outline_outlined,
                maxLines: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 4: REVIEW SUMMARY ---
  Widget _buildSummaryStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Review Your Claim',
            Icons.fact_check_outlined,
            scheme,
          ),
          _buildCardContainer(
            scheme,
            children: [
              _summaryRow(scheme, 'PA Code', _paCodeController.text),
              _summaryRow(scheme, 'Issued By', _callCenterAgentController.text),
              _summaryRow(
                scheme,
                'Reimbursement Code',
                _reimbursementCodeController.text,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCardContainer(
            scheme,
            children: [
              _summaryRow(scheme, 'Claim Type', _selectedClaimType ?? '-'),
              _summaryRow(
                scheme,
                'Incurred Date',
                _incurredDate == null
                    ? '-'
                    : '${_incurredDate!.day.toString().padLeft(2, '0')}/'
                          '${_incurredDate!.month.toString().padLeft(2, '0')}/'
                          '${_incurredDate!.year}',
              ),
              _summaryRow(scheme, 'State', _selectedState ?? '-'),
              _summaryRow(scheme, 'City', _selectedCity ?? '-'),
              _summaryRow(
                scheme,
                'Provider Name',
                _providerNameController.text,
              ),
              _summaryRow(
                scheme,
                'Claimed Amount',
                '₦${_claimAmountController.text}',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCardContainer(
            scheme,
            children: [
              _summaryRow(
                scheme,
                'Attachments',
                '${_uploadedFiles.length} file(s) attached',
              ),
              _summaryRow(
                scheme,
                'Comments',
                _commentController.text.isEmpty
                    ? 'None'
                    : _commentController.text,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Verify all fields before submitting. Claims cannot be edited after submission.',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- PROGRESS BAR (Active from Step 1) ---
  Widget _buildProgressBar(ColorScheme scheme) {
    final stepTitles = [
      'PA & Codes',
      'Claim Details',
      'Documents',
      'Review & Submit',
    ];

    final formStepIndex = _currentStep - 1; // 0..3

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${formStepIndex + 1} of 4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              Text(
                stepTitles[formStepIndex],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(4, (i) {
              final isActive = i <= formStepIndex;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 5,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? scheme.primary
                        : scheme.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM NAV BUTTONS ---
  Widget _buildBottomNav(ColorScheme scheme) {
    final isIntro = _currentStep == 0;
    final isSummary = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(isIntro ? 'Cancel' : 'Back'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isSummary ? _confirmAndSubmit : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isIntro
                      ? 'I Have My PA Code'
                      : (isSummary ? 'Submit Reimbursement' : 'Next Step'),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---
  Widget _buildSectionHeader(String title, IconData icon, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer(
    ColorScheme scheme, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ColorScheme scheme,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 20,
          color: scheme.onSurface.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required ColorScheme scheme,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      dropdownColor: scheme.surface,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        hint,
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: scheme.onSurface.withValues(alpha: 0.5),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCityDropdown(ColorScheme scheme) {
    final isDisabled = _selectedState == null;
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      validator: (v) => v == null ? 'Select a city' : null,
      dropdownColor: scheme.surface,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDisabled
            ? scheme.onSurface.withValues(alpha: 0.05)
            : scheme.surfaceContainer,
        prefixIcon: Icon(
          Icons.location_on_outlined,
          size: 20,
          color: scheme.onSurface.withValues(alpha: isDisabled ? 0.2 : 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        'Select a city',
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: isDisabled ? 0.2 : 0.4),
          fontSize: 14,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: scheme.onSurface.withValues(alpha: isDisabled ? 0.2 : 0.5),
      ),
      items: isDisabled
          ? []
          : _cities
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
      onChanged: isDisabled ? null : (v) => setState(() => _selectedCity = v),
    );
  }

  Widget _buildDateField(ColorScheme scheme) {
    return FormField<DateTime>(
      validator: (_) => _incurredDate == null ? 'Select incurred date' : null,
      builder: (formFieldState) {
        final hasError = formFieldState.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context, formFieldState),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: hasError
                      ? Border.all(color: scheme.error, width: 1.2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _incurredDate == null
                              ? 'Select Date'
                              : '${_incurredDate!.day.toString().padLeft(2, '0')}/'
                                    '${_incurredDate!.month.toString().padLeft(2, '0')}/'
                                    '${_incurredDate!.year}',
                          style: TextStyle(
                            color: _incurredDate == null
                                ? scheme.onSurface.withValues(alpha: 0.4)
                                : scheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: TextStyle(color: scheme.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUploadArea(ColorScheme scheme) {
    final isMaxed = _uploadedFiles.length >= _maxFiles;
    return GestureDetector(
      onTap: isMaxed ? null : _simulateFileUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: isMaxed
              ? scheme.onSurface.withValues(alpha: 0.03)
              : scheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMaxed
                ? scheme.onSurface.withValues(alpha: 0.1)
                : scheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: isMaxed
                  ? scheme.onSurface.withValues(alpha: 0.3)
                  : scheme.primary,
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              isMaxed ? 'Maximum file limit reached' : 'Tap to upload receipts',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Supports PDF, JPG, PNG (Max 5MB per file)',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFilesList(ColorScheme scheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_uploadedFiles.length, (index) {
        return Chip(
          backgroundColor: scheme.surfaceContainer,
          avatar: Icon(
            Icons.insert_drive_file_outlined,
            size: 16,
            color: scheme.primary,
          ),
          label: Text(
            _uploadedFiles[index],
            style: TextStyle(fontSize: 12, color: scheme.onSurface),
          ),
          onDeleted: () => _removeFile(index),
          deleteIconColor: scheme.error.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _summaryRow(
    ColorScheme scheme,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
