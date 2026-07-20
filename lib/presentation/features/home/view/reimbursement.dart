import 'package:flutter/material.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/feedbsck_modal.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

class ReimbursementScreen extends StatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  State<ReimbursementScreen> createState() => _ReimbursementScreenState();
}

class _Step {
  static const confirm = 0;
  static const paCode = 1;
  static const providerClaim = 2;
  // static const documents = 3;
  static const summary = 4;
}

class _ReimbursementScreenState extends State<ReimbursementScreen> {
  final _paFormKey = GlobalKey<FormState>();
  final _providerFormKey = GlobalKey<FormState>();

  final _providerNameController = TextEditingController();
  final _claimAmountController = TextEditingController();
  final _reimbursementCodeController = TextEditingController();
  final _paCodeController = TextEditingController();
  final _callCenterAgentController = TextEditingController();
  final _commentController = TextEditingController();

  String? _selectedClaimType;
  String? _selectedState;
  String? _selectedCity;
  DateTime? _incurredDate;

  final List<String> _uploadedFiles = [];
  final int _maxFiles = 5;

  int _currentStep = _Step.confirm;
  final PageController _pageController = PageController();

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

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------

  void _goToPage(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    // Validate the current step before advancing.
    if (_currentStep == _Step.paCode) {
      if (!_paFormKey.currentState!.validate()) return;
    } else if (_currentStep == _Step.providerClaim) {
      if (!_providerFormKey.currentState!.validate()) return;
    }
    if (_currentStep < _Step.summary) {
      _goToPage(_currentStep + 1);
    }
  }

  void _back() {
    if (_currentStep == _Step.paCode) {
      // Leaving the flow entirely from the first real step.
      Navigator.of(context).maybePop();
      return;
    }
    if (_currentStep > _Step.confirm) {
      _goToPage(_currentStep - 1);
    }
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

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
        title: const Text('Submit reimbursement request?'),
        content: const Text(
          'Once submitted, you cannot edit this claim. Confirm the details are correct.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Review again'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
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

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  if (_currentStep != _Step.confirm) _buildProgressBar(scheme),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildConfirmStep(scheme),
                        _buildPaCodeStep(scheme),
                        _buildProviderClaimStep(scheme),
                        _buildDocumentsStep(scheme),
                        _buildSummaryStep(scheme),
                      ],
                    ),
                  ),
                  if (_currentStep != _Step.confirm) _buildBottomNav(scheme),
                ],
              ),
            ),
            FloatingAppBar(
              scrollController: _scrollController,
              username: 'User',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmStep(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: scheme.primary),
          const SizedBox(height: 20),
          Text(
            'Request a reimbursement?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will need your PA code, provider details, and receipts for this claim.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _goToPage(_Step.paCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Yes, Start Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Not Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaCodeStep(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _paFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Pre-Authorization & Codes',
              Icons.vpn_key_outlined,
              scheme,
            ),
            _buildCardContainer(
              scheme,
              children: [
                _buildLabel('Pre-Authorization (PA) Code', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _paCodeController,
                  hint: 'Enter PA Code',
                  prefixIcon: Icons.verified_user_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter PA code' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Issued By (Call Center Representative)', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _callCenterAgentController,
                  hint: 'Who issued this PA code?',
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
                  hint: 'Enter Reimbursement Code',
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

  Widget _buildProviderClaimStep(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  hint: 'Enter hospital or provider name',
                  prefixIcon: Icons.apartment_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter provider name' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Claimed Amount', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _claimAmountController,
                  hint: 'Enter Claim Amount (₦)',
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

  Widget _buildDocumentsStep(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  _buildLabel('Upload Receipts / Prescription', scheme),
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
              _buildLabel('Comments / Extra Information', scheme),
              _buildTextField(
                scheme: scheme,
                controller: _commentController,
                hint: 'Enter any supplementary context here...',
                prefixIcon: Icons.chat_bubble_outline_outlined,
                maxLines: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              _summaryRow(scheme, 'Provider', _providerNameController.text),
              _summaryRow(
                scheme,
                'Claimed Amount',
                '₦${_claimAmountController.text}',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCardContainer(
            scheme,
            children: [
              _summaryRow(
                scheme,
                'Attachments',
                '${_uploadedFiles.length} file(s)',
              ),
              _summaryRow(
                scheme,
                'Comments',
                _commentController.text.isEmpty ? '-' : _commentController.text,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                  'Check every field above. Submitting locks this claim for review.',
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

  Widget _summaryRow(
    ColorScheme scheme,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  Widget _buildProgressBar(ColorScheme scheme) {
    final displayStep = _currentStep; // 1..4
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $displayStep of 4',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(4, (i) {
              final stepIndex = i + 1;
              final isActive = stepIndex <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.1),
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

  Widget _buildBottomNav(ColorScheme scheme) {
    final isSummary = _currentStep == _Step.summary;
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
              height: 52,
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isSummary ? _confirmAndSubmit : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isSummary ? 'Submit Claim Request' : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
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
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
        fillColor: scheme.surfaceContainerHigh,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
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
      dropdownColor: scheme.surfaceContainerHigh,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.2),
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
      dropdownColor: scheme.surfaceContainerHigh,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDisabled
            ? scheme.onSurface.withValues(alpha: 0.05)
            : scheme.surfaceContainerHigh,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.2),
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
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: isMaxed
              ? scheme.onSurface.withValues(alpha: 0.03)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMaxed
                ? scheme.onSurface.withValues(alpha: 0.1)
                : scheme.primary.withValues(alpha: 0.25),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: isMaxed
                  ? scheme.onSurface.withValues(alpha: 0.3)
                  : scheme.primary,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              isMaxed ? 'Maximum file limit reached' : 'Tap to upload files',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
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
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }),
    );
  }
}
