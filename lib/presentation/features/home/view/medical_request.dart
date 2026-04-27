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
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSelected ? Colors.grey : kNavyBlue,
                  foregroundColor: _isSelected ? Colors.black : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital),
                    Text('New Prescription'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSelected = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSelected ? kNavyBlue : Colors.grey,
                  foregroundColor: _isSelected ? Colors.white : Colors.black,
                ),
                child: Row(
                  children: [Icon(Icons.health_and_safety), Text('Refill')],
                ),
              ),
            ],
          ),
          _isSelected
              ? Expanded(
                  child: _newPrescribtion(
                    context,
                    nigerianStates,
                    selectedState,
                    (value) {
                      setState(() {
                        selectedState = value;
                      });
                    },
                    null,
                  ),
                )
              : _requestRefill(),
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

Widget _requestRefill() {
  return Column(
    children: [DropdownButton(items: [], onChanged: (hello) {})],
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
