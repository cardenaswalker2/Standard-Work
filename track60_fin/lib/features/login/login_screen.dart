import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/excel_service.dart';
import '../../core/widgets/track60_logo.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/widgets/ios_pwa_install_guide_modal.dart';
import '../operator/operator_dashboard_screen.dart';
import '../plant_admin/plant_admin_shell_screen.dart';
import '../superadmin/superadmin_shell_screen.dart';
import '../supervisor/supervisor_shell_screen.dart';
import '../ultra_admin/ultra_admin_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cedulaController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _routeByUserRole(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final user = provider.currentUser;
    if (user == null) return;

    Widget nextScreen;
    if (user.isUltraAdmin) {
      nextScreen = const UltraAdminShellScreen();
    } else if (user.isSuperAdmin) {
      nextScreen = const SuperAdminShellScreen();
    } else if (user.isPlantAdmin) {
      nextScreen = const PlantAdminShellScreen();
    } else if (user.isSupervisor) {
      nextScreen = const SupervisorShellScreen();
    } else {
      nextScreen = const OperatorDashboardScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  Future<void> _handleOperatorLogin(String cedula) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final success = await provider.loginWithCedula(cedula);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _routeByUserRole(context);
    } else {
      setState(() {
        _errorMessage = 'Cédula no encontrada o colaborador inactivo en el sistema.';
      });
    }
  }

  Future<void> _handlePinLogin(String pin, {String? targetUserId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final success = await provider.loginWithPin(pin, targetUserId: targetUserId);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context); // Cierra diálogo PIN
      _routeByUserRole(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN incorrecto o usuario sin permisos directivos.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDirectorLoginDialog() {
    _pinController.clear();
    bool obscure = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF002F6C)),
              ),
              const SizedBox(width: 12),
              const Text('Acceso Directivo & Admin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa tu PIN de seguridad asignado (Superadmin, Admin de Planta o Supervisor):',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: obscure,
                  maxLength: 6,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu PIN de acceso',
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF002F6C)),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF002F6C)),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                if (_pinController.text.isNotEmpty) {
                  _handlePinLogin(_pinController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002F6C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Ingresar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRoleChip(String label, String pin, String userId) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide(color: Colors.grey.shade300),
      onPressed: () {
        _pinController.text = pin;
        _handlePinLogin(pin, targetUserId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO HEADER CON FOTO AÉREA OFICIAL Y GRADIENTE AZUL
            Stack(
              children: [
                Container(
                  height: 290,
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
                          const Color(0xFF002F6C).withValues(alpha: 0.94),
                          const Color(0xFF0F172A).withValues(alpha: 0.98),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barra Superior con Botón Ayuda y Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'GRUPO DARNEL · STANDARD WORK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
                              tooltip: 'Guía del Sistema',
                              onPressed: () => HelpGuideModal.show(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Logo Principal
                        const Track60Logo(size: 42, isDark: true),
                        const SizedBox(height: 12),
                        const Text(
                          'Plataforma de Estandarización y Seguimiento Operativo Multiplanta',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // CONTENIDO PRINCIPAL: TARJETA DE LOGIN
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF002F6C).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.badge_rounded, color: Color(0xFF002F6C), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ingreso al Sistema TRACK60',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      Text(
                                        'Ingresa con tu Cédula o PIN Directivo',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              TextField(
                                controller: _cedulaController,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Cédula o PIN de Acceso',
                                  hintText: 'Ingresa tu Cédula o PIN',
                                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF002F6C)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFCA5A5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Botón Ingresar
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_cedulaController.text.isNotEmpty) {
                                          _handleOperatorLogin(_cedulaController.text.trim());
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF002F6C),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text(
                                        'Ingresar a TRACK60',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Acceso Directivo / PIN
                      OutlinedButton.icon(
                        onPressed: _showDirectorLoginDialog,
                        icon: const Icon(Icons.shield_rounded, color: Color(0xFF002F6C)),
                        label: const Text(
                          'Portal de Supervisión & Administración (PIN)',
                          style: TextStyle(color: Color(0xFF002F6C), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          side: const BorderSide(color: Color(0xFF002F6C), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botón Guía iPhone PWA
                      TextButton.icon(
                        onPressed: () => IosPwaInstallGuideModal.show(context),
                        icon: const Icon(Icons.phone_iphone_rounded, size: 18, color: Color(0xFF002F6C)),
                        label: const Text(
                          '¿Usas iPhone? Instalar como App (PWA)',
                          style: TextStyle(color: Color(0xFF002F6C), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pie de página corporativo, guía y pilares TRACK60
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          children: [
                            // 1. Guía rápida de acceso
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF002F6C)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Guía rápida de acceso',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Operadores / Colaboradores: ingresa con tu número de Cédula.\n'
                                    '• Supervisores y Administradores: ingresa con tu PIN corporativo.',
                                    style: TextStyle(fontSize: 12, height: 1.45, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2. Pilares de TRACK60
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildInfoPillarCard(
                                  icon: Icons.fact_check_outlined,
                                  title: 'Standard Work',
                                  subtitle: 'Actividades diarias por planta y turno',
                                ),
                                _buildInfoPillarCard(
                                  icon: Icons.camera_alt_outlined,
                                  title: 'Evidencia Real',
                                  subtitle: 'Registro fotográfico y aprobación',
                                ),
                                _buildInfoPillarCard(
                                  icon: Icons.factory_outlined,
                                  title: 'Multiplanta',
                                  subtitle: 'Control jerárquico por área y rol',
                                ),
                                _buildInfoPillarCard(
                                  icon: Icons.devices_outlined,
                                  title: 'Multiplataforma',
                                  subtitle: 'Web, Android y iPhone (PWA)',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 3. Barra de estado y soporte
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.verified_user_outlined, size: 15, color: Color(0xFF16A34A)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conexión Segura SSL · Servidor Corporativo',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Acceso exclusivo para personal autorizado · Grupo Darnel\nSoporte interno: TI / Mejora Continua',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.35),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPillarCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 245,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF002F6C)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorTile({
    required String nombre,
    required String cargo,
    required String planta,
    required String cedula,
    required String iniciales,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        _cedulaController.text = cedula;
        _handleOperatorLogin(cedula);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Text(iniciales, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  Text('$cargo · $planta', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(cedula, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
