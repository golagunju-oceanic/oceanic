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
  final _formKey = GlobalKey<FormState>();

  final _providerNameController = TextEditingController();
  final _claimAmountController = TextEditingController();
  final _reimbursementCodeController = TextEditingController();
  final _commentController = TextEditingController();

  String? _selectedClaimType;
  String? _selectedState;
  String? _selectedCity;
  DateTime? _incurredDate;

  int _uploadedFiles = 0;
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
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
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
    if (picked != null) setState(() => _incurredDate = picked);
  }

  void _simulateFileUpload() {
    if (_uploadedFiles < _maxFiles) {
      setState(() => _uploadedFiles++);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File added'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reimbursement submitted successfully'),
          backgroundColor: scheme.primary,
        ),
      );
    }
    showHmoFeedbackModal(context);
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildLabel('Claim Type', scheme),
                            _buildDropdown(
                              scheme: scheme,
                              hint: 'Claim Type',
                              value: _selectedClaimType,
                              items: _claimTypes,
                              onChanged: (v) =>
                                  setState(() => _selectedClaimType = v),
                              validator: (v) =>
                                  v == null ? 'Select claim type' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Claimed Incurred Date', scheme),
                            _buildDateField(scheme),
                            const SizedBox(height: 20),
                            _buildLabel('Select State', scheme),
                            _buildDropdown(
                              scheme: scheme,
                              hint: 'Select',
                              value: _selectedState,
                              items: _states,
                              onChanged: (v) => setState(() {
                                _selectedState = v;
                                _selectedCity = null;
                              }),
                              validator: (v) =>
                                  v == null ? 'Select a state' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Select City', scheme),
                            _buildCityDropdown(scheme),
                            const SizedBox(height: 20),
                            _buildLabel('Provider Name', scheme),
                            _buildTextField(
                              scheme: scheme,
                              controller: _providerNameController,
                              hint: 'Enter provider name',
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter provider name'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Claimed Amount', scheme),
                            _buildTextField(
                              scheme: scheme,
                              controller: _claimAmountController,
                              hint: 'Enter Claim Amount',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter claim amount'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Reimbursement Code', scheme),
                            _buildTextField(
                              scheme: scheme,
                              controller: _reimbursementCodeController,
                              hint: 'Enter Your Reimbursement Code',
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter reimbursement code'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Comment', scheme),
                            _buildTextField(
                              scheme: scheme,
                              controller: _commentController,
                              hint: 'Enter comment',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel('Upload Prescription', scheme),
                                Text(
                                  '$_uploadedFiles/$_maxFiles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildUploadArea(scheme),
                            const SizedBox(height: 32),
                            _buildSubmitButton(scheme),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
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

  Widget _buildLabel(String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ColorScheme scheme,
    required TextEditingController controller,
    required String hint,
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
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error, width: 1),
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
      dropdownColor: scheme.surfaceContainer,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
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
        Icons.keyboard_arrow_down,
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
      dropdownColor: scheme.surfaceContainer,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDisabled
            ? scheme.onSurface.withValues(alpha: 0.06)
            : scheme.surfaceContainer,
        prefixIcon: Icon(
          Icons.location_on_outlined,
          color: scheme.onSurface.withValues(alpha: 0.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      hint: Text(
        'Select a city',
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: scheme.onSurface.withValues(alpha: 0.5),
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
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            Icon(
              Icons.calendar_today_outlined,
              color: scheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(ColorScheme scheme) {
    final isMaxed = _uploadedFiles >= _maxFiles;
    return GestureDetector(
      onTap: isMaxed ? null : _simulateFileUpload,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isMaxed
              ? scheme.onSurface.withValues(alpha: 0.06)
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isMaxed
                ? scheme.onSurface.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: scheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              _uploadedFiles > 0
                  ? '$_uploadedFiles file${_uploadedFiles > 1 ? 's' : ''} selected'
                  : 'Upload Files',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
