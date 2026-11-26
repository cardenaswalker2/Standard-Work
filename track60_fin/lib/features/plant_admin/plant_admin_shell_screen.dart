import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/ultra_report_service.dart';
import '../../data/models/app_models.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/theme/app_theme.dart';
import 'proplanes_screen.dart';
import '../login/login_screen.dart';
import '../../core/widgets/track60_charts.dart';
import '../../core/widgets/templates_modal.dart';

class PlantAdminShellScreen extends StatefulWidget {
  const PlantAdminShellScreen({super.key});

  @override
  State<PlantAdminShellScreen> createState() => _PlantAdminShellScreenState();
}

class _PlantAdminShellScreenState extends State<PlantAdminShellScreen> {
  int _currentTabIndex = 0;

  static const _darnelNavy = Color(0xFF002F6C);
  static const _bg = Color(0xFFF5F5F7);
  static const _sidebarBg = Color(0xFFECECEE);
  static const _border = Color(0xFFE5E5EA);
  static const _ink = Color(0xFF1D1D1F);
  static const _muted = Color(0xFF86868B);

  static const _navItems = [
    (label: 'Actividades', icon: Icons.add_task_rounded),
    (label: 'Tablero', icon: Icons.space_dashboard_rounded),
    (label: 'Equipo', icon: Icons.groups_rounded),
    (label: 'Planes', icon: Icons.fact_check_rounded),
    (label: 'Reportes', icon: Icons.analytics_rounded),
    (label: 'Corporativas', icon: Icons.campaign_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;
    final plant = provider.currentPlant;
    final isWide = MediaQuery.of(context).size.width >= 860;

    final bodyContent = IndexedStack(
      index: _currentTabIndex,
      children: [
        const _PlantAdminActivityCreatorTab(),
        _PlantAdminDashboardTab(onNavigateTab: (idx) => setState(() => _currentTabIndex = idx)),
        const _PlantAdminTeamTab(),
        const ProPlanesScreen(embedded: true),
        const _PlantAdminReportsTab(),
        const _PlantAdminCorporateAssignmentTab(),
      ],
    );

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          if (isWide)
            Container(
              width: 236,
              decoration: const BoxDecoration(
                color: _sidebarBg,
                border: Border(right: BorderSide(color: _border, width: 0.9)),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _darnelNavy,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.factory_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TRACK60', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _darnelNavy, letterSpacing: 0.3)),
                                Text(plant?.nombre ?? 'Admin de Planta', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _navItems.length,
                        itemBuilder: (context, i) {
                          final item = _navItems[i];
                          final active = _currentTabIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: active ? _darnelNavy : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(() => _currentTabIndex = i),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(item.icon, size: 18, color: active ? Colors.white : _ink),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                            color: active ? Colors.white : _ink,
                                          ),
                                        ),
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
                    const Divider(height: 1, color: _border),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: _darnelNavy.withValues(alpha: 0.12),
                            child: Text(user?.iniciales ?? 'AP', style: const TextStyle(color: _darnelNavy, fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.nombre ?? 'Admin de Planta', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
                                Text(plant?.codigo ?? 'Planta', style: const TextStyle(fontSize: 10.5, color: _muted)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cerrar Sesión',
                            icon: const Icon(Icons.logout_rounded, size: 18, color: _muted),
                            onPressed: () {
                              provider.logout();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: _border, width: 0.8)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: _darnelNavy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.factory_rounded, color: Colors.white, size: 12),
                                const SizedBox(width: 5),
                                Text(
                                  plant?.codigo.isNotEmpty == true ? plant!.codigo : 'PLANTA',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _navItems[_currentTabIndex].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3),
                                ),
                                Text(
                                  '${user?.nombre ?? 'Admin de Planta'} · ${plant?.nombre ?? 'Sede Darnel'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: _muted),
                                ),
                              ],
                            ),
                          ),
                          _headerIconBtn(
                            tooltip: 'Guía',
                            icon: Icons.help_outline_rounded,
                            onPressed: () => HelpGuideModal.show(context),
                          ),
                          const SizedBox(width: 6),
                          _headerIconBtn(
                            tooltip: 'Reportes',
                            icon: Icons.analytics_outlined,
                            onPressed: () => setState(() => _currentTabIndex = 4),
                          ),
                          if (!isWide) ...[
                            const SizedBox(width: 6),
                            _headerIconBtn(
                              tooltip: 'Cerrar Sesión',
                              icon: Icons.logout_rounded,
                              onPressed: () {
                                provider.logout();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: bodyContent),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _border, width: 0.8)),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentTabIndex,
                onTap: (index) => setState(() => _currentTabIndex = index),
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: _darnelNavy,
                unselectedItemColor: const Color(0xFF8E8E93),
                selectedLabelStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                type: BottomNavigationBarType.fixed,
                items: _navItems
                    .map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.label))
                    .toList(),
              ),
            ),
    );
  }

  Widget _headerIconBtn({required String tooltip, required IconData icon, required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: _darnelNavy, size: 18),
          ),
        ),
      ),
    );
  }
}

/// TAB 1: DASHBOARD Y KPIS DE PLANTA LOCAL CON FL_CHART
class _PlantAdminDashboardTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const _PlantAdminDashboardTab({this.onNavigateTab});

  @override
  State<_PlantAdminDashboardTab> createState() => _PlantAdminDashboardTabState();
}

class _PlantAdminDashboardTabState extends State<_PlantAdminDashboardTab> {
  int _subTab = 0;

  void _showTasksSheet(BuildContext context, List<ActivityInstance> list, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('$title (${list.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            if (list.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('Sin actividades en este filtro.')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final t = list[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(t.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: t.done ? const Color(0xFF34C759) : const Color(0xFFFF3B30), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text('${t.area} · ${t.timeStart}-${t.timeEnd}', style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final plantUsers = provider.usersForCurrentPlant;
    final operators = plantUsers.where((u) => u.isOperator).toList();
    final supervisors = plantUsers.where((u) => u.isSupervisor).toList();
    final instances = provider.instances;
    final plans = provider.proPlans;

    final totalTasks = instances.length;
    final reportedTasks = instances.where((i) => i.done).length;
    final complianceRate = totalTasks > 0 ? ((reportedTasks / totalTasks) * 100).toStringAsFixed(1) : '0.0';

    final todayTasks = provider.tasksForSelectedDay;
    final completedToday = todayTasks.where((i) => i.done).length;
    final totalToday = todayTasks.length;

    final altaTasks = instances.where((i) => i.prioridad.toLowerCase().contains('alta') || i.fija).length;
    final mediaTasks = instances.where((i) => i.prioridad.toLowerCase().contains('media') || (!i.fija && i.requierePlanAccion)).length;
    final bajaTasks = (instances.length - altaTasks - mediaTasks).clamp(0, 9999);

    final weeklyTrend = List.generate(5, (index) {
      final day = index + 1;
      final dayInst = instances.where((i) => i.day == day).toList();
      if (dayInst.isEmpty) return 0.0;
      final dayDone = dayInst.where((i) => i.done).length;
      return double.parse(((dayDone / dayInst.length) * 100).toStringAsFixed(1));
    });

    final completadasCount = instances.where((i) => i.done).length;
    final vencidasCount = instances.where((i) => !i.done && i.day < provider.selectedDay).length;
    final pendientesCount = (instances.length - completadasCount - vencidasCount).clamp(0, 9999);

    double realAxisPct(bool Function(ActivityInstance) test, double fallback) {
      final sub = instances.where(test).toList();
      if (sub.isEmpty) return fallback;
      return (sub.where((i) => i.done).length / sub.length) * 100.0;
    }

    final realGlobalPct = totalTasks > 0 ? (reportedTasks / totalTasks) * 100.0 : 0.0;
    final radarScores = {
      'Calidad': realAxisPct((i) => i.category.toLowerCase().contains('calidad') || i.area.toLowerCase().contains('calidad'), realGlobalPct),
      'Seguridad': realAxisPct((i) => i.category.toLowerCase().contains('ehs') || i.category.toLowerCase().contains('seguridad') || i.area.toLowerCase().contains('seguridad'), realGlobalPct),
      '5S Piso': provider.gembaLogs.isNotEmpty
          ? (provider.gembaLogs.first['score'] as num).toDouble()
          : realAxisPct((i) => i.nombre.toLowerCase().contains('5s') || i.category.toLowerCase().contains('5s'), realGlobalPct),
      'OEE': realAxisPct((i) => i.fija, realGlobalPct),
      'Disciplina': realGlobalPct,
    };

    final Map<String, List<ActivityInstance>> byArea = {};
    for (final i in instances) {
      final a = i.area.trim().isEmpty ? 'General' : i.area.trim();
      byArea.putIfAbsent(a, () => []).add(i);
    }
    final areaEntries = byArea.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    final usersById = {for (final u in plantUsers) u.id: u};
    final Map<String, List<ActivityInstance>> byOwner = {};
    for (final i in instances) {
      byOwner.putIfAbsent(i.userId, () => []).add(i);
    }
    final ownerEntries = byOwner.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    const dayLabels = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};
    final dayCounts = List.generate(6, (idx) {
      final d = idx + 1;
      final sub = instances.where((i) => i.day == d).toList();
      final done = sub.where((i) => i.done).length;
      return (day: d, done: done, pend: sub.length - done);
    });
    final maxDayY = dayCounts.fold<int>(4, (m, e) => [m, e.done, e.pend].reduce((a, b) => a > b ? a : b)).toDouble() + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _subTabBtn(0, 'Resumen', Icons.dashboard_outlined),
                _subTabBtn(1, 'Gráficas', Icons.bar_chart_rounded),
                _subTabBtn(2, 'Áreas', Icons.category_outlined),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_subTab == 0) ...[
            Row(
              children: [
                Expanded(
                  child: _build3DCard(
                    'Cumplimiento',
                    '$complianceRate%',
                    Icons.verified_rounded,
                    const Color(0xFF002F6C),
                    onTap: () => _showTasksSheet(context, instances, 'Actividades de Planta'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _build3DCard(
                    'Hoy',
                    '$completedToday/$totalToday',
                    Icons.today_rounded,
                    const Color(0xFF34C759),
                    onTap: () => _showTasksSheet(context, todayTasks, 'Actividades de Hoy'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _build3DCard(
                    'Colaboradores',
                    '${operators.length}',
                    Icons.groups_rounded,
                    const Color(0xFF007AFF),
                    onTap: () => widget.onNavigateTab?.call(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _build3DCard(
                    'Supervisores',
                    '${supervisors.length}',
                    Icons.shield_rounded,
                    const Color(0xFF5856D6),
                    onTap: () => widget.onNavigateTab?.call(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pulso Operativo (Toca para ver)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _pulseTile('Pendientes', '$pendientesCount', const Color(0xFF007AFF), () => _showTasksSheet(context, instances.where((i) => !i.done).toList(), 'Pendientes')),
                      const SizedBox(width: 8),
                      _pulseTile('Vencidas', '$vencidasCount', const Color(0xFFFF3B30), () => _showTasksSheet(context, instances.where((i) => !i.done && i.day < provider.selectedDay).toList(), 'Vencidas')),
                      const SizedBox(width: 8),
                      _pulseTile('Con Plan', '${instances.where((i) => i.requierePlanAccion || i.planAccionObligatorio).length}', const Color(0xFFFF9500), () => widget.onNavigateTab?.call(3)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => widget.onNavigateTab?.call(3),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Planes de Acción en Vivo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)))),
                        Text('Gestionar (${plans.length}) ›', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _pulseTile('Pendientes', '${plans.where((p) => p.estado == 'Pendiente').length}', const Color(0xFFFF3B30), () => widget.onNavigateTab?.call(3)),
                        const SizedBox(width: 8),
                        _pulseTile('En Proceso', '${plans.where((p) => p.estado == 'En Proceso' || p.estado == 'En Revisión').length}', const Color(0xFFFF9500), () => widget.onNavigateTab?.call(3)),
                        const SizedBox(width: 8),
                        _pulseTile('Cumplidos', '${plans.where((p) => p.estado == 'Cumplido').length}', const Color(0xFF34C759), () => widget.onNavigateTab?.call(3)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_subTab == 1) ...[
            WeeklyTrendLineCard(
              values: weeklyTrend,
              title: 'Tendencia Semanal de Planta',
              subtitle: 'Cumplimiento real Lunes a Viernes',
            ),
            const SizedBox(height: 16),
            TaskStatusDoughnutCard(
              completadas: completadasCount,
              pendientes: pendientesCount,
              vencidas: vencidasCount,
              title: 'ESTADO OPERATIVO DE PLANTA',
              subtitle: 'Toca un estado para ver actividades',
              onSegmentTap: (status) {
                final list = status == 'COMPLETADA'
                    ? instances.where((i) => i.done).toList()
                    : instances.where((i) => !i.done).toList();
                _showTasksSheet(context, list, status == 'COMPLETADA' ? 'Completadas' : 'Pendientes');
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E5EA))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Completadas vs. Pendientes por Día', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                  const SizedBox(height: 2),
                  const Text('Verde = Hechas · Rojo = Pendientes (Lun–Sáb)', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 155,
                    child: BarChart(
                      BarChartData(
                        maxY: maxDayY,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF2F2F7), strokeWidth: 1)),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF8E8E93))))),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 6), child: Text(dayLabels[v.toInt() + 1] ?? '', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))))),
                        ),
                        barGroups: List.generate(6, (i) => BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(toY: dayCounts[i].done.toDouble(), color: const Color(0xFF34C759), width: 9, borderRadius: BorderRadius.circular(4)),
                            BarChartRodData(toY: dayCounts[i].pend.toDouble(), color: const Color(0xFFFF3B30), width: 9, borderRadius: BorderRadius.circular(4)),
                          ],
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E5EA))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Carga y Cumplimiento por Responsable', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                  const SizedBox(height: 10),
                  if (ownerEntries.isEmpty)
                    const Text('Sin actividades asignadas aún.', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))
                  else
                    ...ownerEntries.take(6).map((e) {
                      final u = usersById[e.key];
                      final name = (u != null && u.nombre.isNotEmpty) ? u.nombre : (e.key == 'UNASSIGNED' ? 'Sin asignar' : e.key);
                      final done = e.value.where((x) => x.done).length;
                      final pct = e.value.isEmpty ? 0.0 : done / e.value.length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
                                Text('$done/${e.value.length} (${(pct * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: pct, minHeight: 7, backgroundColor: const Color(0xFFF2F2F7), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002F6C)))),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CriticalityPieChartCard(
              alta: altaTasks,
              media: mediaTasks,
              baja: bajaTasks,
              onSegmentTap: (crit) => _showTasksSheet(context, instances.where((i) => i.prioridad.toUpperCase() == crit).toList(), 'Criticidad $crit'),
            ),
            const SizedBox(height: 16),
            Radar5SChartCard(scores: radarScores),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E5EA))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cumplimiento por Área (Real)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                  const SizedBox(height: 2),
                  const Text('Toca un área para ver sus actividades', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
                  const SizedBox(height: 12),
                  if (areaEntries.isEmpty)
                    const Text('Sin áreas con actividades registradas aún.', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))
                  else
                    ...areaEntries.map((e) {
                      final done = e.value.where((x) => x.done).length;
                      final pct = e.value.isEmpty ? 0.0 : done / e.value.length;
                      final color = pct >= 0.9 ? const Color(0xFF34C759) : (pct >= 0.5 ? const Color(0xFF007AFF) : const Color(0xFFFF9500));
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _showTasksSheet(context, e.value, 'Área: ${e.key}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                                  Text('$done/${e.value.length} (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: pct, minHeight: 7, backgroundColor: const Color(0xFFF2F2F7), valueColor: AlwaysStoppedAnimation<Color>(color))),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _subTabBtn(int idx, String label, IconData icon) {
    final active = _subTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: active ? const Color(0xFF002F6C) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? Colors.white : const Color(0xFF3A3A3C)),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF3A3A3C))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pulseTile(String label, String value, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DCard(String title, String val, IconData icon, Color color, {VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)))),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                    child: Icon(icon, size: 15, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// TAB 2: GESTIÓN DEL EQUIPO LOCAL CON RELEVO OPERATIVO Y PERFIL 360°
class _PlantAdminTeamTab extends StatelessWidget {
  const _PlantAdminTeamTab();

  void _showRelevoDialog(BuildContext context, StandardWorkProvider provider, List<UserProfile> operators) {
    String? fromOp = operators.isNotEmpty ? operators.first.id : null;
    String? toOp = operators.length > 1 ? operators[1].id : null;
    int selectedDay = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setRelevoState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: Color(0xFF002F6C)),
              SizedBox(width: 8),
              Text('Relevo Operativo Inmediato', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transfiere toda la jornada de un colaborador ausente a otro operario en 1 solo toque:'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: fromOp,
                decoration: const InputDecoration(labelText: 'Colaborador Ausente (De)'),
                items: operators.map((o) => DropdownMenuItem(value: o.id, child: Text('${o.nombre} (${o.cargo})'))).toList(),
                onChanged: (val) => setRelevoState(() => fromOp = val),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: toOp,
                decoration: const InputDecoration(labelText: 'Colaborador de Relevo (A)'),
                items: operators.map((o) => DropdownMenuItem(value: o.id, child: Text('${o.nombre} (${o.cargo})'))).toList(),
                onChanged: (val) => setRelevoState(() => toOp = val),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Día de la Jornada'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Lunes')),
                  DropdownMenuItem(value: 2, child: Text('Martes')),
                  DropdownMenuItem(value: 3, child: Text('Miércoles')),
                  DropdownMenuItem(value: 4, child: Text('Jueves')),
                  DropdownMenuItem(value: 5, child: Text('Viernes')),
                ],
                onChanged: (val) {
                  if (val != null) setRelevoState(() => selectedDay = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (fromOp != null && toOp != null && fromOp != toOp) {
                  await provider.transferOperatorDayTasks(fromUserId: fromOp!, toUserId: toOp!, day: selectedDay);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('¡Jornada transferida exitosamente al relevo!')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: const Text('Confirmar Relevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _inspectCollaborator360(BuildContext context, UserProfile user, List<ActivityInstance> userInstances) {
    final completed = userInstances.where((i) => i.done).length;
    final total = userInstances.length;
    final pct = total > 0 ? ((completed / total) * 100).toStringAsFixed(0) : '0';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF002F6C),
                    child: Text(user.iniciales, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${user.cargo} · ${user.area}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('Cédula: ${user.cedula}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Text('Cumplimiento', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('$pct%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Text('Completadas', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('$completed de $total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Actividades Estándar Asignadas en la Semana:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (userInstances.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No hay actividades específicas programadas para este colaborador.'),
                )
              else
                ...userInstances.take(8).map((ins) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: ins.done ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ins.done ? const Color(0xFF86EFAC) : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(ins.done ? Icons.check_circle : Icons.circle_outlined, size: 16, color: ins.done ? Colors.green : Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(ins.nombre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          Text('${ins.timeStart} - ${ins.timeEnd}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    )),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
                  child: const Text('Cerrar Perfil 360°', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditUserModal(BuildContext context, UserProfile user) {
    final cedulaCtrl = TextEditingController(text: user.cedula);
    final nombreCtrl = TextEditingController(text: user.nombre);
    final cargoCtrl = TextEditingController(text: user.cargo);
    final areaCtrl = TextEditingController(text: user.area);
    final emailCtrl = TextEditingController(text: user.email);
    final pinCtrl = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Editar ${user.nombre}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
                const SizedBox(height: 8),
                TextField(controller: cedulaCtrl, decoration: const InputDecoration(labelText: 'Cédula')),
                const SizedBox(height: 8),
                TextField(controller: cargoCtrl, decoration: const InputDecoration(labelText: 'Cargo')),
                const SizedBox(height: 8),
                TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Área Operativa')),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                if (user.isSupervisor) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: pinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo PIN de Supervisor',
                      hintText: 'Dejar vacío para mantener el actual (mín. 4 dígitos)',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final newPin = pinCtrl.text.trim();
                      if (user.isSupervisor && newPin.isNotEmpty && newPin.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Color(0xFFDC2626), content: Text('El PIN debe tener al menos 4 dígitos')),
                        );
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                        await provider.updateFullUser(
                          userId: user.id,
                          cedula: cedulaCtrl.text.trim(),
                          nombre: nombreCtrl.text.trim(),
                          cargo: cargoCtrl.text.trim(),
                          area: areaCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          rol: user.rol,
                          plantId: user.plantId,
                          activo: user.activo,
                          newPin: newPin.isNotEmpty ? newPin : null,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('Usuario actualizado en la nube')),
                          );
                        }
                      } catch (e) {
                        setModalState(() => saving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text('Error al actualizar: $e')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: Text(saving ? 'Guardando...' : 'Actualizar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar Baja de Usuario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
        content: Text('¿Estás seguro de dar de baja a ${user.nombre} (${user.cargo})? Sus tareas históricas quedarán archivadas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                await provider.deleteUserFromCloud(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario eliminado de la nube')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreateUserModal(BuildContext context, bool isSupervisor) {
    final idCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final cargoCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isSupervisor ? 'Registrar Supervisor de Planta' : 'Registrar Operador de Planta',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Código (ej. OP-05 / SUP-02)')),
              const SizedBox(height: 8),
              TextField(controller: cedulaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cédula')),
              const SizedBox(height: 8),
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
              const SizedBox(height: 8),
              TextField(controller: cargoCtrl, decoration: const InputDecoration(labelText: 'Cargo')),
              const SizedBox(height: 8),
              TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Área Operativa')),
              const SizedBox(height: 8),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              if (isSupervisor) ...[
                const SizedBox(height: 8),
                TextField(controller: pinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN de Supervisor (4 dígitos)')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (idCtrl.text.isNotEmpty && cedulaCtrl.text.isNotEmpty && nombreCtrl.text.isNotEmpty) {
                final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                if (isSupervisor) {
                  await provider.createSupervisor(
                    id: idCtrl.text.trim(),
                    cedula: cedulaCtrl.text.trim(),
                    nombre: nombreCtrl.text.trim(),
                    cargo: cargoCtrl.text.trim(),
                    area: areaCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    pin: pinCtrl.text.trim(),
                  );
                } else {
                  await provider.createOperator(
                    id: idCtrl.text.trim(),
                    cedula: cedulaCtrl.text.trim(),
                    nombre: nombreCtrl.text.trim(),
                    cargo: cargoCtrl.text.trim(),
                    area: areaCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${isSupervisor ? "Supervisor" : "Operador"} registrado exitosamente')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final users = provider.usersForCurrentPlant.where((u) => !u.isPlantAdmin && !u.isSuperAdmin).toList();
    final operators = users.where((u) => u.isOperator).toList();
    final instances = provider.instances;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Equipo de Planta', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.3)),
                      Text('${users.length} integrantes activos', style: const TextStyle(fontSize: 12, color: Color(0xFF86868B))),
                    ],
                  ),
                ),
                if (operators.length >= 2)
                  ActionChip(
                    avatar: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF002F6C)),
                    label: const Text('Relevo', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E5EA)),
                    onPressed: () => _showRelevoDialog(context, provider, operators),
                  ),
              ],
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Text(
                      'Sin supervisores ni colaboradores.\nUsa los botones de abajo para agregar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF86868B)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 130),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      final userInstances = instances.where((i) => i.userId == u.id).toList();

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _inspectCollaborator360(context, u, userInstances),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 21,
                                backgroundColor: u.isSupervisor ? const Color(0xFF007AFF).withValues(alpha: 0.12) : const Color(0xFF002F6C).withValues(alpha: 0.12),
                                child: Text(u.iniciales, style: TextStyle(color: u.isSupervisor ? const Color(0xFF007AFF) : const Color(0xFF002F6C), fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: Color(0xFF1D1D1F))),
                                    Text('${u.cargo} · Cédula: ${u.cedula}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xFF86868B))),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: u.isSupervisor ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        u.isSupervisor ? 'SUPERVISOR' : 'COLABORADOR',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: u.isSupervisor ? const Color(0xFF007AFF) : const Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF002F6C)),
                                tooltip: 'Editar Datos',
                                onPressed: () => _showEditUserModal(context, u),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFFF3B30)),
                                tooltip: 'Dar de Baja / Eliminar',
                                onPressed: () => _confirmDeleteUser(context, u),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_supervisor',
            onPressed: () => _showCreateUserModal(context, true),
            backgroundColor: const Color(0xFF007AFF),
            icon: const Icon(Icons.shield_outlined, color: Colors.white),
            label: const Text('Supervisor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'fab_operador',
            onPressed: () => _showCreateUserModal(context, false),
            backgroundColor: const Color(0xFF002F6C),
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text('Colaborador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// TAB 3: BANDEJA DE ASIGNACIÓN DE ACTIVIDADES CORPORATIVAS (8 TAREAS JAVIER JULIO)
class _PlantAdminCorporateAssignmentTab extends StatelessWidget {
  const _PlantAdminCorporateAssignmentTab();

  void _showAssignModal(BuildContext context, ActivityModel act, StandardWorkProvider provider) {
    final plantUsers = provider.usersForCurrentPlant;
    final assignees = plantUsers.where((u) => u.isOperator || u.isSupervisor).toList();

    // Opciones: supervisores, colaboradores de la planta + usuarios genéricos de turno
    final List<Map<String, String>> assignOptions = [
      ...assignees.map((o) => {'id': o.id, 'name': '${o.isSupervisor ? "🛡" : "👤"} ${o.nombre} (${o.isSupervisor ? "Supervisor" : o.cargo})'}),
      {'id': 'GEN_TAB_01', 'name': '📱 Tableta Línea Extrusión 01 (Genérico Turno)'},
      {'id': 'GEN_TAB_02', 'name': '📱 Tableta Termoformado 02 (Genérico Turno)'},
      {'id': 'GEN_LIDER', 'name': '👷 Líder Operativo de Turno (Genérico)'},
    ];

    String selectedTarget = assignOptions.first['id']!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.assignment_ind_rounded, color: Color(0xFF002F6C)),
              SizedBox(width: 8),
              Text('Asignar Responsable Local', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actividad Corporativa (Javier Julio):',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                act.nombre,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Selecciona quién llevará el registro en tu planta (operador con nombre propio o tableta genérica de turno):',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedTarget,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Responsable en Planta *'),
                items: assignOptions.map((opt) => DropdownMenuItem(value: opt['id'], child: Text(opt['name']!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedTarget = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                await provider.assignCorporateActivityToOperator(
                  activityId: act.id!,
                  targetUserId: selectedTarget,
                  plantId: provider.currentUser?.plantId ?? 'PL-EXTRUSA',
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF16A34A),
                      content: Text('¡Responsable asignado a la actividad corporativa!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: const Text('Confirmar Asignación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final corporateActivities = provider.activities.where((a) => a.esGlobal).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: corporateActivities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt_rounded, size: 52, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('No hay actividades corporativas pendientes de asignar', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: corporateActivities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final act = corporateActivities[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: App3D.cardShadow(baseColor: const Color(0xFF7C3AED)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CORPORATIVA · JAVIER JULIO',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                              ),
                            ),
                            Text('${act.timeStart} - ${act.timeEnd}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(act.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        if (act.descripcion.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(act.descripcion, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${act.area} · ${act.category}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ElevatedButton.icon(
                              onPressed: () => _showAssignModal(context, act, provider),
                              icon: const Icon(Icons.touch_app_rounded, size: 14, color: Colors.white),
                              label: const Text('Asignar Responsable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF002F6C),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// TAB 4: CREADOR DE ACTIVIDADES DE PLANTA (CON SUBTAREAS Y EVIDENCIAS)
class _PlantAdminActivityCreatorTab extends StatefulWidget {
  const _PlantAdminActivityCreatorTab();

  @override
  State<_PlantAdminActivityCreatorTab> createState() => _PlantAdminActivityCreatorTabState();
}

class _PlantAdminActivityCreatorTabState extends State<_PlantAdminActivityCreatorTab> {
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController(text: 'Producción / Operaciones');
  final _catCtrl = TextEditingController(text: 'Operación Estándar');
  final _horaIniCtrl = TextEditingController(text: '07:00');
  final _horaFinCtrl = TextEditingController(text: '08:00');
  bool _fija = true;
  String _tipoActividad = 'ejecucion'; // 'ejecucion' o 'registro'
  bool _requierePlanAccion = false;
  bool _planAccionObligatorio = false;
  String _prioridad = 'Alta';
  String _planTemplate = 'Estándar 5W1H';
  final _planGuiaCtrl = TextEditingController(
    text: 'Hallazgo · Causa Raíz · Acción Correctiva · Responsable · Fecha Compromiso',
  );
  String? _selectedOperatorId;
  String _activitySearch = '';
  int _dayFilter = 0; // 0 = Todos, 1..6 = L..S
  bool _scheduleView = false;
  int _wizardStep = 0;
  ActivityInstance? _editingActivity;

  final List<ActivitySubtaskModel> _subtasks = [];

  void _loadTemplate(String templateName) {
    if (templateName == '5s_extrusion') {
      _nombreCtrl.text = 'Inspección 5S en Línea de Extrusión';
      _descCtrl.text = 'Verificación del estado de tolvas, tableros sombra y despeje de pasillos';
      _areaCtrl.text = 'Extrusión';
      _catCtrl.text = '5S y Seguridad';
      _horaIniCtrl.text = '07:00';
      _horaFinCtrl.text = '07:45';
      _fija = true;
      _subtasks.clear();
      _subtasks.addAll([
        ActivitySubtaskModel(activityId: 0, orden: 1, nombre: 'Despeje de pasillo y zona de bobinado', descripcion: 'Garantizar que no existan obstáculos ni restos de plástico en el suelo', requiereFoto: true, requiereComentario: true),
        ActivitySubtaskModel(activityId: 0, orden: 2, nombre: 'Verificación de tablero sombra de herramientas', descripcion: 'Comprobar llaves Allen, espátula de bronce y cortador de cinta', requiereFoto: true, requiereComentario: false),
        ActivitySubtaskModel(activityId: 0, orden: 3, nombre: 'Revisión de tolva de alimentación y purga', descripcion: 'Inspeccionar que no haya contaminación cruzada de polímero', requiereFoto: true, requiereComentario: true),
      ]);
    } else if (templateName == 'calidad_termoformado') {
      _nombreCtrl.text = 'Control de Calibre y Espesor Termoformado';
      _descCtrl.text = 'Monitoreo de espesores por cuadrantes en bandejas espumadas';
      _areaCtrl.text = 'Termoformado';
      _catCtrl.text = 'Calidad Operativa';
      _horaIniCtrl.text = '10:00';
      _horaFinCtrl.text = '10:45';
      _fija = false;
      _subtasks.clear();
      _subtasks.addAll([
        ActivitySubtaskModel(activityId: 0, orden: 1, nombre: 'Toma de muestra de 5 bandejas consecutivas', descripcion: 'Retirar al final de la cinta transportadora', requiereFoto: false, requiereComentario: true),
        ActivitySubtaskModel(activityId: 0, orden: 2, nombre: 'Medición de espesor en cuadrante central con micrómetro', descripcion: 'Registrar valor en mm (tolerancia 1.25 a 1.35 mm)', requiereFoto: true, requiereMedicion: true, requiereComentario: true),
        ActivitySubtaskModel(activityId: 0, orden: 3, nombre: 'Prueba de resistencia al apilamiento', descripcion: 'Comprobar rigidez estructural en mesa de pruebas', requiereFoto: true, requiereComentario: false),
      ]);
    }
    setState(() {});
  }

  void _addSubtaskDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool reqFoto = false;
    bool reqComentario = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSubState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Agregar Subtarea Paso a Paso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del Paso *')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Instrucción operativa')),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Requiere Foto de Evidencia', style: TextStyle(fontSize: 13)),
                value: reqFoto,
                onChanged: (val) => setSubState(() => reqFoto = val),
              ),
              SwitchListTile(
                title: const Text('Requiere Comentario', style: TextStyle(fontSize: 13)),
                value: reqComentario,
                onChanged: (val) => setSubState(() => reqComentario = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _subtasks.add(ActivitySubtaskModel(
                      activityId: 0,
                      orden: _subtasks.length + 1,
                      nombre: nameCtrl.text.trim(),
                      descripcion: descCtrl.text.trim(),
                      requiereFoto: reqFoto,
                      requiereComentario: reqComentario,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  final Set<int> _selectedDays = {1, 2, 3, 4, 5};

  void _showExtraTaskRequestModal(BuildContext context, StandardWorkProvider provider) {
    final justCtrl = TextEditingController();
    String prioridad = 'Media';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setReqState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Límite de 10 Tareas Diarias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'El colaborador ya cuenta con 10 tareas asignadas para este día (8 Corporativas + 2 Locales).',
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para habilitar una tarea adicional (#11+), debes solicitar autorización formal a Dirección General (Javier Julio):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: prioridad,
                  decoration: const InputDecoration(labelText: 'Nivel de Criticidad / Prioridad *'),
                  items: const [
                    DropdownMenuItem(value: 'Baja', child: Text('🔵 Baja (Mejora o Soporte)')),
                    DropdownMenuItem(value: 'Media', child: Text('🟡 Media (Operación Relevante)')),
                    DropdownMenuItem(value: 'Alta', child: Text('🔴 Alta (Seguridad / Calidad Crítica)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setReqState(() => prioridad = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: justCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Justificación Técnica Operativa *',
                    hintText: 'Explica a Javier Julio por qué esta tarea debe superar el cupo de 10...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (justCtrl.text.trim().isNotEmpty) {
                  await provider.requestExtraTask(
                    nombre: _nombreCtrl.text.trim(),
                    descripcion: _descCtrl.text.trim(),
                    area: _areaCtrl.text.trim(),
                    prioridad: prioridad,
                    justificacion: justCtrl.text.trim(),
                    dias: _selectedDays.join(','),
                    timeStart: _horaIniCtrl.text.trim(),
                    timeEnd: _horaFinCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF002F6C),
                        content: Text('Solicitud formal enviada a Javier Julio para revisión.'),
                      ),
                    );
                    _nombreCtrl.clear();
                    _descCtrl.clear();
                    setState(() => _subtasks.clear());
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: const Text('Enviar a Javier Julio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _saveActivity() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre de la actividad')),
      );
      return false;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día para programar la actividad')),
      );
      return false;
    }

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final planCriteria = _requierePlanAccion
        ? 'Plantilla Plan ($_planTemplate): ${_planGuiaCtrl.text.trim()}'
        : '';

    if (_editingActivity != null) {
      await provider.updateActivityGroup(
        activityId: _editingActivity!.activityId,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        area: _areaCtrl.text.trim(),
        category: _catCtrl.text.trim(),
        timeStart: _horaIniCtrl.text.trim(),
        timeEnd: _horaFinCtrl.text.trim(),
        fija: _fija,
        prioridad: _prioridad,
        tipoActividad: _tipoActividad,
        requierePlanAccion: _requierePlanAccion || _planAccionObligatorio,
        planAccionObligatorio: _planAccionObligatorio,
        criteriosCumplimiento: planCriteria,
        days: _selectedDays.toList()..sort(),
        targetPlantId: provider.currentUser?.plantId,
        targetUserId: _selectedOperatorId ?? 'ALL',
        subtasks: _subtasks,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('¡Actividad actualizada con éxito!')),
        );
        _editingActivity = null;
        return true;
      }
      return false;
    }

    if (_selectedOperatorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el colaborador o equipo responsable')),
      );
      return false;
    }

    if (!provider.canCreateMorePlantActivities) {
      _showExtraTaskRequestModal(context, provider);
      return false;
    }

    bool exceedsTen = false;
    for (final day in _selectedDays) {
      final count = provider.getTaskCountForDay(userId: _selectedOperatorId!, day: day);
      if (count >= 10) {
        exceedsTen = true;
        break;
      }
    }

    if (exceedsTen) {
      _showExtraTaskRequestModal(context, provider);
      return false;
    }

    await provider.createPlantActivity(
      userId: _selectedOperatorId!,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      category: _catCtrl.text.trim(),
      timeStart: _horaIniCtrl.text.trim(),
      timeEnd: _horaFinCtrl.text.trim(),
      fija: _fija,
      dias: (_selectedDays.toList()..sort()).join(','),
      subtasks: _subtasks,
      tipoActividad: _tipoActividad,
      requierePlanAccion: _requierePlanAccion || _planAccionObligatorio,
      planAccionObligatorio: _planAccionObligatorio,
      criteriosCumplimiento: planCriteria,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('¡Actividad creada y asignada con éxito!'),
        ),
      );
      _nombreCtrl.clear();
      _descCtrl.clear();
      setState(() => _subtasks.clear());
      return true;
    }
    return false;
  }

  void _openCreateActivityModal(BuildContext context, {ActivityInstance? editingActivity}) async {
    _wizardStep = 0;
    _editingActivity = editingActivity;
    final prov = Provider.of<StandardWorkProvider>(context, listen: false);
    if (editingActivity != null) {
      _nombreCtrl.text = editingActivity.nombre;
      _descCtrl.text = editingActivity.descripcion;
      _areaCtrl.text = editingActivity.area;
      _catCtrl.text = editingActivity.category;
      _horaIniCtrl.text = editingActivity.timeStart;
      _horaFinCtrl.text = editingActivity.timeEnd;
      _fija = editingActivity.fija;
      _prioridad = editingActivity.prioridad.isEmpty ? 'Alta' : editingActivity.prioridad;
      _tipoActividad = editingActivity.tipoActividad;
      _requierePlanAccion = editingActivity.requierePlanAccion || editingActivity.planAccionObligatorio;
      _planAccionObligatorio = editingActivity.planAccionObligatorio;
      _selectedOperatorId = editingActivity.userId;
      final sameGroup = prov.instances.where((i) => i.activityId == editingActivity.activityId).toList();
      if (sameGroup.isNotEmpty) {
        _selectedDays
          ..clear()
          ..addAll(sameGroup.map((i) => i.day));
      }
      final subs = await prov.getSubtasksForActivity(editingActivity.activityId);
      _subtasks
        ..clear()
        ..addAll(subs);
    } else {
      _nombreCtrl.clear();
      _descCtrl.clear();
      _requierePlanAccion = false;
      _planAccionObligatorio = false;
      _subtasks.clear();
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final provider = Provider.of<StandardWorkProvider>(sheetCtx);
          final operators = provider.usersForCurrentPlant.where((u) => u.isOperator || u.isSupervisor).toList();
          if (_selectedOperatorId == null && operators.isNotEmpty) {
            _selectedOperatorId = operators.first.id;
          }
          const stepLabels = ['1. Qué y Quién', '2. Horario y Plan', '3. Subtareas'];
          const dayNames = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};

          return Container(
            height: MediaQuery.of(sheetCtx).size.height * 0.92,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999)),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(18, 10, 10, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              editingActivity != null ? 'Editar Actividad de Planta' : 'Nueva Actividad de Planta',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                            ),
                            Text(
                              'Cupo local: ${provider.localActivitiesCountForPlant}/${provider.allowedCreationCapacityForPlant}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF86868B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(sheetCtx).pop()),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildPlantAccordionStep(
                          stepIndex: 0,
                          setSheetState: setSheetState,
                          title: '1. Qué y Quién',
                          summary: _nombreCtrl.text.trim().isEmpty ? 'Sin nombre' : _nombreCtrl.text.trim(),
                          isCompleted: _wizardStep > 0 && _nombreCtrl.text.trim().isNotEmpty,
                          children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Plantilla (opcional):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                              TextButton.icon(
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                onPressed: () {
                                  TemplatesModal.show(
                                    context: sheetCtx,
                                    onSelectTemplate: (tmpl) {
                                      setSheetState(() {
                                        _nombreCtrl.text = tmpl.nombre;
                                        _descCtrl.text = tmpl.descripcion;
                                        _areaCtrl.text = tmpl.area;
                                        _catCtrl.text = tmpl.category;
                                        _prioridad = tmpl.prioridad;
                                        _fija = tmpl.fija;
                                        _tipoActividad = tmpl.tipoActividad;
                                        _planAccionObligatorio = tmpl.planAccionObligatorio;
                                        _requierePlanAccion = tmpl.planAccionObligatorio;
                                        _subtasks
                                          ..clear()
                                          ..addAll(tmpl.subtasks.map((s) => s.copyWith(activityId: 0)));
                                      });
                                    },
                                  );
                                },
                                icon: const Icon(Icons.auto_stories_rounded, size: 15, color: Color(0xFF002F6C)),
                                label: const Text('Catálogo / Nueva', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                              ),
                            ],
                          ),
                          const Text('Modalidad de la Actividad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setSheetState(() => _tipoActividad = 'ejecucion'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(color: _tipoActividad == 'ejecucion' ? const Color(0xFF002F6C) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                                      child: Center(
                                        child: Text('Ejecución', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _tipoActividad == 'ejecucion' ? Colors.white : const Color(0xFF3A3A3C))),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setSheetState(() => _tipoActividad = 'registro'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(color: _tipoActividad == 'registro' ? const Color(0xFF002F6C) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                                      child: Center(
                                        child: Text('Registro / Reunión', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _tipoActividad == 'registro' ? Colors.white : const Color(0xFF3A3A3C))),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: operators.any((o) => o.id == _selectedOperatorId) ? _selectedOperatorId : (operators.isNotEmpty ? operators.first.id : null),
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Asignar a Responsable *',
                              prefixIcon: const Icon(Icons.person_pin_rounded, color: Color(0xFF002F6C)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: operators
                                .map((o) => DropdownMenuItem(
                                      value: o.id,
                                      child: Text('${o.nombre} (${o.isSupervisor ? 'Supervisor' : o.cargo})', overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) => setSheetState(() => _selectedOperatorId = v),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nombreCtrl,
                            decoration: InputDecoration(
                              labelText: 'Nombre de la Actividad *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Descripción / Instrucción',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_nombreCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                    const SnackBar(backgroundColor: Color(0xFFDC2626), content: Text('Escribe el nombre de la actividad antes de continuar.')),
                                  );
                                  return;
                                }
                                setSheetState(() => _wizardStep = 1);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('Siguiente: Horario y Plan →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        ..._buildPlantAccordionStep(
                          stepIndex: 1,
                          setSheetState: setSheetState,
                          title: '2. Horario y Plan',
                          summary: '${_horaIniCtrl.text}-${_horaFinCtrl.text} · ${_selectedDays.length} día(s) · $_prioridad',
                          isCompleted: _wizardStep > 1 && _selectedDays.isNotEmpty,
                          children: [
                          TextField(
                            controller: _areaCtrl,
                            decoration: InputDecoration(labelText: 'Área Destino', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _catCtrl,
                            decoration: InputDecoration(labelText: 'Categoría', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _horaIniCtrl,
                                  readOnly: true,
                                  onTap: () async {
                                    final parts = _horaIniCtrl.text.split(':');
                                    final init = TimeOfDay(hour: int.tryParse(parts.first) ?? 7, minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);
                                    final picked = await showTimePicker(context: sheetCtx, initialTime: init);
                                    if (picked != null) {
                                      setSheetState(() => _horaIniCtrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                                    }
                                  },
                                  decoration: InputDecoration(labelText: 'Hora Inicio (toca)', prefixIcon: const Icon(Icons.access_time_rounded, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _horaFinCtrl,
                                  readOnly: true,
                                  onTap: () async {
                                    final parts = _horaFinCtrl.text.split(':');
                                    final init = TimeOfDay(hour: int.tryParse(parts.first) ?? 8, minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);
                                    final picked = await showTimePicker(context: sheetCtx, initialTime: init);
                                    if (picked != null) {
                                      setSheetState(() => _horaFinCtrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                                    }
                                  },
                                  decoration: InputDecoration(labelText: 'Hora Fin (toca)', prefixIcon: const Icon(Icons.timer_off_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (ctx) {
                              final existing = <String, ActivityInstance>{};
                              for (final i in provider.instances) {
                                if (!_selectedDays.contains(i.day)) continue;
                                existing.putIfAbsent('${i.nombre}__${i.timeStart}', () => i);
                              }
                              final list = existing.values.toList()..sort((a, b) => a.timeStart.compareTo(b.timeStart));
                              return Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5EA))),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                                  leading: const Icon(Icons.calendar_today_rounded, size: 17, color: Color(0xFF002F6C)),
                                  title: Text('Ver horario actual (${list.length})', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                                  children: [
                                    if (list.isEmpty)
                                      const Padding(padding: EdgeInsets.fromLTRB(14, 0, 14, 12), child: Text('Sin actividades en estos días.', style: TextStyle(fontSize: 11.5, color: Color(0xFF86868B))))
                                    else
                                      ...list.take(8).map((a) => ListTile(
                                            dense: true,
                                            leading: Text('${a.timeStart}-${a.timeEnd}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF002F6C))),
                                            title: Text(a.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          )),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text('Días que aplica', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: dayNames.entries.map((e) {
                              final isSel = _selectedDays.contains(e.key);
                              return FilterChip(
                                label: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : const Color(0xFF1D1D1F))),
                                selected: isSel,
                                selectedColor: const Color(0xFF002F6C),
                                backgroundColor: Colors.white,
                                onSelected: (val) => setSheetState(() {
                                  if (val) {
                                    _selectedDays.add(e.key);
                                  } else if (_selectedDays.length > 1) {
                                    _selectedDays.remove(e.key);
                                  }
                                }),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA))),
                            child: SwitchListTile(
                              title: const Text('Actividad Fija Inmutable', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              value: _fija,
                              activeThumbColor: const Color(0xFF002F6C),
                              onChanged: (val) => setSheetState(() => _fija = val),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _requierePlanAccion ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _requierePlanAccion ? const Color(0xFF002F6C) : const Color(0xFFE5E5EA)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Incluir Plan de Acción', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF002F6C))),
                                  subtitle: const Text('Habilita registrar planes desde esta actividad o reunión', style: TextStyle(fontSize: 11)),
                                  value: _requierePlanAccion,
                                  activeThumbColor: const Color(0xFF002F6C),
                                  onChanged: (val) => setSheetState(() {
                                    _requierePlanAccion = val;
                                    if (!val) _planAccionObligatorio = false;
                                  }),
                                ),
                                if (_requierePlanAccion) ...[
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: const Text('¿Plan obligatorio para cerrar?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                    value: _planAccionObligatorio,
                                    activeThumbColor: const Color(0xFFFF3B30),
                                    onChanged: (val) => setSheetState(() => _planAccionObligatorio = val),
                                  ),
                                  DropdownButtonFormField<String>(
                                    initialValue: _planTemplate,
                                    isExpanded: true,
                                    decoration: InputDecoration(isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                    items: const [
                                      DropdownMenuItem(value: 'Estándar 5W1H', child: Text('Estándar 5W1H (Qué, Quién, Cuándo)', overflow: TextOverflow.ellipsis)),
                                      DropdownMenuItem(value: '5 Porqués (Causa Raíz)', child: Text('5 Porqués (Causa Raíz)', overflow: TextOverflow.ellipsis)),
                                      DropdownMenuItem(value: 'Seguimiento Reunión Diaria', child: Text('Seguimiento Reunión Diaria', overflow: TextOverflow.ellipsis)),
                                      DropdownMenuItem(value: 'Personalizada', child: Text('Personalizada', overflow: TextOverflow.ellipsis)),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setSheetState(() => _planTemplate = v);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _planGuiaCtrl,
                                    maxLines: 2,
                                    decoration: InputDecoration(labelText: 'Estructura del Plan', isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setSheetState(() => _wizardStep = 0),
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text('← Atrás', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_selectedDays.isEmpty) {
                                      ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                        const SnackBar(backgroundColor: Color(0xFFDC2626), content: Text('Selecciona al menos un día.')),
                                      );
                                      return;
                                    }
                                    setSheetState(() => _wizardStep = 2);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text('Siguiente: Subtareas →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 10),
                        ..._buildPlantAccordionStep(
                          stepIndex: 2,
                          setSheetState: setSheetState,
                          title: '3. Subtareas y Envío',
                          summary: '${_subtasks.length} paso(s) configurados',
                          isCompleted: false,
                          children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtareas (${_subtasks.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _addSubtaskDialog();
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    if (sheetCtx.mounted) setSheetState(() {});
                                  });
                                },
                                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                label: const Text('Agregar Paso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_subtasks.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(18),
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5EA))),
                              child: const Center(child: Text('Sin subtareas aún. Toca "+ Agregar Paso".', style: TextStyle(fontSize: 12, color: Color(0xFF86868B)))),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _subtasks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final s = _subtasks[i];
                                return ListTile(
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E5EA))),
                                  leading: CircleAvatar(radius: 12, backgroundColor: const Color(0xFF002F6C), child: Text('${i + 1}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                                  title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF3B30)),
                                    onPressed: () {
                                      setState(() => _subtasks.removeAt(i));
                                      setSheetState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setSheetState(() => _wizardStep = 1),
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text('← Atrás', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final ok = await _saveActivity();
                                    if (ok && sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                                  },
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                  label: Text(editingActivity != null ? 'Guardar Cambios' : 'Crear y Programar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                ),
                              ),
                            ],
                          ),
                        ]),
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

  List<Widget> _buildPlantAccordionStep({
    required int stepIndex,
    required StateSetter setSheetState,
    required String title,
    required String summary,
    required bool isCompleted,
    required List<Widget> children,
  }) {
    final isOpen = _wizardStep == stepIndex;
    return [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? const Color(0xFF002F6C) : (isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFE5E5EA)),
            width: isOpen ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setSheetState(() => _wizardStep = stepIndex),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isOpen
                      ? const Color(0xFF002F6C)
                      : (isCompleted ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)),
                  borderRadius: isOpen
                      ? const BorderRadius.vertical(top: Radius.circular(14))
                      : BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOpen
                          ? Icons.expand_less_rounded
                          : (isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
                      size: 19,
                      color: isOpen ? Colors.white : (isCompleted ? const Color(0xFF16A34A) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isOpen ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (!isOpen && summary.isNotEmpty)
                            Text(
                              summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isCompleted ? const Color(0xFF15803D) : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isOpen)
                      Text(
                        isCompleted ? 'Editar' : 'Abrir',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF002F6C),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final plantUsers = provider.usersForCurrentPlant;
    final userMap = {for (final u in plantUsers) u.id: u};

    final plantActivities = provider.instances.where((inst) {
      if (!userMap.containsKey(inst.userId)) return false;
      if (_dayFilter != 0 && inst.day != _dayFilter) return false;
      if (_activitySearch.isNotEmpty) {
        final q = _activitySearch.toLowerCase();
        final ownerName = (userMap[inst.userId]?.nombre ?? '').toLowerCase();
        if (!inst.nombre.toLowerCase().contains(q) &&
            !inst.area.toLowerCase().contains(q) &&
            !ownerName.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Agrupar actividades repetidas por nombre + horario
    final Map<String, List<ActivityInstance>> groupedMap = {};
    for (final inst in plantActivities) {
      final key = '${inst.nombre}__${inst.timeStart}__${inst.timeEnd}';
      groupedMap.putIfAbsent(key, () => []).add(inst);
    }
    final groups = groupedMap.values.toList();

    return Container(
      color: const Color(0xFFF2F2F7),
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Actividades de la Planta',
                                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                                ),
                                Text(
                                  '${groups.length} rutinas · ${plantActivities.length} asignaciones',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: provider.canCreateMorePlantActivities ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Cupo local: ${provider.localActivitiesCountForPlant}/${provider.allowedCreationCapacityForPlant}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: provider.canCreateMorePlantActivities ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _kpiMiniCard('Rutinas', '${groups.length}', const Color(0xFF002F6C)),
                            const SizedBox(width: 8),
                            _kpiMiniCard('Hechas', '${plantActivities.where((i) => i.done).length}', const Color(0xFF34C759)),
                            const SizedBox(width: 8),
                            _kpiMiniCard('Pendientes', '${plantActivities.where((i) => !i.done).length}', const Color(0xFFFF3B30)),
                            const SizedBox(width: 8),
                            _kpiMiniCard('Con Plan', '${groups.where((g) => g.first.requierePlanAccion || g.first.planAccionObligatorio).length}', const Color(0xFFFF9500)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          onChanged: (v) => setState(() => _activitySearch = v),
                          decoration: InputDecoration(
                            hintText: 'Buscar por actividad, área o responsable...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: const [
                                    {'d': 0, 'l': 'Todos'},
                                    {'d': 1, 'l': 'Lun'},
                                    {'d': 2, 'l': 'Mar'},
                                    {'d': 3, 'l': 'Mié'},
                                    {'d': 4, 'l': 'Jue'},
                                    {'d': 5, 'l': 'Vie'},
                                    {'d': 6, 'l': 'Sáb'},
                                  ].map((item) {
                                    final d = item['d'] as int;
                                    final label = item['l'] as String;
                                    final sel = _dayFilter == d;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                        selected: sel,
                                        selectedColor: const Color(0xFF002F6C),
                                        backgroundColor: Colors.white,
                                        visualDensity: VisualDensity.compact,
                                        side: BorderSide(color: sel ? const Color(0xFF002F6C) : const Color(0xFFE5E5EA)),
                                        onSelected: (_) => setState(() => _dayFilter = d),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _viewBtn(Icons.view_agenda_outlined, 'Lista', !_scheduleView, () => setState(() => _scheduleView = false)),
                                  _viewBtn(Icons.calendar_view_day_rounded, 'Horario', _scheduleView, () => setState(() => _scheduleView = true)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: groups.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.assignment_outlined, size: 44, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text('No hay actividades para mostrar', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : _scheduleView
                            ? ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                                itemCount: groups.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (_, idx) {
                                  final grp = groups[idx];
                                  final first = grp.first;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _openPlantActivityDetailSheet(context, grp, userMap),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA))),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 66,
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                            decoration: BoxDecoration(color: const Color(0xFF002F6C).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                                            child: Column(
                                              children: [
                                                Text(first.timeStart, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF002F6C))),
                                                Text(first.timeEnd, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(first.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                                Text('${first.area} · ${grp.length} asignaciones', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xFF86868B))),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF002F6C)),
                                            onPressed: () => _openCreateActivityModal(context, editingActivity: first),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : LayoutBuilder(
                            builder: (ctx, constraints) {
                              final isWide = constraints.maxWidth >= 720;
                              if (isWide) {
                                return GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    mainAxisExtent: 118,
                                  ),
                                  itemCount: groups.length,
                                  itemBuilder: (_, idx) => _buildPlantGroupCard(groups[idx], userMap),
                                );
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                                itemCount: groups.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, idx) => _buildPlantGroupCard(groups[idx], userMap),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: FloatingActionButton.extended(
                heroTag: 'plant_admin_create_act_fab',
                onPressed: () => _openCreateActivityModal(context),
                backgroundColor: const Color(0xFF002F6C),
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                icon: const Icon(Icons.add_task_rounded, size: 20),
                label: const Text('+ Crear Actividad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiMiniCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF86868B))),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _viewBtn(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: active ? const Color(0xFF002F6C) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? Colors.white : const Color(0xFF3A3A3C)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF3A3A3C))),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantGroupCard(List<ActivityInstance> group, Map<String, UserProfile> userMap) {
    final first = group.first;
    final doneCount = group.where((i) => i.done).length;
    final pct = group.isEmpty ? 0.0 : doneCount / group.length;
    final accentColor = doneCount == group.length ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    final ownerNames = group.map((i) => userMap[i.userId]?.nombre).whereType<String>().toSet().toList();
    final peopleLabel = ownerNames.isEmpty
        ? 'Sin asignar'
        : ownerNames.length == 1
            ? ownerNames.first
            : '${ownerNames.first} +${ownerNames.length - 1}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openPlantActivityDetailSheet(context, group, userMap),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.3),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 36,
                    decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(999)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          first.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$peopleLabel · ${first.area} · ${first.timeStart}-${first.timeEnd}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF002F6C)),
                    tooltip: 'Editar Actividad',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _openCreateActivityModal(context, editingActivity: first),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF3B30)),
                    tooltip: 'Eliminar Actividad',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _confirmDeletePlantGroup(context, group),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF2F2F7),
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$doneCount/${group.length} completadas',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePlantGroup(BuildContext context, List<ActivityInstance> group) async {
    final first = group.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Eliminar Actividad', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('¿Deseas eliminar "${first.nombre}" y todas sus asignaciones?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
            onPressed: () => Navigator.pop(dCtx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await Provider.of<StandardWorkProvider>(context, listen: false).deleteActivity(first.activityId);
    }
  }

  void _openPlantActivityDetailSheet(BuildContext context, List<ActivityInstance> group, Map<String, UserProfile> userMap) {
    final first = group.first;
    final doneCount = group.where((i) => i.done).length;
    const dayLabels = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};
    int sheetDay = 0;
    String sheetStatus = 'ALL';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final filtered = group.where((inst) {
            if (sheetDay != 0 && inst.day != sheetDay) return false;
            if (sheetStatus == 'PENDING' && inst.done) return false;
            if (sheetStatus == 'DONE' && !inst.done) return false;
            return true;
          }).toList();

          return Container(
            height: MediaQuery.of(sheetCtx).size.height * 0.84,
            decoration: const BoxDecoration(color: Color(0xFFF5F5F7), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999))),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(first.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                                const SizedBox(height: 2),
                                Text('${first.area} · ${first.timeStart}-${first.timeEnd} · $doneCount/${group.length} completadas', style: const TextStyle(fontSize: 12, color: Color(0xFF86868B))),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF002F6C), size: 20),
                            onPressed: () {
                              Navigator.of(sheetCtx).pop();
                              _openCreateActivityModal(context, editingActivity: first);
                            },
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30), size: 20),
                            onPressed: () {
                              Navigator.of(sheetCtx).pop();
                              _confirmDeletePlantGroup(context, group);
                            },
                          ),
                          IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(sheetCtx).pop()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...[(0, 'Todos'), (1, 'Lun'), (2, 'Mar'), (3, 'Mié'), (4, 'Jue'), (5, 'Vie'), (6, 'Sáb')].map((d) {
                              final sel = sheetDay == d.$1;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(d.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                  selected: sel,
                                  selectedColor: const Color(0xFF002F6C),
                                  backgroundColor: const Color(0xFFF5F5F7),
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (_) => setSheetState(() => sheetDay = d.$1),
                                ),
                              );
                            }),
                            ...[('ALL', 'Todos'), ('PENDING', 'Pendientes'), ('DONE', 'Completadas')].map((s) {
                              final sel = sheetStatus == s.$1;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(s.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                  selected: sel,
                                  selectedColor: const Color(0xFF34C759),
                                  backgroundColor: const Color(0xFFF5F5F7),
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (_) => setSheetState(() => sheetStatus = s.$1),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Sin asignaciones para este filtro.', style: TextStyle(color: Color(0xFF86868B))))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final inst = filtered[i];
                            final owner = userMap[inst.userId];
                            final statusColor = inst.done ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA))),
                              child: Row(
                                children: [
                                  Icon(inst.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: statusColor, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${owner?.nombre ?? 'Sin asignar'} (${owner?.isSupervisor == true ? 'Supervisor' : 'Operador'})',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
                                        ),
                                        Text('${dayLabels[inst.day] ?? 'Día ${inst.day}'} · ${inst.timeStart}-${inst.timeEnd}', style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                                    child: Text(inst.done ? 'Completada' : 'Pendiente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                                  ),
                                ],
                              ),
                            );
                          },
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

/// TAB 4: REPORTES DE PLANTA (EXCEL + PDF CON FILTROS Y SELECCIÓN)
class _PlantAdminReportsTab extends StatefulWidget {
  const _PlantAdminReportsTab();

  @override
  State<_PlantAdminReportsTab> createState() => _PlantAdminReportsTabState();
}

class _PlantAdminReportsTabState extends State<_PlantAdminReportsTab> {
  String _areaFilter = 'ALL';
  String _userFilter = 'ALL';
  String _statusFilter = 'ALL';
  String _priorityFilter = 'ALL';
  String _typeFilter = 'ALL';
  int _dayFilter = 0;
  final Set<int> _deselectedIds = {};

  bool _incSummary = true;
  bool _incActivities = true;
  bool _incSubtasks = true;
  bool _incPlans = true;
  bool _exporting = false;

  static const _darnelNavy = Color(0xFF002F6C);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final plant = provider.currentPlant;
    final users = provider.usersForCurrentPlant;
    final usersById = {for (final u in users) u.id: u};

    final areas = <String>{
      ...provider.corporateAreas,
      ...provider.instances.map((i) => i.area).where((a) => a.trim().isNotEmpty),
    }.toList()
      ..sort();

    final filteredInstances = provider.instances.where((i) {
      if (_areaFilter != 'ALL' && i.area != _areaFilter) return false;
      if (_userFilter != 'ALL' && i.userId != _userFilter) return false;
      if (_priorityFilter != 'ALL' && i.prioridad.toLowerCase() != _priorityFilter.toLowerCase()) return false;
      if (_typeFilter != 'ALL' && i.tipoActividad != _typeFilter) return false;
      if (_dayFilter != 0 && i.day != _dayFilter) return false;
      if (_statusFilter == 'DONE' && !i.done) return false;
      if (_statusFilter == 'PENDING' && i.done) return false;
      if (_statusFilter == 'OVERDUE' && (i.done || i.day >= provider.selectedDay)) return false;
      return true;
    }).toList();

    final selectedInstances = filteredInstances.where((i) => i.id == null || !_deselectedIds.contains(i.id)).toList();
    final filteredPlans = provider.proPlans.where((p) => _areaFilter == 'ALL' || p.area == _areaFilter).toList();
    final doneCount = selectedInstances.where((i) => i.done).length;
    final pct = selectedInstances.isEmpty ? '0.0' : ((doneCount / selectedInstances.length) * 100).toStringAsFixed(1);
    final ratio = selectedInstances.isEmpty ? 0.0 : doneCount / selectedInstances.length;

    Future<void> runExport({required bool isPdf}) async {
      if (_exporting) return;
      setState(() => _exporting = true);
      try {
        final targetPlants = plant != null ? [plant] : <PlantModel>[];
        final summary = '${plant?.nombre ?? "Planta"} · ${_areaFilter == "ALL" ? "Todas las áreas" : _areaFilter}';
        if (isPdf) {
          await UltraReportService.instance.generateFilteredExecutivePdf(
            issuerName: provider.currentUser?.nombre ?? 'Admin Planta',
            filterSummary: summary,
            plants: targetPlants,
            instances: selectedInstances,
            plans: filteredPlans,
            usersById: usersById,
            includeSummary: _incSummary,
            includeRanking: targetPlants.isNotEmpty,
            includeActivities: _incActivities,
            includeSubtasks: _incSubtasks,
            includePlans: _incPlans,
          );
        } else {
          await ExcelService.instance.exportFilteredReport(
            filterSummary: summary,
            plants: targetPlants,
            instances: selectedInstances,
            plans: filteredPlans,
            usersById: usersById,
            includeSummary: _incSummary,
            includeRanking: targetPlants.isNotEmpty,
            includeActivities: _incActivities,
            includeSubtasks: _incSubtasks,
            includePlans: _incPlans,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: const Color(0xFF16A34A), content: Text(isPdf ? 'PDF generado' : 'Excel (.csv) generado')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFFFF3B30), content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _exporting = false);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reportes de Planta', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                    Text('Filtra, selecciona filas y exporta Excel o PDF', style: TextStyle(fontSize: 12, color: Color(0xFF86868B))),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() {
                  _areaFilter = 'ALL';
                  _userFilter = 'ALL';
                  _statusFilter = 'ALL';
                  _priorityFilter = 'ALL';
                  _typeFilter = 'ALL';
                  _dayFilter = 0;
                  _deselectedIds.clear();
                }),
                icon: const Icon(Icons.refresh_rounded, size: 16, color: _darnelNavy),
                label: const Text('Limpiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _darnelNavy)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E5EA))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Filtros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _darnelNavy)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: (['ALL', ...areas].contains(_areaFilter)) ? _areaFilter : 'ALL',
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Área', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todas las Áreas')),
                    ...areas.map((a) => DropdownMenuItem(value: a, child: Text(a, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _areaFilter = v ?? 'ALL'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: (['ALL', ...users.map((u) => u.id)].contains(_userFilter)) ? _userFilter : 'ALL',
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Responsable', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todo el Equipo')),
                    ...users.where((u) => u.isOperator || u.isSupervisor).map((u) => DropdownMenuItem(value: u.id, child: Text(u.nombre, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _userFilter = v ?? 'ALL'),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [(0, 'Todos días'), (1, 'Lun'), (2, 'Mar'), (3, 'Mié'), (4, 'Jue'), (5, 'Vie'), (6, 'Sáb')].map((d) {
                    final sel = _dayFilter == d.$1;
                    return ChoiceChip(
                      label: Text(d.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                      selected: sel,
                      selectedColor: _darnelNavy,
                      backgroundColor: const Color(0xFFF5F5F7),
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _dayFilter = d.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [('ALL', 'Todos'), ('DONE', 'Completadas'), ('PENDING', 'Pendientes'), ('OVERDUE', 'Vencidas')].map((e) {
                    final sel = _statusFilter == e.$1;
                    return ChoiceChip(
                      label: Text(e.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                      selected: sel,
                      selectedColor: const Color(0xFF007AFF),
                      backgroundColor: const Color(0xFFF5F5F7),
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _statusFilter = e.$1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E5EA))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. Contenido y Selección', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _darnelNavy)),
                CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, activeColor: _darnelNavy, title: const Text('Resumen KPI'), value: _incSummary, onChanged: (v) => setState(() => _incSummary = v ?? true)),
                CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, activeColor: _darnelNavy, title: const Text('Detalle de Actividades'), value: _incActivities, onChanged: (v) => setState(() => _incActivities = v ?? true)),
                CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, activeColor: _darnelNavy, title: const Text('Avance de Subtareas'), value: _incSubtasks, onChanged: (v) => setState(() => _incSubtasks = v ?? true)),
                CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, activeColor: _darnelNavy, title: const Text('Planes de Acción'), value: _incPlans, onChanged: (v) => setState(() => _incPlans = v ?? true)),
                if (filteredInstances.isNotEmpty) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filas (${selectedInstances.length}/${filteredInstances.length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      TextButton(
                        onPressed: () => setState(() {
                          if (_deselectedIds.isEmpty) {
                            for (final i in filteredInstances) {
                              if (i.id != null) _deselectedIds.add(i.id!);
                            }
                          } else {
                            _deselectedIds.clear();
                          }
                        }),
                        child: Text(_deselectedIds.isEmpty ? 'Deseleccionar todo' : 'Seleccionar todo', style: const TextStyle(fontSize: 11.5)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: filteredInstances.length,
                      itemBuilder: (_, idx) {
                        final item = filteredInstances[idx];
                        final checked = item.id == null || !_deselectedIds.contains(item.id);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: _darnelNavy,
                          value: checked,
                          onChanged: item.id == null
                              ? null
                              : (v) => setState(() {
                                    if (v == true) {
                                      _deselectedIds.remove(item.id);
                                    } else {
                                      _deselectedIds.add(item.id!);
                                    }
                                  }),
                          title: Text(item.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          subtitle: Text('${item.area} · ${item.done ? 'Completada' : 'Pendiente'}', style: const TextStyle(fontSize: 11)),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _darnelNavy, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3. Exportar ($pct% cumplimiento)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: ratio, minHeight: 7, backgroundColor: Colors.white.withValues(alpha: 0.16), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34C759)))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exporting ? null : () => runExport(isPdf: false),
                        icon: const Icon(Icons.table_chart_rounded, size: 18, color: _darnelNavy),
                        label: const Text('Excel', style: TextStyle(color: _darnelNavy, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exporting ? null : () => runExport(isPdf: true),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
                        label: const Text('PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
