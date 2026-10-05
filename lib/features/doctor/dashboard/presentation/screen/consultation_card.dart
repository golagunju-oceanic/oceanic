import 'package:flutter/material.dart';

class ConsultationCard extends StatelessWidget {
  const ConsultationCard({
    super.key,
    required this.patientName,
    required this.type,
    required this.time,
    this.date,
    this.status,
    this.onTap,
    this.onStart,
  });

  final String patientName;
  final String type;
  final String time;
  final String? date;
  final String? status;
  final VoidCallback? onTap;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bool isUpcoming = status == 'Upcoming';
    final bool isVideo = type == 'Video Consultation';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient information
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person_outline, color: scheme.primary),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (status != null) _buildStatusBadge(scheme, status!),
                ],
              ),

              const SizedBox(height: 16),

              // Date and time
              Row(
                children: [
                  if (date != null) ...[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      date!,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(width: 20),
                  ],

                  Icon(
                    Icons.access_time_outlined,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              // Start consultation button
              if (isUpcoming && onStart != null) ...[
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStart,
                    icon: Icon(
                      isVideo ? Icons.videocam_outlined : Icons.phone_outlined,
                    ),
                    label: Text(
                      isVideo
                          ? 'Start Video Consultation'
                          : 'Start Audio Consultation',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme scheme, String status) {
    final bool isUpcoming = status == 'Upcoming';

    final Color backgroundColor = isUpcoming
        ? scheme.primary.withValues(alpha: 0.1)
        : scheme.secondary.withValues(alpha: 0.1);

    final Color textColor = isUpcoming ? scheme.primary : scheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
