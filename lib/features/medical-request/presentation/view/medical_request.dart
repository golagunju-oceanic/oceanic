import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:oceanic/data/models/states.dart';

import 'package:oceanic/features/medical-request/data/models/beneficiary_model.dart';
import 'package:oceanic/features/medical-request/data/models/chorinc_medication_model.dart';
import 'package:oceanic/features/medical-request/data/models/refill_request_model.dart';

import 'package:oceanic/features/medical-request/presentation/provider/medication_provider.dart';
import 'package:oceanic/features/medical-request/presentation/state/medication_state.dart';

import 'package:oceanic/presentation/widgets/drawer.dart';
import 'package:oceanic/presentation/widgets/floating_app_bar.dart';

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

  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    _deliveryAddressController.dispose();
    _conditionController.dispose();
    _commentsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 84),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSegmentedControl(scheme),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildRequestRefillForm(scheme, medicationState)
                      : _buildNewPrescriptionForm(scheme, medicationState),
                ),
              ],
            ),

            FloatingAppBar(
              scrollController: _scrollController,
              text: 'Medication Request',
              onMenuTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? scheme.onPrimary
                      : scheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
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
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntroCard(
            scheme: scheme,
            icon: Icons.autorenew_rounded,
            title: 'Request medication refill',
            description:
                'Request a refill from your active chronic medication profile.',
          ),

          const SizedBox(height: 24),

          _buildFormLabel('Enrollee', scheme),

          const SizedBox(height: 8),

          _buildEnrolleeCard(scheme, medicationState),

          const SizedBox(height: 20),

          _buildFormLabel('State', scheme, required: true),

          const SizedBox(height: 8),

          _buildSelectorTile(
            text: _selectedState ?? 'Select State',
            icon: Icons.map_outlined,
            isSet: _selectedState != null,
            scheme: scheme,
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

          const SizedBox(height: 20),

          _buildFormLabel('City', scheme, required: true),

          const SizedBox(height: 8),

          _buildSelectorTile(
            text: _selectedCity ?? 'Select City',
            icon: Icons.location_on_outlined,
            isSet: _selectedCity != null,
            scheme: scheme,
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

          const SizedBox(height: 20),

          _buildFormLabel('Delivery Address', scheme, required: true),

          const SizedBox(height: 8),

          _buildTextField(
            controller: _deliveryAddressController,
            scheme: scheme,
            hint: 'Enter the full delivery address',
            icon: Icons.home_outlined,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildFormLabel('Chronic Medications', scheme)),

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
                  icon: Icon(Icons.refresh_rounded, color: scheme.primary),
                ),
            ],
          ),

          const SizedBox(height: 8),

          _buildChronicMedicationSection(scheme, medicationState),

          const SizedBox(height: 32),

          _buildSubmitButton(
            label: 'Submit Refill Request',
            scheme: scheme,
            isLoading: medicationState.isSubmitting,
            onPressed: _submitRefill,
          ),

          const SizedBox(height: 20),

          _buildContactFooter(scheme),
        ],
      ),
    );
  }

  Widget _buildChronicMedicationSection(
    ColorScheme scheme,
    MedicationState medicationState,
  ) {
    final enrollee = medicationState.selectedBeneficiary;

    if (enrollee == null) {
      return _buildEmptyCard(
        scheme,
        icon: Icons.person_outline_rounded,
        text: 'Unable to load enrollee information.',
      );
    }

    if (!enrollee.isChronicEligible) {
      return _buildEmptyCard(
        scheme,
        icon: Icons.info_outline_rounded,
        text: 'You are not currently eligible for chronic medication refills.',
      );
    }

    if (medicationState.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: _cardDecoration(scheme),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final medications = medicationState.chronicMedications;

    if (medications.isEmpty) {
      return _buildEmptyCard(
        scheme,
        icon: Icons.medication_outlined,
        text: 'No chronic medications were found for this enrollee.',
      );
    }

    return Column(
      children: medications.map((medication) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMedicationCard(medication, scheme),
        );
      }).toList(),
    );
  }

  Widget _buildMedicationCard(
    ChronicMedicationModel medication,
    ColorScheme scheme,
  ) {
    final medicationKey = medication.name;

    final isSelected = _selectedMedications.containsKey(medicationKey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primary.withValues(alpha: 0.05)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelected,
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

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  medication.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          if (isSelected) ...[
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: _selectedMedications[medicationKey]!.quantity
                        .toString(),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(scheme, hint: 'Quantity'),
                    onChanged: (value) {
                      final quantity = int.tryParse(value) ?? 0;

                      _selectedMedications[medicationKey]!.quantity = quantity;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 4,
                  child: TextFormField(
                    initialValue: _selectedMedications[medicationKey]!.dosage,
                    decoration: _inputDecoration(
                      scheme,
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
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntroCard(
            scheme: scheme,
            icon: Icons.description_outlined,
            title: 'New prescription',
            description:
                'Upload a valid prescription and tell us where the medication should be processed.',
          ),

          const SizedBox(height: 24),

          _buildFormLabel('Enrollee', scheme),

          const SizedBox(height: 8),

          _buildEnrolleeCard(scheme, medicationState),

          const SizedBox(height: 20),

          _buildFormLabel(
            'Prescription Document / Photo',
            scheme,
            required: true,
          ),

          const SizedBox(height: 8),

          _buildPrescriptionUpload(scheme),

          const SizedBox(height: 20),

          _buildFormLabel('State', scheme, required: true),

          const SizedBox(height: 8),

          _buildSelectorTile(
            text: _selectedState ?? 'Select State',
            icon: Icons.map_outlined,
            isSet: _selectedState != null,
            scheme: scheme,
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

          const SizedBox(height: 20),

          _buildFormLabel('City / Location', scheme, required: true),

          const SizedBox(height: 8),

          _buildSelectorTile(
            text: _selectedCity ?? 'Select City',
            icon: Icons.location_on_outlined,
            isSet: _selectedCity != null,
            scheme: scheme,
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

          const SizedBox(height: 20),

          _buildFormLabel('Condition / Illness', scheme, required: true),

          const SizedBox(height: 6),

          Text(
            'Specify the illness or medical condition this prescription is for.',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 10),

          _buildTextField(
            controller: _conditionController,
            scheme: scheme,
            hint: 'e.g. Malaria, hypertension',
            icon: Icons.health_and_safety_outlined,
          ),

          const SizedBox(height: 20),

          _buildFormLabel('Additional Comments', scheme),

          const SizedBox(height: 8),

          _buildTextField(
            controller: _commentsController,
            scheme: scheme,
            hint: 'Enter any extra instructions or notes for the pharmacist...',
            maxLines: 4,
          ),

          const SizedBox(height: 28),

          _buildSubmitButton(
            label: 'Submit Prescription Request',
            scheme: scheme,
            isLoading: medicationState.isSubmitting,
            onPressed: _submitPrescription,
          ),

          if (medicationState.prescriptionResponse != null) ...[
            const SizedBox(height: 16),
            _buildPrescriptionSuccessCard(scheme, medicationState),
          ],

          const SizedBox(height: 20),

          _buildContactFooter(scheme),
        ],
      ),
    );
  }

  Widget _buildPrescriptionUpload(ColorScheme scheme) {
    final hasFile = _prescriptionFilePath != null;

    return InkWell(
      onTap: _showUploadModal,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: hasFile
              ? scheme.primary.withValues(alpha: 0.06)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: hasFile
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _prescriptionFileName ?? 'Prescription',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tap to replace file',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.5),
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
                    icon: Icon(Icons.close_rounded, color: scheme.error),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: scheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Prescription',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF, JPG, JPEG or PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request submitted',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Request: ${result.requestNumber}',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'Status: ${result.status}',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(alpha: 0.7),
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
  ) {
    if (medicationState.isLoading &&
        medicationState.selectedBeneficiary == null) {
      return Container(
        height: 76,
        decoration: _cardDecoration(scheme),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final enrollee = medicationState.selectedBeneficiary;

    if (enrollee == null) {
      return InkWell(
        onTap: () {
          ref.read(medicationViewModelProvider.notifier).getBeneficiaries();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(scheme),
          child: Row(
            children: [
              Icon(Icons.refresh_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Unable to load enrollee profile. Tap to retry.'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline_rounded, color: scheme.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollee.fullName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Member ID: ${enrollee.memberId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.verified_user_outlined, color: scheme.primary, size: 22),
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
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
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

                const SizedBox(height: 12),

                _uploadTile(
                  icon: Icons.camera_alt_outlined,
                  text: 'Take a photo',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),

                _uploadTile(
                  icon: Icons.photo_library_outlined,
                  text: 'Select from gallery',
                  scheme: scheme,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),

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
    return ListTile(
      onTap: onTap,
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
      trailing: Icon(
        Icons.chevron_right,
        color: scheme.onSurface.withValues(alpha: 0.4),
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
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        List<String> filtered = List.from(items);

        return StatefulBuilder(
          builder: (context, setModalState) {
            final scheme = Theme.of(context).colorScheme;

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.70,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 16),

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
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: scheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) {
                                return Divider(
                                  height: 1,
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                );
                              },
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(filtered[index]),
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
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------
  // REUSABLE UI
  // --------------------------------------------------

  Widget _buildIntroCard({
    required ColorScheme scheme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          fontSize: 14,
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: _cardDecoration(scheme),
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
                      : scheme.onSurface.withValues(alpha: 0.45),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required ColorScheme scheme,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: _inputDecoration(scheme, hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme scheme, {
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      hintStyle: TextStyle(
        color: scheme.onSurface.withValues(alpha: 0.4),
        fontSize: 13,
      ),
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
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
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.onPrimary,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyCard(
    ColorScheme scheme, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(scheme),
      child: Column(
        children: [
          Icon(icon, size: 30, color: scheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  Widget _buildContactFooter(ColorScheme scheme) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Need help with your request? Contact ',
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
              ),
            ),
            const TextSpan(text: ' or email '),
            TextSpan(
              text: 'pbm@oceanichealthng.com',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
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
