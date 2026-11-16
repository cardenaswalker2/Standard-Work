import 'package:flutter/material.dart';
import '../../data/models/app_models.dart';

class NotificationDetailDialog extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailDialog({super.key, required this.notification});

  static void show(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (_) => NotificationDetailDialog(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String tag;

    switch (notification.type) {
      case 'corporate_assignment':
        icon = Icons.campaign_rounded;
        color = const Color(0xFF7C3AED);
        tag = 'DIRECTIVA GENERAL (JAVIER JULIO)';
        break;
      case 'rejection':
        icon = Icons.warning_rounded;
        color = const Color(0xFFDC2626);
        tag = 'CORRECCIÓN DE EVIDENCIA SOLICITADA';
        break;
      case 'assignment':
      case 'plant_assignment':
        icon = Icons.assignment_turned_in_rounded;
        color = const Color(0xFF002F6C);
        tag = 'NUEVA ASIGNACIÓN DE ESTÁNDAR';
        break;
      case 'request_approved':
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF16A34A);
        tag = 'AUTORIZACIÓN DIRECTIVA';
        break;
      default:
        icon = Icons.notifications_active_rounded;
        color = const Color(0xFF0284C7);
        tag = 'NOVEDAD OPERATIVA';
    }

    final formattedDate =
        '${notification.timestamp.day.toString().padLeft(2, '0')}/${notification.timestamp.month.toString().padLeft(2, '0')}/${notification.timestamp.year} ${notification.timestamp.hour.toString().padLeft(2, '0')}:${notification.timestamp.minute.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                notification.body,
                style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
              ),
            ),
            const SizedBox(height: 16),

            // Guía para el trabajador
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta notificación ha sido registrada formalmente en tu historial operativo de la planta.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF0369A1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002F6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Entendido y Cerrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

