import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/ultra_report_service.dart';
import '../../data/models/app_models.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/theme/app_theme.dart';
import '../login/login_screen.dart';
import '../../core/widgets/track60_charts.dart';
import '../../core/widgets/templates_modal.dart';

class SuperAdminShellScreen extends StatefulWidget {
  const SuperAdminShellScreen({super.key});

  @override
  State<SuperAdminShellScreen> createState() => _SuperAdminShellScreenState();
}

class _SuperAdminShellScreenState extends State<SuperAdminShellScreen> {
  int _currentTabIndex = 0;

  static const _darnelNavy = Color(0xFF002F6C);
  static const _bg = Color(0xFFF5F5F7);
  static const _sidebarBg = Color(0xFFECECEE);
  static const _border = Color(0xFFE5E5EA);
  static const _ink = Color(0xFF1D1D1F);
  static const _muted = Color(0xFF86868B);

  static const _navItems = [
    (label: 'Torre', icon: Icons.space_dashboard_rounded),
    (label: 'Asignar', icon: Icons.add_task_rounded),
    (label: 'Procesos', icon: Icons.business_rounded),
    (label: 'Alertas', icon: Icons.notifications_active_outlined),
    (label: 'Reportes', icon: Icons.analytics_rounded),
    (label: 'Logs', icon: Icons.history_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;
    final isWide = MediaQuery.of(context).size.width >= 860;

    final bodyContent = IndexedStack(
      index: _currentTabIndex,
      children: [
        _SuperAdminControlTowerTab(
          onNavigateTab: (idx) => setState(() => _currentTabIndex = idx),
        ),
        const _SuperAdminCorporateDispatchTab(),
        const _SuperAdminPlantAdminsTab(),
        const _SuperAdminExtraTasksApprovalTab(),
        const _SuperAdminReportsTab(),
        const _SuperAdminAuditTab(),
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
                            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TRACK60', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _darnelNavy, letterSpacing: 0.3)),
                                Text('Grupo Darnel · Dirección', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _muted)),
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
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                          color: active ? Colors.white : _ink,
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
                            child: Text(user?.iniciales ?? 'JJ', style: const TextStyle(color: _darnelNavy, fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.nombre ?? 'Javier Julio', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
                                const Text('Super Admin', style: TextStyle(fontSize: 10.5, color: _muted)),
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
                // BARRA SUPERIOR LIMPIA ESTILO APPLE + DARNEL AZUL Y BLANCO
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _darnelNavy,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                                    SizedBox(width: 5),
                                    Text(
                                      'SUPERADMIN',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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
                                      '${user?.nombre ?? 'Javier Julio'} · Grupo Darnel',
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
                          if (provider.emergencyAlertActive) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'ALERTA ROJA EHS: ${provider.emergencyAlertMessage}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
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
                selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500),
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

/// TAB 1: TORRE DE CONTROL CON SEMÁFORO, GRÁFICAS Y GOBERNANZA OPERATIVA
class _SuperAdminControlTowerTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const _SuperAdminControlTowerTab({this.onNavigateTab});

  @override
  State<_SuperAdminControlTowerTab> createState() => _SuperAdminControlTowerTabState();
}

class _SuperAdminControlTowerTabState extends State<_SuperAdminControlTowerTab> {
  String _selectedPlantFilter = 'TODAS';
  int _towerSubTab = 0; // 0: Resumen, 1: Gráficas, 2: Sedes
  String _selectedCriticalityFilter = 'TODAS';
  String _selectedStatusFilter = 'TODOS';
  String _searchQuery = '';
  bool _isLiveMode = true;
  DateTime _lastUpdated = DateTime.now();
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _startLiveTimer();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    if (!_isLiveMode) return;
    _liveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      setState(() {
        _lastUpdated = DateTime.now();
      });
    });
  }

  void _showFilteredTasksSheet(
    BuildContext context,
    StandardWorkProvider provider, {
    required String title,
    String? statusFilter,
    String? criticalityFilter,
    String? plantFilter,
  }) {
    final activityById = {for (final a in provider.activities) a.id: a};
    final tasks = provider.instances.where((t) {
      final act = activityById[t.activityId];
      if (plantFilter != null && plantFilter != 'TODAS' && t.plantId != plantFilter) return false;
      if (criticalityFilter != null && criticalityFilter != 'TODAS') {
        final crit = (act?.prioridad ?? 'MEDIA').toUpperCase();
        if (crit != criticalityFilter.toUpperCase()) return false;
      }
      if (statusFilter == 'COMPLETADA' && !t.done) return false;
      if (statusFilter == 'PENDIENTE' && t.done) return false;
      if (statusFilter == 'VENCIDA' && t.done) return false;
      return true;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: Color(0xFF002F6C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title (${tasks.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text('No hay actividades que coincidan con este filtro.', style: TextStyle(color: Color(0xFF64748B))),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, idx) {
                    final t = tasks[idx];
                    final isDone = t.done;
                    final statusColor = isDone
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF0284C7);
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        child: Icon(
                          isDone ? Icons.check_circle : Icons.schedule,
                          size: 16,
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        activityById[t.activityId]?.nombre ?? 'Actividad ${t.activityId}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      subtitle: Text(
                        '${t.plantId} · Criticidad: ${activityById[t.activityId]?.prioridad ?? 'MEDIA'} · ${isDone ? 'Completada' : 'Pendiente'}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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

  void _showLiveInspectionDialog(BuildContext context, StandardWorkProvider provider) {
    final plants = provider.allPlants;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF002F6C)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Auditoría Sorpresa / Observador en Vivo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Selecciona la sede industrial para entrar en tiempo real a inspeccionar su operación:',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 14),
              ...plants.map((p) {
                final pInst = provider.instances.where((i) => i.plantId == p.id).toList();
                final pDone = pInst.where((i) => i.done).length;
                final pRate = pInst.isEmpty ? 0 : ((pDone / pInst.length) * 100).round();
                final loc = p.ubicacion.trim().isNotEmpty ? ' · ${p.ubicacion}' : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.factory_rounded, color: Color(0xFF002F6C)),
                    title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${p.codigo}$loc · $pDone/${pInst.length} tareas ($pRate%)'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF0284C7)),
                    onTap: () {
                      provider.setObservingPlant(p.id);
                      Navigator.pop(ctx);
                      _inspectPlant(context, p, provider.allUsers);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context, StandardWorkProvider provider) {
    final alertCtrl = TextEditingController(text: 'Parada Preventiva de Seguridad Industrial en todas las líneas');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Alerta Roja EHS / Parada General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta acción activará un protocolo de seguridad que notifica a todos los colaboradores y supervisores de todas las plantas:',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alertCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Motivo de la Alerta EHS',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          if (provider.emergencyAlertActive)
            ElevatedButton(
              onPressed: () {
                provider.toggleEmergencyAlert(false, '');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              child: const Text('Desactivar Alerta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              onPressed: () {
                if (alertCtrl.text.isNotEmpty) {
                  provider.toggleEmergencyAlert(true, alertCtrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              child: const Text('Activar Alerta Roja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  void _inspectPlant(BuildContext context, PlantModel plant, List<UserProfile> users) {
    final plantUsers = users.where((u) => u.plantId == plant.id).toList();
    final admin = users.firstWhere((u) => u.id == plant.adminId, orElse: () => users.first);

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.domain_rounded, color: Color(0xFF002F6C), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plant.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${plant.codigo} · ${plant.ubicacion}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                    child: const Text('🟢 Operando', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),

              // Responsables
              const Text('Estructura de Mando de la Planta:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: const Color(0xFF002F6C), child: Text(admin.iniciales, style: const TextStyle(color: Colors.white, fontSize: 11))),
                title: Text('Administrador: ${admin.nombre}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Cargo: ${admin.cargo} · PIN: ${admin.pin}'),
              ),
              const SizedBox(height: 10),

              // Métricas reales por Área de la Planta
              const Text('Cumplimiento por Área (Real):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Builder(builder: (ctx) {
                final plantInst = ctx.watch<StandardWorkProvider>().instances.where((i) => i.plantId == plant.id).toList();
                if (plantInst.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Sin actividades asignadas en esta planta aún.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  );
                }
                final Map<String, List<ActivityInstance>> byArea = {};
                for (final inst in plantInst) {
                  byArea.putIfAbsent(inst.area.isEmpty ? 'General' : inst.area, () => []).add(inst);
                }
                return Column(
                  children: byArea.entries.map((e) {
                    final done = e.value.where((t) => t.done).length;
                    final pct = ((done / e.value.length) * 100).round();
                    final color = pct >= 80
                        ? const Color(0xFF16A34A)
                        : (pct >= 50 ? const Color(0xFF0284C7) : const Color(0xFFEA580C));
                    return _buildLineStatusRow(e.key, '$pct% ($done/${e.value.length} tareas)', color);
                  }).toList(),
                );
              }),
              const SizedBox(height: 16),

              Text('Personal Adscrito (${plantUsers.length} colaboradores):', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...plantUsers.map((u) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: Colors.grey.shade300, child: Text(u.iniciales, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${u.nombre} (${u.cargo})', style: const TextStyle(fontSize: 12))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                          child: Text(u.rol.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Cerrar Inspección', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildLineStatusRow(String line, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(line, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final plants = provider.allPlants;
    final users = provider.allUsers;
    final admins = users.where((u) => u.isPlantAdmin).toList();
    final operators = users.where((u) => u.isOperator).toList();

    // Métricas dinámicas reales para Torre de Control (filtradas por planta si aplica)
    final allInstances = provider.instances;
    final instances = _selectedPlantFilter == 'TODAS'
        ? allInstances
        : allInstances.where((i) => i.plantId == _selectedPlantFilter).toList();
    final filteredOperators = _selectedPlantFilter == 'TODAS'
        ? operators
        : operators.where((o) => o.plantId == _selectedPlantFilter).toList();
    final totalInstances = instances.length;
    final completedInstances = instances.where((i) => i.done).length;
    final complianceRate = totalInstances > 0 ? ((completedInstances / totalInstances) * 100).toStringAsFixed(1) : '0.0';

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

    final realGlobalPct = totalInstances > 0 ? (completedInstances / totalInstances) * 100.0 : 0.0;
    final radarScores = {
      'Calidad': realAxisPct((i) => i.category.toLowerCase().contains('calidad') || i.area.toLowerCase().contains('calidad'), realGlobalPct),
      'Seguridad': realAxisPct((i) => i.category.toLowerCase().contains('ehs') || i.category.toLowerCase().contains('seguridad') || i.area.toLowerCase().contains('seguridad'), realGlobalPct),
      '5S Piso': provider.gembaLogs.isNotEmpty
          ? (provider.gembaLogs.first['score'] as num).toDouble()
          : realAxisPct((i) => i.nombre.toLowerCase().contains('5s') || i.category.toLowerCase().contains('5s'), realGlobalPct),
      'OEE': realAxisPct((i) => i.fija, realGlobalPct),
      'Disciplina': realGlobalPct,
    };

    final plantStats = plants.map((p) {
      final pInst = instances.where((i) => i.plantId == p.id).toList();
      final pDone = pInst.where((i) => i.done).length;
      final pOverdue = pInst.where((i) => !i.done && i.day < provider.selectedDay).length;
      final pPending = (pInst.length - pDone - pOverdue).clamp(0, 9999);
      final pRate = pInst.isEmpty ? 0.0 : (pDone / pInst.length) * 100.0;
      final pOps = operators.where((o) => o.plantId == p.id).length;
      final pSups = users.where((u) => u.plantId == p.id && u.isSupervisor).length;
      return (
        plant: p,
        total: pInst.length,
        done: pDone,
        pending: pPending,
        overdue: pOverdue,
        rate: pRate,
        ops: pOps,
        sups: pSups,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA SUPERIOR ESTILO APPLE
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen Ejecutivo',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.4),
                    ),
                    Text(
                      'Indicadores consolidados en tiempo real',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _showLiveInspectionDialog(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFF34C759)),
                        SizedBox(width: 6),
                        Text('En Vivo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // FILTRO GLOBAL POR PLANTA + SUB-TABS ESTILO APPLE (RESUMEN | GRÁFICAS | SEDES)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('Todas las Plantas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _selectedPlantFilter == 'TODAS' ? Colors.white : const Color(0xFF1D1D1F))),
                    selected: _selectedPlantFilter == 'TODAS',
                    selectedColor: const Color(0xFF002F6C),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => setState(() => _selectedPlantFilter = 'TODAS'),
                  ),
                ),
                ...plants.map((p) {
                  final sel = _selectedPlantFilter == p.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(p.nombre, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                      selected: sel,
                      selectedColor: const Color(0xFF002F6C),
                      backgroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _selectedPlantFilter = p.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _towerSubTabBtn(0, 'Resumen', Icons.dashboard_outlined),
                _towerSubTabBtn(1, 'Gráficas', Icons.bar_chart_rounded),
                _towerSubTabBtn(2, 'Sedes', Icons.domain_rounded),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_towerSubTab == 0) ...[
          // TARJETAS KPI ESTILO APPLE iOS 18 (TODAS TOCABLES)
          Row(
            children: [
              Expanded(
                child: _build3DMetricCard(
                  title: 'Plantas Activas',
                  value: '${plants.length}',
                  subtitle: 'Toca para ver sedes',
                  icon: Icons.factory_rounded,
                  color: const Color(0xFF007AFF),
                  accentColor: const Color(0xFF007AFF),
                  onTap: () => widget.onNavigateTab?.call(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _build3DMetricCard(
                  title: 'Admins Planta',
                  value: '${admins.length}',
                  subtitle: 'Toca para gestionar',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF5856D6),
                  accentColor: const Color(0xFF5856D6),
                  onTap: () => widget.onNavigateTab?.call(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _build3DMetricCard(
                  title: 'Colaboradores',
                  value: '${filteredOperators.length}',
                  subtitle: 'Toca para ver detalle',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF34C759),
                  accentColor: const Color(0xFF34C759),
                  onTap: () => _showUsersListSheet(context, provider, 'Colaboradores Activos', filteredOperators),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _build3DMetricCard(
                  title: 'Cumplimiento',
                  value: '$complianceRate%',
                  subtitle: '$completedInstances/$totalInstances tareas',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFFAF52DE),
                  accentColor: const Color(0xFFAF52DE),
                  onTap: () => _showFilteredTasksSheet(
                    context,
                    provider,
                    title: 'Todas las Actividades',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // PULSO DE HOY VS SEMANA (TOCABLE)
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
                const Text('Pulso Operativo (Toca para filtrar)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPulseTile(
                      label: 'Hoy (Día ${provider.selectedDay})',
                      value: '${instances.where((i) => i.day == provider.selectedDay).length}',
                      color: const Color(0xFF002F6C),
                      onTap: () => _showFilteredTasksSheet(context, provider, title: 'Actividades de Hoy'),
                    ),
                    const SizedBox(width: 8),
                    _buildPulseTile(
                      label: 'Vencidas',
                      value: '$vencidasCount',
                      color: const Color(0xFFFF3B30),
                      onTap: () => _showFilteredTasksSheet(context, provider, title: 'Actividades Vencidas', statusFilter: 'VENCIDA'),
                    ),
                    const SizedBox(width: 8),
                    _buildPulseTile(
                      label: 'Con Plan',
                      value: '${instances.where((i) => i.requierePlanAccion || i.planAccionObligatorio).length}',
                      color: const Color(0xFFFF9500),
                      onTap: () => _showPlansSheet(context, provider),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildActionPlansLiveCard(context, provider),
          const SizedBox(height: 14),
          // TABLERO DE GOBERNANZA OPERATIVA REAL (APPLE DARK GLASS · TOCABLE)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Color(0xFF0A84FF), size: 19),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Gobernanza Operativa',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('En Vivo', style: TextStyle(color: Color(0xFF30D158), fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onNavigateTab?.call(3),
                        child: _buildRealMetricBox(
                          'Solicitudes >10',
                          '${provider.extraTaskRequests.where((r) => r.estado == 'Pendiente').length}',
                          'Toca para revisar',
                          const Color(0xFFFF9F0A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showDirectivesSheet(context, provider),
                        child: _buildRealMetricBox(
                          'Directivas',
                          '${provider.announcements.length}',
                          'Toca para gestionar',
                          const Color(0xFF0A84FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onNavigateTab?.call(5),
                        child: _buildRealMetricBox(
                          'Auditorías',
                          '${provider.auditLogs.length}',
                          'Toca para ver logs',
                          const Color(0xFF30D158),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ] else if (_towerSubTab == 1) ...[
          // SUB-TAB 1: ANALÍTICA Y GRÁFICAS AVANZADAS (100% REALES Y TOCABLES)
          _buildPlantDayHeatmapCard(context, provider, plants, allInstances),
          const SizedBox(height: 16),

          // SEMÁFORO DE CUMPLIMIENTO POR PLANTA (ESTILO APPLE)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Cumplimiento por Planta (%)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('>90% Óptimo', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text('Estándar de calidad, seguridad y mantenimiento de turnos', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
                const SizedBox(height: 18),
                SizedBox(
                  height: 175,
                  child: plantStats.isEmpty
                      ? const Center(child: Text('Sin plantas registradas', style: TextStyle(color: Color(0xFF8E8E93))))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final st = plantStats[group.x.toInt()];
                                  return BarTooltipItem(
                                    '${st.plant.nombre}\n${st.rate.toStringAsFixed(1)}% (${st.done}/${st.total} tareas)',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (val, meta) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= plantStats.length) return const Text('');
                                    final code = plantStats[idx].plant.codigo.isNotEmpty
                                        ? plantStats[idx].plant.codigo
                                        : plantStats[idx].plant.nombre.replaceAll('Planta ', '');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(code, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3A3A3C))),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (val, meta) => Text('${val.toInt()}%', style: const TextStyle(fontSize: 9.5, color: Color(0xFF8E8E93))),
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 25,
                              getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF2F2F7), strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(plantStats.length, (i) {
                              final st = plantStats[i];
                              final barColor = st.rate >= 90
                                  ? const Color(0xFF34C759)
                                  : (st.rate >= 60 ? const Color(0xFF007AFF) : const Color(0xFFFF9500));
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: st.rate.clamp(2.0, 100.0),
                                    color: barColor,
                                    width: 24,
                                    borderRadius: BorderRadius.circular(8),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: const Color(0xFFF2F2F7),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
                if (plantStats.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF2F2F7)),
                  const SizedBox(height: 10),
                  ...plantStats.map((st) {
                    final badgeColor = st.rate >= 90
                        ? const Color(0xFF34C759)
                        : (st.rate >= 60 ? const Color(0xFF007AFF) : const Color(0xFFFF3B30));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              st.plant.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${st.done}/${st.total} · ${st.pending} pend',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${st.rate.toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // FILA RESPONSIVA 1: TENDENCIA SEMANAL MULTIPLANTA + ESTADO DE CUMPLIMIENTO OPERATIVO
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final trendCard = WeeklyTrendLineCard(
                values: weeklyTrend,
                title: 'Tendencia Semanal Multiplanta',
                subtitle: 'Evolución de cumplimiento Lunes a Viernes',
              );
              final statusCard = TaskStatusDoughnutCard(
                completadas: completadasCount,
                pendientes: pendientesCount,
                vencidas: vencidasCount,
                title: 'ESTADO OPERATIVO CORPORATIVO',
                subtitle: 'Toca un estado para ver el detalle de actividades',
                onSegmentTap: (status) => _showFilteredTasksSheet(
                  context,
                  provider,
                  title: status == 'COMPLETADA'
                      ? 'Actividades Completadas'
                      : status == 'VENCIDA'
                          ? 'Actividades Vencidas / Novedad'
                          : 'Actividades En Progreso / Pendientes',
                  statusFilter: status,
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: trendCard),
                    const SizedBox(width: 16),
                    Expanded(child: statusCard),
                  ],
                );
              }
              return Column(
                children: [
                  trendCard,
                  const SizedBox(height: 16),
                  statusCard,
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // FILA RESPONSIVA 2: DESGLOSE DE CRITICIDAD + RADAR 5S
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final critCard = CriticalityPieChartCard(
                alta: altaTasks,
                media: mediaTasks,
                baja: bajaTasks,
                onSegmentTap: (crit) => _showFilteredTasksSheet(
                  context,
                  provider,
                  title: 'Actividades de Criticidad $crit',
                  criticalityFilter: crit,
                ),
              );
              final radarCard = Radar5SChartCard(
                scores: radarScores,
                onPillarTap: (pillar, score) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF1D1D1F),
                      content: Text('$pillar: ${score.toStringAsFixed(1)}% real consolidado'),
                    ),
                  );
                },
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: critCard),
                    const SizedBox(width: 16),
                    Expanded(child: radarCard),
                  ],
                );
              }
              return Column(
                children: [
                  critCard,
                  const SizedBox(height: 16),
                  radarCard,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // CUMPLIMIENTO POR ÁREA + NUEVAS GRÁFICAS OPERATIVAS (100% REALES Y TOCABLES)
          _buildAreaComplianceCard(context, provider),
          const SizedBox(height: 16),
          _buildDailyGroupedBarCard(context, provider, instances),
          const SizedBox(height: 16),
          _buildOwnerWorkloadCard(context, provider, instances, users),
          const SizedBox(height: 16),
          _buildModalitySplitCard(context, provider, instances),
          ] else ...[
          // SUB-TAB 2: RANKING Y SEDES INSPECCIONABLES
          // RANKING REAL POR PLANTA (APPLE CARD)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFF9500), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Ranking Real por Planta',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.ios_share_rounded, size: 18, color: Color(0xFF007AFF)),
                      tooltip: 'Exportar Ranking',
                      onPressed: () => ExcelService.instance.exportAndShare(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (plantStats.isEmpty)
                  const Text('Sin plantas registradas aún.', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))
                else
                  ...(() {
                    final ranked = List.of(plantStats)..sort((a, b) => b.rate.compareTo(a.rate));
                    const medals = ['🥇 1°', '🥈 2°', '🥉 3°'];
                    return List.generate(ranked.length, (i) {
                      final st = ranked[i];
                      final badge = i < medals.length ? medals[i] : '${i + 1}°';
                      final c = st.rate >= 80
                          ? const Color(0xFF34C759)
                          : (st.rate >= 50 ? const Color(0xFF007AFF) : const Color(0xFFFF9500));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _inspectPlant(context, st.plant, users),
                          child: _buildBenchmarkingRow(
                            badge,
                            st.plant.nombre,
                            '${st.rate.toStringAsFixed(1)}%',
                            '${st.done}/${st.total} tareas · ${st.ops} op.',
                            c,
                          ),
                        ),
                      );
                    });
                  })(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // LISTADO DE PLANTAS INSPECCIONABLES
          const Text(
            'Sedes Industriales Darnel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.2),
          ),
          const SizedBox(height: 2),
          const Text(
            'Toca una sede para inspeccionar áreas y responsables',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final st = plantStats[index];
              final plant = st.plant;
              final plantOps = st.ops;
              final plantAdmin = users.firstWhere(
                (u) => u.id == plant.adminId,
                orElse: () => users.first,
              );
              final pctColor = st.rate >= 90
                  ? const Color(0xFF34C759)
                  : (st.rate >= 60 ? const Color(0xFF007AFF) : const Color(0xFFFF9500));

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _inspectPlant(context, plant, users),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.domain_rounded, color: Color(0xFF007AFF), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plant.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${plant.codigo} · ${plant.ubicacion}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Inspeccionar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                                  SizedBox(width: 2),
                                  Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFF007AFF)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildPlantStatPill('${st.rate.toStringAsFixed(0)}% Cumpl.', pctColor),
                            _buildPlantStatPill('Tareas: ${st.done}/${st.total}', const Color(0xFF1D1D1F)),
                            _buildPlantStatPill('Pendientes: ${st.pending}', const Color(0xFF007AFF)),
                            if (st.overdue > 0) _buildPlantStatPill('Vencidas: ${st.overdue}', const Color(0xFFFF3B30)),
                            _buildPlantStatPill('Sup: ${st.sups} · Op: $plantOps', const Color(0xFF8E8E93)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF2F2F7)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Admin: ${plantAdmin.nombre}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3C)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$plantOps Colaboradores',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ],
        ],
      ),
    );
  }

  Widget _towerSubTabBtn(int index, String label, IconData icon) {
    final active = _towerSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _towerSubTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF002F6C) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? Colors.white : const Color(0xFF3A3A3C)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF3A3A3C)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantDayHeatmapCard(BuildContext context, StandardWorkProvider provider, List<PlantModel> plants, List<ActivityInstance> allInstances) {
    const days = [(1, 'L'), (2, 'M'), (3, 'X'), (4, 'J'), (5, 'V'), (6, 'S')];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mapa de Calor: Planta × Día', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
          const SizedBox(height: 2),
          const Text('Cumplimiento diario real por sede (toca una celda)', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 96, child: Text('Sede', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8E8E93)))),
              ...days.map((d) => Expanded(child: Center(child: Text(d.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF002F6C)))))),
            ],
          ),
          const SizedBox(height: 6),
          if (plants.isEmpty)
            const Text('Sin plantas registradas.', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))
          else
            ...plants.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(p.codigo.isNotEmpty ? p.codigo : p.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                      ...days.map((d) {
                        final cell = allInstances.where((i) => i.plantId == p.id && i.day == d.$1).toList();
                        final done = cell.where((i) => i.done).length;
                        final pct = cell.isEmpty ? -1.0 : (done / cell.length) * 100.0;
                        final bg = pct < 0
                            ? const Color(0xFFF2F2F7)
                            : (pct >= 90 ? const Color(0xFF34C759) : (pct >= 50 ? const Color(0xFF007AFF) : const Color(0xFFFF9500)));
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _showFilteredTasksSheet(context, provider, title: '${p.nombre} · Día ${d.$2}', plantFilter: p.id),
                              child: Container(
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: pct < 0 ? bg : bg.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: pct < 0 ? const Color(0xFFE5E5EA) : bg.withValues(alpha: 0.45)),
                                ),
                                child: Text(
                                  pct < 0 ? '—' : '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: pct < 0 ? const Color(0xFF8E8E93) : bg),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildDailyGroupedBarCard(BuildContext context, StandardWorkProvider provider, List<ActivityInstance> instances) {
    const dayLabels = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};
    final dayCounts = List.generate(6, (idx) {
      final d = idx + 1;
      final sub = instances.where((i) => i.day == d).toList();
      final done = sub.where((i) => i.done).length;
      final pend = sub.length - done;
      return (day: d, done: done, pend: pend);
    });
    final maxY = dayCounts.fold<int>(4, (m, e) => [m, e.done, e.pend].reduce((a, b) => a > b ? a : b)).toDouble() + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Completadas vs. Pendientes por Día', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
          const SizedBox(height: 2),
          const Text('Verde = Hechas · Rojo = Pendientes (Lun a Sáb)', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
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
    );
  }

  Widget _buildOwnerWorkloadCard(BuildContext context, StandardWorkProvider provider, List<ActivityInstance> instances, List<UserProfile> users) {
    final usersById = {for (final u in users) u.id: u};
    final Map<String, List<ActivityInstance>> byOwner = {};
    for (final i in instances) {
      byOwner.putIfAbsent(i.userId, () => []).add(i);
    }
    final ranked = byOwner.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Carga y Cumplimiento por Responsable', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
          const SizedBox(height: 2),
          const Text('Top colaboradores con actividades asignadas', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
          const SizedBox(height: 12),
          if (ranked.isEmpty)
            const Text('Sin actividades asignadas aún.', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))
          else
            ...ranked.take(6).map((e) {
              final u = usersById[e.key];
              final name = (u != null && u.nombre.isNotEmpty) ? u.nombre : (e.key == 'UNASSIGNED' ? 'Sin asignar' : e.key);
              final done = e.value.where((x) => x.done).length;
              final pct = e.value.isEmpty ? 0.0 : (done / e.value.length);
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(value: pct, minHeight: 7, backgroundColor: const Color(0xFFF2F2F7), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002F6C))),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildModalitySplitCard(BuildContext context, StandardWorkProvider provider, List<ActivityInstance> instances) {
    final exec = instances.where((i) => i.tipoActividad != 'registro').toList();
    final meet = instances.where((i) => i.tipoActividad == 'registro').toList();
    final execDone = exec.where((i) => i.done).length;
    final meetDone = meet.where((i) => i.done).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ejecución vs. Registro / Reunión', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPulseTile(
                label: 'Ejecución (${exec.length})',
                value: '$execDone hechas',
                color: const Color(0xFF002F6C),
                onTap: () => _showFilteredTasksSheet(context, provider, title: 'Actividades de Ejecución'),
              ),
              const SizedBox(width: 10),
              _buildPulseTile(
                label: 'Reuniones (${meet.length})',
                value: '$meetDone hechas',
                color: const Color(0xFF007AFF),
                onTap: () => _showFilteredTasksSheet(context, provider, title: 'Registros / Reuniones'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlantStatPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _build3DMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                    child: Icon(icon, size: 15, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Color(0xFF8E8E93))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseTile({required String label, required String value, required Color color, required VoidCallback onTap}) {
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

  Widget _buildAreaComplianceCard(BuildContext context, StandardWorkProvider provider) {
    final Map<String, List<ActivityInstance>> byArea = {};
    for (final i in provider.instances) {
      final a = i.area.trim().isEmpty ? 'General' : i.area.trim();
      byArea.putIfAbsent(a, () => []).add(i);
    }
    final entries = byArea.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cumplimiento por Área (Real)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
          const SizedBox(height: 2),
          const Text('Toca un área para ver sus actividades', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93))),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text('Sin áreas con actividades registradas aún.', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))
          else
            ...entries.take(6).map((e) {
              final done = e.value.where((x) => x.done).length;
              final pct = e.value.isEmpty ? 0.0 : (done / e.value.length);
              final color = pct >= 0.9 ? const Color(0xFF34C759) : (pct >= 0.5 ? const Color(0xFF007AFF) : const Color(0xFFFF9500));
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _showFilteredTasksSheet(context, provider, title: 'Área: ${e.key}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)))),
                          Text('$done/${e.value.length} (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFF2F2F7),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActionPlansLiveCard(BuildContext context, StandardWorkProvider provider) {
    final plans = provider.proPlans;
    final pend = plans.where((p) => p.estado == 'Pendiente').length;
    final proc = plans.where((p) => p.estado == 'En Proceso' || p.estado == 'En Revisión').length;
    final done = plans.where((p) => p.estado == 'Cumplido').length;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showPlansSheet(context, provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Planes de Acción en Vivo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                ),
                Text('Ver todos (${plans.length}) ›', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPulseTile(label: 'Pendientes', value: '$pend', color: const Color(0xFFFF3B30), onTap: () => _showPlansSheet(context, provider)),
                const SizedBox(width: 8),
                _buildPulseTile(label: 'En Proceso', value: '$proc', color: const Color(0xFFFF9500), onTap: () => _showPlansSheet(context, provider)),
                const SizedBox(width: 8),
                _buildPulseTile(label: 'Cumplidos', value: '$done', color: const Color(0xFF34C759), onTap: () => _showPlansSheet(context, provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUsersListSheet(BuildContext context, StandardWorkProvider provider, String title, List<UserProfile> users) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('$title (${users.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            if (users.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('Sin usuarios registrados.')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFF002F6C), child: Text(u.iniciales, style: const TextStyle(color: Colors.white, fontSize: 12))),
                      title: Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text('${u.cargo} · Planta: ${u.plantId}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30)),
                        tooltip: 'Eliminar usuario',
                        onPressed: () async {
                          await provider.deleteUserFromCloud(u.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
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

  void _showPlansSheet(BuildContext context, StandardWorkProvider provider) {
    final plans = provider.proPlans;
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
                Expanded(child: Text('Planes de Acción (${plans.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            if (plans.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('No hay planes de acción creados aún.')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = plans[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.plan, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          const SizedBox(height: 4),
                          Text('Planta: ${p.plantId} · Resp: ${p.responsable} · ${p.estado} (${p.porcentajeAvance.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11.5, color: Color(0xFF86868B))),
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

  void _showDirectivesSheet(BuildContext context, StandardWorkProvider provider) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Directivas Corporativas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título de la Directiva', isDense: true)),
              const SizedBox(height: 8),
              TextField(controller: bodyCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mensaje oficial', isDense: true)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;
                    provider.postAnnouncement(
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                      author: provider.currentUser?.nombre ?? 'Super Admin',
                    );
                    titleCtrl.clear();
                    bodyCtrl.clear();
                    setSheetState(() {});
                  },
                  child: const Text('Publicar Directiva', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const Divider(height: 22),
              Expanded(
                child: provider.announcements.isEmpty
                    ? const Center(child: Text('Sin directivas publicadas.', style: TextStyle(color: Color(0xFF86868B))))
                    : ListView.separated(
                        itemCount: provider.announcements.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final a = provider.announcements[i];
                          return ListTile(
                            tileColor: const Color(0xFFF5F5F7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text('${a['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: Text('${a['body'] ?? ''}', style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenchmarkingRow(String rank, String plant, String score, String detail, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
      ),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plant, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              score,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealMetricBox(String title, String val, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 9), maxLines: 1),
        ],
      ),
    );
  }
}

/// TAB NUEVA: BANDEJA DE APROBACIÓN DE TAREAS EXCEPCIONALES (>10 TAREAS)
class _SuperAdminExtraTasksApprovalTab extends StatelessWidget {
  const _SuperAdminExtraTasksApprovalTab();

  void _reviewDialog(BuildContext context, ExtraTaskRequestModel req, StandardWorkProvider provider) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFF002F6C)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Revisión de Tarea Excepcional (>10)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Planta Solicitante: ${req.plantId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002F6C))),
              const SizedBox(height: 4),
              Text('Tarea propuesta: ${req.nombre}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Horario: ${req.timeStart} - ${req.timeEnd} · Área: ${req.area}'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prioridad declarada: ${req.prioridad.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    const SizedBox(height: 4),
                    Text('Justificación del Administrador:\n"${req.justificacion}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observación de Dirección (en caso de rechazo)',
                  hintText: 'Ej. No autorizada por balance de cargas...',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.reviewExtraTaskRequest(
                requestId: req.id!,
                approve: false,
                motivoRechazo: reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : 'Rechazada por capacidad operativa excedida',
                assignedUserId: 'ALL',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: Color(0xFFDC2626), content: Text('Solicitud rechazada. Se notificó a la planta.')),
                );
              }
            },
            child: const Text('Rechazar', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.reviewExtraTaskRequest(
                requestId: req.id!,
                approve: true,
                assignedUserId: 'ALL',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('¡Tarea adicional #11+ APROBADA y habilitada en planta!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Aprobar Tarea', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final requests = provider.extraTaskRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: requests.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF34C759)),
                      SizedBox(height: 12),
                      Text(
                        'Sin solicitudes pendientes',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF1D1D1F), fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Todas las plantas se mantienen dentro del estándar operativo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = requests[index];
                Color priColor;
                switch (req.prioridad) {
                  case 'Alta':
                    priColor = const Color(0xFFDC2626);
                    break;
                  case 'Media':
                    priColor = const Color(0xFFD97706);
                    break;
                  default:
                    priColor = const Color(0xFF0284C7);
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: App3D.cardShadow(baseColor: priColor),
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
                                color: priColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SOLICITUD #11+ · ${req.prioridad.toUpperCase()}',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: priColor),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: req.estado == 'Aprobada'
                                    ? const Color(0xFFDCFCE7)
                                    : (req.estado == 'Rechazada' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                req.estado.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: req.estado == 'Aprobada'
                                      ? const Color(0xFF166534)
                                      : (req.estado == 'Rechazada' ? const Color(0xFF991B1B) : const Color(0xFF92400E)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Planta: ${req.plantId} · Solicitó: ${req.adminId}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(req.nombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text('Justificación: "${req.justificacion}"', style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontStyle: FontStyle.italic)),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${req.timeStart} - ${req.timeEnd} · ${req.area}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            if (req.estado == 'Pendiente')
                              ElevatedButton.icon(
                                onPressed: () => _reviewDialog(context, req, provider),
                                icon: const Icon(Icons.rate_review_rounded, size: 14, color: Colors.white),
                                label: const Text('Revisar Solicitud', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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

/// TAB 2: GESTIÓN DE ADMINISTRADORES DE PLANTA CON CREACIÓN DE SEDES
class _SuperAdminPlantAdminsTab extends StatelessWidget {
  const _SuperAdminPlantAdminsTab();

  void _showCreateProcessWithAdminModal(BuildContext context, StandardWorkProvider provider) {
    final procIdCtrl = TextEditingController(text: 'PL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final procCodCtrl = TextEditingController(text: 'PRC-0${provider.allPlants.length + 1}');
    final procNomCtrl = TextEditingController();
    final procUbiCtrl = TextEditingController(text: 'Planta Principal Darnel');

    final adminIdCtrl = TextEditingController(text: 'AD-0${provider.allPlants.length + 1}');
    final adminCedulaCtrl = TextEditingController();
    final adminNomCtrl = TextEditingController();
    final adminCargoCtrl = TextEditingController(text: 'Gerente / Admin de Proceso');
    final adminEmailCtrl = TextEditingController();
    final adminPinCtrl = TextEditingController(text: '1234');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF002F6C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.add_business_rounded, color: Color(0xFF002F6C), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nuevo Proceso & Administrador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
                            Text('Creación atómica de proceso y asignación de admin en un solo paso', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('1. DATOS DEL PROCESO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(controller: procNomCtrl, decoration: const InputDecoration(labelText: 'Nombre del Proceso *', hintText: 'Ej. Extrusión Lámina PET')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: procCodCtrl, decoration: const InputDecoration(labelText: 'Código (ej. EXT-01)'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: procUbiCtrl, decoration: const InputDecoration(labelText: 'Ubicación / Sede'))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('2. ADMINISTRADOR RESPONSABLE DEL PROCESO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(controller: adminNomCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo del Administrador *', hintText: 'Ej. Ing. Yonny López')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: adminCedulaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cédula *'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: adminPinCtrl, keyboardType: TextInputType.number, maxLength: 4, decoration: const InputDecoration(labelText: 'PIN de Acceso (4 dígitos) *', counterText: ''))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: adminCargoCtrl, decoration: const InputDecoration(labelText: 'Cargo'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: adminEmailCtrl, decoration: const InputDecoration(labelText: 'Correo Corporativo'))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: const Text('Crear Proceso y Asignar Administrador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C), padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        if (procNomCtrl.text.trim().isEmpty || adminNomCtrl.text.trim().isEmpty || adminCedulaCtrl.text.trim().isEmpty || adminPinCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa los campos obligatorios (*)')));
                          return;
                        }
                        final error = await provider.createProcessWithAdmin(
                          processId: procIdCtrl.text.trim(),
                          codigo: procCodCtrl.text.trim(),
                          nombreProceso: procNomCtrl.text.trim(),
                          ubicacion: procUbiCtrl.text.trim(),
                          adminCedula: adminCedulaCtrl.text.trim(),
                          adminNombre: adminNomCtrl.text.trim(),
                          adminCargo: adminCargoCtrl.text.trim(),
                          adminEmail: adminEmailCtrl.text.trim(),
                          adminPin: adminPinCtrl.text.trim(),
                        );
                        if (error != null) {
                          if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: const Color(0xFFDC2626)));
                        } else {
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceso y Administrador creados exitosamente en una sola transacción'), backgroundColor: Color(0xFF16A34A)));
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditAdminDialog(BuildContext context, UserProfile admin, StandardWorkProvider provider) {
    final nombreCtrl = TextEditingController(text: admin.nombre);
    final cargoCtrl = TextEditingController(text: admin.cargo);
    final cedulaCtrl = TextEditingController(text: admin.cedula);
    final emailCtrl = TextEditingController(text: admin.email);
    final pinCtrl = TextEditingController();
    String selectedPlantId = admin.plantId;
    bool activo = admin.activo;
    bool saving = false;

    final plantIds = provider.allPlants.map((p) => p.id).toList();
    if (!plantIds.contains(selectedPlantId) && plantIds.isNotEmpty) {
      selectedPlantId = plantIds.first;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF002F6C).withValues(alpha: 0.12),
                child: Text(admin.iniciales, style: const TextStyle(color: Color(0xFF002F6C), fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Editar ${admin.nombre}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cargoCtrl,
                  decoration: InputDecoration(labelText: 'Cargo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cedulaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Cédula / Documento', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Correo Corporativo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true),
                ),
                const SizedBox(height: 10),
                if (provider.allPlants.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: selectedPlantId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: 'Planta / Proceso Asignado', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true),
                    items: provider.allPlants
                        .map((p) => DropdownMenuItem(value: p.id, child: Text('${p.nombre} (${p.codigo})', overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedPlantId = v ?? selectedPlantId),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: pinCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nuevo PIN de Acceso (opcional)',
                    hintText: 'Dejar vacío para mantener el actual',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Usuario Activo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  value: activo,
                  activeThumbColor: const Color(0xFF34C759),
                  onChanged: (v) => setModalState(() => activo = v),
                ),
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
                      if (newPin.isNotEmpty && newPin.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Color(0xFFDC2626), content: Text('El PIN debe tener al menos 4 dígitos')),
                        );
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        await provider.updateFullUser(
                          userId: admin.id,
                          cedula: cedulaCtrl.text.trim(),
                          nombre: nombreCtrl.text.trim(),
                          cargo: cargoCtrl.text.trim(),
                          area: admin.area,
                          email: emailCtrl.text.trim(),
                          rol: admin.rol,
                          plantId: selectedPlantId,
                          activo: activo,
                          newPin: newPin.isNotEmpty ? newPin : null,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF16A34A),
                              content: Text(newPin.isNotEmpty ? 'Datos y nuevo PIN guardados en la nube' : 'Datos actualizados en la nube'),
                            ),
                          );
                        }
                      } catch (e) {
                        setModalState(() => saving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: Text(saving ? 'Guardando...' : 'Guardar Cambios', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAdmin(BuildContext context, UserProfile admin, StandardWorkProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar Eliminación', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
        content: Text('¿Deseas dar de baja al Administrador ${admin.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteUserFromCloud(admin.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Administrador eliminado de la nube')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final admins = provider.allUsers.where((u) => u.isPlantAdmin).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: admins.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Sin procesos ni administradores creados.\nToca "+ Nuevo Proceso" para comenzar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: admins.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final admin = admins[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.12),
                        child: Text(admin.iniciales, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(admin.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1D1D1F))),
                            const SizedBox(height: 2),
                            Text(admin.cargo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(999)),
                                  child: Text('Planta: ${admin.plantId}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3C))),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFF002F6C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                                  child: Text(
                                    admin.pin.isNotEmpty ? 'PIN: ${admin.pin}' : 'PIN activo',
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (admin.activo ? const Color(0xFF34C759) : const Color(0xFFFF3B30)).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    admin.activo ? 'Activo' : 'Inactivo',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: admin.activo ? const Color(0xFF16A34A) : const Color(0xFFFF3B30)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF007AFF), size: 20),
                        tooltip: 'Editar Administrador',
                        onPressed: () => _showEditAdminDialog(context, admin, provider),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30), size: 20),
                        tooltip: 'Dar de Baja',
                        onPressed: () => _confirmDeleteAdmin(context, admin, provider),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_new_process',
        onPressed: () => _showCreateProcessWithAdminModal(context, provider),
        backgroundColor: const Color(0xFF007AFF),
        elevation: 2,
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: const Text('Nuevo Proceso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// TAB 3: DESPACHO CORPORATIVO GLOBAL
class _SuperAdminCorporateDispatchTab extends StatefulWidget {
  const _SuperAdminCorporateDispatchTab();

  @override
  State<_SuperAdminCorporateDispatchTab> createState() => _SuperAdminCorporateDispatchTabState();
}

class _SuperAdminCorporateDispatchTabState extends State<_SuperAdminCorporateDispatchTab> {
  String _search = '';
  String _plantFilter = 'ALL';
  int _dayFilter = 0; // 0 = Todos, 1..6 = Lun..Sáb
  bool _scheduleView = false; // false = Lista, true = Horario / Calendario

  void _openCreateDispatchSheet(BuildContext context, {ActivityInstance? editingActivity}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        height: MediaQuery.of(sheetCtx).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editingActivity != null ? 'Editar Actividad Corporativa' : 'Nueva Actividad Corporativa',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          editingActivity != null
                              ? 'Actualiza horario, área, tipo o plan de acción'
                              : 'Crea y asigna rutinas marco a una o todas las plantas',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _SuperAdminCorporateDispatchForm(
                editingActivity: editingActivity,
                onDispatched: () {
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
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
    final usersById = {for (final u in provider.allUsers) u.id: u};
    final plants = provider.allPlants;

    final filtered = provider.instances.where((inst) {
      final owner = usersById[inst.userId];
      if (_plantFilter != 'ALL' && inst.plantId != _plantFilter && owner?.plantId != _plantFilter) return false;
      if (_dayFilter != 0 && inst.day != _dayFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final ownerName = (owner?.nombre ?? '').toLowerCase();
        if (!inst.nombre.toLowerCase().contains(q) &&
            !inst.area.toLowerCase().contains(q) &&
            !ownerName.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Agrupar actividades repetidas por nombre + horario y ordenar cronológicamente
    final Map<String, List<ActivityInstance>> groupedMap = {};
    for (final inst in filtered) {
      final key = '${inst.nombre}__${inst.timeStart}__${inst.timeEnd}';
      groupedMap.putIfAbsent(key, () => []).add(inst);
    }
    final groups = groupedMap.values.toList()
      ..sort((a, b) => a.first.timeStart.compareTo(b.first.timeStart));

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Actividades Corporativas',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.3),
                              ),
                              Text(
                                '${groups.length} rutinas únicas · ${filtered.length} asignaciones',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.category_rounded, size: 15, color: Color(0xFF007AFF)),
                              label: const Text('Áreas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFBFDBFE)),
                              onPressed: () => _openCatalogsManagerSheet(context),
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              avatar: const Icon(Icons.auto_stories_rounded, size: 15, color: Color(0xFF002F6C)),
                              label: const Text('Plantillas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              onPressed: () {
                                TemplatesModal.show(
                                  context: context,
                                  onSelectTemplate: (_) => _openCreateDispatchSheet(context),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // TARJETAS RESUMEN ARRIBA (ESTILO APPLE)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDispatchKpiCard(
                            'Rutinas',
                            '${groups.length}',
                            const Color(0xFF007AFF),
                            Icons.layers_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDispatchKpiCard(
                            'Hechas',
                            '${filtered.where((i) => i.done).length}',
                            const Color(0xFF34C759),
                            Icons.check_circle_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDispatchKpiCard(
                            'Pendientes',
                            '${filtered.where((i) => !i.done).length}',
                            const Color(0xFFFF3B30),
                            Icons.pending_actions_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDispatchKpiCard(
                            'Con Plan',
                            '${groups.where((g) => g.first.requierePlanAccion || g.first.planAccionObligatorio).length}',
                            const Color(0xFFFF9500),
                            Icons.flag_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar por actividad, área o responsable...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8E8E93)),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('Todas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _plantFilter == 'ALL' ? Colors.white : const Color(0xFF1D1D1F))),
                              selected: _plantFilter == 'ALL',
                              selectedColor: const Color(0xFF007AFF),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: _plantFilter == 'ALL' ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA)),
                              onSelected: (_) => setState(() => _plantFilter = 'ALL'),
                            ),
                          ),
                          ...plants.map((p) {
                            final sel = _plantFilter == p.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(p.nombre, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                selected: sel,
                                selectedColor: const Color(0xFF007AFF),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: sel ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA)),
                                onSelected: (_) => setState(() => _plantFilter = p.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // FILTRO POR DÍA + MODO LISTA / HORARIO
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                (0, 'Todos'),
                                (1, 'Lun'),
                                (2, 'Mar'),
                                (3, 'Mié'),
                                (4, 'Jue'),
                                (5, 'Vie'),
                                (6, 'Sáb'),
                              ].map((d) {
                                final sel = _dayFilter == d.$1;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(d.$2, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                    selected: sel,
                                    selectedColor: const Color(0xFF002F6C),
                                    backgroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                    side: BorderSide(color: sel ? const Color(0xFF002F6C) : const Color(0xFFE5E5EA)),
                                    onSelected: (_) => setState(() => _dayFilter = d.$1),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _viewToggleBtn(
                                icon: Icons.view_agenda_outlined,
                                label: 'Lista',
                                active: !_scheduleView,
                                onTap: () => setState(() => _scheduleView = false),
                              ),
                              _viewToggleBtn(
                                icon: Icons.calendar_view_day_rounded,
                                label: 'Horario',
                                active: _scheduleView,
                                onTap: () => setState(() => _scheduleView = true),
                              ),
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
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 125),
                            itemCount: groups.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, idx) {
                              final grp = groups[idx];
                              final first = grp.first;
                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _openGroupDetailSheet(context, grp, usersById),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE5E5EA)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 68,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF002F6C).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
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
                                            Text(first.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${first.area} · ${first.plantId} · ${grp.length} asig.',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF002F6C)),
                                        onPressed: () => _openCreateDispatchSheet(context, editingActivity: first),
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
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 125),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 118,
                              ),
                              itemCount: groups.length,
                              itemBuilder: (_, idx) => _buildCorporateGroupCard(groups[idx], usersById),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 125),
                            itemCount: groups.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, idx) => _buildCorporateGroupCard(groups[idx], usersById),
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
            heroTag: 'superadmin_create_act_fab',
            onPressed: () => _openCreateDispatchSheet(context),
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

  Widget _buildCorporateGroupCard(List<ActivityInstance> group, Map<String, UserProfile> usersById) {
    final first = group.first;
    final doneCount = group.where((i) => i.done).length;
    final pct = group.isEmpty ? 0.0 : doneCount / group.length;
    final allDone = doneCount == group.length;
    final accentColor = allDone ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    final plantNames = group
        .map((i) => usersById[i.userId]?.plantId)
        .whereType<String>()
        .toSet()
        .toList();
    final ownerNames = group
        .map((i) => usersById[i.userId]?.nombre)
        .whereType<String>()
        .toSet()
        .toList();

    final scopeLabel = plantNames.isEmpty
        ? 'Corporativa'
        : plantNames.length == 1
            ? plantNames.first
            : '${plantNames.length} plantas';
    final peopleLabel = ownerNames.isEmpty
        ? 'Sin asignar'
        : ownerNames.length == 1
            ? ownerNames.first
            : '${ownerNames.first} +${ownerNames.length - 1}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openGroupDetailSheet(context, group, usersById),
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
                      '$scopeLabel · $peopleLabel · ${first.timeStart}-${first.timeEnd}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF007AFF)),
                tooltip: 'Editar Actividad',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: () => _openCreateDispatchSheet(context, editingActivity: first),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF3B30)),
                tooltip: 'Eliminar Actividad',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: () async {
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
                },
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

  Future<void> _confirmDeleteGroup(BuildContext context, List<ActivityInstance> group) async {
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

  void _openGroupDetailSheet(BuildContext context, List<ActivityInstance> group, Map<String, UserProfile> usersById) {
    final first = group.first;
    final doneCount = group.where((i) => i.done).length;
    const dayLabels = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};
    String sheetPlant = 'ALL';
    int sheetDay = 0;
    String sheetStatus = 'ALL'; // ALL, PENDING, DONE

    final plantOptions = <String>{
      for (final inst in group) (usersById[inst.userId]?.plantId ?? inst.plantId),
    }.where((p) => p.isNotEmpty).toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final filteredGroup = group.where((inst) {
            final ownerPlant = usersById[inst.userId]?.plantId ?? inst.plantId;
            if (sheetPlant != 'ALL' && ownerPlant != sheetPlant) return false;
            if (sheetDay != 0 && inst.day != sheetDay) return false;
            if (sheetStatus == 'PENDING' && inst.done) return false;
            if (sheetStatus == 'DONE' && !inst.done) return false;
            return true;
          }).toList();

          return Container(
            height: MediaQuery.of(sheetCtx).size.height * 0.86,
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
                                Text(
                                  '${first.area} · ${first.timeStart}-${first.timeEnd} · $doneCount/${group.length} completadas',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF86868B)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Editar Actividad',
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF002F6C), size: 20),
                            onPressed: () {
                              Navigator.of(sheetCtx).pop();
                              _openCreateDispatchSheet(context, editingActivity: first);
                            },
                          ),
                          IconButton(
                            tooltip: 'Eliminar Actividad',
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30), size: 20),
                            onPressed: () {
                              Navigator.of(sheetCtx).pop();
                              _confirmDeleteGroup(context, group);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                          ),
                        ],
                      ),
                      if (first.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(first.descripcion, style: const TextStyle(fontSize: 12, color: Color(0xFF3A3A3C))),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // FILTROS POR PLANTA, DÍA Y ESTADO
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('Todas (${group.length})', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sheetPlant == 'ALL' ? Colors.white : const Color(0xFF1D1D1F))),
                                selected: sheetPlant == 'ALL',
                                selectedColor: const Color(0xFF002F6C),
                                backgroundColor: const Color(0xFFF5F5F7),
                                visualDensity: VisualDensity.compact,
                                onSelected: (_) => setSheetState(() => sheetPlant = 'ALL'),
                              ),
                            ),
                            ...plantOptions.map((pl) {
                              final sel = sheetPlant == pl;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(pl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                  selected: sel,
                                  selectedColor: const Color(0xFF002F6C),
                                  backgroundColor: const Color(0xFFF5F5F7),
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (_) => setSheetState(() => sheetPlant = pl),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...[
                              (0, 'Todos días'),
                              (1, 'Lun'),
                              (2, 'Mar'),
                              (3, 'Mié'),
                              (4, 'Jue'),
                              (5, 'Vie'),
                              (6, 'Sáb'),
                            ].map((d) {
                              final sel = sheetDay == d.$1;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(d.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF1D1D1F))),
                                  selected: sel,
                                  selectedColor: const Color(0xFF007AFF),
                                  backgroundColor: const Color(0xFFF5F5F7),
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (_) => setSheetState(() => sheetDay = d.$1),
                                ),
                              );
                            }),
                            const SizedBox(width: 6),
                            ...[
                              ('ALL', 'Todos'),
                              ('PENDING', 'Pendientes'),
                              ('DONE', 'Completadas'),
                            ].map((s) {
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mostrando ${filteredGroup.length} de ${group.length} asignaciones', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF86868B))),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredGroup.isEmpty
                      ? const Center(child: Text('No hay asignaciones con estos filtros.', style: TextStyle(color: Color(0xFF86868B))))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                          itemCount: filteredGroup.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final inst = filteredGroup[i];
                            final owner = usersById[inst.userId];
                            final ownerLabel = (owner != null && owner.nombre.isNotEmpty)
                                ? owner.nombre
                                : (inst.userId == 'UNASSIGNED' ? 'Sin asignar' : inst.userId);
                            final initials = owner?.iniciales ?? (ownerLabel == 'Sin asignar' ? 'SA' : ownerLabel.substring(0, 1).toUpperCase());
                            final statusColor = inst.done ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE5E5EA)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: const Color(0xFF002F6C).withValues(alpha: 0.1),
                                    child: Text(initials, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF002F6C))),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ownerLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${owner?.plantId ?? inst.plantId} · ${dayLabels[inst.day] ?? 'Día ${inst.day}'}',
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF86868B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      inst.done ? 'Completada' : 'Pendiente',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
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
          );
        },
      ),
    );
  }

  Widget _viewToggleBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF002F6C) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? Colors.white : const Color(0xFF3A3A3C)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF3A3A3C)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchKpiCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  void _openCatalogsManagerSheet(BuildContext context) {
    final areaCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final provider = Provider.of<StandardWorkProvider>(sheetCtx);
          return Container(
            height: MediaQuery.of(sheetCtx).size.height * 0.80,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 10, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gestión de Áreas y Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            Text('Crea y administra los catálogos reales de tu operación', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(sheetCtx).pop()),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Áreas Operativas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: areaCtrl,
                              decoration: InputDecoration(
                                hintText: 'Ej. Extrusión, Calidad, Empaque...',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (areaCtrl.text.trim().isEmpty) return;
                              await provider.addCorporateArea(areaCtrl.text);
                              areaCtrl.clear();
                              setSheetState(() {});
                            },
                            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                            label: const Text('Crear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (provider.corporateAreas.isEmpty)
                        const Text('Aún no has creado áreas. Agrega la primera arriba.', style: TextStyle(fontSize: 12, color: Color(0xFF86868B)))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.corporateAreas
                              .map((a) => Chip(
                                    label: Text(a, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    backgroundColor: Colors.white,
                                    deleteIcon: const Icon(Icons.close_rounded, size: 16),
                                    onDeleted: () async {
                                      await provider.removeCorporateArea(a);
                                      setSheetState(() {});
                                    },
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 22),
                      const Text('Categorías de Actividades', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: catCtrl,
                              decoration: InputDecoration(
                                hintText: 'Ej. Seguridad EHS, 5S, Mantenimiento...',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (catCtrl.text.trim().isEmpty) return;
                              await provider.addCorporateCategory(catCtrl.text);
                              catCtrl.clear();
                              setSheetState(() {});
                            },
                            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                            label: const Text('Crear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002F6C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (provider.corporateCategories.isEmpty)
                        const Text('Aún no has creado categorías. Agrega la primera arriba.', style: TextStyle(fontSize: 12, color: Color(0xFF86868B)))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.corporateCategories
                              .map((c) => Chip(
                                    label: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    backgroundColor: Colors.white,
                                    deleteIcon: const Icon(Icons.close_rounded, size: 16),
                                    onDeleted: () async {
                                      await provider.removeCorporateCategory(c);
                                      setSheetState(() {});
                                    },
                                  ))
                              .toList(),
                        ),
                    ],
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

class _SuperAdminCorporateDispatchForm extends StatefulWidget {
  final VoidCallback? onDispatched;
  final ActivityInstance? editingActivity;
  const _SuperAdminCorporateDispatchForm({this.onDispatched, this.editingActivity});

  @override
  State<_SuperAdminCorporateDispatchForm> createState() => _SuperAdminCorporateDispatchFormState();
}

class _SuperAdminCorporateDispatchFormState extends State<_SuperAdminCorporateDispatchForm> {
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _horaIniCtrl = TextEditingController(text: '08:00');
  final _horaFinCtrl = TextEditingController(text: '09:00');

  String _area = 'Todas las Áreas';
  String _categoria = 'General';
  String _prioridad = 'Alta';
  bool _fija = true;
  String _tipoActividad = 'ejecucion'; // 'ejecucion' o 'registro'
  bool _incluyeReunion = false;
  final _reunionHoraCtrl = TextEditingController(text: '08:00 AM');
  String _reunionLugar = 'Sala de Planta';
  bool _planAccionObligatorio = false;
  bool _requierePlanAccion = false;
  String _planTemplate = 'Estándar 5W1H';
  final _planGuiaCtrl = TextEditingController(
    text: 'Hallazgo · Causa Raíz · Acción Correctiva · Responsable · Fecha Compromiso',
  );
  int _wizardStep = 0; // 0: Qué y Quién, 1: Horario y Plan, 2: Subtareas
  String _targetPlanta = 'ALL';
  String _targetUserId = 'ALL';
  bool _isSaving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final e = widget.editingActivity;
    if (e != null) {
      _nombreCtrl.text = e.nombre;
      _descCtrl.text = e.descripcion;
      _horaIniCtrl.text = e.timeStart;
      _horaFinCtrl.text = e.timeEnd;
      _area = e.area.isEmpty ? 'Todas las Áreas' : e.area;
      _categoria = e.category.isEmpty ? 'General' : e.category;
      _prioridad = e.prioridad.isEmpty ? 'Alta' : e.prioridad;
      _fija = e.fija;
      _tipoActividad = e.tipoActividad;
      _requierePlanAccion = e.requierePlanAccion || e.planAccionObligatorio;
      _planAccionObligatorio = e.planAccionObligatorio;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final prov = context.read<StandardWorkProvider>();
        final sameGroup = prov.instances.where((i) => i.activityId == e.activityId).toList();
        final subs = await prov.getSubtasksForActivity(e.activityId);
        if (!mounted) return;
        setState(() {
          if (sameGroup.isNotEmpty) {
            _selectedDays
              ..clear()
              ..addAll(sameGroup.map((i) => i.day));
            final plants = sameGroup.map((i) => i.plantId).toSet();
            if (plants.length == 1) _targetPlanta = plants.first;
            final users = sameGroup.map((i) => i.userId).toSet();
            if (users.length == 1 && users.first != 'UNASSIGNED') _targetUserId = users.first;
          }
          if (subs.isNotEmpty) {
            _subtasks
              ..clear()
              ..addAll(subs);
          }
        });
      });
    }
  }
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Lun-Vie por defecto

  final List<ActivitySubtaskModel> _subtasks = [
    const ActivitySubtaskModel(
      activityId: 0,
      orden: 1,
      nombre: 'Inspección de uso de EPP y condiciones de seguridad',
      descripcion: 'Verificar chaleco reflectivo, casco, gafas y calzado dieléctrico en línea',
      instruccion: 'Inspección visual obligatoria a todos los colaboradores del turno',
      requiereFoto: true,
      requiereComentario: true,
    ),
    const ActivitySubtaskModel(
      activityId: 0,
      orden: 2,
      nombre: 'Verificación de parada de emergencia y guardas perimetrales',
      descripcion: 'Comprobar operatividad del switch de desconexión y sensores',
      instruccion: 'Comprobar que las guardas estén bloqueadas y sensores activos',
      requiereFoto: false,
      requiereComentario: true,
    ),
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _horaIniCtrl.dispose();
    _horaFinCtrl.dispose();
    _reunionHoraCtrl.dispose();
    _planGuiaCtrl.dispose();
    super.dispose();
  }

  void _loadTemplate(String type) {
    setState(() {
      if (type == 'ehs') {
        _nombreCtrl.text = 'Auditoría de Seguridad EHS Grupo Darnel';
        _descCtrl.text = 'Inspección de condiciones seguras, extintores, pasillos y uso estricto de EPP.';
        _area = 'Seguridad EHS';
        _categoria = 'Seguridad y Salud EHS';
        _prioridad = 'Alta';
        _fija = true;
        _subtasks.clear();
        _subtasks.addAll([
          const ActivitySubtaskModel(
            activityId: 0,
            orden: 1,
            nombre: 'Inspección de EPP completo y chaleco reflectivo',
            descripcion: 'Verificar que ningún colaborador labore sin protección ocular y auditiva',
            requiereFoto: true,
            requiereComentario: true,
          ),
          const ActivitySubtaskModel(
            activityId: 0,
            orden: 2,
            nombre: 'Revisión de botiquines y extintores vigentes',
            descripcion: 'Presión en zona verde y libre de obstáculos a 1 metro a la redonda',
            requiereFoto: true,
            requiereComentario: false,
          ),
        ]);
      } else if (type == '5s') {
        _nombreCtrl.text = 'Ronda Gemba 5S y Despeje de Puesto';
        _descCtrl.text = 'Estandarización visual, orden de herramientas y limpieza profunda de tolvas.';
        _area = 'Todas las Áreas';
        _categoria = '5S y Orden Gemba';
        _prioridad = 'Media';
        _fija = true;
        _subtasks.clear();
        _subtasks.addAll([
          const ActivitySubtaskModel(
            activityId: 0,
            orden: 1,
            nombre: 'Despeje de pasillos y demarcación amarilla',
            descripcion: 'Cero materias primas, tarimas o residuos fuera de su zona marcada',
            requiereFoto: true,
            requiereComentario: true,
          ),
          const ActivitySubtaskModel(
            activityId: 0,
            orden: 2,
            nombre: 'Control de tablero sombra de herramientas',
            descripcion: 'Comprobar llaves fijas, espátula de bronce y lubricantes en su puesto',
            requiereFoto: true,
            requiereComentario: false,
          ),
        ]);
      } else if (type == 'calidad') {
        _nombreCtrl.text = 'Inspección de Tolerancias y Calibre Q4';
        _descCtrl.text = 'Control de espesor, peso por millar y verificación de ausencia de rebabas.';
        _area = 'Calidad y Laboratorio';
        _categoria = 'Calidad y Tolerancias';
        _prioridad = 'Alta';
        _fija = false;
        _subtasks.clear();
        _subtasks.addAll([
          const ActivitySubtaskModel(
            activityId: 0,
            orden: 1,
            nombre: 'Medición de calibre con micrómetro digital',
            descripcion: 'Tomar muestra de 5 probetas y validar desviación contra ficha técnica',
            requiereFoto: true,
            requiereComentario: true,
            requiereMedicion: true,
          ),
          const ActivitySubtaskModel(
            activityId: 0,
            orden: 2,
            nombre: 'Prueba de sellado térmico y hermeticidad',
            descripcion: 'Ensayo en cámara de vacío a 25 inHg durante 30 segundos',
            requiereFoto: false,
            requiereComentario: true,
          ),
        ]);
      }
    });
  }

  void _showSubtaskDialog({int? editIndex}) {
    final titleCtrl = TextEditingController(text: editIndex != null ? _subtasks[editIndex].nombre : '');
    final descCtrl = TextEditingController(text: editIndex != null ? _subtasks[editIndex].descripcion : '');
    bool reqFoto = editIndex != null ? _subtasks[editIndex].requiereFoto : true;
    bool reqComentario = editIndex != null ? _subtasks[editIndex].requiereComentario : true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            editIndex != null ? 'Editar Subtarea / Paso' : 'Nueva Subtarea Corporativa',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Título del Paso / Comprobación *',
                    hintText: 'Ej. Revisar nivel de aceite hidráulico',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Instrucción o Criterio Técnico',
                    hintText: 'Ej. Nivel entre las marcas MIN y MAX',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Requisitos de Evidencia Obligatoria:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('📷 Requiere Foto de Evidencia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('El colaborador debe tomar foto en vivo', style: TextStyle(fontSize: 11)),
                  value: reqFoto,
                  activeColor: const Color(0xFF0284C7),
                  onChanged: (val) => setDlgState(() => reqFoto = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('💬 Requiere Comentario Técnico', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Obliga a registrar observaciones', style: TextStyle(fontSize: 11)),
                  value: reqComentario,
                  activeColor: const Color(0xFFF59E0B),
                  onChanged: (val) => setDlgState(() => reqComentario = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                setState(() {
                  final newSub = ActivitySubtaskModel(
                    activityId: 0,
                    orden: editIndex != null ? editIndex + 1 : _subtasks.length + 1,
                    nombre: titleCtrl.text.trim(),
                    descripcion: descCtrl.text.trim(),
                    requiereFoto: reqFoto,
                    requiereComentario: reqComentario,
                  );
                  if (editIndex != null) {
                    _subtasks[editIndex] = newSub;
                  } else {
                    _subtasks.add(newSub);
                  }
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: Text(editIndex != null ? 'Guardar Cambios' : 'Agregar Paso', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _dispatch() async {
    if (_isSaving) return;
    if (_nombreCtrl.text.trim().isEmpty) {
      setState(() {
        _wizardStep = 0;
        _formError = 'Por favor escribe el nombre de la actividad corporativa en el Paso 1.';
      });
      return;
    }

    if (_selectedDays.isEmpty) {
      setState(() {
        _wizardStep = 1;
        _formError = 'Debes seleccionar al menos un día de la semana en el Paso 2.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final sortedDays = (_selectedDays.toList()..sort()).join(',');

    final baseDesc = _descCtrl.text.trim();
    final isMeetingMode = _tipoActividad == 'registro';
    final fullDesc = isMeetingMode
        ? '${baseDesc.isNotEmpty ? "$baseDesc\n" : ""}[REUNIÓN PROGRAMADA: ${_reunionHoraCtrl.text.trim()} · $_reunionLugar]'
        : baseDesc;
    final planCriteria = _requierePlanAccion
        ? 'Plantilla Plan ($_planTemplate): ${_planGuiaCtrl.text.trim()}'
        : '';

    try {
      if (widget.editingActivity != null) {
        await provider.updateActivityGroup(
          activityId: widget.editingActivity!.activityId,
          nombre: _nombreCtrl.text.trim(),
          descripcion: fullDesc,
          area: _area,
          category: _categoria,
          timeStart: _horaIniCtrl.text.trim(),
          timeEnd: _horaFinCtrl.text.trim(),
          fija: _fija,
          prioridad: _prioridad,
          tipoActividad: _tipoActividad,
          requierePlanAccion: _requierePlanAccion || _planAccionObligatorio,
          planAccionObligatorio: _planAccionObligatorio,
          criteriosCumplimiento: planCriteria,
          days: _selectedDays.toList()..sort(),
          targetPlantId: _targetPlanta,
          targetUserId: _targetUserId,
          subtasks: _subtasks,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF16A34A),
              content: Text('¡Actividad actualizada con éxito!'),
            ),
          );
          widget.onDispatched?.call();
        }
        return;
      }

      await provider.dispatchCorporateActivity(
        nombre: _nombreCtrl.text.trim(),
        descripcion: fullDesc,
        area: _area,
        category: _categoria,
        timeStart: _horaIniCtrl.text.trim(),
        timeEnd: _horaFinCtrl.text.trim(),
        fija: _fija,
        dias: sortedDays,
        prioridad: _prioridad,
        subtasks: _subtasks,
        tipoActividad: _tipoActividad,
        requierePlanAccion: _requierePlanAccion || _planAccionObligatorio,
        planAccionObligatorio: _planAccionObligatorio,
        criteriosCumplimiento: planCriteria,
        targetPlantIds: _targetPlanta == 'ALL' ? null : [_targetPlanta],
        targetUserIds: _targetUserId == 'ALL' ? null : [_targetUserId],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('¡Directiva Corporativa despachada con éxito!'),
          ),
        );
        _nombreCtrl.clear();
        _descCtrl.clear();
        widget.onDispatched?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formError = 'No se pudo guardar la actividad: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};
    const stepLabels = ['1. Qué y Quién', '2. Horario y Plan', '3. Subtareas'];

    return Column(
      children: [
        // BARRA DE PASOS LIMPIA ESTILO APPLE + DARNEL AZUL
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7),
            border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.8)),
          ),
          child: Row(
            children: List.generate(3, (idx) {
              final active = _wizardStep == idx;
              final done = _wizardStep > idx;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx < 2 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _wizardStep = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF002F6C)
                            : (done ? const Color(0xFF002F6C).withValues(alpha: 0.12) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? const Color(0xFF002F6C) : const Color(0xFFE5E5EA),
                        ),
                      ),
                      child: Text(
                        stepLabels[idx],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : (done ? const Color(0xFF002F6C) : const Color(0xFF86868B)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_formError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formError!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF991B1B)),
                          onPressed: () => setState(() => _formError = null),
                        ),
                      ],
                    ),
                  ),
                if (_wizardStep == 0) ...[
                  // PASO 1: PLANTILLA OPCIONAL + MODALIDAD + DESTINO + NOMBRE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Plantilla (opcional):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF1D1D1F))),
                      TextButton.icon(
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        onPressed: () {
                          TemplatesModal.show(
                            context: context,
                            onSelectTemplate: (tmpl) {
                              setState(() {
                                _nombreCtrl.text = tmpl.nombre;
                                _descCtrl.text = tmpl.descripcion;
                                _area = tmpl.area;
                                _categoria = tmpl.categoria;
                                _prioridad = tmpl.prioridad;
                                _fija = tmpl.fija;
                                _tipoActividad = tmpl.tipoActividad;
                                _planAccionObligatorio = tmpl.planAccionObligatorio;
                                _requierePlanAccion = tmpl.planAccionObligatorio;
                                _subtasks.clear();
                                _subtasks.addAll(tmpl.subtasks.map((s) => s.copyWith(activityId: 0)));
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Plantilla "${tmpl.nombre}" aplicada'), backgroundColor: const Color(0xFF002F6C)),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.auto_stories_rounded, size: 15, color: Color(0xFF002F6C)),
                        label: const Text('Catálogo / Nueva', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      final realTemplates = context.watch<StandardWorkProvider>().templates;
                      if (realTemplates.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: realTemplates
                                .map((tmpl) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildTemplateChip(tmpl.nombre, () {
                                        setState(() {
                                          _nombreCtrl.text = tmpl.nombre;
                                          _descCtrl.text = tmpl.descripcion;
                                          _area = tmpl.area;
                                          _categoria = tmpl.categoria;
                                          _prioridad = tmpl.prioridad;
                                          _fija = tmpl.fija;
                                          _tipoActividad = tmpl.tipoActividad;
                                          _planAccionObligatorio = tmpl.planAccionObligatorio;
                                          _requierePlanAccion = tmpl.planAccionObligatorio;
                                          _subtasks.clear();
                                          _subtasks.addAll(tmpl.subtasks.map((s) => s.copyWith(activityId: 0)));
                                        });
                                      }),
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),

                  const Text('Modalidad de la Actividad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1D1D1F))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _tipoActividad = 'ejecucion';
                              _incluyeReunion = false;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _tipoActividad == 'ejecucion' ? const Color(0xFF002F6C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.engineering_rounded, size: 16, color: _tipoActividad == 'ejecucion' ? Colors.white : const Color(0xFF3A3A3C)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Ejecución',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _tipoActividad == 'ejecucion' ? Colors.white : const Color(0xFF3A3A3C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _tipoActividad = 'registro';
                              _incluyeReunion = true;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _tipoActividad == 'registro' ? const Color(0xFF002F6C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.groups_rounded, size: 16, color: _tipoActividad == 'registro' ? Colors.white : const Color(0xFF3A3A3C)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Registro / Reunión',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _tipoActividad == 'registro' ? Colors.white : const Color(0xFF3A3A3C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_tipoActividad == 'registro') ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Datos de la Reunión / Comité', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _reunionHoraCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Hora Reunión',
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _reunionLugar,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Lugar',
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Sala de Planta', child: Text('Sala de Planta', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'Piso / Gemba', child: Text('Piso / Gemba', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'Virtual / Teams', child: Text('Virtual / Teams', overflow: TextOverflow.ellipsis)),
                                  ],
                                  onChanged: (v) => setState(() => _reunionLugar = v ?? 'Sala de Planta'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Builder(
                    builder: (context) {
                      final provider = context.watch<StandardWorkProvider>();
                      final allPlants = provider.allPlants;
                      final validPlant = (['ALL', ...allPlants.map((p) => p.id)].contains(_targetPlanta)) ? _targetPlanta : 'ALL';
                      final selectableUsers = provider.allUsers.where((u) {
                        if (!u.isOperator && !u.isSupervisor) return false;
                        if (validPlant != 'ALL' && u.plantId != validPlant) return false;
                        return true;
                      }).toList();
                      final validUser = (['ALL', ...selectableUsers.map((u) => u.id)].contains(_targetUserId)) ? _targetUserId : 'ALL';

                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: validPlant,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Planta Destino',
                              prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF002F6C)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: [
                              const DropdownMenuItem(value: 'ALL', child: Text('Todas las Plantas', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              ...allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre, overflow: TextOverflow.ellipsis, maxLines: 1))),
                            ],
                            onChanged: (val) => setState(() {
                              _targetPlanta = val ?? 'ALL';
                              _targetUserId = 'ALL';
                            }),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: validUser,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Asignar a Persona o Equipo',
                              prefixIcon: const Icon(Icons.person_pin_rounded, color: Color(0xFF002F6C)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: [
                              const DropdownMenuItem(value: 'ALL', child: Text('Todos en la planta seleccionada', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              ...selectableUsers.map((u) => DropdownMenuItem(
                                    value: u.id,
                                    child: Text('${u.nombre} (${u.isSupervisor ? 'Supervisor' : 'Operador'} · ${u.plantId})', overflow: TextOverflow.ellipsis, maxLines: 1),
                                  )),
                            ],
                            onChanged: (val) => setState(() => _targetUserId = val ?? 'ALL'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Actividad *',
                      hintText: 'Ej. Reunión Diaria de Arranque / Auditoría 5S',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción / Objetivo *',
                      hintText: 'Instrucción clara para el responsable...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _wizardStep = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002F6C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Siguiente: Horario y Plan de Acción →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ] else if (_wizardStep == 1) ...[
                  // PASO 2: ÁREA, CATEGORÍA, CRITICIDAD, HORARIO, DÍAS Y PLAN DE ACCIÓN
                  Builder(
                    builder: (context) {
                      final provider = context.watch<StandardWorkProvider>();
                      final areaItems = <String>{'Todas las Áreas', ...provider.corporateAreas, _area}.toList();
                      final catItems = <String>{'General', ...provider.corporateCategories, _categoria}.toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Área Destino', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                              TextButton.icon(
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                onPressed: () => _quickAddCatalogItem(
                                  context: context,
                                  title: 'Nueva Área',
                                  hint: 'Ej. Extrusión, Calidad...',
                                  onSave: (val) async {
                                    await provider.addCorporateArea(val);
                                    setState(() => _area = val);
                                  },
                                ),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF002F6C)),
                                label: const Text('Nueva Área', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: _area,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: areaItems.map((a) => DropdownMenuItem(value: a, child: Text(a, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _area = val);
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Categoría', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                              TextButton.icon(
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                onPressed: () => _quickAddCatalogItem(
                                  context: context,
                                  title: 'Nueva Categoría',
                                  hint: 'Ej. Seguridad EHS, 5S...',
                                  onSave: (val) async {
                                    await provider.addCorporateCategory(val);
                                    setState(() => _categoria = val);
                                  },
                                ),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF002F6C)),
                                label: const Text('Nueva Categoría', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: _categoria,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: catItems.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _categoria = val);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text('Nivel de Criticidad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChoice('Alta', const Color(0xFFFF3B30)),
                      const SizedBox(width: 8),
                      _buildPriorityChoice('Media', const Color(0xFFFF9500)),
                      const SizedBox(width: 8),
                      _buildPriorityChoice('Baja', const Color(0xFF007AFF)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _horaIniCtrl,
                          readOnly: true,
                          onTap: () async {
                            final parts = _horaIniCtrl.text.split(':');
                            final init = TimeOfDay(
                              hour: int.tryParse(parts.first) ?? 8,
                              minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
                            );
                            final picked = await showTimePicker(context: context, initialTime: init);
                            if (picked != null) {
                              setState(() {
                                _horaIniCtrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Hora Inicio (toca)',
                            prefixIcon: const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF002F6C)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _horaFinCtrl,
                          readOnly: true,
                          onTap: () async {
                            final parts = _horaFinCtrl.text.split(':');
                            final init = TimeOfDay(
                              hour: int.tryParse(parts.first) ?? 9,
                              minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
                            );
                            final picked = await showTimePicker(context: context, initialTime: init);
                            if (picked != null) {
                              setState(() {
                                _horaFinCtrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Hora Fin (toca)',
                            prefixIcon: const Icon(Icons.timer_off_outlined, size: 18, color: Color(0xFF002F6C)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // CALENDARIO / HORARIO RÁPIDO DEL DÍA DENTRO DE HORARIO
                  Builder(
                    builder: (context) {
                      final allInst = context.watch<StandardWorkProvider>().instances;
                      final existing = <String, ActivityInstance>{};
                      for (final i in allInst) {
                        if (!_selectedDays.contains(i.day)) continue;
                        if (_targetPlanta != 'ALL' && i.plantId != _targetPlanta) continue;
                        existing.putIfAbsent('${i.nombre}__${i.timeStart}', () => i);
                      }
                      final list = existing.values.toList()..sort((a, b) => a.timeStart.compareTo(b.timeStart));
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E5EA)),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.calendar_today_rounded, size: 17, color: Color(0xFF002F6C)),
                          title: Text('Ver horario actual (${list.length} actividades)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                          children: [
                            if (list.isEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
                                child: Text('No hay actividades programadas aún en estos días.', style: TextStyle(fontSize: 11.5, color: Color(0xFF86868B))),
                              )
                            else
                              ...list.take(8).map((a) => ListTile(
                                    dense: true,
                                    leading: Text('${a.timeStart}-${a.timeEnd}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF002F6C))),
                                    title: Text(a.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    subtitle: Text('${a.area} · ${a.plantId}', style: const TextStyle(fontSize: 10.5)),
                                  )),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Días que aplica', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Row(
                        children: [
                          TextButton(onPressed: () => setState(() => _selectedDays.addAll([1, 2, 3, 4, 5])), child: const Text('Lun-Vie', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                          TextButton(onPressed: () => setState(() => _selectedDays.addAll([1, 2, 3, 4, 5, 6])), child: const Text('Todos', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                        ],
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: dayNames.entries.map((e) {
                      final isSelected = _selectedDays.contains(e.key);
                      return FilterChip(
                        label: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : const Color(0xFF1D1D1F))),
                        selected: isSelected,
                        selectedColor: const Color(0xFF002F6C),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: isSelected ? const Color(0xFF002F6C) : const Color(0xFFE5E5EA)),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedDays.add(e.key);
                            } else if (_selectedDays.length > 1) {
                              _selectedDays.remove(e.key);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: SwitchListTile(
                      title: const Text('Actividad Fija Inmutable', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      subtitle: const Text('No se puede reprogramar sin autorización', style: TextStyle(fontSize: 11)),
                      value: _fija,
                      activeThumbColor: const Color(0xFF002F6C),
                      onChanged: (val) => setState(() => _fija = val),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // PLAN DE ACCIÓN + PLANTILLA DEL PLAN
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
                          subtitle: const Text('Activa la creación de planes desde esta actividad o reunión', style: TextStyle(fontSize: 11)),
                          value: _requierePlanAccion,
                          activeThumbColor: const Color(0xFF002F6C),
                          onChanged: (val) => setState(() {
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
                            onChanged: (val) => setState(() => _planAccionObligatorio = val),
                          ),
                          const SizedBox(height: 8),
                          const Text('Plantilla de Plan de Acción:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _planTemplate,
                            isExpanded: true,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Estándar 5W1H', child: Text('Estándar 5W1H (Qué, Quién, Cuándo)', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: '5 Porqués (Causa Raíz)', child: Text('5 Porqués (Análisis Causa Raíz)', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'Seguimiento Reunión Diaria', child: Text('Seguimiento Reunión Diaria (Acuerdos)', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'Personalizada', child: Text('Personalizada', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                _planTemplate = v;
                                if (v == 'Estándar 5W1H') {
                                  _planGuiaCtrl.text = 'Hallazgo · Causa Raíz · Acción Correctiva · Responsable · Fecha Compromiso';
                                } else if (v == '5 Porqués (Causa Raíz)') {
                                  _planGuiaCtrl.text = 'Problema · 5 Porqués · Contramedida · Responsable · Verificación';
                                } else if (v == 'Seguimiento Reunión Diaria') {
                                  _planGuiaCtrl.text = 'Tema / Indicador · Desviación · Acuerdo · Responsable · Fecha Cierre';
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _planGuiaCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Estructura / Campos del Plan',
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _wizardStep = 0),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('← Atrás', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _wizardStep = 2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002F6C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Siguiente: Subtareas →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // PASO 3: SUBTAREAS Y REQUISITOS (DISPONIBLE PARA EJECUCIÓN Y REGISTRO/REUNIÓN)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.checklist_rounded, color: Color(0xFF002F6C), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _tipoActividad == 'registro'
                                ? 'Puntos de agenda, asistencia o entregables de la Reunión (${_subtasks.length} pasos)'
                                : 'Checklist operativo paso a paso (${_subtasks.length} pasos)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF002F6C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtareas (${_subtasks.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D1D1F))),
                      ElevatedButton.icon(
                        onPressed: () => _showSubtaskDialog(),
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: const Text('Agregar Paso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002F6C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_subtasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E5EA)),
                      ),
                      child: const Center(
                        child: Text(
                          'Sin subtareas aún. Toca "+ Agregar Paso" para añadir puntos de verificación o agenda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF86868B)),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subtasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = _subtasks[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E5EA)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFF002F6C),
                                child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    if (s.descripcion.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(s.descripcion, style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
                                    ],
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        if (s.requiereFoto)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                            child: const Text('📷 Foto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                                          ),
                                        if (s.requiereComentario)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFFF9500).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                            child: const Text('💬 Comentario', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFF9500))),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF002F6C)),
                                onPressed: () => _showSubtaskDialog(editIndex: i),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF3B30)),
                                onPressed: () => setState(() => _subtasks.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _wizardStep = 1),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('← Atrás', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF002F6C))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _dispatch,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded, color: Colors.white, size: 17),
                          label: Text(
                            _isSaving
                                ? 'Guardando...'
                                : (widget.editingActivity != null ? 'Guardar Cambios' : 'Crear y Asignar'),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002F6C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
      backgroundColor: const Color(0xFF002F6C).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: onTap,
    );
  }

  Future<void> _quickAddCatalogItem({
    required BuildContext context,
    required String title,
    required String hint,
    required Future<void> Function(String val) onSave,
  }) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              await onSave(v);
              if (dlgCtx.mounted) Navigator.of(dlgCtx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChoice(String label, Color color) {
    final isSelected = _prioridad == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _prioridad = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: isSelected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// TAB 4: COMUNICADOS Y DIRECTIVAS OFICIALES DE GERENCIA
class _SuperAdminAnnouncementsTab extends StatelessWidget {
  const _SuperAdminAnnouncementsTab();

  void _showNewAnnouncementDialog(BuildContext context, StandardWorkProvider provider) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Publicar Directiva Corporativa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título de la Directiva')),
            const SizedBox(height: 8),
            TextField(controller: bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Mensaje / Directriz Oficial')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                provider.postAnnouncement(
                  title: titleCtrl.text.trim(),
                  body: bodyCtrl.text.trim(),
                  author: 'Javier Julio · Superadmin',
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
            child: const Text('Publicar a Todas las Plantas', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final announcements = provider.announcements;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = announcements[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['type'] as String,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                        ),
                      ),
                      Text(item['date'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(item['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(item['body'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3)),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Text('Emitido por: ${item['author']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAnnouncementDialog(context, provider),
        backgroundColor: const Color(0xFF002F6C),
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text('Nueva Directiva', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// TAB 5: AUDITORÍA Y TRAZABILIDAD GLOBAL
class _SuperAdminAuditTab extends StatelessWidget {
  const _SuperAdminAuditTab();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final logs = provider.auditLogs;

    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Sin eventos de auditoría registrados aún.', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded, color: Color(0xFF007AFF), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 3),
                    Text(log.details, style: const TextStyle(fontSize: 12, color: Color(0xFF3A3A3C))),
                    const SizedBox(height: 6),
                    Text(
                      'Usuario: ${log.userId} · ${log.timestamp.toString().substring(0, 16)}',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// TAB 5: REPORTES Y EXPORTACIÓN (EXCEL + PDF CON FILTROS Y SELECCIÓN)
class _SuperAdminReportsTab extends StatefulWidget {
  const _SuperAdminReportsTab();

  @override
  State<_SuperAdminReportsTab> createState() => _SuperAdminReportsTabState();
}

class _SuperAdminReportsTabState extends State<_SuperAdminReportsTab> {
  String _plantFilter = 'ALL';
  String _areaFilter = 'ALL';
  String _userFilter = 'ALL';
  String _statusFilter = 'ALL'; // ALL, DONE, PENDING, OVERDUE
  String _priorityFilter = 'ALL'; // ALL, Alta, Media, Baja
  String _typeFilter = 'ALL'; // ALL, ejecucion, registro
  int _dayFilter = 0; // 0 = Todos, 1..6 = Lun..Sáb
  final Set<int> _deselectedIds = {};

  bool _incSummary = true;
  bool _incRanking = true;
  bool _incActivities = true;
  bool _incSubtasks = true;
  bool _incPlans = true;
  bool _exporting = false;

  static const _darnelNavy = Color(0xFF002F6C);
  static const _border = Color(0xFFE5E5EA);
  static const _ink = Color(0xFF1D1D1F);
  static const _muted = Color(0xFF86868B);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final plants = provider.allPlants;
    final users = provider.allUsers;
    final usersById = {for (final u in users) u.id: u};

    final areas = <String>{
      ...provider.corporateAreas,
      ...provider.instances.map((i) => i.area).where((a) => a.trim().isNotEmpty),
    }.toList()
      ..sort();

    final filteredInstances = provider.instances.where((i) {
      if (_plantFilter != 'ALL' && i.plantId != _plantFilter) return false;
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

    final filteredPlans = provider.proPlans.where((p) {
      if (_plantFilter != 'ALL' && p.plantId != _plantFilter) return false;
      if (_areaFilter != 'ALL' && p.area != _areaFilter) return false;
      return true;
    }).toList();

    final doneCount = selectedInstances.where((i) => i.done).length;
    final pct = selectedInstances.isEmpty ? '0.0' : ((doneCount / selectedInstances.length) * 100).toStringAsFixed(1);
    final ratio = selectedInstances.isEmpty ? 0.0 : (doneCount / selectedInstances.length);

    final filterParts = <String>[
      if (_plantFilter != 'ALL') 'Planta: $_plantFilter',
      if (_areaFilter != 'ALL') 'Área: $_areaFilter',
      if (_userFilter != 'ALL') 'Persona: ${usersById[_userFilter]?.nombre ?? _userFilter}',
      if (_statusFilter != 'ALL') 'Estado: $_statusFilter',
      if (_priorityFilter != 'ALL') 'Criticidad: $_priorityFilter',
      if (_typeFilter != 'ALL') 'Modalidad: $_typeFilter',
      if (_dayFilter != 0) 'Día: $_dayFilter',
    ];
    final filterSummary = filterParts.isEmpty ? 'Todas las plantas y actividades' : filterParts.join(' · ');

    Future<void> runExport({required bool isPdf}) async {
      if (_exporting) return;
      setState(() => _exporting = true);
      try {
        final targetPlants = _plantFilter == 'ALL'
            ? plants
            : plants.where((p) => p.id == _plantFilter).toList();
        if (isPdf) {
          await UltraReportService.instance.generateFilteredExecutivePdf(
            issuerName: provider.currentUser?.nombre ?? 'Super Admin',
            filterSummary: filterSummary,
            plants: targetPlants,
            instances: selectedInstances,
            plans: filteredPlans,
            usersById: usersById,
            includeSummary: _incSummary,
            includeRanking: _incRanking,
            includeActivities: _incActivities,
            includeSubtasks: _incSubtasks,
            includePlans: _incPlans,
          );
        } else {
          await ExcelService.instance.exportFilteredReport(
            filterSummary: filterSummary,
            plants: targetPlants,
            instances: selectedInstances,
            plans: filteredPlans,
            usersById: usersById,
            includeSummary: _incSummary,
            includeRanking: _incRanking,
            includeActivities: _incActivities,
            includeSubtasks: _incSubtasks,
            includePlans: _incPlans,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF16A34A),
              content: Text(isPdf ? 'PDF Ejecutivo generado con éxito' : 'Reporte Excel (.csv) generado con éxito'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: const Color(0xFFFF3B30), content: Text('Error al exportar: $e')),
          );
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
                    Text('Centro de Reportes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3)),
                    Text('Filtra, selecciona filas exactas y exporta Excel o PDF', style: TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() {
                  _plantFilter = 'ALL';
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
          const SizedBox(height: 10),

          // PLANTILLAS RÁPIDAS DE REPORTE
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  label: const Text('Resumen Semanal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _darnelNavy)),
                  backgroundColor: Colors.white,
                  onPressed: () => setState(() {
                    _statusFilter = 'ALL';
                    _typeFilter = 'ALL';
                    _dayFilter = 0;
                    _incSummary = true;
                    _incRanking = true;
                    _incActivities = true;
                    _incPlans = true;
                    _deselectedIds.clear();
                  }),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Solo Pendientes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFFF3B30))),
                  backgroundColor: Colors.white,
                  onPressed: () => setState(() {
                    _statusFilter = 'PENDING';
                    _incSummary = true;
                    _incActivities = true;
                    _deselectedIds.clear();
                  }),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Reuniones / Comités', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                  backgroundColor: Colors.white,
                  onPressed: () => setState(() {
                    _typeFilter = 'registro';
                    _statusFilter = 'ALL';
                    _deselectedIds.clear();
                  }),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Auditoría Planes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFFF9500))),
                  backgroundColor: Colors.white,
                  onPressed: () => setState(() {
                    _incSummary = true;
                    _incPlans = true;
                    _incActivities = false;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // TARJETA DE FILTROS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Filtros de Información', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _darnelNavy)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: (['ALL', ...plants.map((p) => p.id)].contains(_plantFilter)) ? _plantFilter : 'ALL',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Planta',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todas las Plantas', overflow: TextOverflow.ellipsis)),
                    ...plants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _plantFilter = v ?? 'ALL'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: (['ALL', ...areas].contains(_areaFilter)) ? _areaFilter : 'ALL',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Área',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todas las Áreas', overflow: TextOverflow.ellipsis)),
                    ...areas.map((a) => DropdownMenuItem(value: a, child: Text(a, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _areaFilter = v ?? 'ALL'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: (['ALL', ...users.map((u) => u.id)].contains(_userFilter)) ? _userFilter : 'ALL',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Persona / Responsable',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todos los Colaboradores', overflow: TextOverflow.ellipsis)),
                    ...users.where((u) => u.isOperator || u.isSupervisor).map(
                          (u) => DropdownMenuItem(value: u.id, child: Text('${u.nombre} (${u.plantId})', overflow: TextOverflow.ellipsis)),
                        ),
                  ],
                  onChanged: (v) => setState(() => _userFilter = v ?? 'ALL'),
                ),
                const SizedBox(height: 12),
                const Text('Día, Modalidad, Estado y Criticidad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [(0, 'Todos días'), (1, 'Lun'), (2, 'Mar'), (3, 'Mié'), (4, 'Jue'), (5, 'Vie'), (6, 'Sáb')].map((d) {
                    final sel = _dayFilter == d.$1;
                    return ChoiceChip(
                      label: Text(d.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : _ink)),
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
                  children: [('ALL', 'Todas'), ('ejecucion', 'Ejecución'), ('registro', 'Registro / Reunión')].map((t) {
                    final sel = _typeFilter == t.$1;
                    return ChoiceChip(
                      label: Text(t.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : _ink)),
                      selected: sel,
                      selectedColor: const Color(0xFF007AFF),
                      backgroundColor: const Color(0xFFF5F5F7),
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _typeFilter = t.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ('ALL', 'Todos'),
                    ('DONE', 'Completadas'),
                    ('PENDING', 'Pendientes'),
                    ('OVERDUE', 'Vencidas'),
                  ].map((e) {
                    final sel = _statusFilter == e.$1;
                    return ChoiceChip(
                      label: Text(e.$2, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: sel ? Colors.white : _ink)),
                      selected: sel,
                      selectedColor: _darnelNavy,
                      backgroundColor: const Color(0xFFF5F5F7),
                      onSelected: (_) => setState(() => _statusFilter = e.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['ALL', 'Alta', 'Media', 'Baja'].map((c) {
                    final sel = _priorityFilter == c;
                    return ChoiceChip(
                      label: Text(c == 'ALL' ? 'Toda Criticidad' : c, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: sel ? Colors.white : _ink)),
                      selected: sel,
                      selectedColor: const Color(0xFF007AFF),
                      backgroundColor: const Color(0xFFF5F5F7),
                      onSelected: (_) => setState(() => _priorityFilter = c),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // TARJETA DE CONTENIDO Y SELECCIÓN INDIVIDUAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. Bloques y Selección Exacta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _darnelNavy)),
                const SizedBox(height: 6),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: _darnelNavy,
                  title: const Text('Resumen Ejecutivo (KPIs)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: _incSummary,
                  onChanged: (v) => setState(() => _incSummary = v ?? true),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: _darnelNavy,
                  title: const Text('Ranking y Gráfica por Planta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: _incRanking,
                  onChanged: (v) => setState(() => _incRanking = v ?? true),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: _darnelNavy,
                  title: const Text('Detalle de Actividades Seleccionadas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: _incActivities,
                  onChanged: (v) => setState(() => _incActivities = v ?? true),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: _darnelNavy,
                  title: const Text('Avance de Subtareas / Checklist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: _incSubtasks,
                  onChanged: (v) => setState(() => _incSubtasks = v ?? true),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: _darnelNavy,
                  title: const Text('Planes de Acción Asociados', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: _incPlans,
                  onChanged: (v) => setState(() => _incPlans = v ?? true),
                ),
                if (filteredInstances.isNotEmpty) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Seleccionar filas (${selectedInstances.length}/${filteredInstances.length})', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _ink)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_deselectedIds.isEmpty) {
                              for (final i in filteredInstances) {
                                if (i.id != null) _deselectedIds.add(i.id!);
                              }
                            } else {
                              _deselectedIds.clear();
                            }
                          });
                        },
                        child: Text(_deselectedIds.isEmpty ? 'Deseleccionar todo' : 'Seleccionar todo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 170,
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
                          subtitle: Text('${item.plantId} · ${item.area} · ${item.done ? 'Completada' : 'Pendiente'}', style: const TextStyle(fontSize: 11)),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // VISTA PREVIA VISUAL Y EXPORTACIÓN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _darnelNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('3. Vista Previa y Exportación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _previewBox('Seleccionadas', '${selectedInstances.length}'),
                    const SizedBox(width: 8),
                    _previewBox('Cumplimiento', '$pct%'),
                    const SizedBox(width: 8),
                    _previewBox('Planes', '${filteredPlans.length}'),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34C759)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exporting ? null : () => runExport(isPdf: false),
                        icon: const Icon(Icons.table_chart_rounded, size: 18, color: _darnelNavy),
                        label: const Text('Exportar Excel', style: TextStyle(color: _darnelNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exporting ? null : () => runExport(isPdf: true),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
                        label: const Text('Exportar PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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

  Widget _previewBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
