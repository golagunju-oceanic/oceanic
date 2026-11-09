import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/doctor/presentation/providers/doctor_providers%20(1).dart';
import '../../domain/entities/doctor_availability.dart';
import '../widgets/doctor_ui.dart';

class _AvailabilityDraft {
  const _AvailabilityDraft({
    required this.dayOfWeek,
    required this.start,
    required this.end,
  });
  final int dayOfWeek;
  final String start;
  final String end;
}

class DoctorAvailabilityScreen extends ConsumerStatefulWidget {
  const DoctorAvailabilityScreen({super.key});
  @override
  ConsumerState<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState
    extends ConsumerState<DoctorAvailabilityScreen> {
  String _clock(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  TimeOfDay _parseClock(String input, TimeOfDay fallback) {
    final parts = input.split(':');
    if (parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        hour < 0 ||
        hour > 23 ||
        minute == null ||
        minute < 0 ||
        minute > 59)
      return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<_AvailabilityDraft?> _showForm([DoctorAvailability? existing]) async {
    int day = existing?.dayOfWeek ?? 1;
    TimeOfDay start = _parseClock(
      existing?.startTime ?? '',
      const TimeOfDay(hour: 9, minute: 0),
    );
    TimeOfDay end = _parseClock(
      existing?.endTime ?? '',
      const TimeOfDay(hour: 17, minute: 0),
    );
    String? validation;
    return showDialog<_AvailabilityDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Add availability' : 'Edit availability',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: day,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      7,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(DoctorFormat.weekday(index)),
                      ),
                    ),
                    onChanged: (value) => setLocalState(() {
                      day = value ?? day;
                      validation = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start time'),
                    trailing: Text(start.format(context)),
                    onTap: () async {
                      final selection = await showTimePicker(
                        context: context,
                        initialTime: start,
                      );
                      if (selection != null && dialogContext.mounted) {
                        setLocalState(() {
                          start = selection;
                          validation = null;
                        });
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End time'),
                    trailing: Text(end.format(context)),
                    onTap: () async {
                      final selection = await showTimePicker(
                        context: context,
                        initialTime: end,
                      );
                      if (selection != null && dialogContext.mounted) {
                        setLocalState(() {
                          end = selection;
                          validation = null;
                        });
                      }
                    },
                  ),
                  if (validation != null)
                    Text(
                      validation!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final startText = _clock(start);
                  final endText = _clock(end);
                  if (startText.compareTo(endText) >= 0) {
                    setLocalState(
                      () =>
                          validation = 'End time must be later than start time',
                    );
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    _AvailabilityDraft(
                      dayOfWeek: day,
                      start: startText,
                      end: endText,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _mutate(
    Future<void> Function() operation,
    String success,
  ) async {
    try {
      await operation();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(DoctorFormat.error(error))));
    }
  }

  Future<void> _save([DoctorAvailability? existing]) async {
    final draft = await _showForm(existing);
    if (draft == null || !mounted) return;
    if (existing == null) {
      await _mutate(
        () => ref
            .read(doctorAvailabilityActionsProvider.notifier)
            .create(
              dayOfWeek: draft.dayOfWeek,
              startTime: draft.start,
              endTime: draft.end,
            ),
        'Availability created',
      );
    } else {
      await _mutate(
        () => ref
            .read(doctorAvailabilityActionsProvider.notifier)
            .update(
              availabilityId: existing.id,
              dayOfWeek: draft.dayOfWeek,
              startTime: draft.start,
              endTime: draft.end,
            ),
        'Availability updated',
      );
    }
  }

  Future<void> _delete(DoctorAvailability slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete availability?'),
        content: Text(
          'Remove ${DoctorFormat.weekday(slot.dayOfWeek)} ${slot.startTime}–${slot.endTime}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _mutate(
      () =>
          ref.read(doctorAvailabilityActionsProvider.notifier).delete(slot.id),
      'Availability deleted',
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(doctorAvailabilityProvider);
    try {
      await ref.read(doctorAvailabilityProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final availability = ref.watch(doctorAvailabilityProvider);
    final isSaving = ref.watch(doctorAvailabilityActionsProvider).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(doctorAvailabilityProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving ? null : () => _save(),
        icon: const Icon(Icons.add),
        label: const Text('Add slot'),
      ),
      body: DoctorLoadView<List<DoctorAvailability>>(
        value: availability,
        onRetry: () => ref.invalidate(doctorAvailabilityProvider),
        builder: (slots) {
          if (slots.isEmpty) {
            return const DoctorEmptyState(
              message: 'No availability configured. Tap Add slot to begin.',
              icon: Icons.event_busy_outlined,
            );
          }
          final sorted = [...slots]
            ..sort((a, b) {
              final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
              return byDay == 0 ? a.startTime.compareTo(b.startTime) : byDay;
            });
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
              children: [
                if (isSaving) const LinearProgressIndicator(),
                for (final slot in sorted)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.schedule_outlined),
                            title: Text(DoctorFormat.weekday(slot.dayOfWeek)),
                            subtitle: Text(
                              '${slot.startTime} – ${slot.endTime}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Edit availability',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: isSaving ? null : () => _save(slot),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Active'),
                                  value: slot.isActive,
                                  onChanged: isSaving
                                      ? null
                                      : (active) => _mutate(
                                          () => ref
                                              .read(
                                                doctorAvailabilityActionsProvider
                                                    .notifier,
                                              )
                                              .update(
                                                availabilityId: slot.id,
                                                isActive: active,
                                              ),
                                          active
                                              ? 'Availability enabled'
                                              : 'Availability disabled',
                                        ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: isSaving
                                    ? null
                                    : () => _delete(slot),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
