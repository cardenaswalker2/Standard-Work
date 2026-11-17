import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/excel_service.dart';
import '../../data/models/app_models.dart';
import '../../core/widgets/notifications_sheet.dart';
import '../../core/widgets/activity_subtasks_modal.dart';
import '../../core/widgets/reprogramming_dialog.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/widgets/industrial_timer_modal.dart';
import '../../core/widgets/opl_sheet_modal.dart';
import '../../core/widgets/action_plan_dialog.dart';
import '../../core/widgets/meeting_record_dialog.dart';
import '../../core/widgets/activity_execution_modal.dart';
import '../../core/theme/app_theme.dart';
import '../login/login_screen.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  // 4 destinos principales del Operador:
  // 0: Mi Día (Actividades para cumplir - primera al entrar)
  // 1: Mi Jornada (Resumen y agenda)
  // 2: Planes (Planes de acción en pantalla dedicada)
  // 3: Indicadores (Métricas personales)
  int _currentScreenIndex = 0;

  String _selectedActivityFilter = 'Todas'; // 'Todas', 'Pendientes', 'Completadas'
  String _searchQuery = '';

  void _showNotifications(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSheet(
        notifications: provider.notifications,
        onMarkAsRead: (id) => provider.markNotificationAsRead(id),
        onMarkAllAsRead: () => provider.markAllNotificationsAsRead(),
      ),
    );
  }

  void _openSubtasksModal(BuildContext context, ActivityInstance instance) {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActivitySubtasksModal(
        instance: instance,
        onComplete: (data) async {
          for (final entry in data.entries) {
            final sid = entry.key;
            final map = entry.value;
            await provider.reportSubtaskExecution(
              instanceId: instance.id!,
              subtaskId: sid,
              photoPath: map['photo'] as String?,
              comment: map['comment'] as String?,
              measuredValue: map['measurement'] as double?,
            );
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Color(0xFF16A34A),
                content: Text('¡Evidencias de subtarea registradas exitosamente!'),
              ),
            );
          }
        },
      ),
    );
  }

  void _openReprogramming(BuildContext context, ActivityInstance instance) {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => ReprogrammingDialog(
        instance: instance,
        onConfirm: (toDay, motivo) async {
          final ok = await provider.requestReprogramming(
            instanceId: instance.id!,
            toDay: toDay,
            motivo: motivo,
          );
          if (context.mounted) {
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF0284C7),
                  content: Text('Actividad reprogramada exitosamente.'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFFDC2626),
                  content: Text('Esta actividad es fija y no admite reprogramación.'),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _handleCompleteActivity(BuildContext context, ActivityInstance item) async {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final error = await provider.completeActivityInstance(instanceId: item.id!);

    if (!context.mounted) return;

    if (error != null) {
      // Regla 6.3: Plan de Acción Obligatorio
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Requisito Obligatorio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            error,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final completed = await ActionPlanDialog.show(
                  context: context,
                  instance: item,
                  isMandatoryForActivity: true,
                );
                if (completed == true && context.mounted) {
                  // Reintentar completar
                  await provider.completeActivityInstance(instanceId: item.id!);
                }
              },
              icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
              label: const Text('Diligenciar Plan Ahora', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('¡Actividad completada y reportada a supervisión!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // HERO HEADER CORPORATIVO
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/darnel_planta.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF002F6C).withValues(alpha: 0.88),
                        const Color(0xFF002F6C).withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.engineering_rounded, color: Colors.white, size: 13),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'NIVEL 4 · OPERACIÓN',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Temporizador',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                icon: const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
                                onPressed: () {
                                  final inst = provider.tasksForSelectedDay.isNotEmpty
                                      ? provider.tasksForSelectedDay.first
                                      : (provider.instances.isNotEmpty ? provider.instances.first : null);
                                  if (inst != null) {
                                    IndustrialTimerModal.show(context, inst);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No hay actividades disponibles para el temporizador.')),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Lección en un Punto (OPL)',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                                onPressed: () {
                                  final inst = provider.tasksForSelectedDay.isNotEmpty
                                      ? provider.tasksForSelectedDay.first
                                      : (provider.instances.isNotEmpty ? provider.instances.first : null);
                                  if (inst != null) {
                                    OplSheetModal.show(context, inst);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No hay lecciones OPL disponibles.')),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Guía',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 20),
                                onPressed: () => HelpGuideModal.show(context),
                              ),
                              IconButton(
                                tooltip: 'Cerrar Sesión',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                onPressed: () {
                                  provider.logout();
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¡Hola, ${user?.nombre.split(' ').first ?? 'Colaborador'}!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${user?.cargo} · Planta ${user?.plantId} · ${user?.area}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // PANTALLAS (0: MI DÍA, 1: MI JORNADA, 2: PLANES, 3: INDICADORES)
          Expanded(
            child: IndexedStack(
              index: _currentScreenIndex,
              children: [
                _buildMiTrabajoActividades(context, provider),
                _buildMiJornadaScreen(context, provider),
                _buildMiTrabajoPlanes(context, provider),
                _buildOperatorIndicadores(context, provider),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentScreenIndex,
        onTap: (index) => setState(() => _currentScreenIndex = index),
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: const Color(0xFF86868B),
        backgroundColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: provider.tasksForSelectedDay.where((t) => !t.done).isNotEmpty,
              label: Text(
                '${provider.tasksForSelectedDay.where((t) => !t.done).length}',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
              child: const Icon(Icons.task_alt_rounded),
            ),
            label: 'Mi Día',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_rounded),
            label: 'Mi Jornada',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: provider.proPlans.where((p) => (p.responsable == provider.currentUser?.nombre || p.creadoPor == provider.currentUser?.id) && p.estado != 'Cumplido').isNotEmpty,
              label: Text(
                '${provider.proPlans.where((p) => (p.responsable == provider.currentUser?.nombre || p.creadoPor == provider.currentUser?.id) && p.estado != 'Cumplido').length}',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
              child: const Icon(Icons.fact_check_rounded),
            ),
            label: 'Planes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'Indicadores',
          ),
        ],
      ),
    );
  }

  // ========================================================
  // PANTALLA 1: MI JORNADA (INICIO DEL COLABORADOR)
  // ========================================================
  Widget _buildMiJornadaScreen(BuildContext context, StandardWorkProvider provider) {
    final allTasks = provider.tasksForSelectedDay;
    final totalCount = allTasks.length;
    final completedCount = allTasks.where((t) => t.done).length;
    final pendingCount = allTasks.where((t) => !t.done).length;
    final urgentCount = allTasks.where((t) => !t.done && (t.prioridad == 'Alta' || t.prioridad == 'Crítica')).length;

    final user = provider.currentUser;
    final myPlans = provider.proPlans.where((p) => (p.responsable == user?.nombre || p.creadoPor == user?.id) && p.estado != 'Cumplido').length;

    final days = [
      {'day': 1, 'name': 'Lunes'},
      {'day': 2, 'name': 'Martes'},
      {'day': 3, 'name': 'Miércoles'},
      {'day': 4, 'name': 'Jueves'},
      {'day': 5, 'name': 'Viernes'},
    ];

    final progressPct = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // SELECTOR DE DÍA
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.map((d) {
              final isSel = provider.selectedDay == d['day'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(d['name'] as String, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : const Color(0xFF334155))),
                  selected: isSel,
                  selectedColor: const Color(0xFF002F6C),
                  backgroundColor: Colors.white,
                  onSelected: (_) => provider.setSelectedDay(d['day'] as int),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // TARJETA DE PROGRESO DE LA JORNADA (ESTILO APPLE)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5EA)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressPct,
                      strokeWidth: 9,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(progressPct >= 1.0 ? const Color(0xFF16A34A) : const Color(0xFF00A3E0)),
                    ),
                    Text(
                      '${(progressPct * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF002F6C)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progreso de tu Jornada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount de $totalCount actividades cumplidas hoy',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progressPct >= 1.0 ? '¡Excelente trabajo! Jornada completada.' : 'Mantén el ritmo del estándar operacional.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // RESUMEN KPI
        Row(
          children: [
            Expanded(child: _buildMiniKpi('Hoy', '$totalCount', const Color(0xFF002F6C), Icons.today_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildMiniKpi('Pendientes', '$pendingCount', const Color(0xFF0284C7), Icons.schedule_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildMiniKpi('Urgentes', '$urgentCount', const Color(0xFFDC2626), Icons.priority_high_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildMiniKpi('Planes', '$myPlans', const Color(0xFFF59E0B), Icons.flag_rounded)),
          ],
        ),
        const SizedBox(height: 16),

        // ACCESOS RÁPIDOS
        const Text('Accesos Rápidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                label: 'Continuar Actividad',
                icon: Icons.play_arrow_rounded,
                color: const Color(0xFF002F6C),
                onTap: () => setState(() {
                  _currentScreenIndex = 0;
                  _selectedActivityFilter = 'Pendientes';
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'Completar Plan',
                icon: Icons.assignment_turned_in_rounded,
                color: const Color(0xFFD97706),
                onTap: () => setState(() {
                  _currentScreenIndex = 2;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // LISTA DE ACTIVIDADES PARA HOY
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Actividades Programadas para Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
            Text('$completedCount/$totalCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF002F6C))),
          ],
        ),
        const SizedBox(height: 8),

        if (allTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('No tienes actividades programadas para este día.', style: TextStyle(fontSize: 13, color: Colors.grey)),
          )
        else
          ...allTasks.map((t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: Icon(
                    t.done ? Icons.check_circle_rounded : (t.esRegistro ? Icons.edit_note_rounded : Icons.radio_button_unchecked_rounded),
                    color: t.done ? const Color(0xFF16A34A) : const Color(0xFF002F6C),
                  ),
                  title: Text(t.nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, decoration: t.done ? TextDecoration.lineThrough : null)),
                  subtitle: Text('${t.timeStart} - ${t.timeEnd} · ${t.area}', style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => setState(() {
                    _currentScreenIndex = 0;
                  }),
                ),
              )),
      ],
    );
  }

  // Nota: Mi Día y Planes ahora son pestañas independientes en el BottomNavigationBar.

  Widget _buildMiTrabajoActividades(BuildContext context, StandardWorkProvider provider) {
    final allTasks = provider.tasksForSelectedDay;

    final filtered = allTasks.where((t) {
      if (_selectedActivityFilter == 'Pendientes' && t.done) return false;
      if (_selectedActivityFilter == 'Completadas' && !t.done) return false;
      if (_searchQuery.isNotEmpty && !t.nombre.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // BUSCADOR Y FILTROS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar actividad...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Pendientes', style: TextStyle(fontSize: 11)),
                selected: _selectedActivityFilter == 'Pendientes',
                selectedColor: const Color(0xFF002F6C),
                labelStyle: TextStyle(color: _selectedActivityFilter == 'Pendientes' ? Colors.white : Colors.black),
                onSelected: (sel) => setState(() => _selectedActivityFilter = sel ? 'Pendientes' : 'Todas'),
              ),
            ],
          ),
        ),

        // LISTA DE TARJETAS DE TRABAJO
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('No hay actividades pendientes en este filtro', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    final isDone = item.done;
                    final borderColor = isDone ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
                    final bgTint = isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: borderColor.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Material(
                        color: bgTint.withValues(alpha: 0.42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: borderColor, width: 1.7),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            if (item.esRegistro) {
                              MeetingRecordDialog.show(context: context, instance: item);
                            } else {
                              ActivityExecutionModal.show(context: context, instance: item);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            // HEADER TARJETA
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                                ),
                                _buildStatusBadge(item),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${item.timeStart} - ${item.timeEnd} · Área: ${item.area}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            if (item.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(item.descripcion, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                            ],
                            const SizedBox(height: 10),

                            // BADGES DE MODALIDAD
                            Wrap(
                              spacing: 6,
                              children: [
                                if (item.esRegistro)
                                  _buildChipBadge('📝 Registro de Información / Reunión', const Color(0xFFEFF6FF), const Color(0xFF0284C7)),
                                if (item.planAccionObligatorio)
                                  _buildChipBadge('⚠️ Plan de Acción Obligatorio', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                                if (item.fija)
                                  _buildChipBadge('🔒 Estándar Fijo', const Color(0xFFF1F5F9), const Color(0xFF475569)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // PROGRESO DE SUBTAREAS
                            if (item.subtasksTotal > 0) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtareas: ${item.subtasksReported}/${item.subtasksTotal}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text('${(item.executionProgress * 100).toInt()}% Avance', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: item.executionProgress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(item.done ? const Color(0xFF16A34A) : const Color(0xFF00A3E0)),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // BOTONES DE ACCIÓN (RESPONSIVOS SIN DESBORDE)
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (!item.fija && !item.done)
                                  TextButton.icon(
                                    onPressed: () => _openReprogramming(context, item),
                                    icon: const Icon(Icons.update_rounded, size: 16),
                                    label: const Text('Reprogramar', style: TextStyle(fontSize: 11)),
                                  ),
                                if (item.esRegistro) ...[
                                  ElevatedButton.icon(
                                    onPressed: () => MeetingRecordDialog.show(context: context, instance: item),
                                    icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                                    label: const Text('Diligenciar Registro', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF007AFF),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                    ),
                                  ),
                                ] else if (item.subtasksTotal > 0) ...[
                                  OutlinedButton.icon(
                                    onPressed: () => _openSubtasksModal(context, item),
                                    icon: const Icon(Icons.checklist_rounded, size: 16),
                                    label: const Text('Checklist & Fotos', style: TextStyle(fontSize: 11)),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                    ),
                                  ),
                                ],
                                if (!item.done && !item.esRegistro)
                                  ElevatedButton.icon(
                                    onPressed: () => ActivityExecutionModal.show(context: context, instance: item),
                                    icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                                    label: const Text('Diligenciar & Finalizar', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF34C759),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMiTrabajoPlanes(BuildContext context, StandardWorkProvider provider) {
    final user = provider.currentUser;
    final myPlans = provider.proPlans.where((p) => p.responsable == user?.nombre || p.creadoPor == user?.id).toList();

    return myPlans.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No tienes planes de acción asignados actualmente', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myPlans.length,
            itemBuilder: (ctx, i) {
              final plan = myPlans[i];
              final isDone = plan.estado == 'Cumplido';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(plan.plan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              plan.estado,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF15803D) : const Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Fecha límite: ${plan.fechaCompromiso} · Área: ${plan.area}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      if (plan.activityNombre != null) ...[
                        const SizedBox(height: 4),
                        Text('Vinculado a: ${plan.activityNombre}', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                      ],
                      if (plan.descripcionSituacion != null && plan.descripcionSituacion!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(plan.descripcionSituacion!, style: const TextStyle(fontSize: 12)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Avance reportado:', style: TextStyle(fontSize: 11)),
                          Text('${(plan.porcentajeAvance * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: plan.porcentajeAvance,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(isDone ? const Color(0xFF16A34A) : const Color(0xFFF59E0B)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => ActionPlanDialog.show(context: context, existingPlan: plan),
                            icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                            label: Text(isDone ? 'Consultar Plan' : 'Actualizar Avance / Completar', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: isDone ? const Color(0xFF64748B) : const Color(0xFF002F6C)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildMiniKpi(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatusBadge(ActivityInstance item) {
    Color bg;
    Color fg;
    String label = item.state;
    if (item.done) {
      if (item.state == 'Validada') {
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
      } else {
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF0284C7);
      }
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildChipBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.bold)),
    );
  }

  // ========================================================
  // PANTALLA 4: INDICADORES DEL OPERADOR
  // ========================================================
  Widget _buildOperatorIndicadores(BuildContext context, StandardWorkProvider provider) {
    final user = provider.currentUser;
    final todayTasks = provider.tasksForSelectedDay;
    final todayDone = todayTasks.where((t) => t.done).length;
    final todayPct = todayTasks.isEmpty ? 0 : ((todayDone / todayTasks.length) * 100).round();

    final weekTasks = provider.instances.where((i) => i.userId == user?.id).toList();
    final weekDone = weekTasks.where((i) => i.done).length;
    final weekPending = weekTasks.length - weekDone;
    final weekPct = weekTasks.isEmpty ? 0 : ((weekDone / weekTasks.length) * 100).round();

    final fixedDone = weekTasks.where((i) => i.fija && i.done).length;
    final fixedTotal = weekTasks.where((i) => i.fija).length;
    final flexDone = weekTasks.where((i) => !i.fija && i.done).length;
    final flexTotal = weekTasks.where((i) => !i.fija).length;

    final myPlans = provider.proPlans.where((p) => p.responsable == user?.nombre || p.creadoPor == user?.id).toList();
    final myPlansClosed = myPlans.where((p) => p.estado == 'Cumplido').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const Text(
          'Mis Indicadores',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.4),
        ),
        const SizedBox(height: 4),
        Text(
          'Seguimiento personal de tu cumplimiento diario y semanal',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOpIndicatorCard(
                title: 'Hoy (${provider.selectedDay})',
                value: '$todayPct%',
                subtitle: '$todayDone de ${todayTasks.length} hechas',
                progress: todayTasks.isEmpty ? 0 : todayDone / todayTasks.length,
                color: todayPct >= 80 ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                icon: Icons.today_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOpIndicatorCard(
                title: 'Semana Total',
                value: '$weekPct%',
                subtitle: '$weekDone hechas · $weekPending pend.',
                progress: weekTasks.isEmpty ? 0 : weekDone / weekTasks.length,
                color: const Color(0xFF007AFF),
                icon: Icons.calendar_view_week_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOpIndicatorCard(
                title: 'Fijas / Flexibles',
                value: '$fixedDone/$fixedTotal',
                subtitle: 'Flexibles: $flexDone/$flexTotal',
                progress: fixedTotal == 0 ? 0 : fixedDone / fixedTotal,
                color: const Color(0xFF5856D6),
                icon: Icons.lock_clock_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOpIndicatorCard(
                title: 'Planes de Acción',
                value: '$myPlansClosed/${myPlans.length}',
                subtitle: '${myPlans.length - myPlansClosed} pendientes',
                progress: myPlans.isEmpty ? 0 : myPlansClosed / myPlans.length,
                color: const Color(0xFFFF9500),
                icon: Icons.fact_check_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E5EA)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Avance por Día de la Semana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
              const SizedBox(height: 12),
              for (final d in const [
                {'k': 1, 'n': 'Lunes'},
                {'k': 2, 'n': 'Martes'},
                {'k': 3, 'n': 'Miércoles'},
                {'k': 4, 'n': 'Jueves'},
                {'k': 5, 'n': 'Viernes'},
              ])
                Builder(builder: (_) {
                  final dTasks = weekTasks.where((t) => t.day == d['k']).toList();
                  final dDone = dTasks.where((t) => t.done).length;
                  final dPct = dTasks.isEmpty ? 0.0 : dDone / dTasks.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(d['n'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F))),
                            Text('$dDone / ${dTasks.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: dPct,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF2F2F7),
                            color: dPct >= 1.0 && dTasks.isNotEmpty ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpIndicatorCard({
    required String title,
    required String value,
    required String subtitle,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3A3A3C))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFFF2F2F7),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
