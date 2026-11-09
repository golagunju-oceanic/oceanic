import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';

import '../../domain/entities/doctor_patient.dart';
import '../widgets/doctor_ui.dart';
import 'doctor_patient_details_screen.dart';

class DoctorPatientsScreen extends ConsumerStatefulWidget {
  const DoctorPatientsScreen({super.key});
  @override
  ConsumerState<DoctorPatientsScreen> createState() =>
      _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends ConsumerState<DoctorPatientsScreen> {
  String _search = '';

  Future<void> _refresh() async {
    ref.invalidate(doctorPatientsProvider);
    try {
      await ref.read(doctorPatientsProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(doctorPatientsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My patients'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(doctorPatientsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _search = value.toLowerCase().trim()),
              decoration: const InputDecoration(
                hintText: 'Search name or member ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: DoctorLoadView<List<DoctorPatient>>(
              value: patients,
              onRetry: () => ref.invalidate(doctorPatientsProvider),
              builder: (all) {
                final visible = all
                    .where(
                      (patient) =>
                          _search.isEmpty ||
                          patient.fullName.toLowerCase().contains(_search) ||
                          (patient.memberId ?? '').toLowerCase().contains(
                            _search,
                          ),
                    )
                    .toList();
                if (visible.isEmpty)
                  return const DoctorEmptyState(
                    message: 'No matching patients',
                  );
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: visible.length,
                    itemBuilder: (context, index) => DoctorPatientCard(
                      patient: visible[index],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DoctorPatientDetailsScreen(
                            patientId: visible[index].id,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
