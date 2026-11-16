import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Consola ejecutiva privada para el Ultra Admin (PIN 147728).
/// Diseño Apple HIG (macOS Bento Command Center / iOS) 100% responsivo.
class UltraAdminShellScreen extends StatefulWidget {
  const UltraAdminShellScreen({super.key});

  @override
  State<UltraAdminShellScreen> createState() => _UltraAdminShellScreenState();
}

class _UltraAdminShellScreenState extends State<UltraAdminShellScreen> {
  // Paleta Apple HIG
  static const Color _bg = Color(0xFFF5F5F7);
  static const Color _sidebarBg = Color(0xFFECECEE);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFE5E5EA);
  static const Color _ink = Color(0xFF1D1D1F);
  static const Color _muted = Color(0xFF86868B);
  static const Color _blue = Color(0xFF007AFF);
  static const Color _green = Color(0xFF34C759);
  static const Color _orange = Color(0xFFFF9500);
  static const Color _red = Color(0xFFFF3B30);
  static const Color _purple = Color(0xFFAF52DE);
  static const Color _teal = Color(0xFF30B0C7);

  int _sectionIndex = 0; // 0: Centro de Mando, 1: Usuarios, 2: Accesos & IP, 3: Galería 5S, 4: Reportes, 5: Auditoría
  bool _isLive = true;
  bool _maintenanceMode = false;
  bool _checkingHealth = false;
  bool _generatingPdf = false;
  bool _backendHealthy = true;
  int _latencyMs = 0;
  DateTime _lastCheck = DateTime.now();
  Timer? _liveTimer;

  // Historial de latencia para gráfica en vivo (últimos 14 puntos)
  final List<double> _latencyHistory = [120, 135, 118, 142, 128, 115, 130];

  // Registro de accesos (IP, ubicación aproximada, dispositivo)
  List<AccessLogEntry> _accessLogs = [];
  bool _loadingAccessLogs = false;
  String? _accessLogsError;
  String _accessFilter = 'ALL'; // ALL | SUCCESS | FAILED

  // Filtros de búsqueda
  String _userSearch = '';
  String _userRoleFilter = 'ALL';
  String _userPlantFilter = 'ALL';
  String _evidencePlantFilter = 'ALL';
  String _evidenceStateFilter = 'ALL';
  String _reportPlantFilter = 'ALL';
  String _accessSearch = '';

  final List<String> _recentErrors = [];

  static const _navItems = [
    _NavItem('Centro de Mando', Icons.space_dashboard_rounded),
    _NavItem('Usuarios', Icons.manage_accounts_rounded),
    _NavItem('Accesos & IP', Icons.radar_rounded),
    _NavItem('Galería 5S', Icons.photo_library_rounded),
    _NavItem('Reportes', Icons.analytics_rounded),
    _NavItem('Auditoría', Icons.shield_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
    _loadAccessLogs();
    _startLiveTimer();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 35), (_) {
      if (_isLive && mounted) {
        _checkBackendHealth();
      }
    });
  }

  Future<void> _loadAccessLogs({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loadingAccessLogs = true;
        _accessLogsError = null;
      });
    }
    try {
      final logs = await context.read<StandardWorkProvider>().fetchAccessLogs();
      if (!mounted) return;
      setState(() {
        _accessLogs = logs;
        _loadingAccessLogs = false;
        _accessLogsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingAccessLogs = false;
        _accessLogsError = 'No se pudo cargar el registro de accesos ($e)';
      });
    }
  }

  Future<void> _checkBackendHealth() async {
    if (_checkingHealth) return;
    setState(() => _checkingHealth = true);
    final sw = Stopwatch()..start();
    try {
      final root = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final res = await http.get(Uri.parse('$root/actuator/health')).timeout(const Duration(seconds: 6));
      sw.stop();
      if (!mounted) return;
      final ms = sw.elapsedMilliseconds;
      setState(() {
        _backendHealthy = res.statusCode == 200;
        _latencyMs = ms;
        _lastCheck = DateTime.now();
        _checkingHealth = false;
        _latencyHistory.add(ms.toDouble().clamp(20, 3000));
        if (_latencyHistory.length > 14) _latencyHistory.removeAt(0);
        if (!_backendHealthy) _pushError('HTTP ${res.statusCode} en /actuator/health');
      });
    } catch (e) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        _backendHealthy = false;
        _latencyMs = sw.elapsedMilliseconds;
        _lastCheck = DateTime.now();
        _checkingHealth = false;
        _latencyHistory.add(sw.elapsedMilliseconds.toDouble().clamp(50, 3000));
        if (_latencyHistory.length > 14) _latencyHistory.removeAt(0);
        _pushError('Fallo de conexión: $e');
      });
    }
  }

  void _pushError(String msg) {
    final ts = _fmtTime(DateTime.now());
    _recentErrors.insert(0, '[$ts] $msg');
    if (_recentErrors.length > 25) _recentErrors.removeLast();
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  String _fmtDateTime(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${_fmtTime(dt)}';

  String _plantName(List<PlantModel> plants, String? id) {
    if (id == null || id.isEmpty || id == 'ALL') return 'Corporativo (Todas)';
    return plants.where((p) => p.id == id).map((p) => p.nombre).firstOrNull ?? id;
  }

  String _roleLabel(String rol) {
    switch (rol.toLowerCase()) {
      case 'ultra_admin':
        return 'Ultra Admin';
      case 'superadmin':
      case 'super_admin':
        return 'Super Admin';
      case 'admin_planta':
      case 'plant_admin':
        return 'Admin Planta';
      case 'supervisor':
        return 'Supervisor';
      default:
        return 'Operador';
    }
  }

  Color _roleColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'ultra_admin':
        return _purple;
      case 'superadmin':
      case 'super_admin':
        return _blue;
      case 'admin_planta':
      case 'plant_admin':
        return _teal;
      case 'supervisor':
        return _orange;
      default:
        return _green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final user = provider.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomBar(),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) _buildDesktopSidebar(provider, user),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context, provider, user, isDesktop),
                  if (_maintenanceMode) _buildMaintenanceBanner(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _checkBackendHealth();
                        await provider.refreshData();
                        await _loadAccessLogs(silent: true);
                      },
                      child: _buildActiveSection(provider, isDesktop),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NAVEGACIÓN ESTILO MACOS / IOS ====================

  Widget _buildDesktopSidebar(StandardWorkProvider provider, UserProfile? user) {
    final failedCount = _accessLogs.where((l) => !l.success).length;
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: _sidebarBg,
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_ink, Color(0xFF3A3A3C)]),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRACK60', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3)),
                      Text('Ultra Admin Studio', style: TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text('MÓDULOS DE CONTROL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.6)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (_, i) {
                final item = _navItems[i];
                final active = _sectionIndex == i;
                int? badge;
                if (i == 1) badge = provider.allUsers.length;
                if (i == 2 && failedCount > 0) badge = failedCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() => _sectionIndex = i);
                      if (i == 2 && _accessLogs.isEmpty) _loadAccessLogs();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: active
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 18, color: active ? _blue : _muted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                color: active ? _ink : const Color(0xFF48484A),
                              ),
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: (i == 2 ? _red : _blue).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$badge',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i == 2 ? _red : _blue),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusDot(color: _backendHealthy ? _green : _red),
                      const SizedBox(width: 6),
                      Text(
                        _backendHealthy ? 'Cloud Online (${_latencyMs}ms)' : 'Cloud Sin Conexión',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(user?.nombre ?? 'Ultra Admin', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink)),
                  const Text('PIN Maestro 147728', style: TextStyle(fontSize: 10, color: _muted)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRolePreviewSheet(context),
                      icon: const Icon(Icons.visibility_rounded, size: 15),
                      label: const Text('Ver como Rol', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar() {
    return NavigationBar(
      selectedIndex: _sectionIndex,
      backgroundColor: _card,
      indicatorColor: _blue.withValues(alpha: 0.14),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) {
        setState(() => _sectionIndex = i);
        if (i == 2 && _accessLogs.isEmpty) _loadAccessLogs();
      },
      destinations: _navItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon, size: 20),
                selectedIcon: Icon(item.icon, size: 20, color: _blue),
                label: item.label.split(' ').first,
              ))
          .toList(),
    );
  }

  Widget _buildTopBar(BuildContext context, StandardWorkProvider provider, UserProfile? user, bool isDesktop) {
    return Container(
      padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 12, isDesktop ? 24 : 16, 12),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.security_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _navItems[_sectionIndex].label,
                  style: TextStyle(fontSize: isDesktop ? 20 : 17, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.4),
                ),
                Text(
                  'Último pulso ${_fmtTime(_lastCheck)} · ${provider.allPlants.length} plantas · ${provider.allUsers.length} usuarios',
                  style: const TextStyle(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
          _ApplePillButton(
            icon: _isLive ? Icons.sensors_rounded : Icons.pause_circle_outline_rounded,
            label: _isLive ? 'En Vivo' : 'Pausado',
            color: _isLive ? _green : _muted,
            onTap: () => setState(() => _isLive = !_isLive),
          ),
          const SizedBox(width: 8),
          _AppleIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Sincronizar todo ahora',
            spinning: _checkingHealth || _loadingAccessLogs,
            onTap: () {
              _checkBackendHealth();
              provider.refreshData();
              _loadAccessLogs();
            },
          ),
          const SizedBox(width: 8),
          _AppleIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Cerrar sesión',
            color: _red,
            onTap: () {
              provider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _orange.withValues(alpha: 0.14),
      child: const Row(
        children: [
          Icon(Icons.construction_rounded, size: 16, color: _orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo Mantenimiento Activo: Operación marcada en ventana de revisión técnica.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSection(StandardWorkProvider provider, bool isDesktop) {
    switch (_sectionIndex) {
      case 0:
        return _buildCommandCenterTab(provider, isDesktop);
      case 1:
        return _buildUsersTab(provider, isDesktop);
      case 2:
        return _buildAccessLogsTab(provider, isDesktop);
      case 3:
        return _buildEvidenceGalleryTab(provider);
      case 4:
        return _buildOperationsAndReportsTab(provider);
      case 5:
        return _buildAuditAndToolsTab(provider);
      default:
        return _buildCommandCenterTab(provider, isDesktop);
    }
  }

  // ==================== 0. CENTRO DE MANDO BENTO ====================

  Widget _buildCommandCenterTab(StandardWorkProvider provider, bool isDesktop) {
    final activities = provider.instances;
    final doneCount = activities.where((a) => a.done).length;
    final globalPct = activities.isEmpty ? 0 : ((doneCount / activities.length) * 100).round();
    final activeUsers = provider.allUsers.where((u) => u.activo).length;
    final failedLogins = _accessLogs.where((l) => !l.success).length;
    final pending5S = activities.where((a) => a.reqFoto && !a.done).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 4 Bento Hero KPIs
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 540 ? 2 : 1);
            final width = (constraints.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _BentoKpiCard(
                  width: width,
                  title: 'Cumplimiento Global',
                  value: '$globalPct%',
                  subtitle: '$doneCount de ${activities.length} tareas hoy',
                  icon: Icons.donut_large_rounded,
                  color: _blue,
                ),
                _BentoKpiCard(
                  width: width,
                  title: 'Personal Activo',
                  value: '$activeUsers / ${provider.allUsers.length}',
                  subtitle: '${provider.allPlants.length} plantas conectadas',
                  icon: Icons.people_alt_rounded,
                  color: _green,
                ),
                _BentoKpiCard(
                  width: width,
                  title: 'Evidencias Pendientes',
                  value: '$pending5S',
                  subtitle: '${provider.photoStandards.length} estándares 5S activos',
                  icon: Icons.camera_alt_rounded,
                  color: _orange,
                ),
                _BentoKpiCard(
                  width: width,
                  title: 'Radar de Accesos',
                  value: '${_accessLogs.length}',
                  subtitle: failedLogins > 0 ? '$failedLogins intentos fallidos' : 'Sin alertas de intrusión',
                  icon: Icons.radar_rounded,
                  color: failedLogins > 0 ? _red : _purple,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Fila Bento: Cumplimiento por Planta + Latencia del Servidor
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildPlantComplianceCard(provider)),
              const SizedBox(width: 14),
              Expanded(flex: 5, child: _buildLatencyCard()),
            ],
          )
        else ...[
          _buildPlantComplianceCard(provider),
          const SizedBox(height: 14),
          _buildLatencyCard(),
        ],

        const SizedBox(height: 16),
        // Acciones Rápidas Ejecutivas
        _AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Acciones Rápidas de Gobierno', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionChipButton(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Crear Usuario',
                    color: _blue,
                    onTap: () => _showUserEditorDialog(context, provider, null),
                  ),
                  _ActionChipButton(
                    icon: Icons.radar_rounded,
                    label: 'Ver IPs & Dispositivos',
                    color: _purple,
                    onTap: () {
                      setState(() => _sectionIndex = 2);
                      _loadAccessLogs();
                    },
                  ),
                  _ActionChipButton(
                    icon: Icons.campaign_rounded,
                    label: 'Comunicado Global',
                    color: _teal,
                    onTap: () => _showGlobalBroadcastDialog(context, provider),
                  ),
                  _ActionChipButton(
                    icon: Icons.warning_amber_rounded,
                    label: 'Alerta Roja de Planta',
                    color: _red,
                    onTap: () => _showPlantRedAlertDialog(context, provider),
                  ),
                  _ActionChipButton(
                    icon: Icons.picture_as_pdf_rounded,
                    label: _generatingPdf ? 'Generando PDF...' : 'PDF Ejecutivo',
                    color: _ink,
                    onTap: _generatingPdf ? () {} : () => _exportExecutivePdf(provider),
                  ),
                  _ActionChipButton(
                    icon: Icons.construction_rounded,
                    label: _maintenanceMode ? 'Desactivar Mantenimiento' : 'Modo Mantenimiento',
                    color: _orange,
                    onTap: () => setState(() => _maintenanceMode = !_maintenanceMode),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantComplianceCard(StandardWorkProvider provider) {
    final plants = provider.allPlants;
    return _AppleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.factory_rounded, size: 18, color: _blue),
              SizedBox(width: 8),
              Text('Cumplimiento por Planta en Tiempo Real', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
            ],
          ),
          const SizedBox(height: 14),
          if (plants.isEmpty)
            const Text('Sin plantas cargadas.', style: TextStyle(fontSize: 12, color: _muted))
          else
            ...plants.map((p) {
              final list = provider.instances.where((a) => a.plantId == p.id).toList();
              final done = list.where((a) => a.done).length;
              final pct = list.isEmpty ? 0.0 : done / list.length;
              final pctLabel = '${(pct * 100).round()}%';
              final barColor = pct >= 0.8 ? _green : (pct >= 0.5 ? _orange : _red);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(p.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink))),
                        Text('$done/${list.length} ($pctLabel)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: barColor)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: _bg,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLatencyCard() {
    final spots = List.generate(_latencyHistory.length, (i) => FlSpot(i.toDouble(), _latencyHistory[i]));
    return _AppleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusDot(color: _backendHealthy ? _green : _red),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Latencia Backend (Render)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
              ),
              Text('${_latencyMs} ms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _backendHealthy ? _green : _red)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 165,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: _border, strokeWidth: 1)),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _backendHealthy ? _blue : _red,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (_backendHealthy ? _blue : _red).withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 1. USUARIOS & CONTROL TOTAL ====================

  Widget _buildUsersTab(StandardWorkProvider provider, bool isDesktop) {
    final q = _userSearch.trim().toLowerCase();
    final filtered = provider.allUsers.where((u) {
      if (_userRoleFilter != 'ALL' && u.rol.toLowerCase() != _userRoleFilter) return false;
      if (_userPlantFilter != 'ALL' && u.plantId != _userPlantFilter) return false;
      if (q.isEmpty) return true;
      return u.nombre.toLowerCase().contains(q) ||
          u.cedula.toLowerCase().contains(q) ||
          u.cargo.toLowerCase().contains(q) ||
          u.area.toLowerCase().contains(q) ||
          u.rol.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gestión Universal de Usuarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
                        Text('Edita cédula, nombre, PIN, rol, planta, cargo o elimina cuentas en tiempo real.', style: TextStyle(fontSize: 12, color: _muted)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showUserEditorDialog(context, provider, null),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nuevo Usuario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: isDesktop ? 300 : double.infinity,
                    child: TextField(
                      onChanged: (v) => setState(() => _userSearch = v),
                      decoration: _appleInputDecoration('Buscar por nombre, cédula, cargo o área...', Icons.search_rounded),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? 210 : 165,
                    child: DropdownButtonFormField<String>(
                      initialValue: _userRoleFilter,
                      decoration: _appleInputDecoration('Rol', Icons.badge_rounded),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('Todos los roles')),
                        DropdownMenuItem(value: 'ultra_admin', child: Text('Ultra Admin')),
                        DropdownMenuItem(value: 'superadmin', child: Text('Super Admin')),
                        DropdownMenuItem(value: 'admin_planta', child: Text('Admin Planta')),
                        DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                        DropdownMenuItem(value: 'operador', child: Text('Operador')),
                      ],
                      onChanged: (v) => setState(() => _userRoleFilter = v ?? 'ALL'),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? 220 : 165,
                    child: DropdownButtonFormField<String>(
                      initialValue: _userPlantFilter,
                      decoration: _appleInputDecoration('Planta', Icons.factory_rounded),
                      items: [
                        const DropdownMenuItem(value: 'ALL', child: Text('Todas las plantas')),
                        ...provider.allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))),
                      ],
                      onChanged: (v) => setState(() => _userPlantFilter = v ?? 'ALL'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('${filtered.length} usuarios encontrados', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
        const SizedBox(height: 8),
        ...filtered.map((u) => _buildUserRowCard(provider, u)),
      ],
    );
  }

  Widget _buildUserRowCard(StandardWorkProvider provider, UserProfile u) {
    final roleColor = _roleColor(u.rol);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _AppleCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: roleColor.withValues(alpha: 0.14),
              child: Text(
                u.iniciales.isNotEmpty ? u.iniciales : 'US',
                style: TextStyle(fontWeight: FontWeight.w800, color: roleColor, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(u.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                      _TagChip(label: _roleLabel(u.rol), color: roleColor),
                      _TagChip(label: u.activo ? 'Activo' : 'Bloqueado', color: u.activo ? _green : _red),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cédula: ${u.cedula}  ·  ${_plantName(provider.allPlants, u.plantId)}  ·  ${u.area.isNotEmpty ? u.area : u.cargo}',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 4,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showUserEditorDialog(context, provider, u),
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: const Text('Editar Todo', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
                IconButton(
                  tooltip: u.activo ? 'Bloquear acceso' : 'Reactivar acceso',
                  icon: Icon(u.activo ? Icons.block_rounded : Icons.check_circle_outline_rounded, color: u.activo ? _orange : _green, size: 20),
                  onPressed: () => provider.toggleUserActive(u.id, !u.activo),
                ),
                if (u.id != provider.currentUser?.id)
                  IconButton(
                    tooltip: 'Eliminar usuario',
                    icon: const Icon(Icons.delete_outline_rounded, color: _red, size: 20),
                    onPressed: () => _confirmDeleteUser(context, provider, u),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 2. RADAR DE ACCESOS, IPS & DISPOSITIVOS ====================

  Widget _buildAccessLogsTab(StandardWorkProvider provider, bool isDesktop) {
    final q = _accessSearch.trim().toLowerCase();
    final filtered = _accessLogs.where((log) {
      if (_accessFilter == 'SUCCESS' && !log.success) return false;
      if (_accessFilter == 'FAILED' && log.success) return false;
      if (q.isEmpty) return true;
      return log.userNombre.toLowerCase().contains(q) ||
          log.identifier.toLowerCase().contains(q) ||
          log.ipAddress.toLowerCase().contains(q) ||
          log.locationLabel.toLowerCase().contains(q) ||
          log.deviceType.toLowerCase().contains(q) ||
          log.os.toLowerCase().contains(q) ||
          log.browser.toLowerCase().contains(q);
    }).toList();

    final okCount = _accessLogs.where((e) => e.success).length;
    final failCount = _accessLogs.where((e) => !e.success).length;
    final uniqueIps = _accessLogs.map((e) => e.ipAddress).toSet().length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // KPIs del Radar
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 780 ? 4 : 2;
            final w = (constraints.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _BentoKpiCard(width: w, title: 'Registros Totales', value: '${_accessLogs.length}', subtitle: 'Últimos 200 logins', icon: Icons.history_rounded, color: _blue),
                _BentoKpiCard(width: w, title: 'Accesos Exitosos', value: '$okCount', subtitle: 'Sesiones válidas', icon: Icons.verified_user_rounded, color: _green),
                _BentoKpiCard(width: w, title: 'Intentos Fallidos', value: '$failCount', subtitle: 'PIN o cédula errónea', icon: Icons.gpp_bad_rounded, color: _red),
                _BentoKpiCard(width: w, title: 'IPs Únicas', value: '$uniqueIps', subtitle: 'Redes detectadas', icon: Icons.public_rounded, color: _purple),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Radar de Seguridad: IPs, Ubicación y Dispositivos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                        Text(
                          'La ubicación (ciudad, región, país e ISP) se resuelve por IP pública. La dirección exacta de calle requiere permiso GPS del navegador.',
                          style: TextStyle(fontSize: 11, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadingAccessLogs ? null : () => _loadAccessLogs(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(_loadingAccessLogs ? 'Cargando...' : 'Actualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isDesktop ? 320 : double.infinity,
                    child: TextField(
                      onChanged: (v) => setState(() => _accessSearch = v),
                      decoration: _appleInputDecoration('Buscar usuario, cédula, IP, ciudad o dispositivo...', Icons.search_rounded),
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ALL', label: Text('Todos')),
                      ButtonSegment(value: 'SUCCESS', label: Text('Exitosos')),
                      ButtonSegment(value: 'FAILED', label: Text('Fallidos')),
                    ],
                    selected: {_accessFilter},
                    onSelectionChanged: (s) => setState(() => _accessFilter = s.first),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_accessLogsError != null)
          _AppleCard(
            child: Text(_accessLogsError!, style: const TextStyle(fontSize: 12, color: _red)),
          )
        else if (_loadingAccessLogs && _accessLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filtered.isEmpty)
          const _AppleCard(
            child: Text('Aún no hay registros de acceso que coincidan con el filtro.', style: TextStyle(fontSize: 13, color: _muted)),
          )
        else
          ...filtered.map(_buildAccessLogCard),
      ],
    );
  }

  Widget _buildAccessLogCard(AccessLogEntry log) {
    final isMobile = log.deviceType.contains('Móvil') || log.deviceType.contains('Teléfono');
    final isTablet = log.deviceType.contains('Tablet');
    final deviceIcon = isMobile ? Icons.smartphone_rounded : (isTablet ? Icons.tablet_mac_rounded : Icons.computer_rounded);
    final statusColor = log.success ? _green : _red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _AppleCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(deviceIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(log.userNombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                      _TagChip(label: log.success ? 'Exitoso' : 'Fallido', color: statusColor),
                      if (log.rol != null) _TagChip(label: _roleLabel(log.rol!), color: _roleColor(log.rol!)),
                      Text('ID: ${log.identifier}', style: const TextStyle(fontSize: 11, color: _muted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      _InfoInline(icon: Icons.public_rounded, text: 'IP: ${log.ipAddress}'),
                      _InfoInline(icon: Icons.location_on_outlined, text: log.locationLabel),
                      if (log.isp.isNotEmpty) _InfoInline(icon: Icons.router_rounded, text: log.isp),
                      _InfoInline(icon: Icons.devices_rounded, text: '${log.deviceType} · ${log.os} · ${log.browser}'),
                    ],
                  ),
                  if (!log.success && log.failureReason != null) ...[
                    const SizedBox(height: 5),
                    Text('Motivo: ${log.failureReason}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _red)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_fmtDateTime(log.createdAt), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted)),
          ],
        ),
      ),
    );
  }

  // ==================== 3. GALERÍA 5S & EVIDENCIAS ====================

  Widget _buildEvidenceGalleryTab(StandardWorkProvider provider) {
    final activities = provider.instances.where((a) {
      if (_evidencePlantFilter != 'ALL' && a.plantId != _evidencePlantFilter) return false;
      if (_evidenceStateFilter == 'DONE' && !a.done) return false;
      if (_evidenceStateFilter == 'PENDING' && a.done) return false;
      return a.reqFoto || (a.observaciones?.isNotEmpty ?? false);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AppleCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Comparador Central 5S', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<String>(
                  initialValue: _evidencePlantFilter,
                  decoration: _appleInputDecoration('Planta', Icons.factory_rounded),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todas las plantas')),
                    ...provider.allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))),
                  ],
                  onChanged: (v) => setState(() => _evidencePlantFilter = v ?? 'ALL'),
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'ALL', label: Text('Todas')),
                  ButtonSegment(value: 'DONE', label: Text('Completadas')),
                  ButtonSegment(value: 'PENDING', label: Text('Pendientes')),
                ],
                selected: {_evidenceStateFilter},
                onSelectionChanged: (s) => setState(() => _evidenceStateFilter = s.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 960 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
            final w = (constraints.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: activities.take(30).map((inst) {
                return SizedBox(
                  width: w,
                  child: _AppleCard(
                    padding: const EdgeInsets.all(14),
                    child: InkWell(
                      onTap: () => _showCompare5SDialog(context, inst, provider.photoStandards),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _TagChip(label: inst.done ? 'Cumplida' : 'Pendiente', color: inst.done ? _green : _orange),
                              const Spacer(),
                              Text(_plantName(provider.allPlants, inst.plantId), style: const TextStyle(fontSize: 10, color: _muted)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(inst.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
                          const SizedBox(height: 4),
                          Text('Área: ${inst.area} · Prioridad: ${inst.prioridad}', style: const TextStyle(fontSize: 11, color: _muted)),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.compare_rounded, size: 14, color: _blue),
                              SizedBox(width: 4),
                              Text('Comparar vs Estándar 5S', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _blue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ==================== 4. REPORTES & OPERACIONES ====================

  Widget _buildOperationsAndReportsTab(StandardWorkProvider provider) {
    final list = _reportPlantFilter == 'ALL'
        ? provider.instances
        : provider.instances.where((a) => a.plantId == _reportPlantFilter).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Centro de Exportación & Respaldo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _generatingPdf ? null : () => _exportExecutivePdf(provider),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(_generatingPdf ? 'Generando...' : 'PDF Ejecutivo (Sello Oficial)'),
                    style: ElevatedButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await UltraReportService.instance.exportFullJsonBackup(provider);
                    },
                    icon: const Icon(Icons.data_object_rounded, size: 18),
                    label: const Text('Respaldo JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ExcelService.instance.generateConsolidatedCsv();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Archivo CSV consolidado generado')),
                        );
                      }
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('Excel / CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: _reportPlantFilter,
                  decoration: _appleInputDecoration('Filtrar actividades por planta', Icons.factory_rounded),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('Todas las plantas')),
                    ...provider.allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))),
                  ],
                  onChanged: (v) => setState(() => _reportPlantFilter = v ?? 'ALL'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...list.take(40).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AppleCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(a.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: a.done ? _green : _orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                          Text('${_plantName(provider.allPlants, a.plantId)} · ${a.area} · ${a.state}', style: const TextStyle(fontSize: 11, color: _muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ==================== 5. AUDITORÍA & ROLES ====================

  Widget _buildAuditAndToolsTab(StandardWorkProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AppleCard(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inspector de Roles en Vivo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                    Text('Abre las pantallas reales de Super Admin, Admin de Planta, Supervisor u Operador.', style: TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showRolePreviewSheet(context),
                icon: const Icon(Icons.visibility_rounded, size: 17),
                label: const Text('Abrir Selector'),
                style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_recentErrors.isNotEmpty) ...[
          _AppleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Incidentes de Red Recientes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _red)),
                const SizedBox(height: 8),
                ..._recentErrors.take(10).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(e, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: _ink)),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        _AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bitácora de Auditoría (${provider.auditLogs.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(height: 10),
              if (provider.auditLogs.isEmpty)
                const Text('Sin eventos registrados aún.', style: TextStyle(fontSize: 12, color: _muted))
              else
                ...provider.auditLogs.take(30).map((log) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: _blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${log.action} - ${log.details} (${log.userId})',
                              style: const TextStyle(fontSize: 12, color: _ink),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DIÁLOGOS & EDITOR UNIVERSAL DE USUARIO ====================

  void _showUserEditorDialog(BuildContext context, StandardWorkProvider provider, UserProfile? existing) {
    final isNew = existing == null;
    final cedulaCtrl = TextEditingController(text: existing?.cedula ?? '');
    final nombreCtrl = TextEditingController(text: existing?.nombre ?? '');
    final cargoCtrl = TextEditingController(text: existing?.cargo ?? '');
    final areaCtrl = TextEditingController(text: existing?.area ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final pinCtrl = TextEditingController();

    String selectedRol = existing?.rol ?? 'operador';
    String selectedPlant = existing?.plantId ?? (provider.allPlants.isNotEmpty ? provider.allPlants.first.id : 'PL-EXTRUSA');
    bool isActive = existing?.activo ?? true;
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(isNew ? Icons.person_add_alt_1_rounded : Icons.manage_accounts_rounded, color: _blue),
              const SizedBox(width: 8),
              Expanded(child: Text(isNew ? 'Crear Nuevo Usuario' : 'Editar Usuario Completo', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nombreCtrl, decoration: _appleInputDecoration('Nombre Completo *', Icons.person_outline_rounded)),
                  const SizedBox(height: 10),
                  TextField(controller: cedulaCtrl, decoration: _appleInputDecoration('Cédula / Identificador *', Icons.badge_outlined)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: cargoCtrl, decoration: _appleInputDecoration('Cargo', Icons.work_outline_rounded))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: areaCtrl, decoration: _appleInputDecoration('Área', Icons.grid_view_rounded))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: _appleInputDecoration('Correo Electrónico', Icons.email_outlined)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: ['ultra_admin', 'superadmin', 'admin_planta', 'supervisor', 'operador'].contains(selectedRol)
                        ? selectedRol
                        : 'operador',
                    decoration: _appleInputDecoration('Rol', Icons.security_rounded),
                    items: const [
                      DropdownMenuItem(value: 'operador', child: Text('Operador / Colaborador')),
                      DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                      DropdownMenuItem(value: 'admin_planta', child: Text('Admin de Planta')),
                      DropdownMenuItem(value: 'superadmin', child: Text('Super Admin')),
                      DropdownMenuItem(value: 'ultra_admin', child: Text('Ultra Admin')),
                    ],
                    onChanged: (v) => setModalState(() => selectedRol = v ?? 'operador'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: ([...provider.allPlants.map((p) => p.id), 'ALL'].contains(selectedPlant)) ? selectedPlant : 'ALL',
                    decoration: _appleInputDecoration('Planta Asignada', Icons.factory_rounded),
                    items: [
                      const DropdownMenuItem(value: 'ALL', child: Text('Corporativo (Todas las plantas)')),
                      ...provider.allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))),
                    ],
                    onChanged: (v) => setModalState(() => selectedPlant = v ?? 'ALL'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pinCtrl,
                          decoration: _appleInputDecoration(
                            isNew ? 'PIN (opcional para operador)' : 'Nuevo PIN (dejar vacío para no cambiar)',
                            Icons.lock_outline_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Generar PIN aleatorio de 6 dígitos',
                        icon: const Icon(Icons.casino_rounded, color: _blue),
                        onPressed: () {
                          final rnd = 100000 + Random().nextInt(900000);
                          setModalState(() => pinCtrl.text = rnd.toString());
                        },
                      ),
                      IconButton(
                        tooltip: 'Copiar PIN',
                        icon: const Icon(Icons.copy_rounded, color: _muted),
                        onPressed: () {
                          if (pinCtrl.text.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: pinCtrl.text));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN copiado al portapapeles')));
                          }
                        },
                      ),
                    ],
                  ),
                  if (!isNew) ...[
                    const SizedBox(height: 6),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cuenta Activa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      value: isActive,
                      onChanged: (v) => setModalState(() => isActive = v),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
              onPressed: saving
                  ? null
                  : () async {
                      if (nombreCtrl.text.trim().isEmpty || cedulaCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y cédula son obligatorios')));
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        if (isNew) {
                          await provider.createFullUser(
                            cedula: cedulaCtrl.text,
                            nombre: nombreCtrl.text,
                            cargo: cargoCtrl.text,
                            area: areaCtrl.text,
                            email: emailCtrl.text,
                            rol: selectedRol,
                            plantId: selectedPlant,
                            pin: pinCtrl.text,
                          );
                        } else {
                          await provider.updateFullUser(
                            userId: existing.id,
                            cedula: cedulaCtrl.text,
                            nombre: nombreCtrl.text,
                            cargo: cargoCtrl.text,
                            area: areaCtrl.text,
                            email: emailCtrl.text,
                            rol: selectedRol,
                            plantId: selectedPlant,
                            activo: isActive,
                            newPin: pinCtrl.text,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isNew ? 'Usuario creado en la nube' : 'Usuario actualizado correctamente')),
                          );
                        }
                      } catch (e) {
                        setModalState(() => saving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: _red, content: Text('Error: $e')));
                        }
                      }
                    },
              child: Text(saving ? 'Guardando...' : (isNew ? 'Crear Usuario' : 'Guardar Cambios')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, StandardWorkProvider provider, UserProfile u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Seguro que deseas eliminar permanentemente a ${u.nombre} (Cédula: ${u.cedula})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.deleteUserFromCloud(u.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: _red, content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportExecutivePdf(StandardWorkProvider provider) async {
    setState(() => _generatingPdf = true);
    try {
      await UltraReportService.instance.generateAndShareExecutivePdf(provider);
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  void _showCompare5SDialog(BuildContext context, ActivityInstance inst, List<PlantPhotoStandardModel> standards) {
    final matchingStd = standards.where((s) => s.plantId == inst.plantId && s.area.toLowerCase() == inst.area.toLowerCase()).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(inst.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Área: ${inst.area} · Estado: ${inst.state}', style: const TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      matchingStd.isNotEmpty ? matchingStd.first.titulo : 'Criterio de Cumplimiento',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matchingStd.isNotEmpty
                          ? matchingStd.first.descripcion
                          : (inst.criteriosCumplimiento.isNotEmpty ? inst.criteriosCumplimiento : 'Cumplir estándar visual de área.'),
                      style: const TextStyle(fontSize: 12, color: _ink),
                    ),
                  ],
                ),
              ),
              if (inst.observaciones != null && inst.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Observación registrada: ${inst.observaciones}', style: const TextStyle(fontSize: 12, color: _ink)),
              ],
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
    String selectedPlant = provider.allPlants.isNotEmpty ? provider.allPlants.first.id : 'PL-EXTRUSA';
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Alerta Roja de Planta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedPlant,
                items: provider.allPlants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                onChanged: (v) => setModal(() => selectedPlant = v ?? selectedPlant),
              ),
              const SizedBox(height: 10),
              TextField(controller: msgCtrl, maxLines: 3, decoration: _appleInputDecoration('Mensaje de alerta urgente', Icons.warning_rounded)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
              onPressed: () async {
                if (msgCtrl.text.trim().isEmpty) return;
                await provider.sendGlobalBroadcast(title: 'ALERTA ROJA ($selectedPlant)', message: msgCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Emitir Alerta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGlobalBroadcastDialog(BuildContext context, StandardWorkProvider provider) {
    final titleCtrl = TextEditingController(text: 'Comunicado Ultra Admin');
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comunicado Global'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: _appleInputDecoration('Título', Icons.title_rounded)),
            const SizedBox(height: 10),
            TextField(controller: msgCtrl, maxLines: 3, decoration: _appleInputDecoration('Mensaje para toda la operación', Icons.campaign_rounded)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
            onPressed: () async {
              if (msgCtrl.text.trim().isEmpty) return;
              await provider.sendGlobalBroadcast(title: titleCtrl.text.trim(), message: msgCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Entrar / Inspeccionar Vista de Rol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded, color: _blue),
                title: const Text('Super Admin Corporativo'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperAdminShellScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.factory_rounded, color: _teal),
                title: const Text('Administrador de Planta'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PlantAdminShellScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user_rounded, color: _orange),
                title: const Text('Supervisor de Planta'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupervisorShellScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded, color: _green),
                title: const Text('Operador / Colaborador'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OperatorDashboardScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _appleInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: _muted),
      filled: true,
      fillColor: _bg,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _AppleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _AppleCard({required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: child,
    );
  }
}

class _BentoKpiCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _BentoKpiCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _AppleCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF86868B)))),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F), letterSpacing: -0.6)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
          ],
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChipButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _InfoInline extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoInline({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF86868B)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF48484A), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _ApplePillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ApplePillButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _AppleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final bool spinning;
  final VoidCallback onTap;
  const _AppleIconButton({required this.icon, required this.tooltip, this.color = const Color(0xFF1D1D1F), this.spinning = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: spinning ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon, color: color, size: 20),
    );
  }
}

