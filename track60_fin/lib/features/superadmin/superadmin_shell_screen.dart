import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/excel_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // HERO HEADER CORPORATIVO CON FOTO AÉREA Y RELIEVE 3D
          Stack(
            children: [
              Container(
                height: 195,
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
                        const Color(0xFF0F172A).withValues(alpha: 0.98),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'TORRE DE CONTROL · SUPERADMIN',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Guía',
                                icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 20),
                                onPressed: () => HelpGuideModal.show(context),
                              ),
                              IconButton(
                                tooltip: 'Exportar Excel',
                                icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 20),
                                onPressed: () async {
                                  try {
                                    await ExcelService.instance.exportAndShare();
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Cerrar Sesión',
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
                        user?.nombre ?? 'Javier Julio',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                      ),
                      const Text(
                        'Dirección General · Gobierno Operativo Grupo Darnel',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      if (provider.emergencyAlertActive) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'ALERTA ROJA EHS: ${provider.emergencyAlertMessage}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // TABS DE NAVEGACIÓN
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: const [
                _SuperAdminControlTowerTab(),
                _SuperAdminCorporateDispatchTab(),
                _SuperAdminPlantAdminsTab(),
                _SuperAdminExtraTasksApprovalTab(),
                _SuperAdminAuditTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        selectedItemColor: const Color(0xFF002F6C),
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Torre'),
          BottomNavigationBarItem(icon: Icon(Icons.add_task_rounded), label: 'Asignar'),
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Procesos'),
          BottomNavigationBarItem(icon: Icon(Icons.rule_folder_rounded), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Logs'),
        ],
      ),
    );
  }
}

/// TAB 1: TORRE DE CONTROL CON SEMÁFORO, GRÁFICAS Y GOBERNANZA OPERATIVA
class _SuperAdminControlTowerTab extends StatefulWidget {
  const _SuperAdminControlTowerTab();

  @override
  State<_SuperAdminControlTowerTab> createState() => _SuperAdminControlTowerTabState();
}

class _SuperAdminControlTowerTabState extends State<_SuperAdminControlTowerTab> {
  String _selectedPlantFilter = 'TODAS';
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

              // Métricas de Línea
              const Text('Líneas de Producción y Estado:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildLineStatusRow('Línea de Extrusión Principal 01', '96% Cumplimiento', const Color(0xFF16A34A)),
              _buildLineStatusRow('Línea de Termoformado y Troquelado', '92% Cumplimiento', const Color(0xFF0284C7)),
              _buildLineStatusRow('Área de Empaque y Paletizado', '98% Cumplimiento', const Color(0xFF16A34A)),
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

    // Métricas dinámicas reales para Torre de Control
    final instances = provider.instances;
    final totalInstances = instances.length;
    final completedInstances = instances.where((i) => i.done).length;
    final complianceRate = totalInstances > 0 ? ((completedInstances / totalInstances) * 100).toStringAsFixed(1) : '94.2';

    final altaTasks = instances.where((i) => i.prioridad.toLowerCase().contains('alta') || i.fija).length;
    final mediaTasks = instances.where((i) => i.prioridad.toLowerCase().contains('media') || (!i.fija && i.requierePlanAccion)).length;
    final bajaTasks = (instances.length - altaTasks - mediaTasks).clamp(1, 9999);

    final weeklyTrend = List.generate(5, (index) {
      final day = index + 1;
      final dayInst = instances.where((i) => i.day == day).toList();
      if (dayInst.isEmpty) return 91.0 + (index * 1.2);
      final dayDone = dayInst.where((i) => i.done).length;
      return double.parse(((dayDone / dayInst.length) * 100).toStringAsFixed(1));
    });

    final completadasCount = instances.where((i) => i.done).length;
    final vencidasCount = instances.where((i) => !i.done && i.day < provider.selectedDay).length;
    final pendientesCount = (instances.length - completadasCount - vencidasCount).clamp(0, 9999);

    final compNum = double.tryParse(complianceRate) ?? 94.2;
    final radarScores = {
      'Calidad': (compNum * 0.98).clamp(75.0, 99.0),
      'Seguridad': 98.0,
      '5S Piso': provider.gembaLogs.isNotEmpty ? (provider.gembaLogs.first['score'] as num).toDouble() : 92.0,
      'OEE': (compNum * 0.96).clamp(70.0, 98.0),
      'Disciplina': totalInstances > 0 ? ((completedInstances / totalInstances) * 100).clamp(70.0, 98.0) : 91.0,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA SUPERIOR DE ACCIONES RÁPIDAS (Sin botón de Alerta EHS)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Semáforo de Operación en Vivo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showLiveInspectionDialog(context, provider),
                icon: const Icon(Icons.remove_red_eye_rounded, size: 14, color: Color(0xFF002F6C)),
                label: const Text('En Vivo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TARJETAS CON EFECTO 3D DE RELIEVE
          Row(
            children: [
              Expanded(
                child: _build3DMetricCard(
                  title: 'Plantas Activas',
                  value: '${plants.length}',
                  subtitle: '100% conectadas',
                  icon: Icons.factory_rounded,
                  color: const Color(0xFF002F6C),
                  accentColor: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _build3DMetricCard(
                  title: 'Admins Planta',
                  value: '${admins.length}',
                  subtitle: 'Liderando sedes',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF0284C7),
                  accentColor: const Color(0xFF38BDF8),
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
                  value: '${operators.length}',
                  subtitle: 'En líneas Darnel',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF16A34A),
                  accentColor: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _build3DMetricCard(
                  title: 'Cumplimiento',
                  value: '$complianceRate%',
                  subtitle: 'Meta: 95.0%',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF7C3AED),
                  accentColor: const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // COMPARATIVO DE PLANTAS FL_CHART
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002F6C).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Semáforo de Cumplimiento por Planta (%)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🟢 >90% Óptimo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Estándar de calidad, seguridad y mantenimiento de turnos', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 20),
                SizedBox(
                  height: 175,
                  child: plantStats.isEmpty
                      ? const Center(child: Text('Sin plantas registradas', style: TextStyle(color: Colors.grey)))
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
                                      child: Text(code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (val, meta) => Text('${val.toInt()}%', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(plantStats.length, (i) {
                              final st = plantStats[i];
                              final barColor = st.rate >= 90
                                  ? const Color(0xFF16A34A)
                                  : (st.rate >= 60 ? const Color(0xFF0284C7) : const Color(0xFFEA580C));
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: st.rate.clamp(2.0, 100.0),
                                    color: barColor,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(6),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: const Color(0xFFF1F5F9),
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
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  ...plantStats.map((st) {
                    final badgeColor = st.rate >= 90
                        ? const Color(0xFF16A34A)
                        : (st.rate >= 60 ? const Color(0xFF0284C7) : const Color(0xFFDC2626));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              st.plant.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Text(
                            '${st.done}/${st.total} tareas · ${st.pending} pend · ${st.ops} op',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${st.rate.toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
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

          // TABLERO DE GOBERNANZA OPERATIVA REAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002F6C), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002F6C).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rule_folder_rounded, color: Color(0xFF38BDF8), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Gobernanza Operativa en Tiempo Real',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                      ),
                      child: const Text('En Vivo', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildRealMetricBox(
                        'Solicitudes >10',
                        '${provider.extraTaskRequests.where((r) => r.estado == 'Pendiente').length}',
                        'Por autorizar',
                        const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildRealMetricBox(
                        'Directivas',
                        '${provider.announcements.length}',
                        'Publicadas',
                        const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildRealMetricBox(
                        'Auditorías',
                        '${provider.auditLogs.length}',
                        'Trazadas hoy',
                        const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // MATRIZ DE BENCHMARKING Y RANKING DE PLANTAS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: App3D.cardShadow(baseColor: const Color(0xFFF59E0B)),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 22),
                        SizedBox(width: 8),
                        Text('Benchmarking Industrial · Ranking Q4', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF002F6C)),
                      tooltip: 'Exportar Ranking',
                      onPressed: () => ExcelService.instance.exportAndShare(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildBenchmarkingRow('🥇 1°', 'Planta Extrusa', '94.2%', '0 Accidentes / 0 Paradas', const Color(0xFF16A34A)),
                const SizedBox(height: 6),
                _buildBenchmarkingRow('🥈 2°', 'Planta Termoformado', '91.8%', '1 Parada Resuelta', const Color(0xFF0284C7)),
                const SizedBox(height: 6),
                _buildBenchmarkingRow('🥉 3°', 'Planta Inyección', '88.5%', '2 Paradas Menores', const Color(0xFFD97706)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // LISTADO DE PLANTAS INSPECCIONABLES
          const Text(
            'Sedes Industriales Darnel (Toca para Inspeccionar)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

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
                  ? const Color(0xFF16A34A)
                  : (st.rate >= 60 ? const Color(0xFF0284C7) : const Color(0xFFEA580C));

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _inspectPlant(context, plant, users),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.domain_rounded, color: Color(0xFF002F6C)),
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
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${plant.codigo} · ${plant.ubicacion}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Inspeccionar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                  SizedBox(width: 2),
                                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF0284C7)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildPlantStatPill('${st.rate.toStringAsFixed(0)}% Cumpl.', pctColor),
                            _buildPlantStatPill('Tareas: ${st.done}/${st.total}', const Color(0xFF002F6C)),
                            _buildPlantStatPill('Pendientes: ${st.pending}', const Color(0xFF0284C7)),
                            if (st.overdue > 0) _buildPlantStatPill('Vencidas: ${st.overdue}', const Color(0xFFDC2626)),
                            _buildPlantStatPill('Sup: ${st.sups} · Op: $plantOps', const Color(0xFF475569)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Admin: ${plantAdmin.nombre}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$plantOps Colaboradores',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildBenchmarkingRow(String rank, String plant, String score, String detail, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(rank, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text(detail, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('Sin solicitudes de tareas adicionales pendientes', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Todas las plantas se mantienen en el estándar de 10 tareas diarias.', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
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
    final pinCtrl = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Editar ${admin.nombre}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
              const SizedBox(height: 8),
              TextField(controller: cargoCtrl, decoration: const InputDecoration(labelText: 'Cargo')),
              const SizedBox(height: 8),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nuevo PIN de Acceso',
                  hintText: 'Dejar vacío para mantener el actual (mín. 4 dígitos)',
                ),
              ),
            ],
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
                          cedula: admin.cedula,
                          nombre: nombreCtrl.text.trim(),
                          cargo: cargoCtrl.text.trim(),
                          area: admin.area,
                          email: admin.email,
                          rol: admin.rol,
                          plantId: admin.plantId,
                          activo: admin.activo,
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: admins.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final admin = admins[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF002F6C),
                child: Text(admin.iniciales, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(admin.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text('${admin.cargo}\nPlanta: ${admin.plantId} · PIN: ${admin.pin}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF002F6C), size: 20),
                    tooltip: 'Editar Administrador',
                    onPressed: () => _showEditAdminDialog(context, admin, provider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                    tooltip: 'Dar de Baja',
                    onPressed: () => _confirmDeleteAdmin(context, admin, provider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_new_process',
        onPressed: () => _showCreateProcessWithAdminModal(context, provider),
        backgroundColor: const Color(0xFF002F6C),
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: const Text('+ Nuevo Proceso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _horaIniCtrl = TextEditingController(text: '08:00');
  final _horaFinCtrl = TextEditingController(text: '09:00');

  String _area = 'Todas las Áreas';
  String _categoria = 'Seguridad y Salud EHS';
  String _prioridad = 'Alta';
  bool _fija = true;
  String _tipoActividad = 'ejecucion'; // 'ejecucion' o 'registro'
  bool _incluyeReunion = false;
  final _reunionHoraCtrl = TextEditingController(text: '08:00 AM');
  String _reunionLugar = 'Sala de Planta';
  bool _planAccionObligatorio = false;
  String _targetPlanta = 'ALL';
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
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe el nombre de la actividad corporativa')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un día de la semana')),
      );
      return;
    }

    if (_tipoActividad == 'ejecucion' && _subtasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En actividad de ejecución, agrega al menos una subtarea para guiar al colaborador')),
      );
      return;
    }

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final sortedDays = (_selectedDays.toList()..sort()).join(',');

    final baseDesc = _descCtrl.text.trim();
    final fullDesc = _incluyeReunion
        ? '${baseDesc.isNotEmpty ? "$baseDesc\n" : ""}[REUNIÓN PROGRAMADA: ${_reunionHoraCtrl.text.trim()} · $_reunionLugar]'
        : baseDesc;

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
      requierePlanAccion: _planAccionObligatorio,
      planAccionObligatorio: _planAccionObligatorio,
      targetPlantIds: _targetPlanta == 'ALL' ? null : [_targetPlanta],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          content: Text('¡Directiva Corporativa de Javier Julio despachada con éxito a todas las plantas!'),
        ),
      );
      _nombreCtrl.clear();
      _descCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BANNER HERO DIRECTIVO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002F6C), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002F6C).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.campaign_rounded, color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Despacho Universal Corporativo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Javier Julio configura las rutinas marco para todas las plantas con control total de días, pasos y evidencias.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // PLANTILLAS RÁPIDAS Y GESTOR DE PLANTILLAS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Plantillas y Estándares:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
              TextButton.icon(
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
                        _subtasks.clear();
                        _subtasks.addAll(tmpl.subtasks.map((s) => s.copyWith(activityId: 0)));
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Plantilla "${tmpl.nombre}" aplicada al despacho'), backgroundColor: const Color(0xFF002F6C)),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.auto_stories_rounded, size: 16, color: Color(0xFF002F6C)),
                label: const Text('Nueva Plantilla / Catálogo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTemplateChip('🛡️ EHS Seguridad', () => _loadTemplate('ehs')),
                const SizedBox(width: 8),
                _buildTemplateChip('⭐ 5S & Orden Gemba', () => _loadTemplate('5s')),
                const SizedBox(width: 8),
                _buildTemplateChip('🔬 Calidad Q4', () => _loadTemplate('calidad')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // MODALIDAD DE ACTIVIDAD
          const Text('Modalidad de la Actividad:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.engineering_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Actividad de Ejecución', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  selected: _tipoActividad == 'ejecucion',
                  selectedColor: const Color(0xFF002F6C),
                  labelStyle: TextStyle(color: _tipoActividad == 'ejecucion' ? Colors.white : const Color(0xFF334155)),
                  onSelected: (_) => setState(() => _tipoActividad = 'ejecucion'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Registro / Reunión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  selected: _tipoActividad == 'registro',
                  selectedColor: const Color(0xFF0284C7),
                  labelStyle: TextStyle(color: _tipoActividad == 'registro' ? Colors.white : const Color(0xFF334155)),
                  onSelected: (_) => setState(() => _tipoActividad = 'registro'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // OPCIÓN DE REUNIÓN PROGRAMADA A X HORA (ESPECIALMENTE PARA RUTINAS FIJAS)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _incluyeReunion ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _incluyeReunion ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    '¿Esta actividad incluye Reunión / Comité?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  subtitle: const Text(
                    'Ideal para rutinas fijas con hora de reunión establecida',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  value: _incluyeReunion,
                  onChanged: (v) => setState(() => _incluyeReunion = v),
                ),
                if (_incluyeReunion) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _reunionHoraCtrl,
                          decoration: InputDecoration(
                            labelText: 'Hora de la Reunión',
                            hintText: 'Ej. 08:00 AM',
                            prefixIcon: const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF0284C7)),
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
                          value: _reunionLugar,
                          decoration: InputDecoration(
                            labelText: 'Lugar / Modalidad',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Sala de Planta', child: Text('Sala de Planta')),
                            DropdownMenuItem(value: 'Piso / Gemba', child: Text('Piso / Gemba')),
                            DropdownMenuItem(value: 'Virtual / Teams', child: Text('Virtual / Teams')),
                          ],
                          onChanged: (v) => setState(() => _reunionLugar = v ?? 'Sala de Planta'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: ['07:00 AM', '08:00 AM', '10:00 AM', '02:00 PM', '04:00 PM']
                        .map((h) => ActionChip(
                              label: Text(h, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => setState(() => _reunionHoraCtrl.text = h),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // PLANTA OBJETIVO
          Builder(
            builder: (context) {
              final allPlants = context.watch<StandardWorkProvider>().allPlants;
              final validValue = (['ALL', ...allPlants.map((p) => p.id)].contains(_targetPlanta)) ? _targetPlanta : 'ALL';
              return DropdownButtonFormField<String>(
                value: validValue,
                decoration: InputDecoration(
                  labelText: 'Alcance Geográfico / Plantas',
                  prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF002F6C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  const DropdownMenuItem(value: 'ALL', child: Text('Todas las Plantas (Despacho Universal)')),
                  ...allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))),
                ],
                onChanged: (val) => setState(() => _targetPlanta = val ?? 'ALL'),
              );
            },
          ),
          const SizedBox(height: 14),

          // CAMPOS BÁSICOS
          TextField(
            controller: _nombreCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre de la Actividad Corporativa *',
              hintText: 'Ej. Verificación de Seguridad y Arranque de Turno',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _descCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Descripción / Directriz Operativa *',
              hintText: 'Instrucción técnica obligatoria para los operadores...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          // ÁREA Y CATEGORÍA
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _area,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Área Destino',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Todas las Áreas', child: Text('Todas las Áreas')),
                    DropdownMenuItem(value: 'Extrusión', child: Text('Extrusión')),
                    DropdownMenuItem(value: 'Termoformado', child: Text('Termoformado')),
                    DropdownMenuItem(value: 'Inyección', child: Text('Inyección')),
                    DropdownMenuItem(value: 'Calidad y Laboratorio', child: Text('Calidad y Laboratorio')),
                    DropdownMenuItem(value: 'Seguridad EHS', child: Text('Seguridad EHS')),
                    DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _area = val);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _categoria,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Seguridad y Salud EHS', child: Text('Seguridad y Salud EHS')),
                    DropdownMenuItem(value: 'Calidad y Tolerancias', child: Text('Calidad y Tolerancias')),
                    DropdownMenuItem(value: '5S y Orden Gemba', child: Text('5S y Orden Gemba')),
                    DropdownMenuItem(value: 'Operativa de Máquina', child: Text('Operativa de Máquina')),
                    DropdownMenuItem(value: 'Mantenimiento Autónomo', child: Text('Mantenimiento Autónomo')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _categoria = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // PRIORIDAD / CRITICIDAD
          const Text('Nivel de Criticidad / Prioridad:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriorityChoice('Alta', const Color(0xFFDC2626)),
              const SizedBox(width: 8),
              _buildPriorityChoice('Media', const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildPriorityChoice('Baja', const Color(0xFF0284C7)),
            ],
          ),
          const SizedBox(height: 14),

          // HORARIO Y TIPO
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _horaIniCtrl,
                  decoration: InputDecoration(
                    labelText: 'Hora Inicio',
                    prefixIcon: const Icon(Icons.access_time_rounded, size: 18),
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
                  decoration: InputDecoration(
                    labelText: 'Hora Fin',
                    prefixIcon: const Icon(Icons.timer_off_outlined, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SwitchListTile(
              title: const Text('Actividad Fija Inmutable (No reprogramable)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('El operador no podrá cambiarla de día sin autorización', style: TextStyle(fontSize: 11)),
              value: _fija,
              activeColor: const Color(0xFFDC2626),
              onChanged: (val) => setState(() => _fija = val),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SwitchListTile(
              title: const Text('Requiere Plan de Acción Obligatorio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('El colaborador no podrá completar la actividad sin diligenciar y cerrar el plan asociado', style: TextStyle(fontSize: 11)),
              value: _planAccionObligatorio,
              activeColor: const Color(0xFFD97706),
              onChanged: (val) => setState(() => _planAccionObligatorio = val),
            ),
          ),
          const SizedBox(height: 16),

          // DÍAS DE LA SEMANA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Qué días de la semana aplica?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => _selectedDays.addAll([1, 2, 3, 4, 5])),
                    child: const Text('Lun-Vie', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedDays.addAll([1, 2, 3, 4, 5, 6])),
                    child: const Text('Toda Semana', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: dayNames.entries.map((e) {
              final isSelected = _selectedDays.contains(e.key);
              return FilterChip(
                label: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : const Color(0xFF0F172A))),
                selected: isSelected,
                selectedColor: const Color(0xFF002F6C),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: isSelected ? const Color(0xFF002F6C) : Colors.grey.shade300),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedDays.add(e.key);
                    } else {
                      if (_selectedDays.length > 1) _selectedDays.remove(e.key);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // SUBTAREAS Y REQUISITOS DINÁMICOS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtareas y Requisitos (${_subtasks.length} pasos):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ElevatedButton.icon(
                onPressed: () => _showSubtaskDialog(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Agregar Paso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002F6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_subtasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text('No hay subtareas. Toca "+ Agregar Paso" para configurar requisitos.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
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
                            Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            if (s.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(s.descripcion, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (s.requiereFoto)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.camera_alt_rounded, size: 12, color: Color(0xFF0284C7)),
                                        SizedBox(width: 4),
                                        Text('Foto Obligatoria', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                      ],
                                    ),
                                  ),
                                if (s.requiereComentario)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.comment_rounded, size: 12, color: Color(0xFFF59E0B)),
                                        SizedBox(width: 4),
                                        Text('Comentario Requerido', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                                      ],
                                    ),
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
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                        onPressed: () => setState(() => _subtasks.removeAt(i)),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // BOTÓN DE DESPACHO
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _dispatch,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text(
                'Despachar Actividad a Todas las Plantas (Javier Julio)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002F6C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final log = logs[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF002F6C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history_rounded, color: Color(0xFF002F6C), size: 20),
          ),
          title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text('${log.details}\nUsuario: ${log.userId} · ${log.timestamp.toString().substring(0, 16)}'),
          isThreeLine: true,
        );
      },
    );
  }
}
