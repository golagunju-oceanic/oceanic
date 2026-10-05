import 'package:flutter/material.dart';
import 'package:oceanic/features/doctor/dashboard/presentation/consultation_details_scree.dart';

import 'package:oceanic/features/doctor/dashboard/presentation/screen/consultation_card.dart';


class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() =>
      _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _consultations = [
    {
      'patientName': 'John Doe',
      'patientId': '110101111',
      'type': 'Video Consultation',
      'date': 'Today',
      'time': '10:30 AM',
      'status': 'Upcoming',
      'reason': 'General consultation',
    },
    {
      'patientName': 'Mary Johnson',
      'patientId': '110101112',
      'type': 'Video Consultation',
      'date': 'Today',
      'time': '12:00 PM',
      'status': 'Upcoming',
      'reason': 'Follow-up consultation',
    },
    {
      'patientName': 'David Williams',
      'patientId': '110101113',
      'type': 'Audio Consultation',
      'date': 'Today',
      'time': '2:30 PM',
      'status': 'Upcoming',
      'reason': 'Medication review',
    },
    {
      'patientName': 'Sarah Brown',
      'patientId': '110101114',
      'type': 'Video Consultation',
      'date': 'Yesterday',
      'time': '11:00 AM',
      'status': 'Completed',
      'reason': 'General consultation',
    },
    {
      'patientName': 'Michael Smith',
      'patientId': '110101115',
      'type': 'Video Consultation',
      'date': 'Yesterday',
      'time': '3:00 PM',
      'status': 'Completed',
      'reason': 'Follow-up consultation',
    },
  ];

  List<Map<String, dynamic>> get _filteredConsultations {
    if (_selectedFilter == 'All') {
      return _consultations;
    }

    return _consultations
        .where(
          (consultation) =>
              consultation['status'] == _selectedFilter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'Consultations',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(scheme),

          const SizedBox(height: 8),

          Expanded(
            child: _buildConsultationList(scheme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme scheme) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        children: [
          _buildFilterChip(
            label: 'All',
            scheme: scheme,
          ),

          const SizedBox(width: 10),

          _buildFilterChip(
            label: 'Upcoming',
            scheme: scheme,
          ),

          const SizedBox(width: 10),

          _buildFilterChip(
            label: 'Completed',
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ColorScheme scheme,
  }) {
    final selected = _selectedFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: scheme.primary,
      backgroundColor: scheme.surfaceContainer,
      labelStyle: TextStyle(
        color: selected
            ? scheme.onPrimary
            : scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildConsultationList(ColorScheme scheme) {
    final consultations = _filteredConsultations;

    if (consultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 50,
              color: scheme.onSurface.withValues(
                alpha: 0.3,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'No consultations found',
              style: TextStyle(
                fontSize: 16,
                color: scheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        30,
      ),
      itemCount: consultations.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final consultation = consultations[index];

        return ConsultationCard(
          patientName: consultation['patientName'],
          type: consultation['type'],
          date: consultation['date'],
          time: consultation['time'],
          status: consultation['status'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConsultationDetailsScreen(
                  consultation: consultation,
                ),
              ),
            );
          },
        );
      },
    );
  }
}