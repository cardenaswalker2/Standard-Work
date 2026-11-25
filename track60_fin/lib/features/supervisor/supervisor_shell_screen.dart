import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/excel_service.dart';
import '../../data/models/app_models.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/widgets/collaborator_profile_modal.dart';
import '../../core/widgets/action_plan_dialog.dart';
import '../../core/widgets/meeting_record_dialog.dart';
import '../../core/widgets/activity_execution_modal.dart';
import '../../core/theme/app_theme.dart';
import '../login/login_screen.dart';
import '../../core/widgets/track60_charts.dart';

class SupervisorShellScreen extends StatefulWidget {
  const SupervisorShellScreen({super.key});

  @override
  State<SupervisorShellScreen> createState() => _SupervisorShellScreenState();
}

class _SupervisorShellScreenState extends State<SupervisorShellScreen> {
  // 5 secciones principales del Supervisor:
  // 0: Mis Actividades (Trabajo personal del Supervisor - primera al entrar)
  // 1: Mi Equipo (Resumen y cumplimiento)
  // 2: Seguimiento (Revisión de actividades del equipo)
  // 3: Planes (Planes de acción en pantalla dedicada)
  // 4: Indicadores (Métricas personales y de equipo)
  int _currentScreenIndex = 0;
  int _touchedSupPieIndex = -1;
  int? _selectedSupChartDay;

  List<SubtaskExecutionModel> _allExecutions = [];
  bool _loading = true;
  String _selectedActivityFilter = 'Todas';
  String _selectedPlanFilter = 'Todos';
  String? _selectedOperatorFilter;
  String _personSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExecutions();
  }

  Future<void> _loadExecutions() async {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final plantId = provider.currentUser?.plantId;
    if (plantId == null) return;

    final list = await provider.getPendingReviewsForPlant();
    if (mounted) {
      setState(() {
        _allExecutions = list;
        _loading = false;
      });
    }
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
                        Text('Inspección de Evidencia en Piso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF002F6C))),
                        Text('Operador ID: ${rev.userId} · Subtarea #${rev.subtaskId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const Divider(height: 24),
              if (rev.fotoPath != null && rev.fotoPath!.isNotEmpty) ...[
                const Text('Registro Fotográfico Adjunto:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: Color(0xFF16A34A)),
                      const SizedBox(width: 10),
                      Text('Medición reportada: ${rev.valorMedido}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A), fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text('Comentario del Colaborador:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: Text(rev.comentario?.isNotEmpty == true ? rev.comentario! : 'Sin observaciones registradas por el operador.', style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                        await provider.rejectSubtaskExecution(executionId: rev.id!, motivoRechazo: 'Evidencia no conforme. Requiere corrección en piso.');
                        Navigator.pop(ctx);
                        _loadExecutions();
                      },
                      icon: const Icon(Icons.thumb_down_alt_rounded, color: Color(0xFFDC2626)),
                      label: const Text('Rechazar', style: TextStyle(color: Color(0xFFDC2626))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final provider = Provider.of<StandardWorkProvider>(context, listen: false);
                        await provider.approveSubtaskExecution(executionId: rev.id!, instanceId: rev.instanceId);
                        Navigator.pop(ctx);
                        _loadExecutions();
                      },
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: const Text('Aprobar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey));
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo_rounded, size: 40, color: Colors.grey));
    } else {
      return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded, size: 40, color: Colors.grey));
    }
  }

  void _showPhotoStandardsModal(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Banco de Estándares Visuales 5S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002F6C))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const Divider(),
            Expanded(
              child: provider.photoStandards.isEmpty
                  ? const Center(child: Text('No hay fotos modelo registradas aún en esta planta.'))
                  : ListView.builder(
                      itemCount: provider.photoStandards.length,
                      itemBuilder: (ctx, i) {
                        final std = provider.photoStandards[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(width: 50, height: 50, child: _buildImageWidget(std.fotoPath)),
                            ),
                            title: Text(std.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${std.area} · ${std.descripcion}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ronda Gemba Walk & Auditoría 5S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002F6C))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const Divider(),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.cleaning_services_rounded, color: Color(0xFF0284C7)),
                      title: Text('1. Seiri (Clasificar / Despejar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Área libre de materiales obsoletos o fuera de estándar.', style: TextStyle(fontSize: 11)),
                    ),
                    ListTile(
                      leading: Icon(Icons.grid_view_rounded, color: Color(0xFF0284C7)),
                      title: Text('2. Seiton (Ordenar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Herramientas y bobinas demarcadas e identificadas.', style: TextStyle(fontSize: 11)),
                    ),
                    ListTile(
                      leading: Icon(Icons.auto_awesome_rounded, color: Color(0xFF0284C7)),
                      title: Text('3. Seiso (Limpiar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Línea de extrusión/termoformado sin residuos ni fugas.', style: TextStyle(fontSize: 11)),
                    ),
                    ListTile(
                      leading: Icon(Icons.fact_check_rounded, color: Color(0xFF0284C7)),
                      title: Text('4. Seiketsu (Estandarizar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Formatos y checklist operacionales visibles y al día.', style: TextStyle(fontSize: 11)),
                    ),
                    ListTile(
                      leading: Icon(Icons.psychology_rounded, color: Color(0xFF0284C7)),
                      title: Text('5. Shitsuke (Disciplina)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Uso riguroso de EPPs y cumplimiento del turno.', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
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
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // HEADER EMPRESARIAL
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
                                  Icon(Icons.security_rounded, color: Colors.white, size: 13),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'NIVEL 3 · SUPERVISOR',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Banco Fotos 5S',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 19),
                                onPressed: () => _showPhotoStandardsModal(context),
                              ),
                              IconButton(
                                tooltip: 'Ronda 5S',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.checklist_rtl_rounded, color: Colors.white, size: 19),
                                onPressed: () => _showGemba5SModal(context),
                              ),
                              IconButton(
                                tooltip: 'Guía',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 19),
                                onPressed: () => HelpGuideModal.show(context),
                              ),
                              IconButton(
                                tooltip: 'Exportar Excel',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 19),
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
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 19),
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
                        user?.nombre ?? 'Supervisor de Planta',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${user?.cargo} · Planta ${user?.plantId} · Equipo Asignado',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // PANTALLAS (0: MIS ACTIVIDADES, 1: MI EQUIPO, 2: SEGUIMIENTO, 3: PLANES, 4: INDICADORES)
          Expanded(
            child: IndexedStack(
              index: _currentScreenIndex,
              children: [
                _buildMisActividades(context, provider),
                _buildResumenEquipo(context, provider),
                _buildSeguimientoActividades(context, provider),
                _buildSeguimientoPlanes(context, provider),
                _buildSupervisorIndicadores(context, provider),
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
        selectedFontSize: 11,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: provider.instances
                  .where((i) => i.userId == user?.id && i.day == provider.selectedDay && !i.done)
                  .isNotEmpty,
              label: Text(
                '${provider.instances.where((i) => i.userId == user?.id && i.day == provider.selectedDay && !i.done).length}',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
              child: const Icon(Icons.task_alt_rounded),
            ),
            label: 'Mis Actividades',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Mi Equipo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Seguimiento',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: provider.proPlans.where((p) => p.estado != 'Cumplido').isNotEmpty,
              label: Text(
                '${provider.proPlans.where((p) => p.estado != 'Cumplido').length}',
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

  Widget _buildMisActividades(BuildContext context, StandardWorkProvider provider) {
    final user = provider.currentUser;
    final myTasks = provider.instances
        .where((i) => i.userId == user?.id && i.day == provider.selectedDay)
        .toList();
    final doneCount = myTasks.where((t) => t.done).length;
    final pct = myTasks.isEmpty ? 0.0 : doneCount / myTasks.length;

    const days = [
      {'day': 1, 'name': 'Lunes'},
      {'day': 2, 'name': 'Martes'},
      {'day': 3, 'name': 'Miércoles'},
      {'day': 4, 'name': 'Jueves'},
      {'day': 5, 'name': 'Viernes'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Selector de día estilo Apple
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.map((d) {
              final isSel = provider.selectedDay == d['day'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    d['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? Colors.white : const Color(0xFF1D1D1F),
                    ),
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFF007AFF),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSel ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (_) => provider.setSelectedDay(d['day'] as int),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Tarjeta Apple de Progreso del Supervisor
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
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFF5F5F7),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 1.0 ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                      ),
                    ),
                    Text(
                      '${(pct * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D1D1F)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mis Actividades Asignadas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 4),
                    Text(
                      '$doneCount de ${myTasks.length} actividades cumplidas hoy',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF86868B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      myTasks.isEmpty
                          ? 'Sin actividades asignadas para este día.'
                          : (pct >= 1.0 ? '¡Excelente! Completaste tu jornada.' : 'Toca una tarjeta roja para ejecutar y completar.'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: pct >= 1.0 && myTasks.isNotEmpty ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (myTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: const Column(
              children: [
                Icon(Icons.task_alt_rounded, size: 42, color: Color(0xFF86868B)),
                SizedBox(height: 8),
                Text('No tienes actividades asignadas este día', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                SizedBox(height: 4),
                Text('Cuando el Admin de Planta te asigne actividades, aparecerán aquí.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF86868B))),
              ],
            ),
          )
        else
          ...myTasks.map((item) {
            final isDone = item.done;
            final borderColor = isDone ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
            final bgTint = isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    if (item.esRegistro) {
                      MeetingRecordDialog.show(context: context, instance: item);
                    } else {
                      ActivityExecutionModal.show(context: context, instance: item);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgTint.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor, width: 1.7),
                      boxShadow: [
                        BoxShadow(color: borderColor.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.nombre,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: borderColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isDone ? 'Cumplida' : 'Sin Completar',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: borderColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.timeStart} - ${item.timeEnd} · Área: ${item.area}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF86868B), fontWeight: FontWeight.w500),
                        ),
                        if (item.descripcion.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(item.descripcion, style: const TextStyle(fontSize: 12, color: Color(0xFF3A3A3C))),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (item.esRegistro) {
                                  MeetingRecordDialog.show(context: context, instance: item);
                                } else {
                                  ActivityExecutionModal.show(context: context, instance: item);
                                }
                              },
                              icon: Icon(isDone ? Icons.visibility_rounded : Icons.play_arrow_rounded, size: 16),
                              label: Text(isDone ? 'Ver Registro' : (item.esRegistro ? 'Diligenciar Reunión' : 'Ejecutar & Completar')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDone ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
          }),
      ],
    );
  }

  // ========================================================
  // PANTALLA 1: RESUMEN DE MI EQUIPO
  // ========================================================
  Widget _buildResumenEquipo(BuildContext context, StandardWorkProvider provider) {
    final operators = provider.usersForCurrentPlant.where((u) => u.isOperator).toList();
    final instances = provider.instances;

    final totalCount = instances.length;
    final completedCount = instances.where((i) => i.done).length;
    final pendingCount = instances.where((i) => !i.done).length;
    final overdueCount = instances.where((i) => !i.done && i.isReprogramada).length;
    final pendingPlans = provider.proPlans.where((p) => p.estado != 'Cumplido').length;
    final pendingReviews = _allExecutions.where((e) => !e.aprobada).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // GRÁFICA COMPACTA Y KPI HEADER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cumplimiento del Turno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${operators.length} Colaboradores', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: totalCount > 0 ? (completedCount / totalCount) : 0,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A3E0)),
                        ),
                        Text(
                          totalCount > 0 ? '${((completedCount / totalCount) * 100).toInt()}%' : '0%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002F6C)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$completedCount de $totalCount actividades realizadas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Planta ${provider.currentPlant?.nombre ?? "Operativa"} · Semana activa', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: totalCount > 0 ? (completedCount / totalCount) : 0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // TARJETAS KPI RESUMIDAS
        Row(
          children: [
            Expanded(child: _buildKpiCard('Pendientes', '$pendingCount', const Color(0xFF0284C7), Icons.schedule_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildKpiCard('Completadas', '$completedCount', const Color(0xFF16A34A), Icons.check_circle_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildKpiCard('Planes Activos', '$pendingPlans', const Color(0xFFF59E0B), Icons.flag_rounded)),
          ],
        ),
        const SizedBox(height: 16),

        // SECCIÓN DE ATENCIÓN INMEDIATA (ALERTAS OPERATIVAS)
        const Text(
          'Situaciones que Requieren Atención Inmediata',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 8),

        if (pendingReviews > 0)
          _buildAlertCard(
            title: '$pendingReviews Evidencias en piso pendientes de validación',
            subtitle: 'Revisa fotografías y mediciones de los operadores para aprobar cumplimiento.',
            color: const Color(0xFF0284C7),
            icon: Icons.rate_review_rounded,
            actionLabel: 'Revisar',
            onAction: () => setState(() {
              _currentScreenIndex = 2;
              _selectedActivityFilter = 'Reportadas';
            }),
          ),

        if (pendingPlans > 0)
          _buildAlertCard(
            title: '$pendingPlans Planes de acción en curso sin cerrar',
            subtitle: 'Compromisos operativos con fecha límite asignados a tu equipo.',
            color: const Color(0xFFF59E0B),
            icon: Icons.warning_amber_rounded,
            actionLabel: 'Ver Planes',
            onAction: () => setState(() {
              _currentScreenIndex = 3;
            }),
          ),

        if (overdueCount > 0)
          _buildAlertCard(
            title: '$overdueCount Actividades con reprogramación o desfase',
            subtitle: 'Identifica causas de no realización en la línea de producción.',
            color: const Color(0xFFDC2626),
            icon: Icons.alarm_off_rounded,
            actionLabel: 'Inspeccionar',
            onAction: () => setState(() {
              _currentScreenIndex = 2;
            }),
          ),

        if (pendingReviews == 0 && pendingPlans == 0 && overdueCount == 0)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A)),
                SizedBox(width: 10),
                Expanded(child: Text('¡Excelente! No hay alertas críticas ni evidencias pendientes en este momento.', style: TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.bold))),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // EQUIPO DE COLABORADORES
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Colaboradores de mi Equipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
            Text('${operators.length} asignados', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),

        ...operators.map((op) {
          final opInstances = instances.where((i) => i.userId == op.id).toList();
          final opCompleted = opInstances.where((i) => i.done).length;
          final opTotal = opInstances.length;
          final pct = opTotal > 0 ? (opCompleted / opTotal) : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF002F6C),
                child: Text(op.iniciales, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              title: Text(op.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${op.cargo} · ${op.area}', style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: pct, minHeight: 4, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(pct >= 1.0 ? const Color(0xFF16A34A) : const Color(0xFF0284C7))),
                  ),
                ],
              ),
              trailing: Text('$opCompleted/$opTotal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF002F6C))),
              onTap: () => CollaboratorProfileModal.show(context, op, opInstances, provider),
            ),
          );
        }),
      ],
    );
  }

  // Nota: Seguimiento y Planes de Acción ahora son pestañas independientes en el BottomNavigationBar.

  Widget _buildSeguimientoActividades(BuildContext context, StandardWorkProvider provider) {
    final instances = provider.instances;
    final operators = provider.usersForCurrentPlant.where((u) => u.isOperator).toList();

    final filtered = instances.where((i) {
      if (_selectedOperatorFilter != null && i.userId != _selectedOperatorFilter) return false;
      if (_selectedActivityFilter == 'Pendientes' && i.done) return false;
      if (_selectedActivityFilter == 'Reportadas' && (!i.done || i.state != 'Reportada')) return false;
      if (_selectedActivityFilter == 'Validadas' && i.state != 'Validada') return false;
      return true;
    }).toList();

    return Column(
      children: [
        // FILTROS HORIZONTALES
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActivityFilterChip('Todas'),
                const SizedBox(width: 6),
                _buildActivityFilterChip('Pendientes'),
                const SizedBox(width: 6),
                _buildActivityFilterChip('Reportadas'),
                const SizedBox(width: 6),
                _buildActivityFilterChip('Validadas'),
                const SizedBox(width: 12),
                // FILTRO DE OPERADOR
                DropdownButton<String?>(
                  value: _selectedOperatorFilter,
                  hint: const Text('Colaborador', style: TextStyle(fontSize: 11)),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos los Colaboradores', style: TextStyle(fontSize: 11))),
                    ...operators.map((op) => DropdownMenuItem(value: op.id, child: Text(op.nombre, style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) => setState(() => _selectedOperatorFilter = val),
                ),
              ],
            ),
          ),
        ),

        // LISTA DE TARJETAS
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('No hay actividades en esta vista', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    final op = operators.firstWhere((u) => u.id == item.userId, orElse: () => UserProfile(id: item.userId, cedula: '', nombre: item.userId, cargo: '', area: item.area, iniciales: 'OP', rol: 'operador', plantId: item.plantId));

                    final relatedExec = _allExecutions.where((e) => e.instanceId == item.id).toList();

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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                                      const SizedBox(height: 2),
                                      Text('${op.nombre} · ${item.area} · ${item.timeStart} - ${item.timeEnd}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                _buildStatusPill(item),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // BADGES DE MODALIDAD
                            Wrap(
                              spacing: 6,
                              children: [
                                if (item.esRegistro)
                                  _buildBadge('📝 Modalidad: Registro / Reunión', const Color(0xFFEFF6FF), const Color(0xFF0284C7)),
                                if (item.planAccionObligatorio)
                                  _buildBadge('⚠️ Plan de Acción Obligatorio', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                                if (item.fija)
                                  _buildBadge('🔒 Fija', const Color(0xFFF1F5F9), const Color(0xFF475569)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // PROGRESO DE SUBTAREAS
                            if (item.subtasksTotal > 0) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Avance Operador: ${item.subtasksReported}/${item.subtasksTotal}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text('Validadas por Supervisor: ${item.subtasksApproved}/${item.subtasksTotal}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: item.executionProgress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(item.subtasksApproved == item.subtasksTotal ? const Color(0xFF16A34A) : const Color(0xFF0284C7)),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // ACCIONES RÁPIDAS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (item.esRegistro)
                                  TextButton.icon(
                                    onPressed: () => MeetingRecordDialog.show(context: context, instance: item, isReadOnly: true),
                                    icon: const Icon(Icons.description_rounded, size: 16),
                                    label: const Text('Consultar Registro', style: TextStyle(fontSize: 12)),
                                  ),
                                if (relatedExec.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _inspectEvidenceModal(context, relatedExec.first),
                                    icon: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
                                    label: const Text('Inspeccionar Evidencias', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSeguimientoPlanes(BuildContext context, StandardWorkProvider provider) {
    final plans = provider.proPlans;
    final operators = provider.usersForCurrentPlant.where((u) => u.isOperator).toList();

    final filtered = plans.where((p) {
      if (_selectedPlanFilter == 'Pendientes' && p.estado != 'Pendiente') return false;
      if (_selectedPlanFilter == 'En Proceso' && p.estado != 'En Proceso') return false;
      if (_selectedPlanFilter == 'Cumplidos' && p.estado != 'Cumplido') return false;
      if (_selectedPlanFilter == 'Vencidos' && !p.isVencido) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // FILTROS
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPlanFilterChip('Todos'),
                const SizedBox(width: 6),
                _buildPlanFilterChip('Pendientes'),
                const SizedBox(width: 6),
                _buildPlanFilterChip('En Proceso'),
                const SizedBox(width: 6),
                _buildPlanFilterChip('Cumplidos'),
                const SizedBox(width: 6),
                _buildPlanFilterChip('Vencidos'),
              ],
            ),
          ),
        ),

        // LISTA DE PLANES DE ACCIÓN
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('No hay planes de acción en esta categoría', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final plan = filtered[i];
                    final isDone = plan.estado == 'Cumplido';
                    final isOverdue = plan.isVencido;

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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(plan.plan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                                      const SizedBox(height: 2),
                                      Text('Responsable: ${plan.responsable} · Área: ${plan.area}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDone ? const Color(0xFFDCFCE7) : (isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isDone ? 'Cumplido' : (isOverdue ? 'Vencido' : plan.estado),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDone ? const Color(0xFF15803D) : (isOverdue ? const Color(0xFFB91C1C) : const Color(0xFFB45309)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (plan.activityNombre != null) ...[
                              const SizedBox(height: 6),
                              Text('Actividad Vinculada: ${plan.activityNombre}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                            ],
                            const SizedBox(height: 8),
                            if (plan.descripcionSituacion != null && plan.descripcionSituacion!.isNotEmpty) ...[
                              Text('Situación / Falla:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                              Text(plan.descripcionSituacion!, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 6),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Fecha Compromiso: ${plan.fechaCompromiso}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                Text('Avance: ${(plan.porcentajeAvance * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: plan.porcentajeAvance,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(isDone ? const Color(0xFF16A34A) : const Color(0xFFF59E0B)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => ActionPlanDialog.show(context: context, existingPlan: plan),
                                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                                  label: const Text('Observación / Avance', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 8),
                                if (!isDone)
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await provider.updateProPlanStatus(planId: plan.id!, nuevoEstado: 'Cumplido', porcentajeAvance: 1.0);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('¡Plan de acción aprobado y cerrado!')));
                                    },
                                    icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                                    label: const Text('Aprobar Plan', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFilterChip(String label) {
    final selected = _selectedActivityFilter == label;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.white : const Color(0xFF334155))),
      selected: selected,
      selectedColor: const Color(0xFF002F6C),
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) => setState(() => _selectedActivityFilter = label),
    );
  }

  Widget _buildPlanFilterChip(String label) {
    final selected = _selectedPlanFilter == label;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.white : const Color(0xFF334155))),
      selected: selected,
      selectedColor: const Color(0xFF002F6C),
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) => setState(() => _selectedPlanFilter = label),
    );
  }

  Widget _buildStatusPill(ActivityInstance item) {
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

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.bold)),
    );
  }

  // ========================================================
  // PANTALLA 5: INDICADORES EJECUTIVOS DEL SUPERVISOR Y EQUIPO
  // ========================================================
  Widget _buildSupervisorIndicadores(BuildContext context, StandardWorkProvider provider) {
    final user = provider.currentUser;
    final myAll = provider.instances.where((i) => i.userId == user?.id).toList();
    final myDone = myAll.where((i) => i.done).length;
    final myPending = myAll.length - myDone;
    final myPct = myAll.isEmpty ? 0 : ((myDone / myAll.length) * 100).round();

    final plantOps = provider.usersForCurrentPlant.where((u) => u.isOperator).toList();
    final plantOpIds = plantOps.map((u) => u.id).toSet();
    final teamAll = provider.instances.where((i) => plantOpIds.contains(i.userId)).toList();
    final teamDone = teamAll.where((i) => i.done).length;
    final teamPending = teamAll.length - teamDone;
    final teamPct = teamAll.isEmpty ? 0 : ((teamDone / teamAll.length) * 100).round();

    final plansAll = provider.proPlans;
    final plansClosed = plansAll.where((p) => p.estado == 'Cumplido').length;
    final plansOpen = plansAll.length - plansClosed;
    final pendingRev = _allExecutions.where((e) => !e.aprobada).length;

    final heroColor = teamPct >= 80
        ? const Color(0xFF34C759)
        : (teamPct >= 50 ? const Color(0xFF007AFF) : const Color(0xFFFF3B30));

    return Container(
      color: const Color(0xFFF2F2F7),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              // HERO RING: CUMPLIMIENTO GLOBAL EQUIPO + PERSONAL
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF002F6C), Color(0xFF005BB5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: const Color(0xFF002F6C).withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, resp) {
                                  if (!event.isInterestedForInteractions || resp == null || resp.touchedSection == null) {
                                    if (_touchedSupPieIndex != -1) setState(() => _touchedSupPieIndex = -1);
                                    return;
                                  }
                                  final idx = resp.touchedSection!.touchedSectionIndex;
                                  if (_touchedSupPieIndex != idx) setState(() => _touchedSupPieIndex = idx);
                                },
                              ),
                              startDegreeOffset: -90,
                              sectionsSpace: 3,
                              centerSpaceRadius: 36,
                              sections: [
                                PieChartSectionData(
                                  value: teamDone == 0 && teamPending == 0 ? 1 : teamDone.toDouble(),
                                  color: const Color(0xFF34C759),
                                  radius: _touchedSupPieIndex == 0 ? 18 : 14,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: teamPending.toDouble(),
                                  color: Colors.white.withValues(alpha: 0.22),
                                  radius: _touchedSupPieIndex == 1 ? 16 : 12,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _touchedSupPieIndex == 0
                                    ? '$teamDone'
                                    : (_touchedSupPieIndex == 1 ? '$teamPending' : '$teamPct%'),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                              Text(
                                _touchedSupPieIndex == 0
                                    ? 'Hechas'
                                    : (_touchedSupPieIndex == 1 ? 'Pend.' : 'Equipo'),
                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: heroColor.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              teamPct >= 80 ? 'Desempeño Óptimo' : (teamPct >= 50 ? 'En Progreso' : 'Requiere Seguimiento'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Indicadores de Supervisión',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Equipo: $teamDone/${teamAll.length} · Tus tareas: $myDone/${myAll.length} ($myPct%)',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4 TARJETAS KPI
              Row(
                children: [
                  Expanded(
                    child: _buildSupervisorMetricCard(
                      title: 'Mis Actividades',
                      value: '$myPct%',
                      subtitle: '$myDone hechas · $myPending pend.',
                      progress: myAll.isEmpty ? 0 : myDone / myAll.length,
                      color: myPct >= 80 ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                      icon: Icons.verified_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSupervisorMetricCard(
                      title: 'Equipo de Piso',
                      value: '$teamPct%',
                      subtitle: '$teamDone hechas · $teamPending pend.',
                      progress: teamAll.isEmpty ? 0 : teamDone / teamAll.length,
                      color: const Color(0xFF007AFF),
                      icon: Icons.groups_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSupervisorMetricCard(
                      title: 'Planes Cerrados',
                      value: '$plansClosed/${plansAll.length}',
                      subtitle: '$plansOpen en curso',
                      progress: plansAll.isEmpty ? 0 : plansClosed / plansAll.length,
                      color: const Color(0xFFAF52DE),
                      icon: Icons.fact_check_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSupervisorMetricCard(
                      title: 'Por Auditar',
                      value: '$pendingRev',
                      subtitle: '${_allExecutions.where((e) => e.aprobada).length} aprobadas',
                      progress: _allExecutions.isEmpty
                          ? 0
                          : _allExecutions.where((e) => e.aprobada).length / _allExecutions.length,
                      color: const Color(0xFFFF9500),
                      icon: Icons.photo_camera_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // GRÁFICA DE BARRAS SEMANAL (L - V)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cumplimiento Diario del Equipo (Lun–Vie)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 4),
                    Text(
                      _selectedSupChartDay == null
                          ? 'Toca cualquier barra para inspeccionar ese día'
                          : () {
                              const dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
                              final dList = teamAll.where((t) => t.day == _selectedSupChartDay!).toList();
                              final dDone = dList.where((t) => t.done).length;
                              return '${dayNames[_selectedSupChartDay! - 1]}: $dDone de ${dList.length} completadas';
                            }(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _selectedSupChartDay == null ? FontWeight.normal : FontWeight.w700,
                        color: _selectedSupChartDay == null ? const Color(0xFF86868B) : const Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 170,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (event, resp) {
                              if (event is FlTapUpEvent && resp?.spot != null) {
                                final d = resp!.spot!.touchedBarGroupIndex + 1;
                                setState(() => _selectedSupChartDay = _selectedSupChartDay == d ? null : d);
                              }
                            },
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF1D1D1F),
                              tooltipBorderRadius: BorderRadius.circular(10),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
                                final dList = teamAll.where((t) => t.day == group.x + 1).toList();
                                final dDone = dList.where((t) => t.done).length;
                                return BarTooltipItem(
                                  '${days[group.x]}\n${rod.toY.toStringAsFixed(0)}% ($dDone/${dList.length})',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                                );
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF2F2F7), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 25,
                                getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  const labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(labels[idx], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(5, (idx) {
                            final dayNum = idx + 1;
                            final dList = teamAll.where((t) => t.day == dayNum).toList();
                            final pct = dList.isEmpty ? 0.0 : (dList.where((t) => t.done).length / dList.length) * 100.0;
                            final barColor = pct >= 80
                                ? const Color(0xFF34C759)
                                : (pct >= 50 ? const Color(0xFF007AFF) : const Color(0xFFFF3B30));
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: pct,
                                  width: 24,
                                  color: barColor,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF2F2F7)),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // RANKING POR COLABORADOR DE PLANTA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Desempeño por Colaborador', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 12),
                    if (plantOps.isEmpty)
                      const Text('No hay operadores asignados en esta planta.', style: TextStyle(fontSize: 12, color: Colors.grey))
                    else
                      ...plantOps.map((op) {
                        final opTasks = teamAll.where((t) => t.userId == op.id).toList();
                        final opDone = opTasks.where((t) => t.done).length;
                        final opPct = opTasks.isEmpty ? 0.0 : opDone / opTasks.length;
                        final opPctInt = (opPct * 100).round();
                        final c = opPctInt >= 80
                            ? const Color(0xFF34C759)
                            : (opPctInt >= 50 ? const Color(0xFF007AFF) : const Color(0xFFFF3B30));
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(op.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                                  ),
                                  Text('$opDone/${opTasks.length} ($opPctInt%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(value: opPct, minHeight: 7, backgroundColor: const Color(0xFFF2F2F7), color: c),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupervisorMetricCard({
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
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.6)),
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
