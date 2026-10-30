import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../core/widgets/darnel_logo.dart';
import '../../core/widgets/activity_card_widget.dart';
import '../../core/widgets/week_selector_widget.dart';
import '../../data/services/standard_work_provider.dart';
import '../activities/add_activity_sheet.dart';
import '../activities/move_activity_sheet.dart';
import '../activities/activity_detail_modal.dart';
import '../planning/four_weeks_planning_screen.dart';
import 'user_menu_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final user = provider.currentProfile;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final todayName = DateUtilsHelper.diasCompletos[provider.hoy - 1];
    final selectedDayName = DateUtilsHelper.diasCompletos[provider.selectedDay - 1];
    final formattedDate = DateUtilsHelper.formatFechaCompleta(DateTime.now());
    final currentMonthName = DateUtilsHelper.getNombreMes(DateTime.now());
    final currentYear = DateTime.now().year;

    final isViewingFuture = provider.selectedDay > provider.hoy;

    return Scaffold(
      body: Column(
        children: [
          // Header Corporativo con Gradiente Oficial
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 16,
              left: 18,
              right: 18,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.gradienteHeader,
            ),
            child: Column(
              children: [
                // Fila Superior: Logo + Título + Avatar
                Row(
                  children: [
                    const DarnelLogoWidget(compact: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Standard Work',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.nombre,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de Acceso Rápido a Planificación 4 Semanas del Excel
                    IconButton(
                      icon: const Icon(Icons.view_week_outlined, color: Colors.white, size: 22),
                      tooltip: 'Planificación 4 Semanas (Excel)',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FourWeeksPlanningScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    // Avatar clickeable
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const UserMenuSheet(),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.iniciales,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Tarjeta Traslúcida: Hoy y Progreso
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoy · $todayName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${provider.todayCompletedCount}/${provider.todayTotalCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'completadas',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Barra de Progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 6,
                    color: Colors.white.withOpacity(0.25),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: provider.todayProgressPercent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.barraVerde,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selector de Días L-V
          WeekSelectorWidget(
            selectedDay: provider.selectedDay,
            hoy: provider.hoy,
            allInstances: provider.instances,
            onSelectDay: (day) => provider.selectDay(day),
          ),

          // Título de la sección de actividades y Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.selectedDay == provider.hoy
                      ? 'ACTIVIDADES DE HOY'
                      : 'ACTIVIDADES DEL $selectedDayName${isViewingFuture ? ' · PROGRAMADAS' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gris,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  ' (${provider.filteredSelectedDayInstances.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gris,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Lista de Actividades
          Expanded(
            child: provider.filteredSelectedDayInstances.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, color: AppColors.gris.withOpacity(0.5), size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Sin actividades para este día',
                            style: TextStyle(
                              color: AppColors.gris,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 85),
                    itemCount: provider.filteredSelectedDayInstances.length,
                    itemBuilder: (context, index) {
                      final item = provider.filteredSelectedDayInstances[index];
                      final ind = provider.getIndicatorsForActivity(item.nombre);

                      return ActivityCardWidget(
                        instance: item,
                        isFuture: item.day > provider.hoy,
                        indicatorMonth: ind['m'] ?? 0,
                        indicatorYear: ind['y'] ?? 0,
                        currentMonthName: currentMonthName,
                        currentYear: currentYear,
                        onTap: () async {
                          final msg = await provider.toggleInstance(item.id!);
                          if (context.mounted && msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                duration: const Duration(milliseconds: 1800),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ActivityDetailModal(
                              instance: item,
                              indicatorMonth: ind['m'] ?? 0,
                              indicatorYear: ind['y'] ?? 0,
                              onSaveNotes: (obs, motivo) async {
                                await provider.saveInstanceNotes(item.id!, observaciones: obs, motivo: motivo);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Observación guardada')),
                                  );
                                }
                              },
                              onEdit: (newName, newDesc) async {
                                final msg = await provider.editActivity(item.activityId, newName, newDesc);
                                if (context.mounted && msg != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                }
                              },
                              onArchive: () async {
                                final msg = await provider.archiveActivity(item.activityId);
                                if (context.mounted && msg != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        onMove: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => MoveActivitySheet(
                              instance: item,
                              onMoveSelected: (newDay) async {
                                final msg = await provider.moveInstance(item.id!, newDay);
                                if (context.mounted && msg != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // Botón Flotante para Agregar Actividades
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradienteFab,
          boxShadow: [
            BoxShadow(
              color: AppColors.azul2.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddActivitySheet(
                  initialDay: provider.selectedDay,
                  initialArea: provider.currentProfile?.area,
                  onSave: ({
                    required nombre,
                    required descripcion,
                    required days,
                    required area,
                    required category,
                    required timeStart,
                    required timeEnd,
                    required isFixed,
                  }) async {
                    final msg = await provider.addNewActivity(
                      nombre: nombre,
                      descripcion: descripcion,
                      days: days,
                      area: area,
                      category: category,
                      timeStart: timeStart,
                      timeEnd: timeEnd,
                      isFixed: isFixed,
                    );
                    if (context.mounted && msg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: AppColors.azul,
                        ),
                      );
                    }
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(28),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
