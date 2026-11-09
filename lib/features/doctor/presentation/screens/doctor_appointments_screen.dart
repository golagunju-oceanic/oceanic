import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';
import 'package:oceanic/features/doctor/presentation/screens/doctor_appointment_details_screen%20(3).dart';

import '../../domain/entities/doctor_appointment.dart';
import '../widgets/doctor_ui.dart';

enum _AppointmentScope { all, today, upcoming }

class DoctorAppointmentsScreen extends ConsumerStatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  ConsumerState<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends ConsumerState<DoctorAppointmentsScreen> {
  _AppointmentScope _scope = _AppointmentScope.all;
  String _status = 'ALL';

  Future<void> _refresh() async {
    final provider = _scope == _AppointmentScope.today
        ? doctorTodayAppointmentsProvider
        : _scope == _AppointmentScope.upcoming
            ? doctorUpcomingAppointmentsProvider
            : doctorAppointmentsProvider;
    ref.invalidate(provider);
    try { await ref.read(provider.future); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = _scope == _AppointmentScope.today
        ? doctorTodayAppointmentsProvider
        : _scope == _AppointmentScope.upcoming
            ? doctorUpcomingAppointmentsProvider
            : doctorAppointmentsProvider;
    final appointments = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments'), actions: [
        IconButton(tooltip: 'Refresh', onPressed: () => ref.invalidate(provider),
            icon: const Icon(Icons.refresh)),
      ]),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            for (final scope in _AppointmentScope.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(scope == _AppointmentScope.all ? 'All' :
                      scope == _AppointmentScope.today ? 'Today' : 'Upcoming'),
                  selected: _scope == scope,
                  onSelected: (_) => setState(() { _scope = scope; _status = 'ALL'; }),
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status', isDense: true, border: OutlineInputBorder()),
            items: const ['ALL', 'PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'MISSED']
                .map((value) => DropdownMenuItem(value: value,
                    child: Text(value == 'ALL' ? 'All statuses' : DoctorFormat.status(value))))
                .toList(),
            onChanged: (value) => setState(() => _status = value ?? 'ALL'),
          ),
        ),
        Expanded(child: DoctorLoadView<List<DoctorAppointment>>(
          value: appointments,
          onRetry: () => ref.invalidate(provider),
          builder: (items) {
            final filtered = items.where((item) => _status == 'ALL' || item.status == _status).toList();
            if (filtered.isEmpty) return const DoctorEmptyState(message: 'No appointments match this filter');
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) => DoctorAppointmentCard(
                  appointment: filtered[index],
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => DoctorAppointmentDetailsScreen(appointmentId: filtered[index].id),
                  )),
                ),
              ),
            );
          },
        )),
      ]),
    );
  }
}
