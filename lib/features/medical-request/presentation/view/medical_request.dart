import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_picker/image_picker.dart';

import 'package:oceanic/data/models/states.dart';

import 'package:oceanic/features/medical-request/data/models/beneficiary_model.dart';

import 'package:oceanic/features/medical-request/data/models/chorinc_medication_model.dart';

import 'package:oceanic/features/medical-request/data/models/refill_request_model.dart';

import 'package:oceanic/features/medical-request/presentation/provider/medication_provider.dart';

import 'package:oceanic/features/medical-request/presentation/state/medication_state.dart';

import 'package:oceanic/presentation/widgets/drawer.dart';

class MedicalRequest extends ConsumerStatefulWidget {
  const MedicalRequest({super.key});

  @override
  ConsumerState<MedicalRequest> createState() => _MedicalRequestState();
}

class _MedicalRequestState extends ConsumerState<MedicalRequest> {
  int _selectedTabIndex = 0;

  String? _selectedState;

  String? _selectedCity;

  final States _states = States();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _deliveryAddressController =
      TextEditingController();

  final TextEditingController _conditionController = TextEditingController();

  final TextEditingController _commentsController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? _prescriptionFilePath;

  String? _prescriptionFileName;

  /// key = drugId

  final Map<String, _RefillMedicationDraft> _selectedMedications = {};

  List<String> get _nigerianStates {
    return _states.states.map((state) => state['name'] as String).toList();
  }

  List<String> _citiesFor(String? stateName) {
    if (stateName == null) return [];

    final stateData = _states.states.firstWhere(
      (state) => state['name'] == stateName,

      orElse: () => {'cities': <String>[]},
    );

    return List<String>.from(stateData['cities'] as List);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(medicationViewModelProvider.notifier).getBeneficiaries();
    });
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();

    _conditionController.dispose();

    _commentsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final medicationState = ref.watch(medicationViewModelProvider);

    ref.listen<MedicationState>(medicationViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.successMessage!)));
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
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
              top: 360.h,
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
            Column(
              children: [
                _buildTopBar(scheme: scheme, isDark: isDark),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                  child: _buildSegmentedControl(scheme, isDark),
                ),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildRequestRefillForm(scheme, medicationState, isDark)
                      : _buildNewPrescriptionForm(
                          scheme,
                          medicationState,
                          isDark,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar({required ColorScheme scheme, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          _buildTopButton(
            icon: Icons.arrow_back_rounded,
            scheme: scheme,
            isDark: isDark,
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication',
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
                  'Refills & prescription requests',
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
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
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

  Widget _buildSegmentedControl(ColorScheme scheme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.025),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Request Refill',
              icon: Icons.medication_outlined,
              isSelected: _selectedTabIndex == 0,
              scheme: scheme,
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                  _selectedMedications.clear();
                });
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'New Prescription',
              icon: Icons.description_outlined,
              isSelected: _selectedTabIndex == 1,
              scheme: scheme,
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17.r,
                color: isSelected
                    ? scheme.onPrimary
                    : scheme.onSurface.withValues(alpha: 0.48),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.3.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? scheme.onPrimary
                        : scheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------

  // REFILL

  // --------------------------------------------------

  Widget _buildRequestRefillForm(
    ColorScheme scheme,
    MedicationState medicationState,
    bool isDark,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('refill'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(
                scheme: scheme,
                icon: Icons.autorenew_rounded,
                eyebrow: 'MEDICATION REFILL',
                title: 'Running low on medication?',
                description:
                    'Request a refill from your active chronic medication profile and have it processed for delivery.',
              ),
              SizedBox(height: 28.h),
              _buildSectionTitle(
                title: 'Enrollee',
                subtitle:
                    'The request will be made using your enrollee profile.',
                scheme: scheme,
              ),
              SizedBox(height: 12.h),
              _buildEnrolleeCard(scheme, medicationState, isDark),
              SizedBox(height: 28.h),
              _buildSectionTitle(
                title: 'Delivery information',
                subtitle: 'Tell us where your medication should be delivered.',
                scheme: scheme,
              ),
              SizedBox(height: 14.h),
              _buildFormLabel('State', scheme, required: true),
              SizedBox(height: 7.h),
              _buildSelectorTile(
                text: _selectedState ?? 'Select State',
                icon: Icons.map_outlined,
                isSet: _selectedState != null,
                scheme: scheme,
                isDark: isDark,
                onTap: () => _showSearchSheet(
                  title: 'Search State',
                  items: _nigerianStates,
                  onSelected: (value) {
                    setState(() {
                      _selectedState = value;
                      _selectedCity = null;
                    });
                  },
                ),
              ),
              SizedBox(height: 18.h),
              _buildFormLabel('City', scheme, required: true),
              SizedBox(height: 7.h),
              _buildSelectorTile(
                text: _selectedCity ?? 'Select City',
                icon: Icons.location_on_outlined,
                isSet: _selectedCity != null,
                scheme: scheme,
                isDark: isDark,
                onTap: _selectedState == null
                    ? null
                    : () {
                        _showSearchSheet(
                          title: 'Search City',
                          items: _citiesFor(_selectedState),
                          onSelected: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        );
                      },
              ),
              SizedBox(height: 18.h),
              _buildFormLabel('Delivery Address', scheme, required: true),
              SizedBox(height: 7.h),
              _buildTextField(
                controller: _deliveryAddressController,
                scheme: scheme,
                isDark: isDark,
                hint: 'Enter the full delivery address',
                icon: Icons.home_outlined,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSectionTitle(
                      title: 'Chronic medications',
                      subtitle: 'Select the medication you want to refill.',
                      scheme: scheme,
                    ),
                  ),
                  if (medicationState.selectedBeneficiary?.isChronicEligible ==
                      true)
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () {
                        final enrollee = medicationState.selectedBeneficiary;
                        if (enrollee != null) {
                          _loadChronicMedications(enrollee);
                        }
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 21.r,
                        color: scheme.primary,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              _buildChronicMedicationSection(scheme, medicationState, isDark),
              SizedBox(height: 30.h),
              _buildSubmitButton(
                label: 'Submit Refill Request',
                scheme: scheme,
                isLoading: medicationState.isSubmitting,
                onPressed: _submitRefill,
              ),
              SizedBox(height: 22.h),
              _buildContactFooter(scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChronicMedicationSection(
    ColorScheme scheme,
    MedicationState medicationState,
    bool isDark,
  ) {
    final enrollee = medicationState.selectedBeneficiary;

    if (enrollee == null) {
      return _buildEmptyCard(
        scheme,
        isDark,
        icon: Icons.person_outline_rounded,
        text: 'Unable to load enrollee information.',
      );
    }

    if (!enrollee.isChronicEligible) {
      return _buildEmptyCard(
        scheme,
        isDark,
        icon: Icons.info_outline_rounded,
        text: 'You are not currently eligible for chronic medication refills.',
      );
    }

    if (medicationState.isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(28.r),
        decoration: _modernCardDecoration(scheme, isDark),
        child: Center(
          child: SizedBox(
            width: 24.r,
            height: 24.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              color: scheme.primary,
            ),
          ),
        ),
      );
    }

    final medications = medicationState.chronicMedications;

    if (medications.isEmpty) {
      return _buildEmptyCard(
        scheme,
        isDark,
        icon: Icons.medication_outlined,
        text: 'No chronic medications were found for this enrollee.',
      );
    }

    return Column(
      children: medications.map((medication) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildMedicationCard(medication, scheme, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildMedicationCard(
    ChronicMedicationModel medication,
    ColorScheme scheme,
    bool isDark,
  ) {
    final medicationKey = medication.name;
    final isSelected = _selectedMedications.containsKey(medicationKey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primary.withValues(alpha: isDark ? 0.10 : 0.045)
            : scheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedMedications[medicationKey] =
                          _RefillMedicationDraft();
                    } else {
                      _selectedMedications.remove(medicationKey);
                    }
                  });
                },
              ),
              SizedBox(width: 4.w),
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.medication_outlined,
                  size: 19.r,
                  color: scheme.secondary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  medication.name,
                  style: TextStyle(
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (isSelected) ...[
            SizedBox(height: 15.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: _selectedMedications[medicationKey]!.quantity
                        .toString(),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 12.sp, color: scheme.onSurface),
                    decoration: _inputDecoration(
                      scheme,
                      isDark,
                      hint: 'Quantity',
                    ),
                    onChanged: (value) {
                      _selectedMedications[medicationKey]!.quantity =
                          int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    initialValue: _selectedMedications[medicationKey]!.dosage,
                    style: TextStyle(fontSize: 12.sp, color: scheme.onSurface),
                    decoration: _inputDecoration(
                      scheme,
                      isDark,
                      hint: 'e.g. 1 tablet daily',
                    ),
                    onChanged: (value) {
                      _selectedMedications[medicationKey]!.dosage = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadChronicMedications(BeneficiaryModel beneficiary) async {
    if (!beneficiary.isChronicEligible) {
      return;
    }

    await ref
        .read(medicationViewModelProvider.notifier)
        .getChronicMedications(beneficiary.id);
  }

  Future<void> _submitRefill() async {
    final medicationState = ref.read(medicationViewModelProvider);

    final enrollee = medicationState.selectedBeneficiary;

    if (enrollee == null) {
      _showLocalError('Unable to load your enrollee profile.');

      return;
    }

    if (!enrollee.isChronicEligible) {
      _showLocalError(
        'You are not currently eligible for chronic medication refills.',
      );

      return;
    }

    if (_selectedState == null) {
      _showLocalError('Please select a state.');

      return;
    }

    if (_selectedCity == null) {
      _showLocalError('Please select a city.');

      return;
    }

    if (_deliveryAddressController.text.trim().isEmpty) {
      _showLocalError('Please enter a delivery address.');

      return;
    }

    if (_selectedMedications.isEmpty) {
      _showLocalError('Please select at least one medication.');

      return;
    }

    for (final item in _selectedMedications.values) {
      if (item.quantity <= 0) {
        _showLocalError('Medication quantity must be greater than zero.');

        return;
      }

      if (item.dosage.trim().isEmpty) {
        _showLocalError(
          'Please enter the dosage for every selected medication.',
        );

        return;
      }
    }

    final request = RefillRequestModel(
      beneficiaryId: enrollee.id,

      state: _selectedState!,

      city: _selectedCity!,

      deliveryAddress: _deliveryAddressController.text.trim(),

      medications: _selectedMedications.entries.map((entry) {
        return RefillMedicationModel(
          customDrugName: entry.key,

          quantity: entry.value.quantity,

          dosage: entry.value.dosage.trim(),
        );
      }).toList(),
    );

    final success = await ref
        .read(medicationViewModelProvider.notifier)
        .submitRefill(request);

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedMedications.clear();
      });

      _deliveryAddressController.clear();
    }
  }

  // --------------------------------------------------

  // NEW PRESCRIPTION

  // --------------------------------------------------

  Widget _buildNewPrescriptionForm(
    ColorScheme scheme,
    MedicationState medicationState,
    bool isDark,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('prescription'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(
                scheme: scheme,
                icon: Icons.description_outlined,
                eyebrow: 'NEW PRESCRIPTION',
                title: 'Have a new prescription?',
                description:
                    'Upload a valid prescription and provide the details needed to process your medication request.',
              ),
              SizedBox(height: 28.h),
              _buildSectionTitle(
                title: 'Enrollee',
                subtitle:
                    'This prescription request will be linked to your profile.',
                scheme: scheme,
              ),
              SizedBox(height: 12.h),
              _buildEnrolleeCard(scheme, medicationState, isDark),
              SizedBox(height: 28.h),
              _buildSectionTitle(
                title: 'Prescription',
                subtitle: 'Upload a clear copy of the prescription.',
                scheme: scheme,
              ),
              SizedBox(height: 14.h),
              _buildFormLabel(
                'Prescription Document / Photo',
                scheme,
                required: true,
              ),
              SizedBox(height: 7.h),
              _buildPrescriptionUpload(scheme, isDark),
              SizedBox(height: 28.h),
              _buildSectionTitle(
                title: 'Processing location',
                subtitle:
                    'Choose where the medication request should be processed.',
                scheme: scheme,
              ),
              SizedBox(height: 14.h),
              _buildFormLabel('State', scheme, required: true),
              SizedBox(height: 7.h),
              _buildSelectorTile(
                text: _selectedState ?? 'Select State',
                icon: Icons.map_outlined,
                isSet: _selectedState != null,
                scheme: scheme,
                isDark: isDark,
                onTap: () => _showSearchSheet(
                  title: 'Search State',
                  items: _nigerianStates,
                  onSelected: (value) {
                    setState(() {
                      _selectedState = value;
                      _selectedCity = null;
                    });
                  },
                ),
              ),
              SizedBox(height: 18.h),
              _buildFormLabel('City / Location', scheme, required: true),
              SizedBox(height: 7.h),
              _buildSelectorTile(
                text: _selectedCity ?? 'Select City',
                icon: Icons.location_on_outlined,
                isSet: _selectedCity != null,
                scheme: scheme,
                isDark: isDark,
                onTap: _selectedState == null
                    ? null
                    : () {
                        _showSearchSheet(
                          title: 'Search City',
                          items: _citiesFor(_selectedState),
                          onSelected: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        );
                      },
              ),
              SizedBox(height: 28.h),
              _buildSectionTitle(
                title: 'Medical information',
                subtitle: 'Tell us what the prescription is for.',
                scheme: scheme,
              ),
              SizedBox(height: 14.h),
              _buildFormLabel('Condition / Illness', scheme, required: true),
              SizedBox(height: 7.h),
              _buildTextField(
                controller: _conditionController,
                scheme: scheme,
                isDark: isDark,
                hint: 'e.g. Malaria, hypertension',
                icon: Icons.health_and_safety_outlined,
              ),
              SizedBox(height: 18.h),
              _buildFormLabel('Additional Comments', scheme),
              SizedBox(height: 7.h),
              _buildTextField(
                controller: _commentsController,
                scheme: scheme,
                isDark: isDark,
                hint: 'Add any extra instructions or notes',
                maxLines: 4,
              ),
              SizedBox(height: 30.h),
              _buildSubmitButton(
                label: 'Submit Prescription Request',
                scheme: scheme,
                isLoading: medicationState.isSubmitting,
                onPressed: _submitPrescription,
              ),
              if (medicationState.prescriptionResponse != null) ...[
                SizedBox(height: 16.h),
                _buildPrescriptionSuccessCard(scheme, medicationState),
              ],
              SizedBox(height: 22.h),
              _buildContactFooter(scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionUpload(ColorScheme scheme, bool isDark) {
    final hasFile = _prescriptionFilePath != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showUploadModal,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: hasFile
                ? scheme.primary.withValues(alpha: isDark ? 0.10 : 0.05)
                : scheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: hasFile
                  ? scheme.primary.withValues(alpha: 0.35)
                  : scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
            ),
          ),
          child: hasFile
              ? Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 21.r,
                        color: scheme.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _prescriptionFileName ?? 'Prescription',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Tap to replace this file',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: scheme.onSurface.withValues(alpha: 0.48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _prescriptionFilePath = null;
                          _prescriptionFileName = null;
                        });
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 19.r,
                        color: scheme.error,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: 54.r,
                      height: 54.r,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: scheme.primary,
                        size: 27.r,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Upload Prescription',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'PDF, JPG, JPEG or PNG',
                      style: TextStyle(
                        fontSize: 10.8.sp,
                        color: scheme.onSurface.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _submitPrescription() async {
    final medicationState = ref.read(medicationViewModelProvider);

    final enrollee = medicationState.selectedBeneficiary;

    if (enrollee == null) {
      _showLocalError('Unable to load your enrollee profile.');

      return;
    }

    if (_prescriptionFilePath == null || _prescriptionFileName == null) {
      _showLocalError('Please upload a prescription.');

      return;
    }

    if (_selectedState == null) {
      _showLocalError('Please select a state.');

      return;
    }

    if (_selectedCity == null) {
      _showLocalError('Please select a city.');

      return;
    }

    if (_conditionController.text.trim().isEmpty) {
      _showLocalError('Please enter the condition or illness.');

      return;
    }

    final success = await ref
        .read(medicationViewModelProvider.notifier)
        .submitPrescription(
          beneficiaryId: enrollee.id,

          stateName: _selectedState!,

          city: _selectedCity!,

          conditionOrIllness: _conditionController.text.trim(),

          additionalComments: _commentsController.text.trim(),

          prescriptionPath: _prescriptionFilePath!,

          prescriptionName: _prescriptionFileName!,
        );

    if (!mounted) return;

    if (success) {
      _conditionController.clear();

      _commentsController.clear();

      setState(() {
        _prescriptionFilePath = null;

        _prescriptionFileName = null;
      });
    }
  }

  Widget _buildPrescriptionSuccessCard(
    ColorScheme scheme,
    MedicationState state,
  ) {
    final result = state.prescriptionResponse!;
    const successColor = Color(0xFF16A34A);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: successColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: successColor, size: 21.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request submitted',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Request: ${result.requestNumber}',
                  style: TextStyle(
                    fontSize: 10.8.sp,
                    color: scheme.onSurface.withValues(alpha: 0.58),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Status: ${result.status}',
                  style: TextStyle(
                    fontSize: 10.8.sp,
                    color: scheme.onSurface.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------

  // BENEFICIARIES

  // --------------------------------------------------

  Widget _buildEnrolleeCard(
    ColorScheme scheme,
    MedicationState medicationState,
    bool isDark,
  ) {
    if (medicationState.isLoading &&
        medicationState.selectedBeneficiary == null) {
      return Container(
        height: 80.h,
        decoration: _modernCardDecoration(scheme, isDark),
        child: Center(
          child: SizedBox(
            width: 22.r,
            height: 22.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              color: scheme.primary,
            ),
          ),
        ),
      );
    }

    final enrollee = medicationState.selectedBeneficiary;

    if (enrollee == null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(medicationViewModelProvider.notifier).getBeneficiaries();
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Ink(
            padding: EdgeInsets.all(16.r),
            decoration: _modernCardDecoration(scheme, isDark),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 21.r,
                    color: scheme.error,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Unable to load enrollee profile. Tap to retry.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.4,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = enrollee.fullName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.055),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: scheme.onPrimary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollee.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Member ID: ${enrollee.memberId}',
                  style: TextStyle(
                    fontSize: 10.8.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.52),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 18.r,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildEligibilityIndicator(

  //   ColorScheme scheme,

  //   BeneficiaryModel beneficiary,

  // ) {

  //   final eligible = beneficiary.isChronicEligible;

  //   final color = eligible ? scheme.primary : scheme.error;

  //   return Row(

  //     children: [

  //       Icon(

  //         eligible ? Icons.check_circle_outline : Icons.info_outline,

  //         color: color,

  //         size: 16,

  //       ),

  //       const SizedBox(width: 6),

  //       Expanded(

  //         child: Text(

  //           eligible

  //               ? 'Eligible for chronic medication refill'

  //               : 'Not currently eligible for chronic medication refill',

  //           style: TextStyle(

  //             color: color,

  //             fontSize: 12,

  //             fontWeight: FontWeight.w500,

  //           ),

  //         ),

  //       ),

  //     ],

  //   );

  // }

  // --------------------------------------------------

  // FILE PICKING

  // --------------------------------------------------

  void _showUploadModal() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    'Upload Prescription',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Choose where you want to upload the prescription from.',
                    style: TextStyle(
                      fontSize: 11.3.sp,
                      height: 1.4,
                      color: scheme.onSurface.withValues(alpha: 0.52),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _uploadTile(
                    icon: Icons.camera_alt_outlined,
                    text: 'Take a photo',
                    scheme: scheme,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  SizedBox(height: 8.h),
                  _uploadTile(
                    icon: Icons.photo_library_outlined,
                    text: 'Select from gallery',
                    scheme: scheme,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  SizedBox(height: 8.h),
                  _uploadTile(
                    icon: Icons.folder_open_outlined,
                    text: 'Select from files',
                    scheme: scheme,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickFile();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,

      imageQuality: 85,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _prescriptionFilePath = image.path;

      _prescriptionFileName = image.name;
    });
  }

  Future<void> _pickFile() async {
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
      _prescriptionFilePath = file.path;

      _prescriptionFileName = file.name;
    });
  }

  Widget _uploadTile({
    required IconData icon,
    required String text,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17.r),
        child: Container(
          padding: EdgeInsets.all(13.r),
          decoration: BoxDecoration(
            color: scheme.onSurface.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(17.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(icon, color: scheme.primary, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: scheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------

  // SEARCH SHEET

  // --------------------------------------------------

  void _showSearchSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<String> filtered = List.from(items);

        return StatefulBuilder(
          builder: (context, setModalState) {
            final scheme = Theme.of(context).colorScheme;

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: scheme.onSurface.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close_rounded, size: 21.r),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setModalState(() {
                            filtered = items
                                .where(
                                  (item) => item.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: scheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            fontSize: 11.5.sp,
                            color: scheme.onSurface.withValues(alpha: 0.40),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20.r,
                            color: scheme.onSurface.withValues(alpha: 0.45),
                          ),
                          filled: true,
                          fillColor: scheme.onSurface.withValues(alpha: 0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 1.2.r,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.50,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.055,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    title: Text(
                                      filtered[index],
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 17.r,
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.28,
                                      ),
                                    ),
                                    onTap: () {
                                      onSelected(filtered[index]);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------

  // REUSABLE UI

  // --------------------------------------------------

  Widget _buildHeroCard({
    required ColorScheme scheme,
    required IconData icon,
    required String eyebrow,
    required String title,
    required String description,
  }) {
    final gradientEnd = Color.lerp(scheme.primary, scheme.secondary, 0.27)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.20),
            blurRadius: 25.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55.r,
            right: -40.r,
            child: Container(
              width: 160.r,
              height: 160.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 20.w,
            bottom: -30.h,
            child: Icon(
              icon,
              size: 110.r,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    eyebrow,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    height: 1.18,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 285.w),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.8.sp,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
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
            fontSize: 17.sp,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.3.sp,
            height: 1.4,
            color: scheme.onSurface.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }

  Widget _buildFormLabel(
    String title,
    ColorScheme scheme, {
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: scheme.error),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectorTile({
    required String text,
    required IconData icon,
    required bool isSet,
    required ColorScheme scheme,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: _modernCardDecoration(scheme, isDark),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: isSet
                      ? scheme.primary.withValues(alpha: 0.09)
                      : scheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 19.r,
                  color: !enabled
                      ? scheme.onSurface.withValues(alpha: 0.25)
                      : isSet
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.42),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                    color: !enabled
                        ? scheme.onSurface.withValues(alpha: 0.30)
                        : isSet
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.44),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.r,
                color: scheme.onSurface.withValues(
                  alpha: enabled ? 0.35 : 0.18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ColorScheme scheme,
    required bool isDark,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: scheme.primary,
      style: TextStyle(
        color: scheme.onSurface,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(scheme, isDark, hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme scheme,
    bool isDark, {
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 19.r, color: scheme.primary),
      hintStyle: TextStyle(
        color: scheme.onSurface.withValues(alpha: 0.38),
        fontSize: 11.8.sp,
      ),
      filled: true,
      fillColor: scheme.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17.r),
        borderSide: BorderSide(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17.r),
        borderSide: BorderSide(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17.r),
        borderSide: BorderSide(color: scheme.primary, width: 1.3.r),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required ColorScheme scheme,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 21.r,
                height: 21.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.r,
                  color: scheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Icon(Icons.arrow_forward_rounded, size: 18.r),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCard(
    ColorScheme scheme,
    bool isDark, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: _modernCardDecoration(scheme, isDark),
      child: Column(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25.r, color: scheme.primary),
          ),
          SizedBox(height: 12.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.8.sp,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.56),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _modernCardDecoration(ColorScheme scheme, bool isDark) {
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(17.r),
      border: Border.all(
        color: scheme.onSurface.withValues(alpha: isDark ? 0.09 : 0.055),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
          blurRadius: 12.r,
          offset: Offset(0, 4.h),
        ),
      ],
    );
  }

  Widget _buildContactFooter(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 19.r,
              color: scheme.primary,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Need help with your request?\n',
                style: TextStyle(
                  fontSize: 10.8.sp,
                  height: 1.45,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
                children: [
                  TextSpan(
                    text: '02013300300',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '  •  '),
                  TextSpan(
                    text: 'pbm@oceanichealthng.com',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocalError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RefillMedicationDraft {
  int quantity;

  String dosage;

  _RefillMedicationDraft({this.quantity = 1, this.dosage = ''});
}
