import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/action_plan_dialog.dart';
import '../../core/widgets/activity_execution_modal.dart';
import '../../core/widgets/activity_subtasks_modal.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/widgets/industrial_timer_modal.dart';
import '../../core/widgets/meeting_record_dialog.dart';
import '../../core/widgets/notifications_sheet.dart';
import '../../core/widgets/opl_sheet_modal.dart';
import '../../core/widgets/reprogramming_dialog.dart';
import '../../data/models/app_models.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/standard_work_provider.dart';
import '../login/login_screen.dart';

const Color _kOpBg = Color(0xFFF5F7FB);
const Color _kOpNavy = Color(0xFF002F6C);
const Color _kOpBlue = Color(0xFF007AFF);
const Color _kOpText = Color(0xFF0F172A);
const Color _kOpMuted = Color(0xFF64748B);
const Color _kOpBorder = Color(0xFFE2E8F0);
const Color _kOpGreen = Color(0xFF16A34A);
const Color _kOpAmber = Color(0xFFD97706);
const Color _kOpRed = Color(0xFFDC2626);

const Map<int, String> _kOpDayNames = {
  1: 'Lun',
  2: 'Mar',
  3: 'Mié',
  4: 'Jue',
  5: 'Vie',
  6: 'Sáb',
};

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  int _currentScreenIndex = 0;
  int _touchedPieIndex = -1;
  int? _selectedChartDay;

  int _dayFilter = 0; // 0 = Todos
  String _statusFilter = 'Todas'; // Todas, Pendientes, Completadas
  String _searchQuery = '';
  bool _scheduleMode = false;
  String _planFilter = 'Todos';

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
            await provider.reportSubtaskExecution(
              instanceId: instance.id!,
              subtaskId: entry.key,
              photoPath: entry.value['photo'] as String?,
              comment: entry.value['comment'] as String?,
              measuredValue: entry.value['measurement'] as double?,
            );
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: _kOpGreen,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: ok ? _kOpBlue : _kOpRed,
                content: Text(
                  ok
                      ? 'Actividad reprogramada exitosamente.'
                      : 'Esta actividad es fija y no admite reprogramación.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleCompleteActivity(BuildContext context, ActivityInstance item) async {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    if (item.tipoActividad == 'registro') {
      await MeetingRecordDialog.show(context: context, instance: item);
      return;
    }

    final executed = await ActivityExecutionModal.show(context: context, instance: item);
    if (executed == true || !context.mounted) return;

    final error = await provider.completeActivityInstance(instanceId: item.id!);
    if (!context.mounted) return;
    if (error != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: _kOpAmber),
              SizedBox(width: 8),
              Text('Requisito Obligatorio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(error, style: const TextStyle(fontSize: 13, color: _kOpText)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await ActionPlanDialog.show(context: context, instance: item, isMandatoryForActivity: true);
                if (ok == true && context.mounted) {
                  await provider.completeActivityInstance(instanceId: item.id!);
                }
              },
              icon: const Icon(Icons.flag_rounded, size: 16, color: Colors.white),
              label: const Text('Diligenciar Plan', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: _kOpNavy),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;
    final isWide = MediaQuery.of(context).size.width >= 900;

    final myAll = provider.instances.where((i) => i.userId == user?.id).toList();
    final pendingToday = myAll.where((i) => !i.done).length;
    final pendingPlans = provider.proPlans.where((p) => p.estado != 'Cumplido').length;

    final navItems = [
      (label: 'Mi Día', icon: Icons.today_rounded, badge: pendingToday),
      (label: 'Mi Jornada', icon: Icons.schedule_rounded, badge: 0),
      (label: 'Planes', icon: Icons.flag_rounded, badge: pendingPlans),
      (label: 'Indicadores', icon: Icons.bar_chart_rounded, badge: 0),
    ];

    final bodyContent = IndexedStack(
      index: _currentScreenIndex,
      children: [
        _buildMiDiaTab(context, provider),
        _buildMiJornadaTab(context, provider),
        _buildPlanesTab(context, provider),
        _buildIndicadoresTab(context, provider),
      ],
    );

    return Scaffold(
      backgroundColor: _kOpBg,
      body: isWide
          ? Row(
              children: [
                _buildDesktopSidebar(user, navItems),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopHeader(context, provider, navItems[_currentScreenIndex].label, isWide: true),
                      Expanded(child: bodyContent),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildTopHeader(context, provider, navItems[_currentScreenIndex].label, isWide: false),
                Expanded(child: bodyContent),
              ],
            ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _currentScreenIndex,
              onTap: (idx) => setState(() => _currentScreenIndex = idx),
              selectedItemColor: _kOpBlue,
              unselectedItemColor: const Color(0xFF86868B),
              backgroundColor: Colors.white,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              items: navItems
                  .map((item) => BottomNavigationBarItem(
                        icon: Badge(
                          isLabelVisible: item.badge > 0,
                          label: Text('${item.badge}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                          child: Icon(item.icon),
                        ),
                        label: item.label,
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildDesktopSidebar(
    UserProfile? user,
    List<({String label, IconData icon, int badge})> navItems,
  ) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6FA),
        border: Border(right: BorderSide(color: _kOpBorder)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: _kOpNavy, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRACK60', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _kOpNavy)),
                        Text(user?.area ?? 'Operación', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _kOpMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: navItems.length,
                itemBuilder: (_, idx) {
                  final item = navItems[idx];
                  final selected = _currentScreenIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      onTap: () => setState(() => _currentScreenIndex = idx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: selected ? _kOpNavy : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 19, color: selected ? Colors.white : _kOpMuted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                  color: selected ? Colors.white : _kOpText,
                                ),
                              ),
                            ),
                            if (item.badge > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white.withValues(alpha: 0.2) : _kOpRed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${item.badge}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                              ),
                          ],
                        ),
                      ),
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

  Widget _buildTopHeader(
    BuildContext context,
    StandardWorkProvider provider,
    String title, {
    required bool isWide,
  }) {
    final user = provider.currentUser;
    return Container(
      padding: EdgeInsets.fromLTRB(16, isWide ? 14 : MediaQuery.of(context).padding.top + 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kOpBorder)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _kOpNavy, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.engineering_rounded, color: Colors.white, size: 13),
                SizedBox(width: 5),
                Text('OPERADOR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _kOpText)),
                Text(
                  '${user?.nombre ?? "Colaborador"} · ${provider.currentPlant?.nombre ?? user?.plantId ?? ""}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _kOpMuted),
                ),
              ],
            ),
          ),
          _headerIconButton(
            tooltip: 'Sincronizar',
            icon: Icons.sync_rounded,
            onPressed: () => provider.refreshData(),
          ),
          _headerIconButton(
            tooltip: 'Notificaciones',
            icon: Icons.notifications_rounded,
            badgeCount: provider.unreadNotificationsCount,
            onPressed: () => _showNotifications(context),
          ),
          _headerIconButton(
            tooltip: 'Cronómetro 60s',
            icon: Icons.timer_rounded,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => IndustrialTimerModal(instance: _fallbackInstance(provider, 'Cronómetro Libre')),
            ),
          ),
          _headerIconButton(
            tooltip: 'Hoja OPL',
            icon: Icons.menu_book_rounded,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => OplSheetModal(instance: _fallbackInstance(provider, 'Lección de Un Punto')),
            ),
          ),
          _headerIconButton(
            tooltip: 'Guía',
            icon: Icons.help_outline_rounded,
            onPressed: () => HelpGuideModal.show(context),
          ),
          _headerIconButton(
            tooltip: 'Cerrar Sesión',
            icon: Icons.logout_rounded,
            onPressed: () {
              provider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _kOpBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kOpBorder),
              ),
              child: Icon(icon, size: 17, color: _kOpNavy),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoKpi(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kOpMuted))),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // --- TAB 0: MI DÍA ---
  Widget _buildMiDiaTab(BuildContext context, StandardWorkProvider provider) {
    final userId = provider.currentUser?.id;
    final allMy = provider.instances.where((i) => i.userId == userId).toList();
    final doneCount = allMy.where((i) => i.done).length;
    final pendingCount = allMy.length - doneCount;
    final pct = allMy.isEmpty ? 0.0 : (doneCount / allMy.length) * 100;

    final filtered = allMy.where((i) {
      if (_dayFilter != 0 && i.day != _dayFilter) return false;
      if (_statusFilter == 'Pendientes' && i.done) return false;
      if (_statusFilter == 'Completadas' && !i.done) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!i.nombre.toLowerCase().contains(q) && !i.area.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));

    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildBentoKpi('Asignadas', '${allMy.length}', _kOpBlue, Icons.layers_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Hechas', '$doneCount', _kOpGreen, Icons.check_circle_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Pendientes', '$pendingCount', _kOpRed, Icons.pending_actions_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Avance', '${pct.toStringAsFixed(0)}%', _kOpNavy, Icons.insights_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
            decoration: InputDecoration(
              hintText: 'Buscar actividad o área...',
              prefixIcon: const Icon(Icons.search_rounded, size: 19, color: _kOpMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kOpBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kOpBorder)),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _dayChip(0, 'Todos'),
                for (final e in _kOpDayNames.entries) _dayChip(e.key, e.value),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Pendientes', 'Completadas'].map((lbl) {
                      final selected = _statusFilter == lbl;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(lbl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _kOpText)),
                          selected: selected,
                          selectedColor: _kOpBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: selected ? _kOpBlue : _kOpBorder),
                          onSelected: (_) => setState(() => _statusFilter = lbl),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, icon: Icon(Icons.view_agenda_rounded, size: 16), label: Text('Lista', style: TextStyle(fontSize: 11))),
                  ButtonSegment(value: true, icon: Icon(Icons.schedule_rounded, size: 16), label: Text('Horario', style: TextStyle(fontSize: 11))),
                ],
                selected: {_scheduleMode},
                onSelectionChanged: (s) => setState(() => _scheduleMode = s.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? _kOpNavy : Colors.white),
                  foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : _kOpText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kOpBorder)),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 42, color: _kOpMuted),
                  SizedBox(height: 10),
                  Text('No hay actividades para este filtro', style: TextStyle(fontWeight: FontWeight.w700, color: _kOpMuted)),
                ],
              ),
            )
          else if (_scheduleMode)
            ..._buildScheduleView(context, filtered)
          else
            ...filtered.map((item) => _buildActivityCard(context, provider, item)),
        ],
      ),
    );
  }

  Widget _dayChip(int day, String label) {
    final selected = _dayFilter == day;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _kOpText)),
        selected: selected,
        selectedColor: _kOpNavy,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? _kOpNavy : _kOpBorder),
        onSelected: (_) => setState(() => _dayFilter = day),
      ),
    );
  }

  List<Widget> _buildScheduleView(BuildContext context, List<ActivityInstance> items) {
    final byHour = <String, List<ActivityInstance>>{};
    for (final i in items) {
      byHour.putIfAbsent(i.timeStart, () => []).add(i);
    }
    final hours = byHour.keys.toList()..sort();
    return hours.map((h) {
      final list = byHour[h]!;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kOpBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _kOpNavy.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _kOpNavy)),
                ),
                const SizedBox(width: 8),
                Text('${list.length} actividad(es)', style: const TextStyle(fontSize: 11, color: _kOpMuted)),
              ],
            ),
            const SizedBox(height: 10),
            ...list.map((inst) => InkWell(
                  onTap: () => _handleCompleteActivity(context, inst),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kOpBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: inst.done ? _kOpGreen.withValues(alpha: 0.4) : _kOpBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(inst.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 18, color: inst.done ? _kOpGreen : _kOpBlue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inst.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('${_kOpDayNames[inst.day] ?? ""} · ${inst.area} · ${inst.timeStart}-${inst.timeEnd}',
                                  style: const TextStyle(fontSize: 11, color: _kOpMuted)),
                            ],
                          ),
                        ),
                        _buildStatusBadge(inst),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActivityCard(BuildContext context, StandardWorkProvider provider, ActivityInstance item) {
    final stripeColor = item.done ? _kOpGreen : (item.prioridad == 'Alta' ? _kOpRed : _kOpBlue);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kOpBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 34, decoration: BoxDecoration(color: stripeColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kOpText)),
                    Text(
                      '${_kOpDayNames[item.day] ?? ""} · ${item.timeStart}-${item.timeEnd} · ${item.area}',
                      style: const TextStyle(fontSize: 11, color: _kOpMuted),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(item),
            ],
          ),
          if (item.descripcion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _kOpMuted)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (!item.done)
                ElevatedButton.icon(
                  onPressed: () => _handleCompleteActivity(context, item),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                  label: Text(item.tipoActividad == 'registro' ? 'Registrar' : 'Ejecutar',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOpNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              if (item.subtasksTotal > 0)
                OutlinedButton.icon(
                  onPressed: () => _openSubtasksModal(context, item),
                  icon: const Icon(Icons.checklist_rounded, size: 15),
                  label: Text('Subtareas (${item.subtasksReported}/${item.subtasksTotal})', style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kOpBlue,
                    side: const BorderSide(color: _kOpBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              if (!item.fija && !item.done)
                OutlinedButton.icon(
                  onPressed: () => _openReprogramming(context, item),
                  icon: const Icon(Icons.event_repeat_rounded, size: 15),
                  label: const Text('Reprogramar', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kOpMuted,
                    side: const BorderSide(color: _kOpBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              if (item.requierePlanAccion)
                OutlinedButton.icon(
                  onPressed: () => ActionPlanDialog.show(context: context, instance: item, isMandatoryForActivity: item.planAccionObligatorio),
                  icon: const Icon(Icons.flag_rounded, size: 15),
                  label: const Text('Plan de Acción', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kOpAmber,
                    side: BorderSide(color: _kOpAmber.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: MI JORNADA ---
  Widget _buildMiJornadaTab(BuildContext context, StandardWorkProvider provider) {
    final userId = provider.currentUser?.id;
    final myAll = provider.instances.where((i) => i.userId == userId).toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => IndustrialTimerModal(instance: _fallbackInstance(provider, 'Cronómetro Libre')),
                ),
                icon: const Icon(Icons.timer_rounded, size: 17, color: Colors.white),
                label: const Text('Cronómetro 60s', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOpNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => OplSheetModal(instance: _fallbackInstance(provider, 'Lección de Un Punto')),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 17),
                label: const Text('Hojas OPL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kOpNavy,
                  side: const BorderSide(color: _kOpBorder),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (myAll.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kOpBorder)),
            child: const Center(child: Text('No tienes actividades programadas en tu jornada.', style: TextStyle(color: _kOpMuted))),
          )
        else
          ..._buildScheduleView(context, myAll),
      ],
    );
  }

  // --- TAB 2: PLANES ---
  Widget _buildPlanesTab(BuildContext context, StandardWorkProvider provider) {
    final plans = provider.proPlans.where((p) {
      if (_planFilter == 'Todos') return true;
      return p.estado == _planFilter;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Pendiente', 'En Proceso', 'Cumplido'].map((lbl) {
                      final selected = _planFilter == lbl;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(lbl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _kOpText)),
                          selected: selected,
                          selectedColor: _kOpNavy,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: selected ? _kOpNavy : _kOpBorder),
                          onSelected: (_) => setState(() => _planFilter = lbl),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => ActionPlanDialog.show(context: context),
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text('Nuevo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOpNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kOpBorder)),
              child: const Center(child: Text('No hay planes de acción registrados.', style: TextStyle(color: _kOpMuted))),
            )
          else
            ...plans.map((p) {
              final isDone = p.estado == 'Cumplido';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kOpBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(p.plan, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kOpText))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isDone ? _kOpGreen : _kOpAmber).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(p.estado, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDone ? _kOpGreen : _kOpAmber)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Resp: ${p.responsable} · Área: ${p.area} · Límite: ${p.fechaCompromiso}',
                        style: const TextStyle(fontSize: 11, color: _kOpMuted)),
                    if (!isDone) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => provider.updateProPlanStatus(planId: p.id!, nuevoEstado: 'Cumplido', porcentajeAvance: 1.0),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: _kOpGreen),
                        label: const Text('Marcar Cumplido', style: TextStyle(fontSize: 12, color: _kOpGreen, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- TAB 3: INDICADORES ---
  Widget _buildIndicadoresTab(BuildContext context, StandardWorkProvider provider) {
    final userId = provider.currentUser?.id;
    final myAll = provider.instances.where((i) => i.userId == userId).toList();
    final total = myAll.length;
    final done = myAll.where((i) => i.done).length;
    final pending = total - done;
    final pct = total == 0 ? 0.0 : (done / total) * 100;

    final dayGroups = <BarChartGroupData>[];
    for (int d = 1; d <= 6; d++) {
      final dayItems = myAll.where((i) => i.day == d).toList();
      final dayPct = dayItems.isEmpty ? 0.0 : (dayItems.where((i) => i.done).length / dayItems.length) * 100;
      dayGroups.add(
        BarChartGroupData(
          x: d,
          barRods: [
            BarChartRodData(
              toY: dayPct,
              width: 18,
              borderRadius: BorderRadius.circular(6),
              color: _selectedChartDay == d ? _kOpBlue : _kOpNavy,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildBentoKpi('Mi Cumplimiento', '${pct.toStringAsFixed(1)}%', _kOpNavy, Icons.insights_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoKpi('Hechas', '$done', _kOpGreen, Icons.check_circle_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoKpi('Pendientes', '$pending', _kOpRed, Icons.pending_rounded)),
          ],
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () async {
            final usersById = {for (final u in provider.allUsers) u.id: u};
            await ExcelService.instance.exportFilteredReport(
              filterSummary: 'Operador · ${provider.currentUser?.nombre ?? ""}',
              plants: provider.currentPlant != null ? [provider.currentPlant!] : [],
              instances: myAll,
              plans: provider.proPlans,
              usersById: usersById,
            );
          },
          icon: const Icon(Icons.table_chart_rounded, size: 17, color: Colors.white),
          label: const Text('Exportar Mi Reporte Excel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kOpGreen,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kOpBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mi Cumplimiento Diario (Lun - Sáb)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kOpNavy)),
              const SizedBox(height: 14),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    barTouchData: BarTouchData(
                      touchCallback: (event, resp) {
                        if (resp?.spot != null && event.isInterestedForInteractions) {
                          setState(() => _selectedChartDay = resp!.spot!.touchedBarGroup.x);
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(_kOpDayNames[v.toInt()] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: dayGroups,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kOpBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resumen de Mis Actividades', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kOpNavy)),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: total == 0
                    ? const Center(child: Text('Sin actividades asignadas todavía', style: TextStyle(color: _kOpMuted)))
                    : PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, resp) {
                              setState(() => _touchedPieIndex = resp?.touchedSection?.touchedSectionIndex ?? -1);
                            },
                          ),
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: done.toDouble(),
                              color: _kOpGreen,
                              radius: _touchedPieIndex == 0 ? 52 : 44,
                              title: '$done\nHechas',
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: pending.toDouble(),
                              color: _kOpRed,
                              radius: _touchedPieIndex == 1 ? 52 : 44,
                              title: '$pending\nPend.',
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ActivityInstance _fallbackInstance(StandardWorkProvider provider, String nombre) {
    final user = provider.currentUser;
    return provider.instances.firstWhere(
      (i) => i.userId == user?.id && !i.done,
      orElse: () => ActivityInstance(
        activityId: 0,
        userId: user?.id ?? '',
        plantId: user?.plantId ?? '',
        weekKey: 'W1',
        nombre: nombre,
        descripcion: '',
        area: user?.area ?? 'Operación',
        category: 'Operación',
        timeStart: '08:00',
        timeEnd: '09:00',
        day: 1,
        orig: 1,
        fija: false,
      ),
    );
  }

  Widget _buildStatusBadge(ActivityInstance item) {
    final bg = item.done ? _kOpGreen.withValues(alpha: 0.12) : _kOpAmber.withValues(alpha: 0.12);
    final fg = item.done ? _kOpGreen : _kOpAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(item.state, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
