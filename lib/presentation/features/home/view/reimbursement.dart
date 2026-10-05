import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oceanic/data/models/states.dart';
import 'package:oceanic/features/reimbursement/Presentation/provider/reimbursement_provider.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/feedbsck_modal.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';
import 'package:oceanic/features/reimbursement/Presentation/state/reimbursement_state.dart';
import 'package:oceanic/features/reimbursement/data/models/submit_reimbursement_request.dart';

class ReimbursementScreen extends ConsumerStatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  ConsumerState<ReimbursementScreen> createState() =>
      _ReimbursementScreenState();
}

class _ReimbursementScreenState extends ConsumerState<ReimbursementScreen> {
  final _codeFormKey = GlobalKey<FormState>();
  final _claimFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  final _reimbursementCodeController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _claimAmountController = TextEditingController();
  final _commentController = TextEditingController();

  int _currentStep =
      0; // 0: Notice/Intro, 1: Code + Bank Details, 2: Claim Details, 3: Document, 4: Review

  String? _selectedClaimType;
  String? _selectedState;
  String? _selectedCity;
  DateTime? _incurredDate;

  final States _statesModel = States();

  List<String> get _nigerianStates =>
      _statesModel.states.map((s) => s['name'] as String).toList();

  List<String> _citiesFor(String? stateName) {
    if (stateName == null) return [];
    final stateData = _statesModel.states.firstWhere(
      (s) => s['name'] == stateName,
      orElse: () => {'cities': <String>[]},
    );
    return List<String>.from(stateData['cities'] as List);
  }

  final List<String> _claimTypes = [
    'Outpatient',
    'Inpatient',
    'Dental',
    'Optical',
    'Maternity',
  ];

  // Single document, matches SubmitReimbursementRequest.documentPath
  String? _documentPath;
  String? _documentFileName;

  @override
  void dispose() {
    _reimbursementCodeController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _providerNameController.dispose();
    _claimAmountController.dispose();
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
      if (!_codeFormKey.currentState!.validate()) return;
    } else if (_currentStep == 2) {
      if (!_claimFormKey.currentState!.validate()) return;
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

  void _showLocalError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDocument() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (file == null || !mounted) {
      return;
    }

    if (file.path == null) {
      _showLocalError('Unable to access the selected file.');
      return;
    }

    setState(() {
      _documentPath = file.path;
      _documentFileName = file.name;
    });
  }

  void _removeDocument() {
    setState(() {
      _documentPath = null;
      _documentFileName = null;
    });
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
    if (_documentPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attach a receipt or prescription first')),
      );
      return;
    }

    if (_incurredDate == null) {
      _showLocalError('Please select the claim incurred date.');
      return;
    }

    final amount = double.tryParse(_claimAmountController.text.trim());

    if (amount == null || amount <= 0) {
      _showLocalError('Please enter a valid claim amount.');
      return;
    }

    // API requires yyyy-MM-dd.
    // Example: 2026-10-02
    final serviceDate = _formatDateForApi(_incurredDate!);

    final request = SubmitReimbursementRequest(
      reimbursementCode: _reimbursementCodeController.text.trim(),

      amount: amount,

      accountNumber: _accountNumberController.text.trim(),

      bankName: _bankNameController.text.trim(),

      accountName: _accountNameController.text.trim(),

      enrolleeNotes: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),

      documentPath: _documentPath!,

      items: [
        ReimbursementItemRequest(
          // IMPORTANT:
          // API item_type is "service", not
          // Outpatient/Inpatient/etc.
          itemType: 'service',

          // IMPORTANT:
          // yyyy-MM-dd
          serviceDate: serviceDate,

          // For now, keep this human-readable.
          description: _selectedClaimType ?? 'Consultation',

          quantity: 1,

          unitPrice: amount,

          // TEMPORARY FOR TESTING:
          // This is the exact service ID that worked
          // in your Postman test.
          service: 12,
        ),
      ],
    );

    debugPrint('=========== UI REQUEST ===========');
    debugPrint('code: ${request.reimbursementCode}');
    debugPrint('claim type displayed: $_selectedClaimType');
    debugPrint('service date sent: $serviceDate');
    debugPrint('service id sent: 12');
    debugPrint('==================================');

    ref
        .read(reimbursementViewModelProvider.notifier)
        .submitReimbursement(request);
  }

  String _formatDateForApi(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    ref.listen<ReimbursementState>(reimbursementViewModelProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess && previous?.isSuccess != true) {
        showHmoFeedbackModal(context);
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: scheme.error,
          ),
        );
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 84),
                if (_currentStep > 0) _buildProgressBar(scheme),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildNoticeStep(scheme),
                      _buildCodeAndBankStep(scheme),
                      _buildClaimDetailsStep(scheme),
                      _buildDocumentStep(scheme),
                      _buildSummaryStep(scheme),
                    ],
                  ),
                ),
                _buildBottomNav(scheme),
              ],
            ),
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

  // --- STEP 0: NOTICE (unchanged) ---
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
            'Please ensure you have your reimbursement code before filling out this form.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
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
          _buildChecklistItem('Reimbursement Code', scheme),
          _buildChecklistItem('Bank Account Details', scheme),
          _buildChecklistItem(
            'Healthcare Provider Name & Claim Amount',
            scheme,
          ),
          _buildChecklistItem('One Receipt or Prescription (Max 5MB)', scheme),
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

  // --- STEP 1: REIMBURSEMENT CODE + BANK DETAILS ---
  Widget _buildCodeAndBankStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _codeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Reimbursement Code & Bank Details',
              Icons.verified_user_outlined,
              scheme,
            ),
            _buildCardContainer(
              scheme,
              children: [
                _buildLabel('Reimbursement Code', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _reimbursementCodeController,
                  hint: 'e.g. PA-993821',
                  prefixIcon: Icons.key_outlined,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter reimbursement code'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Account Number', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _accountNumberController,
                  hint: 'Enter account number',
                  prefixIcon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter account number' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Bank Name', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _bankNameController,
                  hint: 'Enter bank name',
                  prefixIcon: Icons.account_balance_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter bank name' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Account Name', scheme),
                _buildTextField(
                  scheme: scheme,
                  controller: _accountNameController,
                  hint: 'Enter account name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter account name' : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: CLAIM DETAILS ---
  Widget _buildClaimDetailsStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _claimFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Claim Details',
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
                  items: _nigerianStates,
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

  // --- STEP 3: DOCUMENT (single file, matches API) ---
  Widget _buildDocumentStep(ColorScheme scheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Supporting Document & Notes',
            Icons.description_outlined,
            scheme,
          ),
          _buildCardContainer(
            scheme,
            children: [
              _buildLabel('Upload Receipt / Prescription', scheme),
              const SizedBox(height: 8),
              _documentPath == null
                  ? _buildUploadArea(scheme)
                  : _buildDocumentChip(scheme),
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

  Widget _buildDocumentChip(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            color: scheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _documentFileName ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: scheme.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: scheme.error.withValues(alpha: 0.7),
            ),
            onPressed: _removeDocument,
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
              _summaryRow(
                scheme,
                'Reimbursement Code',
                _reimbursementCodeController.text,
              ),
              _summaryRow(
                scheme,
                'Account Number',
                _accountNumberController.text,
              ),
              _summaryRow(scheme, 'Bank Name', _bankNameController.text),
              _summaryRow(
                scheme,
                'Account Name',
                _accountNameController.text,
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
              _summaryRow(scheme, 'Attachment', _documentFileName ?? 'None'),
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
        ],
      ),
    );
  }

  // --- PROGRESS BAR ---
  Widget _buildProgressBar(ColorScheme scheme) {
    final stepTitles = [
      'Code & Bank',
      'Claim Details',
      'Document',
      'Review & Submit',
    ];
    final formStepIndex = _currentStep - 1;

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

  // --- BOTTOM NAV ---
  Widget _buildBottomNav(ColorScheme scheme) {
    final isIntro = _currentStep == 0;
    final isSummary = _currentStep == 4;
    final isLoading = ref.watch(
      reimbursementViewModelProvider.select((s) => s.isLoading),
    );

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
                onPressed: isLoading ? null : _back,
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
                onPressed: isLoading
                    ? null
                    : (isSummary ? _confirmAndSubmit : _next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isIntro
                            ? 'I Have My Code'
                            : (isSummary
                                  ? 'Submit Reimbursement'
                                  : 'Next Step'),
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

  // --- REUSABLE HELPERS (unchanged from before) ---
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
    final availableCities = _citiesFor(_selectedState);

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
          : availableCities
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
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: scheme.primary, size: 32),
            const SizedBox(height: 6),
            Text(
              'Tap to upload receipt',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Supports PDF, JPG, PNG (Max 5MB)',
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
