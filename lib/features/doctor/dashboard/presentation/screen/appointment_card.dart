import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.time,
    required this.type,
    required this.status,
    this.onTap,
  });

  final String patientName;
  final String time;
  final String type;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bool isVideo = type == 'Video Consultation';
    final bool isPending = status == 'Pending';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVideo
                    ? Icons.videocam_outlined
                    : Icons.phone_outlined,
                color: scheme.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: scheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Flexible(
                        child: Text(
                          isVideo ? 'Video' : 'Audio',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isPending
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isPending
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}