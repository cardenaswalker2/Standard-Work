import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../data/models/app_models.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/ultra_report_service.dart';
import '../login/login_screen.dart';
import '../operator/operator_dashboard_screen.dart';
import '../plant_admin/plant_admin_shell_screen.dart';
import '../superadmin/superadmin_shell_screen.dart';
import '../supervisor/supervisor_shell_screen.dart';

/// Consola privada de arquitectura, salud y control total para el Ultra Admin (PIN 147728).
/// Diseño inspirado en Apple Human Interface Guidelines (macOS / iOS) y 100% responsivo.
class UltraAdminShellScreen extends StatefulWidget {
  const UltraAdminShellScreen({super.key});

  @override
  State<UltraAdminShellScreen> createState() => _UltraAdminShellScreenState();
}

class _UltraAdminShellScreenState extends State<UltraAdminShellScreen> {
  // Paleta Apple HIG
  static const Color _bg = Color(0xFFF5F5F7);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFE5E5EA);
  static const Color _ink = Color(0xFF1D1D1F);
  static const Color _muted = Color(0xFF86868B);
  static const Color _blue = Color(0xFF007AFF);
  static const Color _green = Color(0xFF34C759);
  static const Color _orange = Color(0xFFFF9500);
  static const Color _red = Color(0xFFFF3B30);
  static const Color _purple = Color(0xFFAF52DE);

  int _segmentIndex = 0; // 0: Sistema, 1: Sesiones & Usuarios, 2: Galería 5S, 3: Reportes & Op, 4: Auditoría
  bool _isLive = true;
  bool _maintenanceMode = false;
  bool _checkingHealth = false;
  bool _generatingPdf = false;
  bool _backendHealthy = true;
  int _latencyMs = 0;
  DateTime _lastCheck = DateTime.now();
  Timer? _liveTimer;

  final List<double> _latencyHistory = [];
  final List<String> _sessionEvents = [];

  String _searchQuery = '';
  String _roleFilter = 'TODOS';
  String _plantFilter = 'TODAS';
  String _evidenceStateFilter = 'TODOS';
  String _activityStatusFilter = 'TODOS';

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
    _startLiveTimer();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    if (!_isLive) return;
    _liveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) _checkBackendHealth();
    });
  }

  Future<void> _checkBackendHealth() async {
    if (_checkingHealth) return;
    setState(() => _checkingHealth = true);
    final sw = Stopwatch()..start();
    try {
      final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final resp = await http
          .get(Uri.parse('$base/actuator/health'))
          .timeout(const Duration(seconds: 8));
      sw.stop();
      if (!mounted) return;
      setState(() {
        _backendHealthy = resp.statusCode == 200;
        _latencyMs = sw.elapsedMilliseconds;
        _latencyHistory.add(_latencyMs.toDouble());
        if (_latencyHistory.length > 20) _latencyHistory.removeAt(0);
        _lastCheck = DateTime.now();
        _checkingHealth = false;
      });
    } catch (e) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        _backendHealthy = false;
        _latencyMs = sw.elapsedMilliseconds;
        _latencyHistory.add(_latencyMs.toDouble());
        if (_latencyHistory.length > 20) _latencyHistory.removeAt(0);
        _lastCheck = DateTime.now();
        _checkingHealth = false;
        _sessionEvents.insert(
          0,
          'Fallo salud backend (${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}): $e',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppleHeader(context, provider, user),
            _buildSegmentedBar(),
            if (_maintenanceMode) _buildMaintenanceBanner(),
            Expanded(
              child: RefreshIndicator(
                color: _blue,
                onRefresh: _checkBackendHealth,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: IndexedStack(
                      index: _segmentIndex,
                      children: [
                        _buildSystemHealthTab(provider),
                        _buildUsersAndSessionsTab(provider),
                        _buildEvidenceGalleryTab(provider),
                        _buildOperationsAndReportsTab(provider),
                        _buildAuditAndToolsTab(provider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleHeader(BuildContext context, StandardWorkProvider provider, UserProfile? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(bottom: BorderSide(color: _border, width: 0.8)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;
          final titleBlock = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D1D1F), Color(0xFF3A3A3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRACK60 · Ultra Admin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _ink, letterSpacing: -0.4),
                  ),
                  Text(
                    'Consola Maestra · ${user?.nombre ?? 'Owner'}',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ],
          );

          final statusControls = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isLive = !_isLive);
                  _startLiveTimer();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_isLive ? _green : _muted).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: (_isLive ? _green : _muted).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: _isLive ? _green : _muted, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isLive ? 'En Vivo · ${_latencyMs}ms' : 'Pausado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isLive ? const Color(0xFF1B7F37) : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Probar servidor ahora',
                onPressed: _checkBackendHealth,
                icon: _checkingHealth
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _blue))
                    : const Icon(Icons.refresh_rounded, color: _blue),
              ),
              TextButton.icon(
                onPressed: () {
                  provider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 17, color: _red),
                label: const Text('Salir', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const SizedBox(height: 10), statusControls],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [titleBlock, statusControls],
          );
        },
      ),
    );
  }

  Widget _buildSegmentedBar() {
    const labels = [
      'Sistema & Salud',
      'Sesiones & Usuarios',
      'Galería Evidencias',
      'Reportes & Op.',
      'Auditoría & Roles',
    ];
    const icons = [
      Icons.monitor_heart_outlined,
      Icons.devices_other_rounded,
      Icons.photo_library_outlined,
      Icons.picture_as_pdf_outlined,
      Icons.admin_panel_settings_outlined,
    ];

    return Container(
      width: double.infinity,
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E9EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(labels.length, (i) {
                final selected = _segmentIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _segmentIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _card : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: selected
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(icons[i], size: 16, color: selected ? _ink : _muted),
                        const SizedBox(width: 6),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected ? _ink : _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceBanner() {
    return Container(
      width: double.infinity,
      color: _orange.withValues(alpha: 0.14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.engineering_rounded, size: 16, color: _orange),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Modo Mantenimiento Preventivo ACTIVADO (solo vista administrativa)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9A5700)),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: SISTEMA, SALUD & GRÁFICA LATENCIA ====================
  Widget _buildSystemHealthTab(StandardWorkProvider provider) {
    final totalUsers = provider.allUsers.length;
    final activeUsers = provider.allUsers.where((u) => u.activo).length;
    final totalPlants = provider.allPlants.length;
    final totalActivities = provider.activities.length;
    final instances = provider.instances;
    final completed = instances.where((i) => i.done).length;
    final pending = instances.length - completed;
    final critCount = provider.activities.where((a) => a.prioridad.toUpperCase() == 'ALTA').length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Estado de Infraestructura & Latencia en Vivo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink),
                    ),
                  ),
                  _statusPill(
                    _backendHealthy ? 'Operativo · 200 OK' : 'Sin respuesta',
                    _backendHealthy ? _green : _red,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (ctx, c) {
                  final tileWidth = c.maxWidth > 760 ? (c.maxWidth - 36) / 4 : (c.maxWidth > 440 ? (c.maxWidth - 12) / 2 : c.maxWidth);
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _infraTile('Backend API (Render)', ApiConfig.baseUrl, _backendHealthy ? _green : _red, Icons.cloud_done_outlined, width: tileWidth),
                      _infraTile('Base de Datos', 'MongoDB Atlas · track60', _backendHealthy ? _blue : _orange, Icons.storage_rounded, width: tileWidth),
                      _infraTile('Latencia Actual', '$_latencyMs ms', _latencyMs < 900 ? _green : _orange, Icons.speed_rounded, width: tileWidth),
                      _infraTile(
                        'Último Chequeo',
                        '${_lastCheck.hour}:${_lastCheck.minute.toString().padLeft(2, '0')}:${_lastCheck.second.toString().padLeft(2, '0')}',
                        _purple,
                        Icons.schedule_rounded,
                        width: tileWidth,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text('Historial de Latencia (ms)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: _latencyHistory.isEmpty
                    ? const Center(child: Text('Midiendo latencia...', style: TextStyle(color: _muted, fontSize: 12)))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: _border, strokeWidth: 0.7)),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: _blue,
                              barWidth: 2.8,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: true, color: _blue.withValues(alpha: 0.12)),
                              spots: List.generate(
                                _latencyHistory.length,
                                (i) => FlSpot(i.toDouble(), _latencyHistory[i]),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 780 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth > 780 ? 1.7 : 1.45,
              children: [
                _metricCard('Plantas Activas', '$totalPlants', 'Operación multiplanta', _blue, Icons.factory_outlined),
                _metricCard('Sesiones / Cuentas', '$activeUsers / $totalUsers', 'Habilitadas en nube', _green, Icons.people_outline_rounded),
                _metricCard('Actividades Base', '$totalActivities', '$critCount críticas', _orange, Icons.checklist_rounded),
                _metricCard('Ejecución Hoy', '$completed / ${instances.length}', '$pending pendientes', _purple, Icons.verified_outlined),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Controles Rápidos & Alertas por Planta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Modo Mantenimiento Preventivo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Muestra aviso preventivo mientras realizas despliegues', style: TextStyle(fontSize: 12, color: _muted)),
                value: _maintenanceMode,
                activeTrackColor: _orange,
                onChanged: (v) => setState(() => _maintenanceMode = v),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFE5F1FF), child: Icon(Icons.campaign_outlined, color: _blue)),
                title: const Text('Enviar Comunicado Global', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Aviso urgente para todas las plantas y roles', style: TextStyle(fontSize: 12, color: _muted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
                onTap: () => _showGlobalBroadcastDialog(context, provider),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFE5E5), child: Icon(Icons.warning_amber_rounded, color: _red)),
                title: const Text('Disparar Alerta Roja por Planta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Notifica falla grave de seguridad o paro preventivo en una planta', style: TextStyle(fontSize: 12, color: _muted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
                onTap: () => _showPlantRedAlertDialog(context, provider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TAB 2: CONTROL DE SESIONES & USUARIOS ====================
  Widget _buildUsersAndSessionsTab(StandardWorkProvider provider) {
    final activeCount = provider.allUsers.where((u) => u.activo).length;
    final blockedCount = provider.allUsers.length - activeCount;

    final users = provider.allUsers.where((u) {
      if (_roleFilter != 'TODOS' && u.rol != _roleFilter) return false;
      if (_plantFilter != 'TODAS' && u.plantId != _plantFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!u.nombre.toLowerCase().contains(q) &&
            !u.cedula.toLowerCase().contains(q) &&
            !u.rol.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Control de Sesiones y Accesos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
                  Wrap(
                    spacing: 8,
                    children: [
                      _statusPill('$activeCount Habilitadas', _green),
                      if (blockedCount > 0) _statusPill('$blockedCount Bloqueadas', _red),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, cédula o rol...',
                  prefixIcon: const Icon(Icons.search_rounded, color: _muted),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final role in ['TODOS', 'ultra_admin', 'superadmin', 'admin_planta', 'supervisor', 'operador'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(role == 'TODOS' ? 'Todos' : role),
                          selected: _roleFilter == role,
                          selectedColor: _blue.withValues(alpha: 0.15),
                          onSelected: (_) => setState(() => _roleFilter = role),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...users.map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _appleCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: u.activo ? _blue.withValues(alpha: 0.12) : _red.withValues(alpha: 0.12),
                          child: Text(
                            u.iniciales,
                            style: TextStyle(fontWeight: FontWeight.w700, color: u.activo ? _blue : _red),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _ink)),
                              Text(
                                'Cédula: ${u.cedula} · Rol: ${u.rol} · Planta: ${u.plantId}',
                                style: const TextStyle(fontSize: 12, color: _muted),
                              ),
                            ],
                          ),
                        ),
                        _statusPill(u.activo ? 'Sesión Permitida' : 'Acceso Revocado', u.activo ? _green : _red),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showResetPinDialog(context, provider, u),
                          icon: const Icon(Icons.key_rounded, size: 15),
                          label: const Text('Asignar Nuevo PIN', style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showRolePlantDialog(context, provider, u),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                          label: const Text('Cambiar Rol / Planta', style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await provider.toggleUserActive(u.id, !u.activo);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${u.nombre}: ${!u.activo ? 'Acceso reactivado' : 'Sesión revocada'}')),
                              );
                            }
                          },
                          icon: Icon(u.activo ? Icons.block_rounded : Icons.check_circle_outline, size: 15, color: u.activo ? _red : _green),
                          label: Text(
                            u.activo ? 'Revocar Acceso' : 'Reactivar',
                            style: TextStyle(fontSize: 12, color: u.activo ? _red : _green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ==================== TAB 3: GALERÍA CENTRAL DE EVIDENCIAS & 5S ====================
  Widget _buildEvidenceGalleryTab(StandardWorkProvider provider) {
    final plants = provider.allPlants;
    final standards = provider.photoStandards;
    final items = provider.instances.where((i) {
      if (_plantFilter != 'TODAS' && i.plantId != _plantFilter) return false;
      if (_evidenceStateFilter != 'TODOS' && i.state != _evidenceStateFilter) return false;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Galería Central de Evidencias & Estándares 5S', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 4),
              const Text('Toca cualquier actividad para comparar la ejecución contra el estándar 5S de la planta.', style: TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final st in ['TODOS', 'Aprobada', 'Reportada', 'Pendiente', 'RequiereCorreccion'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(st == 'TODOS' ? 'Todos' : st),
                          selected: _evidenceStateFilter == st,
                          onSelected: (_) => setState(() => _evidenceStateFilter = st),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Todas las plantas'),
                      selected: _plantFilter == 'TODAS',
                      onSelected: (_) => setState(() => _plantFilter = 'TODAS'),
                    ),
                    const SizedBox(width: 8),
                    ...plants.map((p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p.nombre),
                            selected: _plantFilter == p.id,
                            onSelected: (_) => setState(() => _plantFilter = p.id),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (items.isEmpty)
          _appleCard(
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: Text('No hay evidencias o actividades en este filtro.', style: TextStyle(color: _muted))),
            ),
          )
        else
          LayoutBuilder(
            builder: (ctx, c) {
              final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cols == 1 ? 2.1 : 1.55,
                ),
                itemCount: items.take(30).length,
                itemBuilder: (_, idx) {
                  final inst = items[idx];
                  final isApproved = inst.state == 'Aprobada' || inst.done;
                  final isWarn = inst.state == 'RequiereCorreccion';
                  final color = isApproved ? _green : (isWarn ? _red : _blue);
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showCompare5SDialog(context, inst, standards),
                    child: _appleCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statusPill(inst.state, color),
                              Icon(inst.reqFoto ? Icons.camera_alt_rounded : Icons.fact_check_outlined, size: 17, color: _muted),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inst.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _ink)),
                              const SizedBox(height: 4),
                              Text('${inst.plantId} · ${inst.area}', style: const TextStyle(fontSize: 11, color: _muted)),
                            ],
                          ),
                          const Row(
                            children: [
                              Icon(Icons.compare_rounded, size: 14, color: _blue),
                              SizedBox(width: 4),
                              Text('Ver comparativo 5S', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _blue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // ==================== TAB 4: OPERACIÓN & REPORTES PDF / JSON ====================
  Widget _buildOperationsAndReportsTab(StandardWorkProvider provider) {
    final acts = provider.activities.where((a) {
      if (_plantFilter != 'TODAS' && a.plantId != _plantFilter) return false;
      if (_activityStatusFilter == 'ALTA' && a.prioridad.toUpperCase() != 'ALTA') return false;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Centro de Reportes Ejecutivos y Respaldo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 4),
              const Text('Genera reportes PDF firmados digitalmente o respaldos completos de la base operativa.', style: TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onPressed: _generatingPdf
                        ? null
                        : () async {
                            setState(() => _generatingPdf = true);
                            try {
                              final code = await UltraReportService.instance.generateAndShareExecutivePdf(provider);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('PDF Ejecutivo generado · Sello $code')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _generatingPdf = false);
                            }
                          },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(_generatingPdf ? 'Generando PDF...' : 'Generar Reporte PDF (1 Clic)'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onPressed: () async {
                      await UltraReportService.instance.exportFullJsonBackup(provider);
                    },
                    icon: const Icon(Icons.data_object_rounded, size: 18),
                    label: const Text('Backup Total JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ExcelService.instance.exportAndShare();
                    },
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: const Text('Exportar Excel / CSV'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Actividades Globales (${acts.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
                  ChoiceChip(
                    label: const Text('Solo Críticas'),
                    selected: _activityStatusFilter == 'ALTA',
                    onSelected: (v) => setState(() => _activityStatusFilter = v ? 'ALTA' : 'TODOS'),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (acts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Sin actividades en este filtro', style: TextStyle(color: _muted))),
                )
              else
                ...acts.take(40).map((a) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.circle, size: 10, color: a.prioridad.toUpperCase() == 'ALTA' ? _red : _blue),
                      title: Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text('${a.plantId} · Área: ${a.area} · Prioridad: ${a.prioridad}', style: const TextStyle(fontSize: 11, color: _muted)),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TAB 5: AUDITORÍA & ROLES ====================
  Widget _buildAuditAndToolsTab(StandardWorkProvider provider) {
    final logs = provider.auditLogs;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inspección Rápida por Rol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showRolePreviewSheet(context),
                icon: const Icon(Icons.visibility_outlined, size: 17),
                label: const Text('Abrir Vista Previa de Cualquier Rol'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_sessionEvents.isNotEmpty) ...[
          _appleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Eventos y Errores Recientes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _red)),
                const SizedBox(height: 8),
                ..._sessionEvents.take(10).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $e', style: const TextStyle(fontSize: 12, color: _ink)),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        _appleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bitácora de Auditoría (${logs.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const Divider(height: 20),
              if (logs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No hay eventos de auditoría registrados aún.', style: TextStyle(color: _muted))),
                )
              else
                ...logs.take(30).map((log) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history_rounded, size: 18, color: _blue),
                      title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text('${log.details}\n${log.timestamp}', style: const TextStyle(fontSize: 11, color: _muted)),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MODALES Y DIALOGOS ====================
  void _showCompare5SDialog(BuildContext context, ActivityInstance inst, List<PlantPhotoStandardModel> standards) {
    final matchingStd = standards.where((s) => s.plantId == inst.plantId).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Comparativo 5S · ${inst.nombre}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EJECUCIÓN EN PISO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _blue)),
                          const SizedBox(height: 6),
                          Text('Estado: ${inst.state}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('Planta: ${inst.plantId} · ${inst.area}', style: const TextStyle(fontSize: 11, color: _muted)),
                          const SizedBox(height: 6),
                          Text(inst.observaciones ?? 'Sin observaciones registradas.', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFEAFBF0), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ESTÁNDAR MODELO 5S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green)),
                          const SizedBox(height: 6),
                          Text(
                            matchingStd.isNotEmpty ? matchingStd.first.titulo : 'Criterio de Cumplimiento',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            matchingStd.isNotEmpty
                                ? matchingStd.first.descripcion
                                : (inst.criteriosCumplimiento.isNotEmpty ? inst.criteriosCumplimiento : 'Cumplir estándar visual de área.'),
                            style: const TextStyle(fontSize: 11, color: _ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showPlantRedAlertDialog(BuildContext context, StandardWorkProvider provider) {
    final plants = provider.allPlants;
    String selectedPlant = plants.isNotEmpty ? plants.first.nombre : 'Todas';
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Alerta Roja / Pausa Preventiva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (plants.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedPlant,
                  decoration: const InputDecoration(labelText: 'Planta afectada', border: OutlineInputBorder()),
                  items: plants.map((p) => DropdownMenuItem(value: p.nombre, child: Text(p.nombre))).toList(),
                  onChanged: (v) => setDlg(() => selectedPlant = v ?? selectedPlant),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Motivo de alerta crítica o pausa preventiva...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
              onPressed: () {
                final text = msgCtrl.text.trim();
                if (text.isEmpty) return;
                provider.postAnnouncement(
                  title: 'ALERTA ROJA · $selectedPlant',
                  body: text,
                  author: provider.currentUser?.nombre ?? 'Ultra Admin',
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alerta Roja enviada a $selectedPlant')),
                  );
                }
              },
              child: const Text('Disparar Alerta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPinDialog(BuildContext context, StandardWorkProvider provider, UserProfile u) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Nuevo PIN para ${u.nombre}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 8,
          decoration: const InputDecoration(labelText: 'Nuevo PIN (mín. 4 dígitos)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
            onPressed: () async {
              final pin = ctrl.text.trim();
              if (pin.length < 4) return;
              await provider.resetUserPin(u.id, pin);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PIN actualizado en la nube para ${u.nombre}')),
                );
              }
            },
            child: const Text('Guardar PIN'),
          ),
        ],
      ),
    );
  }

  void _showRolePlantDialog(BuildContext context, StandardWorkProvider provider, UserProfile u) {
    String selectedRole = u.rol;
    String selectedPlant = u.plantId;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Rol y Planta · ${u.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: ['ultra_admin', 'superadmin', 'admin_planta', 'supervisor', 'operador'].contains(selectedRole) ? selectedRole : 'operador',
                decoration: const InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'ultra_admin', child: Text('Ultra Admin')),
                  DropdownMenuItem(value: 'superadmin', child: Text('Super Admin')),
                  DropdownMenuItem(value: 'admin_planta', child: Text('Admin de Planta')),
                  DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                  DropdownMenuItem(value: 'operador', child: Text('Operador')),
                ],
                onChanged: (v) => setDlg(() => selectedRole = v ?? selectedRole),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: selectedPlant,
                decoration: const InputDecoration(labelText: 'Planta (ej. ALL o PL-EXTRUSA)', border: OutlineInputBorder()),
                onChanged: (v) => selectedPlant = v.trim(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
              onPressed: () async {
                await provider.updateUserRoleAndPlant(u.id, selectedRole, selectedPlant);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGlobalBroadcastDialog(BuildContext context, StandardWorkProvider provider) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Comunicado Global'),
        content: TextField(
          controller: msgCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe el aviso urgente para todas las plantas...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
            onPressed: () {
              final text = msgCtrl.text.trim();
              if (text.isEmpty) return;
              provider.postAnnouncement(
                title: 'Aviso Ultra Admin',
                body: text,
                author: provider.currentUser?.nombre ?? 'Ultra Admin',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comunicado global enviado')));
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showRolePreviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inspeccionar Vista por Rol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: _blue),
              title: const Text('Super Admin'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperAdminShellScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.factory_rounded, color: _green),
              title: const Text('Admin de Planta'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PlantAdminShellScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_rounded, color: _orange),
              title: const Text('Supervisor'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SupervisorShellScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: _purple),
              title: const Text('Operador / Colaborador'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OperatorDashboardScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ESTILO APPLE ====================
  Widget _appleCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(18)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 0.9),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _infraTile(String title, String value, Color color, IconData icon, {double width = 210}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _ink, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return _appleCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w600))),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _ink, letterSpacing: -0.5)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: _muted)),
        ],
      ),
    );
  }
}
