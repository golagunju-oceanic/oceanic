import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_booking_provider.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/sample/book_appointment_screen%20(2).dart';
import 'package:oceanic/features/Telemedicine/presentation/widgets/telemedicine_ui.dart';

import 'my_telemedicine_appointments_screen.dart';

/// Entry screen for the member's Telemedicine menu, after your existing consent step.
class AvailableDoctorsScreen extends ConsumerStatefulWidget {
  const AvailableDoctorsScreen({super.key});

  @override
  ConsumerState<AvailableDoctorsScreen> createState() =>
      _AvailableDoctorsScreenState();
}

class _AvailableDoctorsScreenState
    extends ConsumerState<AvailableDoctorsScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final data = ref.watch(availableTelemedicineDoctorsProvider);
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Telemedicine'),
        actions: [
          IconButton(
            tooltip: 'My consultations',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const MyTelemedicineAppointmentsScreen(),
              ),
            ),
            icon: const Icon(Icons.event_note_rounded),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(availableTelemedicineDoctorsProvider);
          try {
            await ref.read(availableTelemedicineDoctorsProvider.future);
          } catch (_) {}
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary,
                            scheme.primary.withValues(alpha: 0.82),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.video_call_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Care, wherever you are',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose an online doctor and book a 30-minute consultation, any time of day.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.87),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const MyTelemedicineAppointmentsScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: const Text('My appointments'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Find your doctor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) =>
                          setState(() => search = value.toLowerCase().trim()),
                      decoration: InputDecoration(
                        hintText: 'Search name or specialty',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: scheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: TelemedicineErrorPanel(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(availableTelemedicineDoctorsProvider),
                ),
              ),
              data: (doctors) {
                final visible = doctors
                    .where(
                      (doctor) =>
                          doctor.isActive &&
                          (doctor.fullName.toLowerCase().contains(search) ||
                              (doctor.specialty ?? '').toLowerCase().contains(
                                search,
                              ) ||
                              doctor.doctorCode.toLowerCase().contains(search)),
                    )
                    .toList();
                if (visible.isEmpty)
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: TelemedicineEmptyPanel(
                      icon: Icons.medical_services_outlined,
                      title: 'No doctors found',
                      subtitle: 'Try another search or check back later.',
                    ),
                  );
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final doctor = visible[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 0,
                          color: scheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: doctor.canBook
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          BookTelemedicineAppointmentScreen(
                                            doctor: doctor,
                                          ),
                                    ),
                                  )
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: scheme.primary.withValues(
                                      alpha: 0.11,
                                    ),
                                    child: Icon(
                                      Icons.medical_services_rounded,
                                      color: scheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor.fullName,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          doctor.specialty ??
                                              'Medical consultation',
                                          style: TextStyle(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          doctor.bookingId,
                                          style: TextStyle(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: doctor.canBook
                                                    ? const Color(0xFF22A06B)
                                                    : scheme.error,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              doctor.canBook
                                                  ? 'ONLINE · Accepting bookings 24/7'
                                                  : 'OFFLINE · Not accepting bookings',
                                              style: TextStyle(
                                                color: doctor.canBook
                                                    ? const Color(0xFF22A06B)
                                                    : scheme.error,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    doctor.canBook
                                        ? Icons.arrow_forward_ios_rounded
                                        : Icons.block_rounded,
                                    size: 16,
                                    color: doctor.canBook
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
