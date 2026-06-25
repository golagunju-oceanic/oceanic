import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/data/models/states.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class MedicalRequest extends ConsumerStatefulWidget {
  const MedicalRequest({super.key});

  @override
  ConsumerState<MedicalRequest> createState() => _MedicalRequestState();
}

class _MedicalRequestState extends ConsumerState<MedicalRequest> {
  bool _isSelected = true;
  String? selectedState;
  String? selectedCity;
  final _states = States();
  List<String> get nigerianStates =>
      _states.states.map((s) => s['name'] as String).toList();

  List<String> citiesFor(String? state) {
    if (state == null) return [];
    return List<String>.from(
      _states.states.firstWhere((s) => s['name'] == state)['cities'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      endDrawer: CustomDrawer(),
      appBar: AppBar(title: const Text('Medical Request')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSelected = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isSelected
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'New Prescription',
                        style: TextStyle(
                          color: !_isSelected
                              ? scheme.onPrimary
                              : scheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSelected = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isSelected
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Request Refill',
                        style: TextStyle(
                          color: _isSelected
                              ? scheme.onPrimary
                              : scheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSelected
                ? _requestRefill(scheme)
                : _newPrescription(scheme),
          ),
        ],
      ),
    );
  }

  Widget _newPrescription(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  sheetAnimationStyle: const AnimationStyle(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                  context: context,
                  builder: (context) => SizedBox(
                    height: 300.h,
                    width: double.infinity,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _uploadOption(
                              Icons.camera_alt,
                              'Take a photo',
                              scheme,
                            ),
                            _uploadOption(
                              Icons.photo_library,
                              'Select from gallery',
                              scheme,
                            ),
                            _uploadOption(
                              Icons.folder,
                              'Select from files',
                              scheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Files',
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select state',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  List<String> filteredStates = List.from(nigerianStates);
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      final modalScheme = Theme.of(context).colorScheme;
                      return Container(
                        padding: const EdgeInsets.all(20),
                        height: 600,
                        color: modalScheme.surface,
                        child: Column(
                          children: [
                            SearchBar(
                              hintText: 'Search state',
                              leading: const Icon(Icons.search),
                              onChanged: (value) {
                                setModalState(() {
                                  filteredStates = nigerianStates
                                      .where(
                                        (s) => s.toLowerCase().contains(
                                          value.toLowerCase(),
                                        ),
                                      )
                                      .toList();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredStates.length,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text(filteredStates[index]),
                                  onTap: () {
                                    setState(
                                      () =>
                                          selectedState = filteredStates[index],
                                    );
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
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedState ?? 'Select state',
                      style: TextStyle(
                        color: selectedState != null
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select city',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  List<String> filteredCities = List.from(
                    citiesFor(selectedState),
                  );
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      final modalScheme = Theme.of(context).colorScheme;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        height: 600,
                        color: modalScheme.surface,
                        child: Column(
                          children: [
                            SearchBar(
                              hintText: 'Search City',
                              leading: const Icon(Icons.search),
                              onChanged: (value) {
                                setModalState(() {
                                  filteredCities =
                                      citiesFor(
                                            selectedState,
                                          ) // not nigerianStates
                                          .where(
                                            (c) => c.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ),
                                          )
                                          .toList();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredCities.length,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text(filteredCities[index]),
                                  onTap: () {
                                    setState(
                                      () =>
                                          selectedCity = filteredCities[index],
                                    );
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
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCity ?? 'Select City',
                      style: TextStyle(
                        color: selectedCity != null
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Medication For',
                  style: TextStyle(color: scheme.onSurface),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        margin: const EdgeInsets.all(20),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Medication For',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, color: scheme.primary),
                ),
              ],
            ),
            Text(
              'Kindly select a condition or illness you want to be treated for.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 12),
            Text(
              'Other comment',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              style: TextStyle(color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Type here',
                hintStyle: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: scheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Submit Request'),
              ),
            ),
            const SizedBox(height: 20),
            _buildContactText(scheme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _requestRefill(ColorScheme scheme) {
    String? selectedBeneficiary;
    String? localState;
    String? localCity;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: StatefulBuilder(
        builder: (context, setLocalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedBeneficiary,
                    dropdownColor: scheme.surfaceContainer,
                    style: TextStyle(color: scheme.onSurface, fontSize: 15),
                    hint: Text(
                      'Please select a beneficiary',
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 15,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                    items: ['John Doe', 'Jane Doe', 'Bob Smith']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setLocalState(() => selectedBeneficiary = v),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select State',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: localState,
                    dropdownColor: scheme.surfaceContainer,
                    style: TextStyle(color: scheme.onSurface, fontSize: 15),
                    hint: Text(
                      'Select',
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 15,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                    items: nigerianStates
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setLocalState(() {
                      localState = v;
                      localCity = null; // reset city when state changes
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select City',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: localCity,
                          dropdownColor: scheme.surfaceContainer,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 15,
                          ),
                          hint: Text(
                            'Select a city',
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.4),
                              fontSize: 15,
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                          // fix
                          items: citiesFor(localState)
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: citiesFor(localState).isEmpty
                              ? null
                              : (v) => setLocalState(() => localCity = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prescribed Medications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: scheme.onPrimary, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Kindly select a prescribed medication',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.35),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildContactText(scheme),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactText(ColorScheme scheme) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            "If you're having difficulty requesting for medication, Kindly contact ",
        style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
        children: [
          TextSpan(
            text: '02013300300',
            style: TextStyle(
              color: scheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(
            text: ' or send us a mail at ',
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
          ),
          TextSpan(
            text: 'pbm@oceanichealthng.com',
            style: TextStyle(
              color: scheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadOption(IconData icon, String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 16, color: scheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
