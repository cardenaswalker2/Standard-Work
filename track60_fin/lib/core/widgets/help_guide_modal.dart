import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';
import '../../features/operator/operator_dashboard_screen.dart';
import '../../features/plant_admin/plant_admin_shell_screen.dart';
import '../../features/superadmin/superadmin_shell_screen.dart';
import '../../features/supervisor/supervisor_shell_screen.dart';
import '../../features/ultra_admin/ultra_admin_shell_screen.dart';
import 'ios_pwa_install_guide_modal.dart';

class HelpGuideModal extends StatefulWidget {
  const HelpGuideModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const HelpGuideModal(),
    );
  }

  @override
  State<HelpGuideModal> createState() => _HelpGuideModalState();
}

class _HelpGuideModalState extends State<HelpGuideModal> {
  static const Color _bg = Color(0xFFF5F5F7);
  static const Color _ink = Color(0xFF1D1D1F);
  static const Color _muted = Color(0xFF86868B);
  static const Color _border = Color(0xFFE5E5EA);
  static const Color _blue = Color(0xFF007AFF);
  static const Color _navy = Color(0xFF002F6C);
  static const Color _green = Color(0xFF34C759);
  static const Color _red = Color(0xFFFF3B30);
  static const Color _orange = Color(0xFFFF9500);
  static const Color _purple = Color(0xFFAF52DE);

  int _selectedTab = 0; // 0: Inicio, 1: Operador, 2: Supervisor, 3: Admin
  bool _initializedTab = false;

  // Estado de desbloqueo por PIN cuando se consulta desde el Login
  final TextEditingController _pinCtrl = TextEditingController();
  bool _verifyingPin = false;
  String? _pinError;
  UserProfile? _unlockedUser;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _initTabForUser(UserProfile? currentUser) {
    if (_initializedTab) return;
    _initializedTab = true;
    if (currentUser == null) {
      _selectedTab = 0;
    } else if (currentUser.isUltraAdmin || currentUser.isSuperAdmin || currentUser.isPlantAdmin) {
      _selectedTab = 3;
    } else if (currentUser.isSupervisor) {
      _selectedTab = 2;
    } else {
      _selectedTab = 1;
    }
  }

  List<_HelpTabMeta> _visibleTabs(UserProfile? currentUser) {
    if (currentUser == null) {
      return const [
        _HelpTabMeta(0, 'Inicio', false),
        _HelpTabMeta(1, 'Operador', false),
        _HelpTabMeta(2, 'Supervisor', true),
        _HelpTabMeta(3, 'Admin', true),
      ];
    }
    if (currentUser.isUltraAdmin || currentUser.isSuperAdmin || currentUser.isPlantAdmin) {
      return const [
        _HelpTabMeta(3, 'Mi Panel Admin', false),
        _HelpTabMeta(0, 'Acceso & App', false),
      ];
    }
    if (currentUser.isSupervisor) {
      return const [
        _HelpTabMeta(2, 'Mi Panel Supervisor', false),
        _HelpTabMeta(0, 'Acceso & App', false),
      ];
    }
    return const [
      _HelpTabMeta(1, 'Mi Panel Operador', false),
      _HelpTabMeta(0, 'Acceso & App', false),
    ];
  }

  bool _isLockedTab(int tabId, UserProfile? currentUser) {
    if (currentUser != null) return false; // Ya está autenticado y solo ve lo suyo
    if (tabId == 0 || tabId == 1) return false;
    if (_unlockedUser == null) return true;
    if (tabId == 2) {
      return !(_unlockedUser!.isSupervisor ||
          _unlockedUser!.isPlantAdmin ||
          _unlockedUser!.isSuperAdmin ||
          _unlockedUser!.isUltraAdmin);
    }
    if (tabId == 3) {
      return !(_unlockedUser!.isPlantAdmin || _unlockedUser!.isSuperAdmin || _unlockedUser!.isUltraAdmin);
    }
    return true;
  }

  Future<void> _verifyPinForTab(int tabId) async {
    final pin = _pinCtrl.text.trim();
    if (pin.length < 4) {
      setState(() => _pinError = 'Ingresa tu PIN corporativo (mínimo 4 dígitos).');
      return;
    }
    setState(() {
      _verifyingPin = true;
      _pinError = null;
    });

    final provider = context.read<StandardWorkProvider>();
    final ok = await provider.loginWithPin(pin);
    if (!mounted) return;

    if (!ok || provider.currentUser == null) {
      setState(() {
        _verifyingPin = false;
        _pinError = 'PIN incorrecto o sin permisos para esta sección.';
      });
      return;
    }

    final u = provider.currentUser!;
    final hasAccess = tabId == 2
        ? (u.isSupervisor || u.isPlantAdmin || u.isSuperAdmin || u.isUltraAdmin)
        : (u.isPlantAdmin || u.isSuperAdmin || u.isUltraAdmin);

    if (!hasAccess) {
      provider.logout();
      setState(() {
        _verifyingPin = false;
        _pinError = 'Tu PIN no corresponde al nivel ${tabId == 2 ? "Supervisor" : "Admin"}.';
      });
      return;
    }

    setState(() {
      _verifyingPin = false;
      _unlockedUser = u;
      _pinError = null;
      _pinCtrl.clear();
    });
  }

  void _enterPanelForUser(BuildContext context, UserProfile user) {
    Widget next;
    if (user.isUltraAdmin) {
      next = const UltraAdminShellScreen();
    } else if (user.isSuperAdmin) {
      next = const SuperAdminShellScreen();
    } else if (user.isPlantAdmin) {
      next = const PlantAdminShellScreen();
    } else if (user.isSupervisor) {
      next = const SupervisorShellScreen();
    } else {
      next = const OperatorDashboardScreen();
    }
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    // Si ya había sesión iniciada antes de abrir el modal, es currentUser; si desbloqueó desde login, es _unlockedUser
    final loggedInUser = _unlockedUser == null ? provider.currentUser : null;
    _initTabForUser(loggedInUser);
    final tabs = _visibleTabs(loggedInUser);
    final effectiveUser = loggedInUser ?? _unlockedUser;

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera fija estilo Apple Sheet
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_navy, _blue]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Centro de Ayuda TRACK60',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3),
                          ),
                          Text(
                            effectiveUser != null
                                ? 'Guía personalizada para ${effectiveUser.nombre}'
                                : 'Guía operativa y acceso seguro por PIN',
                            style: const TextStyle(fontSize: 11, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_unlockedUser != null) {
                          // Si desbloqueó desde el login y cierra sin entrar, limpiamos sesión temporal
                          provider.logout();
                        }
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded, color: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: tabs.map((t) {
                      final active = _selectedTab == t.id;
                      final locked = _isLockedTab(t.id, loggedInUser);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedTab = t.id;
                            _pinError = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: active
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 5, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (locked) ...[
                                  Icon(Icons.lock_outline_rounded, size: 12, color: active ? _blue : _muted),
                                  const SizedBox(width: 3),
                                ],
                                Flexible(
                                  child: Text(
                                    t.label,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                      color: active ? _blue : _muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Contenido desplazable
          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(18),
              shrinkWrap: true,
              children: [
                if (_isLockedTab(_selectedTab, loggedInUser))
                  _buildPinGateCard(_selectedTab)
                else ...[
                  if (_selectedTab == 0) ..._buildInicioSection(context),
                  if (_selectedTab == 1) ..._buildOperadorSection(effectiveUser),
                  if (_selectedTab == 2) ..._buildSupervisorSection(context, effectiveUser),
                  if (_selectedTab == 3) ..._buildAdminSection(context, effectiveUser),
                  if (_selectedTab != 0) ...[
                    const SizedBox(height: 14),
                    _buildVisualLegend(),
                  ],
                  const SizedBox(height: 14),
                  _buildFaqSection(),
                ],
                const SizedBox(height: 14),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinGateCard(int tabId) {
    final roleLabel = tabId == 2 ? 'Supervisor' : 'Administrador / Dirección';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _navy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_person_rounded, color: _navy, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Área Privada · $roleLabel', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                    const Text('Por seguridad, esta guía requiere tu PIN corporativo.', style: TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verifyPinForTab(tabId),
            decoration: InputDecoration(
              labelText: 'Ingresa tu PIN de $roleLabel',
              hintText: '••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: _blue),
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          if (_pinError != null) ...[
            const SizedBox(height: 10),
            Text(_pinError!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _red)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _verifyingPin ? null : () => _verifyPinForTab(tabId),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _verifyingPin
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.verified_user_rounded, size: 18),
              label: Text(_verifyingPin ? 'Verificando PIN...' : 'Desbloquear Guía Privada'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard({
    required String greeting,
    required String subtitle,
    required Color accent,
    UserProfile? enterUser,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent, _navy]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.88), height: 1.4)),
          if (enterUser != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _enterPanelForUser(context, enterUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _navy,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              icon: const Icon(Icons.login_rounded, size: 17),
              label: const Text('Ingresar a mi Panel ahora', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildInicioSection(BuildContext context) {
    return [
      const _GuideCard(
        icon: Icons.badge_rounded,
        color: _blue,
        title: '1. Ingreso para Colaboradores (Cédula)',
        desc: 'En la pantalla inicial selecciona "Colaborador (Cédula)" e ingresa tu número de cédula sin espacios ni puntos.',
      ),
      const _GuideCard(
        icon: Icons.shield_rounded,
        color: _navy,
        title: '2. Ingreso Directivo & Supervisión (PIN)',
        desc: 'Cambia al selector "Directivo (PIN)" e ingresa tu PIN corporativo asignado para acceder a tu tablero privado.',
      ),
      _GuideCard(
        icon: Icons.install_mobile_rounded,
        color: _green,
        title: '3. App en Celular (Android APK o iPhone PWA)',
        desc: 'Usa la APK nativa en Android o instala como App independiente (PWA) en Safari (iPhone) o Chrome.',
        trailing: TextButton(
          onPressed: () {
            Navigator.pop(context);
            IosPwaInstallGuideModal.show(context);
          },
          child: const Text('Instalar PWA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ),
    ];
  }

  List<Widget> _buildOperadorSection(UserProfile? user) {
    final firstName = user?.nombre.split(' ').first ?? 'Colaborador';
    return [
      _buildWelcomeCard(
        greeting: '¡Hola, $firstName!',
        subtitle: 'Esto es lo que te vas a encontrar en tu panel de Operación: tu jornada del día, tus tareas asignadas y herramientas rápidas para reportar tu trabajo.',
        accent: _blue,
      ),
      const _GuideCard(
        icon: Icons.wb_sunny_rounded,
        color: _blue,
        title: 'Mi Jornada y Semáforo de Avance',
        desc: 'Cambia entre Lunes y Viernes arriba para ver tu anillo de progreso y cuántas actividades llevas cumplidas hoy.',
      ),
      const _GuideCard(
        icon: Icons.checklist_rounded,
        color: _green,
        title: 'Subtareas, Fotos 5S y Mediciones',
        desc: 'Toca cualquier tarjeta roja para abrir las subtareas, tomar la foto en vivo o registrar la medición antes de finalizar.',
      ),
      const _GuideCard(
        icon: Icons.timer_outlined,
        color: _orange,
        title: 'Temporizador, OPL y Reprogramación',
        desc: 'Usa el cronómetro y las lecciones OPL en la barra superior. Solo las actividades flexibles permiten solicitar reprogramación.',
      ),
    ];
  }

  List<Widget> _buildSupervisorSection(BuildContext context, UserProfile? user) {
    final firstName = user?.nombre.split(' ').first ?? 'Supervisor';
    return [
      _buildWelcomeCard(
        greeting: '¡Hola, $firstName!',
        subtitle: 'Esto es lo que te vas a encontrar en tu panel de Supervisor: resumen de tu equipo en planta, revisión de evidencias y tu pestaña propia "Mis Actividades".',
        accent: const Color(0xFF0284C7),
        enterUser: _unlockedUser,
      ),
      const _GuideCard(
        icon: Icons.task_alt_rounded,
        color: _blue,
        title: 'Mis Actividades (Pestaña Propia)',
        desc: 'Ejecuta y marca cumplidas las rutinas que el Administrador de Planta te asignó directamente (borde rojo pendiente, verde cumplida).',
      ),
      const _GuideCard(
        icon: Icons.verified_user_rounded,
        color: _green,
        title: 'Auditoría de Piso y Banco Fotos 5S',
        desc: 'Aprueba o rechaza con observación técnica las evidencias de tu equipo en "Seguimiento" y carga fotos modelo 5S desde la cabecera.',
      ),
      const _GuideCard(
        icon: Icons.checklist_rtl_rounded,
        color: _purple,
        title: 'Ronda Gemba 5S y Reporte Excel',
        desc: 'Realiza inspecciones 5S por línea y descarga el reporte consolidado desde los íconos superiores.',
      ),
    ];
  }

  List<Widget> _buildAdminSection(BuildContext context, UserProfile? user) {
    final firstName = user?.nombre.split(' ').first ?? 'Administrador';
    return [
      _buildWelcomeCard(
        greeting: '¡Hola, $firstName!',
        subtitle: 'Esto es lo que te vas a encontrar en tu panel de Gestión: control de personal, asignación de rutinas, seguimiento en tiempo real y analítica de cumplimiento.',
        accent: _navy,
        enterUser: _unlockedUser,
      ),
      const _GuideCard(
        icon: Icons.manage_accounts_rounded,
        color: _blue,
        title: 'Gestión de Usuarios, Cédulas y PINs',
        desc: 'Crea cuentas, edita datos o restablece PINs directamente en la nube y asigna rutinas tanto a Operadores como a Supervisores.',
      ),
      const _GuideCard(
        icon: Icons.apartment_rounded,
        color: _navy,
        title: 'Despacho de Rutinas, Reuniones y Modo En Vivo',
        desc: 'Programa actividades fijas con reunión a hora específica, inspecciona cada sede en tiempo real y monitorea el cumplimiento por planta.',
      ),
      const _GuideCard(
        icon: Icons.table_chart_rounded,
        color: _orange,
        title: 'PROPLANES y Solicitudes (>10 Tareas)',
        desc: 'Da seguimiento a planes de acción obligatorios y solicita o aprueba ampliación de cupo diario en planta.',
      ),
    ];
  }

  Widget _buildVisualLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leyenda Visual de Actividades', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LegendBadge(label: 'Borde Rojo · Sin Completar', color: _red, filled: true),
              _LegendBadge(label: 'Borde Verde · Cumplida', color: _green, filled: true),
              _LegendBadge(label: 'Estándar Fijo (Inmutable)', color: Color(0xFF475569)),
              _LegendBadge(label: 'Reunión Programada', color: _blue),
              _LegendBadge(label: 'Plan de Acción Obligatorio', color: _orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text('Preguntas Frecuentes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
          ),
          Divider(height: 1, color: _border),
          ExpansionTile(
            title: Text('¿Qué hago si olvidé mi PIN o no aparece mi cédula?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              Text(
                'Solicita al Administrador de tu Planta o a Dirección que actualice tu cédula o te asigne un nuevo PIN desde su módulo de Usuarios.',
                style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
              ),
            ],
          ),
          Divider(height: 1, color: _border),
          ExpansionTile(
            title: Text('¿Por qué no me deja marcar cumplida una actividad?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              Text(
                'Verifica si tiene subtareas pendientes por reportar, foto obligatoria o un Plan de Acción (PROPLAN) requerido antes del cierre.',
                style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
              ),
            ],
          ),
          Divider(height: 1, color: _border),
          ExpansionTile(
            title: Text('¿Dónde veo los comunicados globales?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              Text(
                'Toca la campanita de notificaciones en tu tablero principal. Los comunicados y alertas emitidas por Dirección se sincronizan en la nube.',
                style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: _green, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRACK60 · Grupo Darnel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
                Text('Soporte interno: TI / Mejora Continua · Conexión SSL', style: TextStyle(fontSize: 11, color: _muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTabMeta {
  final int id;
  final String label;
  final bool requiresPin;
  const _HelpTabMeta(this.id, this.label, this.requiresPin);
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final Widget? trailing;

  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF1D1D1F))),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _LegendBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _LegendBadge({required this.label, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.08 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: filled ? 1.4 : 0.8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
