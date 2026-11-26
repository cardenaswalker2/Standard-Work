import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/action_plan_dialog.dart';
import '../../core/widgets/activity_execution_modal.dart';
import '../../core/widgets/activity_subtasks_modal.dart';
import '../../core/widgets/collaborator_profile_modal.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/widgets/meeting_record_dialog.dart';
import '../../data/models/app_models.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/ultra_report_service.dart';
import '../login/login_screen.dart';

const Color _kSupBg = Color(0xFFF5F7FB);
const Color _kSupNavy = Color(0xFF002F6C);
const Color _kSupBlue = Color(0xFF007AFF);
const Color _kSupText = Color(0xFF0F172A);
const Color _kSupMuted = Color(0xFF64748B);
const Color _kSupBorder = Color(0xFFE2E8F0);
const Color _kSupGreen = Color(0xFF16A34A);
const Color _kSupAmber = Color(0xFFD97706);
const Color _kSupRed = Color(0xFFDC2626);

const Map<int, String> _kSupDayNames = {
  1: 'Lun',
  2: 'Mar',
  3: 'Mié',
  4: 'Jue',
  5: 'Vie',
  6: 'Sáb',
};

class SupervisorShellScreen extends StatefulWidget {
  const SupervisorShellScreen({super.key});

  @override
  State<SupervisorShellScreen> createState() => _SupervisorShellScreenState();
}

class _SupervisorShellScreenState extends State<SupervisorShellScreen> {
  int _currentScreenIndex = 0;
  int _touchedPieIndex = -1;
  int? _selectedChartDay;

  List<SubtaskExecutionModel> _allExecutions = [];
  bool _loadingExecutions = true;

  // Filtros Mis Actividades
  int _myDayFilter = 0; // 0 = Todos
  String _mySearch = '';
  bool _myScheduleMode = false;

  // Filtros Mi Equipo
  String _teamSearch = '';

  // Filtros Seguimiento
  String _segStatusFilter = 'Todas'; // Todas, Pendientes, Completadas, Por Validar
  String? _segOperatorId;
  int _segDayFilter = 0;

  // Filtros Planes
  String _planFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadExecutions();
  }

  Future<void> _loadExecutions() async {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    if (provider.currentUser == null) return;
    final list = await provider.getPendingReviewsForPlant();
    if (mounted) {
      setState(() {
        _allExecutions = list;
        _loadingExecutions = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    await provider.refreshData();
    await _loadExecutions();
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.photo_rounded, size: 40, color: Colors.grey),
      );
    }
    if (kIsWeb) {
      return const Icon(Icons.image_rounded, size: 40, color: Colors.grey);
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded, size: 40, color: Colors.grey),
    );
  }

  void _inspectEvidenceModal(BuildContext context, SubtaskExecutionModel rev) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inspección de Evidencia en Piso',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _kSupNavy),
                        ),
                        Text(
                          'Operador ID: ${rev.userId} · Subtarea #${rev.subtaskId}',
                          style: const TextStyle(fontSize: 12, color: _kSupMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const Divider(height: 24),
              if (rev.fotoPath != null && rev.fotoPath!.isNotEmpty) ...[
                const Text('Registro Fotográfico Adjunto:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: _buildImageWidget(rev.fotoPath!),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (rev.valorMedido != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: _kSupGreen),
                      const SizedBox(width: 10),
                      Text(
                        'Medición reportada: ${rev.valorMedido}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: _kSupGreen, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text('Comentario del Colaborador:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kSupBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kSupBorder),
                ),
                child: Text(
                  rev.comentario?.isNotEmpty == true ? rev.comentario! : 'Sin observaciones registradas por el operador.',
                  style: const TextStyle(fontSize: 13, color: _kSupText),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                        await provider.rejectSubtaskExecution(
                          executionId: rev.id!,
                          motivoRechazo: 'Evidencia no conforme. Requiere corrección en piso.',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _loadExecutions();
                      },
                      icon: const Icon(Icons.thumb_down_alt_rounded, color: _kSupRed),
                      label: const Text('Rechazar', style: TextStyle(color: _kSupRed, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _kSupRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                        await provider.approveSubtaskExecution(executionId: rev.id!, instanceId: rev.instanceId);
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _loadExecutions();
                      },
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: const Text('Aprobar', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kSupGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoStandardsModal(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Banco de Estándares Visuales 5S', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _kSupNavy)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const Divider(),
            Expanded(
              child: provider.photoStandards.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay fotos modelo registradas aún en esta planta.',
                        style: TextStyle(color: _kSupMuted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.photoStandards.length,
                      itemBuilder: (_, i) {
                        final std = provider.photoStandards[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _kSupBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _kSupBorder),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(width: 54, height: 54, child: _buildImageWidget(std.fotoPath)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(std.titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _kSupText)),
                                    const SizedBox(height: 2),
                                    Text('${std.area} · ${std.descripcion}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _kSupMuted)),
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

  void _showGemba5SModal(BuildContext context) {
    final areaCtrl = TextEditingController(text: 'Piso de Producción');
    final obsCtrl = TextEditingController();
    final scores = <String, int>{
      'Seiri (Clasificar)': 5,
      'Seiton (Ordenar)': 5,
      'Seiso (Limpiar)': 5,
      'Seiketsu (Estandarizar)': 5,
      'Shitsuke (Disciplina)': 5,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ronda Gemba Walk & Auditoría 5S', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _kSupNavy)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: areaCtrl,
                        decoration: InputDecoration(
                          labelText: 'Área / Línea Auditada',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...scores.keys.map((pillar) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _kSupBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _kSupBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(pillar, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                                DropdownButton<int>(
                                  value: scores[pillar],
                                  underline: const SizedBox(),
                                  items: [1, 2, 3, 4, 5]
                                      .map((v) => DropdownMenuItem(value: v, child: Text('$v / 5', style: const TextStyle(fontWeight: FontWeight.w700))))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) setModalState(() => scores[pillar] = v);
                                  },
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                      TextField(
                        controller: obsCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Hallazgos / Observaciones Gemba',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                    final avg = scores.values.reduce((a, b) => a + b) / scores.length;
                    final pctScore = (avg * 20).round();
                    await provider.submitGemba5SWalk(
                      plantId: provider.currentUser?.plantId ?? 'ALL',
                      score: pctScore,
                      notes: '${areaCtrl.text.trim().isEmpty ? "General" : areaCtrl.text.trim()}: ${obsCtrl.text.trim()}',
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kSupGreen,
                          content: Text('Ronda 5S registrada ($pctScore%)'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: const Text('Registrar Auditoría 5S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kSupNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;
    final isWide = MediaQuery.of(context).size.width >= 900;

    final myPendingCount = provider.instances
        .where((i) => i.userId == user?.id && i.day == provider.selectedDay && !i.done)
        .length;
    final openPlansCount = provider.proPlans.where((p) => p.estado != 'Cumplido').length;
    final pendingReviewsCount = _allExecutions.where((e) => e.reportada && !e.aprobada && (e.motivoRechazo == null || e.motivoRechazo!.isEmpty)).length;

    final navItems = [
      (label: 'Mis Actividades', icon: Icons.task_alt_rounded, badge: myPendingCount),
      (label: 'Mi Equipo', icon: Icons.groups_rounded, badge: 0),
      (label: 'Seguimiento', icon: Icons.fact_check_rounded, badge: pendingReviewsCount),
      (label: 'Planes', icon: Icons.flag_rounded, badge: openPlansCount),
      (label: 'Indicadores', icon: Icons.bar_chart_rounded, badge: 0),
    ];

    final bodyContent = IndexedStack(
      index: _currentScreenIndex,
      children: [
        _buildMisActividades(context, provider),
        _buildResumenEquipo(context, provider),
        _buildSeguimientoActividades(context, provider),
        _buildSeguimientoPlanes(context, provider),
        _buildSupervisorIndicadores(context, provider),
      ],
    );

    return Scaffold(
      backgroundColor: _kSupBg,
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
              selectedItemColor: _kSupBlue,
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
        border: Border(right: BorderSide(color: _kSupBorder)),
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
                    decoration: BoxDecoration(
                      color: _kSupNavy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRACK60', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _kSupNavy)),
                        Text(
                          'Planta ${user?.plantId ?? "-"}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: _kSupMuted),
                        ),
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
                          color: selected ? _kSupNavy : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 19, color: selected ? Colors.white : _kSupMuted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                  color: selected ? Colors.white : _kSupText,
                                ),
                              ),
                            ),
                            if (item.badge > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white.withValues(alpha: 0.2) : _kSupRed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${item.badge}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                ),
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
        border: Border(bottom: BorderSide(color: _kSupBorder)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kSupNavy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security_rounded, color: Colors.white, size: 13),
                SizedBox(width: 5),
                Text(
                  'SUPERVISOR',
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
                Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _kSupText)),
                Text(
                  '${user?.nombre ?? "Supervisor"} · ${provider.currentPlant?.nombre ?? user?.plantId ?? ""}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _kSupMuted),
                ),
              ],
            ),
          ),
          _headerIconButton(
            tooltip: 'Actualizar datos',
            icon: Icons.sync_rounded,
            onPressed: _refreshAll,
          ),
          _headerIconButton(
            tooltip: 'Banco Estándares 5S',
            icon: Icons.photo_library_rounded,
            onPressed: () => _showPhotoStandardsModal(context),
          ),
          _headerIconButton(
            tooltip: 'Ronda Gemba 5S',
            icon: Icons.checklist_rtl_rounded,
            onPressed: () => _showGemba5SModal(context),
          ),
          _headerIconButton(
            tooltip: 'Guía de Uso',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _kSupBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kSupBorder),
            ),
            child: Icon(icon, size: 17, color: _kSupNavy),
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
              Expanded(
                child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kSupMuted)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // --- TAB 0: MIS ACTIVIDADES ---
  Widget _buildMisActividades(BuildContext context, StandardWorkProvider provider) {
    final user = provider.currentUser;
    final allMy = provider.instances.where((i) => i.userId == user?.id).toList();
    final filtered = allMy.where((i) {
      if (_myDayFilter != 0 && i.day != _myDayFilter) return false;
      if (_mySearch.isNotEmpty) {
        final q = _mySearch.toLowerCase();
        if (!i.nombre.toLowerCase().contains(q) && !i.area.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));

    final doneCount = allMy.where((i) => i.done).length;
    final pendingCount = allMy.length - doneCount;
    final planCount = allMy.where((i) => i.requierePlanAccion).length;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildBentoKpi('Asignadas', '${allMy.length}', _kSupBlue, Icons.layers_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Hechas', '$doneCount', _kSupGreen, Icons.check_circle_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Pendientes', '$pendingCount', _kSupRed, Icons.pending_actions_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Con Plan', '$planCount', _kSupAmber, Icons.flag_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _mySearch = v.trim()),
            decoration: InputDecoration(
              hintText: 'Buscar en mis actividades o áreas...',
              prefixIcon: const Icon(Icons.search_rounded, size: 19, color: _kSupMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kSupBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kSupBorder)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _dayFilterChip(0, 'Todos', _myDayFilter, (d) => setState(() => _myDayFilter = d)),
                      for (final entry in _kSupDayNames.entries)
                        _dayFilterChip(entry.key, entry.value, _myDayFilter, (d) => setState(() => _myDayFilter = d)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, icon: Icon(Icons.view_agenda_rounded, size: 16), label: Text('Lista', style: TextStyle(fontSize: 11))),
                  ButtonSegment(value: true, icon: Icon(Icons.schedule_rounded, size: 16), label: Text('Horario', style: TextStyle(fontSize: 11))),
                ],
                selected: {_myScheduleMode},
                onSelectionChanged: (s) => setState(() => _myScheduleMode = s.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? _kSupNavy : Colors.white),
                  foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : _kSupText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kSupBorder)),
              child: const Column(
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 42, color: _kSupMuted),
                  SizedBox(height: 10),
                  Text('No tienes actividades para este filtro', style: TextStyle(fontWeight: FontWeight.w700, color: _kSupMuted)),
                ],
              ),
            )
          else if (_myScheduleMode)
            ..._buildScheduleView(filtered, (inst) => _executeSupervisorActivity(context, provider, inst))
          else
            ...filtered.map((inst) => _buildMyActivityCard(context, provider, inst)),
        ],
      ),
    );
  }

  Widget _dayFilterChip(int day, String label, int current, ValueChanged<int> onTap) {
    final selected = day == current;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _kSupText)),
        selected: selected,
        selectedColor: _kSupNavy,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? _kSupNavy : _kSupBorder),
        onSelected: (_) => onTap(day),
      ),
    );
  }

  List<Widget> _buildScheduleView(List<ActivityInstance> items, ValueChanged<ActivityInstance> onTap) {
    final byHour = <String, List<ActivityInstance>>{};
    for (final inst in items) {
      byHour.putIfAbsent(inst.timeStart, () => []).add(inst);
    }
    final hours = byHour.keys.toList()..sort();
    return hours.map((hour) {
      final list = byHour[hour]!;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kSupBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _kSupNavy.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(hour, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _kSupNavy)),
                ),
                const SizedBox(width: 8),
                Text('${list.length} actividad(es)', style: const TextStyle(fontSize: 11, color: _kSupMuted, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            ...list.map((inst) {
              final st = _supStatusStyle(inst);
              return InkWell(
                onTap: () => onTap(inst),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: st.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: st.border, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        inst.done ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        size: 20,
                        color: st.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inst.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _kSupText)),
                            Text(
                              '${_kSupDayNames[inst.day] ?? ""} · ${inst.area} · ${inst.timeStart}-${inst.timeEnd}',
                              style: const TextStyle(fontSize: 11, color: _kSupMuted),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusPill(inst),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _executeSupervisorActivity(BuildContext context, StandardWorkProvider provider, ActivityInstance inst) async {
    if (inst.tipoActividad == 'registro') {
      await MeetingRecordDialog.show(context: context, instance: inst);
    } else {
      await ActivityExecutionModal.show(context: context, instance: inst);
    }
    await _refreshAll();
  }

  ({Color bg, Color border, Color accent}) _supStatusStyle(ActivityInstance item) {
    if (item.done) {
      return (bg: const Color(0xFFF0FDF4), border: const Color(0xFF86EFAC), accent: _kSupGreen);
    }
    if (item.state == 'Reprogramada') {
      return (bg: const Color(0xFFFFFBEB), border: const Color(0xFFFDE68A), accent: _kSupAmber);
    }
    return (bg: const Color(0xFFFEF2F2), border: const Color(0xFFFCA5A5), accent: _kSupRed);
  }

  Widget _buildMyActivityCard(BuildContext context, StandardWorkProvider provider, ActivityInstance inst) {
    final st = _supStatusStyle(inst);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: st.border, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 5, height: 38, decoration: BoxDecoration(color: st.accent, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inst.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kSupText)),
                    Text(
                      '${_kSupDayNames[inst.day] ?? ""} · ${inst.timeStart}-${inst.timeEnd} · ${inst.area}',
                      style: const TextStyle(fontSize: 11, color: _kSupMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(inst),
            ],
          ),
          if (inst.descripcion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(inst.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _kSupText)),
          ],
          if (inst.subtasksTotal > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: inst.subtasksReported / inst.subtasksTotal,
                      minHeight: 5,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(st.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${inst.subtasksReported}/${inst.subtasksTotal} pasos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: st.accent)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (!inst.done)
                ElevatedButton.icon(
                  onPressed: () => _executeSupervisorActivity(context, provider, inst),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                  label: Text(inst.tipoActividad == 'registro' ? 'Registrar Reunión' : 'Ejecutar',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kSupNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              if (inst.subtasksTotal > 0)
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ActivitySubtasksModal(
                        instance: inst,
                        onComplete: (data) async {
                          for (final e in data.entries) {
                            await provider.reportSubtaskExecution(
                              instanceId: inst.id!,
                              subtaskId: e.key,
                              photoPath: e.value['photo'] as String?,
                              comment: e.value['comment'] as String?,
                              measuredValue: e.value['measurement'] as double?,
                            );
                          }
                          await _refreshAll();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.checklist_rounded, size: 15),
                  label: Text('Subtareas (${inst.subtasksReported}/${inst.subtasksTotal})', style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kSupBlue,
                    side: const BorderSide(color: _kSupBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              if (inst.requierePlanAccion)
                OutlinedButton.icon(
                  onPressed: () async {
                    await ActionPlanDialog.show(context: context, instance: inst, isMandatoryForActivity: inst.planAccionObligatorio);
                    await _refreshAll();
                  },
                  icon: const Icon(Icons.flag_rounded, size: 15),
                  label: const Text('Plan de Acción', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kSupAmber,
                    side: BorderSide(color: _kSupAmber.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: MI EQUIPO ---
  Widget _buildResumenEquipo(BuildContext context, StandardWorkProvider provider) {
    final plantId = provider.currentUser?.plantId ?? '';
    final operators = provider.allUsers.where((u) => u.isOperator && u.plantId == plantId).where((u) {
      if (_teamSearch.isEmpty) return true;
      final q = _teamSearch.toLowerCase();
      return u.nombre.toLowerCase().contains(q) || u.area.toLowerCase().contains(q);
    }).toList();

    final teamTasks = provider.instances.where((i) => i.plantId == plantId).toList();
    final doneTeam = teamTasks.where((i) => i.done).length;
    final pct = teamTasks.isEmpty ? 0.0 : (doneTeam / teamTasks.length) * 100;
    final pendingRev = _allExecutions.where((e) => e.reportada && !e.aprobada && (e.motivoRechazo == null || e.motivoRechazo!.isEmpty)).length;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildBentoKpi('Operadores', '${operators.length}', _kSupNavy, Icons.groups_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('Cumplimiento', '${pct.toStringAsFixed(0)}%', _kSupGreen, Icons.verified_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildBentoKpi('x Revisar', '$pendingRev', _kSupAmber, Icons.rate_review_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showGemba5SModal(context),
                  icon: const Icon(Icons.checklist_rtl_rounded, size: 17, color: Colors.white),
                  label: const Text('Ronda Gemba 5S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kSupNavy,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPhotoStandardsModal(context),
                  icon: const Icon(Icons.photo_library_rounded, size: 17),
                  label: const Text('Estándares 5S', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kSupNavy,
                    side: const BorderSide(color: _kSupBorder),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _teamSearch = v.trim()),
            decoration: InputDecoration(
              hintText: 'Buscar colaborador por nombre o área...',
              prefixIcon: const Icon(Icons.search_rounded, size: 19, color: _kSupMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kSupBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kSupBorder)),
            ),
          ),
          const SizedBox(height: 12),
          if (operators.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kSupBorder)),
              child: const Center(child: Text('No hay operadores asignados a esta planta.', style: TextStyle(color: _kSupMuted))),
            )
          else
            ...operators.map((op) {
              final opTasks = teamTasks.where((t) => t.userId == op.id).toList();
              final opDone = opTasks.where((t) => t.done).length;
              final opPct = opTasks.isEmpty ? 0.0 : opDone / opTasks.length;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kSupBorder)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _kSupNavy.withValues(alpha: 0.1),
                          child: Text(op.iniciales, style: const TextStyle(color: _kSupNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(op.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kSupText)),
                              Text('${op.cargo} · ${op.area}', style: const TextStyle(fontSize: 11, color: _kSupMuted)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ver Perfil',
                          icon: const Icon(Icons.person_search_rounded, color: _kSupBlue),
                          onPressed: () => CollaboratorProfileModal.show(context, op, opTasks, provider),
                        ),
                        IconButton(
                          tooltip: 'Ver Actividades',
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: _kSupMuted),
                          onPressed: () {
                            setState(() {
                              _segOperatorId = op.id;
                              _currentScreenIndex = 2;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: opPct,
                        minHeight: 7,
                        backgroundColor: _kSupBg,
                        valueColor: AlwaysStoppedAnimation<Color>(opPct >= 0.8 ? _kSupGreen : (opPct >= 0.4 ? _kSupAmber : _kSupBlue)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$opDone/${opTasks.length} completadas', style: const TextStyle(fontSize: 11, color: _kSupMuted, fontWeight: FontWeight.w600)),
                        Text('${(opPct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _kSupNavy)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- TAB 2: SEGUIMIENTO ---
  Widget _buildSeguimientoActividades(BuildContext context, StandardWorkProvider provider) {
    final plantId = provider.currentUser?.plantId ?? '';
    final operators = provider.allUsers.where((u) => u.isOperator && u.plantId == plantId).toList();
    final usersById = {for (final u in provider.allUsers) u.id: u};

    final pendingReviews = _allExecutions.where((e) => e.reportada && !e.aprobada && (e.motivoRechazo == null || e.motivoRechazo!.isEmpty)).toList();

    final list = provider.instances.where((i) {
      if (i.plantId != plantId) return false;
      if (_segOperatorId != null && i.userId != _segOperatorId) return false;
      if (_segDayFilter != 0 && i.day != _segDayFilter) return false;
      if (_segStatusFilter == 'Pendientes' && i.done) return false;
      if (_segStatusFilter == 'Completadas' && !i.done) return false;
      if (_segStatusFilter == 'Por Validar' && i.state != 'Reportada') return false;
      return true;
    }).toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loadingExecutions)
            const LinearProgressIndicator()
          else if (pendingReviews.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kSupAmber.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rate_review_rounded, color: _kSupAmber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Evidencias por Validar (${pendingReviews.length})',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _kSupText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...pendingReviews.take(5).map((rev) => InkWell(
                        onTap: () => _inspectEvidenceModal(context, rev),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_camera_rounded, size: 16, color: _kSupBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${usersById[rev.userId]?.nombre ?? rev.userId} · Subtarea #${rev.subtaskId}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Text('Revisar >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kSupBlue)),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todas', 'Pendientes', 'Completadas', 'Por Validar'].map((lbl) {
                final selected = _segStatusFilter == lbl;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(lbl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _kSupText)),
                    selected: selected,
                    selectedColor: _kSupNavy,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? _kSupNavy : _kSupBorder),
                    onSelected: (_) => setState(() => _segStatusFilter = lbl),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _segOperatorId,
                  decoration: InputDecoration(
                    labelText: 'Filtrar Colaborador',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kSupBorder)),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todo el Equipo')),
                    ...operators.map((op) => DropdownMenuItem(value: op.id, child: Text(op.nombre))),
                  ],
                  onChanged: (v) => setState(() => _segOperatorId = v),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _segDayFilter,
                items: [
                  const DropdownMenuItem(value: 0, child: Text('Todos los días')),
                  for (final e in _kSupDayNames.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _segDayFilter = v ?? 0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kSupBorder)),
              child: const Center(child: Text('No hay actividades que coincidan con los filtros.', style: TextStyle(color: _kSupMuted))),
            )
          else
            ...list.map((inst) {
              final opName = usersById[inst.userId]?.nombre ?? inst.userId;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kSupBorder)),
                child: Row(
                  children: [
                    Icon(inst.done ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        color: inst.done ? _kSupGreen : _kSupAmber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inst.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('$opName · ${_kSupDayNames[inst.day] ?? ""} · ${inst.timeStart}-${inst.timeEnd}',
                              style: const TextStyle(fontSize: 11, color: _kSupMuted)),
                        ],
                      ),
                    ),
                    _buildStatusPill(inst),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- TAB 3: PLANES DE ACCIÓN ---
  Widget _buildSeguimientoPlanes(BuildContext context, StandardWorkProvider provider) {
    final plans = provider.proPlans.where((p) {
      if (_planFilter == 'Todos') return true;
      return p.estado == _planFilter;
    }).toList();

    return RefreshIndicator(
      onRefresh: _refreshAll,
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
                          label: Text(lbl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _kSupText)),
                          selected: selected,
                          selectedColor: _kSupNavy,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: selected ? _kSupNavy : _kSupBorder),
                          onSelected: (_) => setState(() => _planFilter = lbl),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await ActionPlanDialog.show(context: context);
                  await _refreshAll();
                },
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text('Nuevo Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSupNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kSupBorder)),
              child: const Center(child: Text('No hay planes de acción para mostrar.', style: TextStyle(color: _kSupMuted))),
            )
          else
            ...plans.map((p) {
              final isDone = p.estado == 'Cumplido';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kSupBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.plan, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kSupText)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isDone ? _kSupGreen : _kSupAmber).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(p.estado, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDone ? _kSupGreen : _kSupAmber)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Resp: ${p.responsable} · Área: ${p.area} · Límite: ${p.fechaCompromiso}',
                        style: const TextStyle(fontSize: 11, color: _kSupMuted)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (!isDone)
                          TextButton.icon(
                            onPressed: () => provider.updateProPlanStatus(planId: p.id!, nuevoEstado: 'Cumplido', porcentajeAvance: 1.0),
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: _kSupGreen),
                            label: const Text('Marcar Cumplido', style: TextStyle(fontSize: 12, color: _kSupGreen, fontWeight: FontWeight.w700)),
                          ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Eliminar Plan',
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: _kSupRed),
                          onPressed: () => provider.deleteProPlan(p.id!),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- TAB 4: INDICADORES ---
  Widget _buildSupervisorIndicadores(BuildContext context, StandardWorkProvider provider) {
    final plantId = provider.currentUser?.plantId ?? '';
    final plantTasks = provider.instances.where((i) => i.plantId == plantId).toList();
    final total = plantTasks.length;
    final done = plantTasks.where((i) => i.done).length;
    final pending = total - done;
    final pct = total == 0 ? 0.0 : (done / total) * 100;

    final dayGroups = <BarChartGroupData>[];
    for (int d = 1; d <= 6; d++) {
      final dayItems = plantTasks.where((i) => i.day == d).toList();
      final dayPct = dayItems.isEmpty ? 0.0 : (dayItems.where((i) => i.done).length / dayItems.length) * 100;
      dayGroups.add(
        BarChartGroupData(
          x: d,
          barRods: [
            BarChartRodData(
              toY: dayPct,
              width: 18,
              borderRadius: BorderRadius.circular(6),
              color: _selectedChartDay == d ? _kSupBlue : _kSupNavy,
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
            Expanded(child: _buildBentoKpi('Cumplimiento Planta', '${pct.toStringAsFixed(1)}%', _kSupNavy, Icons.insights_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoKpi('Completadas', '$done', _kSupGreen, Icons.check_circle_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoKpi('Pendientes', '$pending', _kSupRed, Icons.pending_rounded)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final usersById = {for (final u in provider.allUsers) u.id: u};
                  await ExcelService.instance.exportFilteredReport(
                    filterSummary: 'Supervisor · Planta $plantId',
                    plants: provider.allPlants.where((p) => p.id == plantId).toList(),
                    instances: plantTasks,
                    plans: provider.proPlans,
                    usersById: usersById,
                  );
                },
                icon: const Icon(Icons.table_chart_rounded, size: 17, color: Colors.white),
                label: const Text('Exportar Excel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSupGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final usersById = {for (final u in provider.allUsers) u.id: u};
                  await UltraReportService.instance.generateFilteredExecutivePdf(
                    issuerName: provider.currentUser?.nombre ?? 'Supervisor',
                    filterSummary: 'Supervisor · Planta $plantId',
                    plants: provider.allPlants.where((p) => p.id == plantId).toList(),
                    instances: plantTasks,
                    plans: provider.proPlans,
                    usersById: usersById,
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 17, color: Colors.white),
                label: const Text('Reporte PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSupNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kSupBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cumplimiento Diario (Lun - Sáb)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kSupNavy)),
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
                          getTitlesWidget: (v, _) => Text(_kSupDayNames[v.toInt()] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _kSupBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Distribución de Ejecución', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kSupNavy)),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: total == 0
                    ? const Center(child: Text('Sin actividades registradas todavía', style: TextStyle(color: _kSupMuted)))
                    : PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, resp) {
                              setState(() {
                                _touchedPieIndex = resp?.touchedSection?.touchedSectionIndex ?? -1;
                              });
                            },
                          ),
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: done.toDouble(),
                              color: _kSupGreen,
                              radius: _touchedPieIndex == 0 ? 52 : 44,
                              title: '$done\nHechas',
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: pending.toDouble(),
                              color: _kSupRed,
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

  Widget _buildStatusPill(ActivityInstance item) {
    final bg = item.done ? _kSupGreen.withValues(alpha: 0.12) : _kSupAmber.withValues(alpha: 0.12);
    final fg = item.done ? _kSupGreen : _kSupAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(item.state, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
