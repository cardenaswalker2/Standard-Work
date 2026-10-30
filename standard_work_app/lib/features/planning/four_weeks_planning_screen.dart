import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/standard_work_provider.dart';
import 'excel_activity_detail_modal.dart';

class FourWeeksPlanningScreen extends StatelessWidget {
  const FourWeeksPlanningScreen({super.key});

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
    final provider = context.watch<StandardWorkProvider>();
    final activities = provider.filteredExcelActivities;
    final categories = ['Todas', ...provider.categoryDistributions.map((c) => c.categoria)];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.gradienteHeader,
          ),
        ),
        title: const Text(
          'Planificación 4 Semanas · Excel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Detalles del Libro',
            onPressed: () => _showBookSummaryDialog(context, provider),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner de Identidad del Responsable Operativo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.azul.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'YL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.azul,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yonny López · ST - WR YONNY LOPEZ.xlsb',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.txt,
                        ),
                      ),
                      Text(
                        'Jefe de Planta / Operaciones Extrusa · 270 actividades programadas',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gris,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borde),

          // Selector de las 4 Semanas
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildWeekButton(context, provider, week: 1, label: 'Semana 1'),
                const SizedBox(width: 6),
                _buildWeekButton(context, provider, week: 2, label: 'Semana 2'),
                const SizedBox(width: 6),
                _buildWeekButton(context, provider, week: 3, label: 'Semana 3'),
                const SizedBox(width: 6),
                _buildWeekButton(context, provider, week: 4, label: 'Semana 4'),
              ],
            ),
          ),

          // Selector de Días de la Semana (Lunes a Viernes o Todos)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDayChip(provider, 0, 'Todos'),
                  const SizedBox(width: 6),
                  _buildDayChip(provider, 1, 'Lun'),
                  const SizedBox(width: 6),
                  _buildDayChip(provider, 2, 'Mar'),
                  const SizedBox(width: 6),
                  _buildDayChip(provider, 3, 'Mié'),
                  const SizedBox(width: 6),
                  _buildDayChip(provider, 4, 'Jue'),
                  const SizedBox(width: 6),
                  _buildDayChip(provider, 5, 'Vie'),
                ],
              ),
            ),
          ),

          // Buscador y Filtro de Categoría
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borde),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: AppColors.gris),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => provider.setExcelSearchQuery(val),
                            decoration: const InputDecoration(
                              hintText: 'Buscar actividad...',
                              hintStyle: TextStyle(fontSize: 12, color: AppColors.gris),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Menú de Categorías
                PopupMenuButton<String>(
                  initialValue: provider.excelSelectedCategory,
                  onSelected: (cat) => provider.setExcelSelectedCategory(cat),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.azul.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.azul.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 16, color: AppColors.azul),
                        const SizedBox(width: 4),
                        Text(
                          provider.excelSelectedCategory == 'Todas'
                              ? 'Categoría'
                              : (provider.excelSelectedCategory.length > 9
                                  ? '${provider.excelSelectedCategory.substring(0, 9)}...'
                                  : provider.excelSelectedCategory),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return categories.map((cat) {
                      return PopupMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borde),

          // Contador de Resultados
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.bg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semana ${provider.excelSelectedWeek} · ${activities.length} actividades programadas',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gris,
                  ),
                ),
                Text(
                  'Original XLSB',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.azul2.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Lista de Actividades
          Expanded(
            child: activities.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron actividades para este filtro.',
                      style: TextStyle(color: AppColors.gris, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final item = activities[index];
                      final catColor = _getCategoryColor(item.category);

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ExcelActivityDetailModal(activity: item),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borde),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Franja de Horario
                              Container(
                                width: 56,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.bg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      item.timeStart,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.azul,
                                      ),
                                    ),
                                    Text(
                                      item.timeEnd,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.gris,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Contenido Principal
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: catColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: catColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${item.dayName} · S${item.weekNumber}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.gris,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (item.isFixed)
                                          const Icon(Icons.lock, size: 12, color: AppColors.azul2),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.activityName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.txt,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Celda Excel: ${item.excelCell}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.gris.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 18, color: AppColors.gris),
                            ],
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

  Widget _buildWeekButton(
    BuildContext context,
    StandardWorkProvider provider, {
    required int week,
    required String label,
  }) {
    final isSelected = provider.excelSelectedWeek == week;
    final count = provider.countActivitiesForWeek(week);

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setExcelSelectedWeek(week),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.azul : AppColors.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.azul : AppColors.borde,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.txt,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count act.',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.gris,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(StandardWorkProvider provider, int dayIndex, String label) {
    final isSelected = provider.excelSelectedDay == dayIndex;

    return GestureDetector(
      onTap: () => provider.setExcelSelectedDay(dayIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.azul2 : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.azul2 : AppColors.borde,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.txt,
          ),
        ),
      ),
    );
  }

  void _showBookSummaryDialog(BuildContext context, StandardWorkProvider provider) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.azul),
              SizedBox(width: 10),
              Text('Resumen del Archivo Excel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Archivo: ST - WR YONNY LOPEZ.xlsb\n'
                  'Responsable: Yonny López (Jefe de Planta)\n'
                  'Área: Planta Extrusa · Darnel Group\n'
                  'Total Semanas: 4 semanas completas\n'
                  'Total Registros: 270 actividades programadas\n\n'
                  'Desglose por semana:\n'
                  '• Semana 1: 70 actividades\n'
                  '• Semana 2: 68 actividades\n'
                  '• Semana 3: 67 actividades\n'
                  '• Semana 4: 65 actividades\n\n'
                  'Distribución Oficial de Tiempos:\n'
                  '• Operación y Ejecución: 28%\n'
                  '• Resultados y Productividad: 18%\n'
                  '• Liderazgo y Personas: 15%\n'
                  '• Proyectos y Mejora: 11%\n'
                  '• Calidad e Inocuidad: 9%\n'
                  '• Seguridad: 5%\n'
                  '• Administración: 12%\n'
                  '• Espacios Libres: 2%',
                  style: TextStyle(fontSize: 12, color: AppColors.txt, height: 1.45),
                ),
                const SizedBox(height: 12),
                if (provider.followupTasks.isNotEmpty) ...[
                  const Text(
                    'Temas de Seguimiento (Hoja Actividades):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.azul),
                  ),
                  const SizedBox(height: 4),
                  ...provider.followupTasks.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${t.tema.split('\n').first} (${t.responsable.trim()})',
                          style: const TextStyle(fontSize: 11, color: AppColors.gris),
                        ),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul)),
            ),
          ],
        );
      },
    );
  }
}
