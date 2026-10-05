import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/date_selction_screen.dart';
import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_alert_dialog.dart';
import 'package:oceanic/presentation/widgets/telemedicine_scaffold.dart';

class DoctorSelectionScreen extends StatefulWidget {
  const DoctorSelectionScreen({super.key});

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  final Set<String> _favoriteDoctorIds = {};

  final List<String> _specialties = [
    'All',
    'General Physician',
    'Pediatrician',
    'Dermatologist',
    'Gynecologist',
  ];

  static const List<Map<String, dynamic>> _doctors = [
    {
      'id': 'DOC-001',
      'name': 'Dr. Nkemjika Obi',
      'specialty': 'General Physician',
      'qualification': 'MBBS, FWACP • 8 yrs exp',
      'rating': 4.8,
      'reviews': 124,
      'clinic': 'Octodoc Tele-Clinic',
      'address': '350, Borno Way, Alagomeji, Yaba',
      'isAvailable': true,
      'nextSlot': 'Today, 2:30 PM',
    },
    {
      'id': 'DOC-002',
      'name': 'Dr. Ayodeji Faola',
      'specialty': 'Pediatrician',
      'qualification': 'MBBS, FMCPaed • 6 yrs exp',
      'rating': 4.5,
      'reviews': 89,
      'clinic': 'Octodoc Tele-Clinic',
      'address': '350, Borno Way, Alagomeji, Yaba',
      'isAvailable': true,
      'nextSlot': 'Today, 4:00 PM',
    },
    {
      'id': 'DOC-003',
      'name': 'Dr. Kelechi Igbokwe',
      'specialty': 'Dermatologist',
      'qualification': 'MBBS, DDV • 10 yrs exp',
      'rating': 4.9,
      'reviews': 210,
      'clinic': 'Octodoc Tele-Clinic',
      'address': '350, Borno Way, Alagomeji, Yaba',
      'isAvailable': false,
      'nextSlot': 'Tomorrow, 10:00 AM',
    },
    {
      'id': 'DOC-004',
      'name': 'Dr. Fatima Bello',
      'specialty': 'Gynecologist',
      'qualification': 'MBBS, FWACS • 12 yrs exp',
      'rating': 4.7,
      'reviews': 156,
      'clinic': 'Octodoc Tele-Clinic',
      'address': '350, Borno Way, Alagomeji, Yaba',
      'isAvailable': true,
      'nextSlot': 'Today, 5:15 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final agreed = await TelemedicineAlertDialog()
          .showTelemedicineConsentDialog(context);

      if (!agreed && mounted) {
        Navigator.pop(context);
      }
    });
  }

  // --- FILTERED DOCTOR LIST ---
  List<Map<String, dynamic>> get _filteredDoctors {
    return _doctors.where((doc) {
      // Specialty Filter
      if (_selectedSpecialty != 'All' &&
          doc['specialty'] != _selectedSpecialty) {
        return false;
      }

      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (doc['name'] as String).toLowerCase();
        final specialty = (doc['specialty'] as String).toLowerCase();
        final clinic = (doc['clinic'] as String).toLowerCase();

        if (!name.contains(query) &&
            !specialty.contains(query) &&
            !clinic.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _toggleFavorite(String doctorId) {
    setState(() {
      if (_favoriteDoctorIds.contains(doctorId)) {
        _favoriteDoctorIds.remove(doctorId);
      } else {
        _favoriteDoctorIds.add(doctorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final doctorList = _filteredDoctors;

    return TelemedicineScaffold(
      currentStep: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Text(
              'Select a Telemedicine Doctor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Connect via video consultation with registered physicians.',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: scheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search doctor by name or specialty...',
                hintStyle: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
                filled: true,
                fillColor:
                    scheme.surfaceContainerLow ?? scheme.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Specialty Filter Chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _specialties.length,
                itemBuilder: (context, index) {
                  final spec = _specialties[index];
                  final isSelected = _selectedSpecialty == spec;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedSpecialty = spec),
                      selectedColor: scheme.primary,
                      backgroundColor:
                          scheme.surfaceContainerLow ?? scheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? scheme.onPrimary
                            : scheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Doctor List
            if (doctorList.isEmpty)
              _buildEmptyState(scheme)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctorList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doctor = doctorList[index];
                  final isFav = _favoriteDoctorIds.contains(doctor['id']);

                  return _buildDoctorCard(
                    doctor: doctor,
                    isFavorite: isFav,
                    onFavoriteToggle: () => _toggleFavorite(doctor['id']),
                    onBookTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DateSelectionScreen(),
                        ),
                      );
                    },
                    scheme: scheme,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- DOCTOR CARD WIDGET ---
  Widget _buildDoctorCard({
    required Map<String, dynamic> doctor,
    required bool isFavorite,
    required VoidCallback onFavoriteToggle,
    required VoidCallback onBookTap,
    required ColorScheme scheme,
  }) {
    final bool isAvailable = doctor['isAvailable'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Online Indicator
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: scheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: scheme.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFF28A745)
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doctor['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? Colors.red
                                : scheme.onSurface.withValues(alpha: 0.4),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor['specialty'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      doctor['qualification'],
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rating Chip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${doctor['rating']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${doctor['reviews']} reviews)',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            height: 1,
          ),
          const SizedBox(height: 12),

          // Clinic & Slot Row
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Next slot: ${doctor['nextSlot']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),

              // Book Appointment Button
              ElevatedButton(
                onPressed: onBookTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Book Consult',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'No doctors match your query',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing your search term or specialty filter.',
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
}
