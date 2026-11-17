import 'package:flutter/material.dart';
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

  static const _tabs = ['Inicio', 'Operador', 'Supervisor', 'Admin'];

  @override
  Widget build(BuildContext context) {
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Centro de Ayuda TRACK60',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.3),
                          ),
                          Text(
                            'Guía interactiva por rol, colores y preguntas frecuentes',
                            style: TextStyle(fontSize: 11, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Selector Segmentado estilo iOS
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final active = _selectedTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: active
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 5, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Text(
                              _tabs[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                color: active ? _blue : _muted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
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
                if (_selectedTab == 0) ..._buildInicioSection(context),
                if (_selectedTab == 1) ..._buildOperadorSection(),
                if (_selectedTab == 2) ..._buildSupervisorSection(),
                if (_selectedTab == 3) ..._buildAdminSection(),
                const SizedBox(height: 16),
                _buildVisualLegend(),
                const SizedBox(height: 16),
                _buildFaqSection(context),
                const SizedBox(height: 16),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInicioSection(BuildContext context) {
    return [
      _GuideCard(
        icon: Icons.badge_rounded,
        color: _blue,
        title: '1. Ingreso para Colaboradores (Cédula)',
        desc: 'En la pantalla inicial selecciona "Colaborador (Cédula)" e ingresa tu número de cédula sin espacios ni puntos.',
      ),
      _GuideCard(
        icon: Icons.shield_rounded,
        color: _navy,
        title: '2. Ingreso Directivo & Supervisión (PIN)',
        desc: 'Cambia al selector "Directivo (PIN)" e ingresa tu PIN corporativo (4 a 6 dígitos) asignado para acceder a tu tablero.',
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

  List<Widget> _buildOperadorSection() {
    return const [
      _GuideCard(
        icon: Icons.wb_sunny_rounded,
        color: _blue,
        title: 'Mi Jornada y Semáforo de Avance',
        desc: 'Cambia entre Lunes y Viernes en la parte superior para ver tu anillo de progreso y tareas pendientes del día.',
      ),
      _GuideCard(
        icon: Icons.checklist_rounded,
        color: _green,
        title: 'Subtareas, Fotos 5S y Mediciones',
        desc: 'Toca cualquier tarjeta roja para abrir las subtareas. Toma la foto en vivo o registra la medición antes de finalizar.',
      ),
      _GuideCard(
        icon: Icons.timer_outlined,
        color: _orange,
        title: 'Temporizador, OPL y Reprogramación',
        desc: 'Usa el cronómetro y las lecciones OPL arriba. Solo las actividades flexibles permiten solicitar reprogramación.',
      ),
    ];
  }

  List<Widget> _buildSupervisorSection() {
    return const [
      _GuideCard(
        icon: Icons.task_alt_rounded,
        color: _blue,
        title: 'Mis Actividades (Pestaña Propia)',
        desc: 'En la pestaña "Mis Actividades" ves las rutinas asignadas directamente a ti por el Admin de Planta para ejecutarlas y cumplirlas.',
      ),
      _GuideCard(
        icon: Icons.verified_user_rounded,
        color: _green,
        title: 'Auditoría de Piso y Banco 5S',
        desc: 'Revisa las evidencias de tu equipo en "Seguimiento", aprueba o rechaza con observación técnica y registra fotos modelo 5S arriba.',
      ),
      _GuideCard(
        icon: Icons.checklist_rtl_rounded,
        color: _purple,
        title: 'Ronda Gemba 5S y Excel',
        desc: 'Evalúa el orden y limpieza de tu línea en la Ronda 5S o exporta el reporte consolidado desde los íconos superiores.',
      ),
    ];
  }

  List<Widget> _buildAdminSection() {
    return const [
      _GuideCard(
        icon: Icons.apartment_rounded,
        color: _navy,
        title: 'Gobierno Multiplanta (Super Admin)',
        desc: 'Supervisa el cumplimiento real de todas las sedes, entra en "En Vivo" como observador y despacha rutinas o reuniones con hora fija.',
      ),
      _GuideCard(
        icon: Icons.manage_accounts_rounded,
        color: _blue,
        title: 'Gestión de Equipo (Admin de Planta)',
        desc: 'Crea, edita cédula/datos o cambia PIN de supervisores y operadores de tu planta, y asigna actividades a ambos roles.',
      ),
      _GuideCard(
        icon: Icons.table_chart_rounded,
        color: _orange,
        title: 'PROPLANES y Solicitudes (>10 Tareas)',
        desc: 'Administra planes de acción obligatorios y solicita ampliación de cupo diario cuando tu planta supere las 10 rutinas.',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Leyenda Visual de Actividades', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LegendBadge(label: 'Borde Rojo · Sin Completar', color: _red, filled: true),
              _LegendBadge(label: 'Borde Verde · Cumplida', color: _green, filled: true),
              _LegendBadge(label: 'Estándar Fijo (Inmutable)', color: const Color(0xFF475569)),
              _LegendBadge(label: 'Reunión Programada', color: _blue),
              _LegendBadge(label: 'Plan de Acción Obligatorio', color: _orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
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

  Widget _buildFooter(BuildContext context) {
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
