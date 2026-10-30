import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/excel_schedule_models.dart';

class ExcelActivityDetailModal extends StatelessWidget {
  final ExcelScheduleActivity activity;

  const ExcelActivityDetailModal({super.key, required this.activity});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Operación y Ejecución':
        return const Color(0xFF006DB2);
      case 'Resultados y Productividad':
        return const Color(0xFF2E7D32);
      case 'Liderazgo y Desarrollo de Personas':
        return const Color(0xFFE65100);
      case 'Proyectos y Mejora Continua':
        return const Color(0xFF0288D1);
      case 'Calidad e Inocuidad':
        return const Color(0xFF7B1FA2);
      case 'Seguridad':
        return const Color(0xFFD32F2F);
      case 'Administración':
        return const Color(0xFF546E7A);
      default:
        return AppColors.azul;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(activity.category);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra superior
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borde,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Encabezado con categoría e indicador de fijación
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: catColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activity.category,
                        style: TextStyle(
                          color: catColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (activity.isFixed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.azul.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 12, color: AppColors.azul),
                        SizedBox(width: 4),
                        Text(
                          'Actividad Fija',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Nombre de la Actividad
            Text(
              activity.activityName,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.txt,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            const Divider(height: 1, color: AppColors.borde),
            const SizedBox(height: 16),

            // Información de Horario y Programación
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Programación',
              value: 'Semana ${activity.weekNumber} · ${activity.dayName}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time,
              title: 'Horario del Evento',
              value: '${activity.timeStart} a ${activity.timeEnd} (${activity.durationMinutes} minutos)',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person_outline,
              title: 'Responsable',
              value: 'Yonny López (Jefe de Planta / Operaciones Extrusa)',
            ),
            const SizedBox(height: 16),

            // Procedencia y Trazabilidad en el Libro Excel
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.table_chart_outlined, size: 16, color: AppColors.azul2),
                      SizedBox(width: 8),
                      Text(
                        'Datos de Origen del Excel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azul,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Archivo: ST - WR YONNY LOPEZ.xlsb\n'
                    '• Hoja: ${activity.excelSheet}\n'
                    '• Celda exacta: ${activity.excelCell} (Fila ${activity.excelRow}, Columna ${activity.excelCol})\n'
                    '• Nombre original: "${activity.originalName}"',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gris,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azul,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.azul2),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gris,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.txt,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
