import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/constants/app_colors.dart';

import 'package:oceanic/presentation/widgets/drawer.dart';

class MedicalRequest extends ConsumerStatefulWidget {
  const MedicalRequest({super.key});

  @override
  ConsumerState<MedicalRequest> createState() => _MedicalRequestState();
}

class _MedicalRequestState extends ConsumerState<MedicalRequest> {
  bool _isSelected = true;
  String? selectedState;
  // String? selectedState2;
  String? selectedCity;
  @override
  Widget build(BuildContext context) {
    const List<String> nigerianStates = [
      'Abia',
      'Adamawa',
      'Akwa Ibom',
      'Anambra',
      'Bauchi',
      'Bayelsa',
      'Benue',
      'Borno',
      'Cross River',
      'Delta',
      'Ebonyi',
      'Edo',
      'Ekiti',
      'Enugu',
      'FCT Abuja',
      'Gombe',
      'Imo',
      'Jigawa',
      'Kaduna',
      'Kano',
      'Katsina',
      'Kebbi',
      'Kogi',
      'Kwara',
      'Lagos',
      'Nasarawa',
      'Niger',
      'Ogun',
      'Ondo',
      'Osun',
      'Oyo',
      'Plateau',
      'Rivers',
      'Sokoto',
      'Taraba',
      'Yobe',
      'Zamfara',
    ];
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
                            ? const Color(0xFF2D2D8E)
                            : const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'New Prescription',
                        style: TextStyle(
                          color: !_isSelected ? Colors.white : Colors.black54,
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
                            ? const Color(0xFF2D2D8E)
                            : const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Request Refill',
                        style: TextStyle(
                          color: _isSelected ? Colors.white : Colors.black54,
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

          // Content
          Expanded(
            child: _isSelected
                ? _requestRefill()
                : _newPrescribtion(
                    context,
                    nigerianStates,
                    selectedState,
                    (value) => setState(() => selectedState = value),
                    selectedCity,
                    (value) => setState(() => selectedCity = value),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _newPrescribtion(
  BuildContext context,
  List<String> states,
  String? selectedState,

  Function(String) onStateSelected,
  String? selectedCity,
  Function(String) onCitySelected,
) {
  return Padding(
    padding: EdgeInsets.all(10),
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
                      margin: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _uploadOption(Icons.camera_alt, "Take a photo"),
                          _uploadOption(
                            Icons.photo_library,
                            "Select from gallery",
                          ),
                          _uploadOption(Icons.folder, "Select from files"),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(5),
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kNavyBlue.withValues(alpha: 0.2),
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [Icon(Icons.upload_file), Text("Upload Files ")],
              ),
            ),
          ),
          Text("Select state", style: TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                List<String> filteredStates = List.from(states);

                return StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      height: 600,
                      child: Column(
                        children: [
                          SearchBar(
                            hintText: 'Search state',
                            leading: Icon(Icons.search),
                            onChanged: (value) {
                              setState(() {
                                filteredStates = states
                                    .where(
                                      (state) => state.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredStates.length,
                              itemBuilder: (context, index) => ListTile(
                                title: Text(filteredStates[index]),
                                onTap: () {
                                  onStateSelected(filteredStates[index]);
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
              margin: EdgeInsets.all(5),
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kNavyBlue.withValues(alpha: 0.2),
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(selectedState ?? "Select state"),
                  Spacer(),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          Text("Select city", style: TextStyle(color: Colors.grey)),
          // SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                List<String> filteredStates = List.from(states);

                return StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      height: 600,
                      child: Column(
                        children: [
                          SearchBar(
                            hintText: 'Search City',
                            leading: Icon(Icons.search),
                            onChanged: (value) {
                              setState(() {
                                filteredStates = states
                                    .where(
                                      (state) => state.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredStates.length,
                              itemBuilder: (context, index) => ListTile(
                                title: Text(filteredStates[index]),
                                onTap: () {
                                  onCitySelected(filteredStates[index]);
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
              margin: EdgeInsets.all(5),
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kNavyBlue.withValues(alpha: 0.2),
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(selectedCity ?? "Select City"),
                  Spacer(),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Text('Medication For'),
              Spacer(),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    builder: (context) {
                      return Container(
                        margin: EdgeInsets.all(20),
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        child: Text('Medication For'),
                      );
                    },
                    context: context,
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          Text(
            'Kindly select a condition or illness you want to be treated for.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          Text('Other comment', style: TextStyle(color: Colors.grey[700])),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type here',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Submit Request'),
            ),
          ),
          SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  "If you're having difficulty reqquesting for medication, Kindly contact ",
              style: TextStyle(color: Colors.grey[800]),
              children: [
                TextSpan(
                  text: '02013300300',
                  style: TextStyle(
                    color: kNavyBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' or send us a mail at '),
                TextSpan(
                  text: 'pbm@oceanichealthng.com',
                  style: TextStyle(
                    color: kNavyBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// Add these to your parent state class:
// bool _isRefill = true;
// String? _selectedBeneficiary;
// String? _selectedState;
// String? _selectedCity;

Widget _requestRefill() {
  // bool isRefill = true;
  String? selectedBeneficiary;
  String? selectedState;
  String? selectedCity;
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            // const SizedBox(height: 20),

            // Tab toggle

            // Name
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedBeneficiary,
                  hint: const Text(
                    'Please select a beneficiary',
                    style: TextStyle(color: Colors.black45, fontSize: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black45,
                  ),
                  items: ['John Doe', 'Jane Doe', 'Bob Smith']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 15)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedBeneficiary = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // State
            const Text(
              'Select State',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedState,
                  hint: const Text(
                    'Select',
                    style: TextStyle(color: Colors.black45, fontSize: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black45,
                  ),
                  items: ['Lagos', 'Abuja', 'Rivers', 'Kano']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 15)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedState = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // City
            const Text(
              'Select City',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.black45,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCity,
                        hint: const Text(
                          'Select a city',
                          style: TextStyle(color: Colors.black45, fontSize: 15),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black45,
                        ),
                        items: ['Ikeja', 'Lekki', 'Victoria Island', 'Yaba']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedCity = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Prescribed medications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prescribed Medications',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D8E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Kindly select a prescribed medication',
                style: TextStyle(color: Colors.black38, fontSize: 14),
              ),
            ),
            const SizedBox(height: 36),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    "If you're having difficulty reqquesting for medication, Kindly contact ",
                style: TextStyle(color: Colors.grey[800]),
                children: [
                  TextSpan(
                    text: '02013300300',
                    style: TextStyle(
                      color: kNavyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' or send us a mail at '),
                  TextSpan(
                    text: 'pbm@oceanichealthng.com',
                    style: TextStyle(
                      color: kNavyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    ),
  );
}

Widget _uploadOption(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: kNavyBlue),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
