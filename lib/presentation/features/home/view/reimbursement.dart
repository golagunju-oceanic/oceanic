import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';
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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: kNavyBlue)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _incurredDate = picked);
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reimbursement submitted successfully'),
          backgroundColor: kNavyBlue,
        ),
      );
    }
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: Colors.white,
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
                            // _buildFormTitle(),
                            const SizedBox(height: 24),

                            // Claim Type
                            _buildLabel('Claim Type'),
                            _buildDropdown(
                              hint: 'Claim Type',
                              value: _selectedClaimType,
                              items: _claimTypes,
                              onChanged: (v) =>
                                  setState(() => _selectedClaimType = v),
                              validator: (v) =>
                                  v == null ? 'Select claim type' : null,
                            ),
                            const SizedBox(height: 20),

                            // Claimed Incurred Date
                            _buildLabel('Claimed Incurred Date'),
                            _buildDateField(),
                            const SizedBox(height: 20),

                            // Select State
                            _buildLabel('Select State'),
                            _buildDropdown(
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

                            // Select City
                            _buildLabel('Select City'),
                            _buildCityDropdown(),
                            const SizedBox(height: 20),

                            // Provider Name
                            _buildLabel('Provider Name'),
                            _buildTextField(
                              controller: _providerNameController,
                              hint: 'Enter provider name',
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter provider name'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Claimed Amount
                            _buildLabel('Claimed Amount'),
                            _buildTextField(
                              controller: _claimAmountController,
                              hint: 'Enter Claim Amount',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter claim amount'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Reimbursement Code
                            _buildLabel('Reimbursement Code'),
                            _buildTextField(
                              controller: _reimbursementCodeController,
                              hint: 'Enter Your Reimbursement Code',
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter reimbursement code'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Comment
                            _buildLabel('Comment'),
                            _buildTextField(
                              controller: _commentController,
                              hint: 'Enter comment',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 20),

                            // Upload Prescription
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel('Upload Prescription'),
                                Text(
                                  '$_uploadedFiles/$_maxFiles',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildUploadArea(),
                            const SizedBox(height: 32),

                            // Submit Button
                            _buildSubmitButton(),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: kDarkTextOnPrimary,
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
          borderSide: const BorderSide(color: kNavyBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      decoration: InputDecoration(
        filled: true,

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
          borderSide: const BorderSide(color: kNavyBlue, width: 1.5),
        ),
      ),
      hint: Text(
        hint,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      validator: (v) => v == null ? 'Select a city' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: _selectedState == null
            ? Colors.grey.shade200
            : kDarkTextOnPrimary,
        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
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
          borderSide: const BorderSide(color: kNavyBlue, width: 1.5),
        ),
      ),
      hint: Text(
        'Select a city',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      items: _selectedState == null
          ? []
          : _cities
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
      onChanged: _selectedState == null
          ? null
          : (v) => setState(() => _selectedCity = v),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _selectedState == null
              ? Colors.grey.shade200
              : kDarkTextOnPrimary,
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
                    ? Colors.grey.shade400
                    : Colors.black87,
                fontSize: 14,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _uploadedFiles < _maxFiles ? _simulateFileUpload : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: _uploadedFiles >= _maxFiles
              ? Colors.grey.shade200
              : kDarkTextOnPrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _uploadedFiles >= _maxFiles
                ? Colors.grey.shade300
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: kNavyBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              _uploadedFiles > 0
                  ? '$_uploadedFiles file${_uploadedFiles > 1 ? 's' : ''} selected'
                  : 'Upload Files',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: kNavyBlue,
          foregroundColor: Colors.white,
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
