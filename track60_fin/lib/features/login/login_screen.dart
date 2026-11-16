import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/help_guide_modal.dart';
import '../../core/widgets/ios_pwa_install_guide_modal.dart';
import '../../core/widgets/track60_logo.dart';
import '../../data/services/standard_work_provider.dart';
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
  // Paleta Apple HIG + Identidad Darnel
  static const Color _bg = Color(0xFFF5F5F7);
  static const Color _ink = Color(0xFF1D1D1F);
  static const Color _muted = Color(0xFF86868B);
  static const Color _border = Color(0xFFE5E5EA);
  static const Color _blue = Color(0xFF007AFF);
  static const Color _navy = Color(0xFF002F6C);
  static const Color _red = Color(0xFFFF3B30);

  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isDirectorMode = false; // false: Colaborador (Cédula), true: Directivo / Admin (PIN)
  bool _obscureInput = false;
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

  Future<void> _submitLogin() async {
    if (_isLoading) return;
    final raw = (_isDirectorMode ? _pinController.text : _cedulaController.text).trim();
    if (raw.isEmpty) {
      setState(() {
        _errorMessage = _isDirectorMode
            ? 'Ingresa tu PIN corporativo para continuar.'
            : 'Ingresa tu número de cédula para continuar.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final success = _isDirectorMode
        ? await provider.loginWithPin(raw)
        : await provider.loginWithCedula(raw);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _routeByUserRole(context);
    } else {
      setState(() {
        _errorMessage = _isDirectorMode
            ? 'PIN incorrecto o usuario sin permisos directivos.'
            : 'Cédula no encontrada o colaborador inactivo en el sistema.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: _bg,
      body: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Panel Izquierdo: Hero Corporativo Apple/Darnel
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/darnel_planta.jpg', fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _navy.withValues(alpha: 0.90),
                      const Color(0xFF0A192F).withValues(alpha: 0.96),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandBadge(),
                      const Spacer(),
                      const Track60Logo(size: 50, isDark: true),
                      const SizedBox(height: 18),
                      const Text(
                        'Operación estandarizada,\nevidencia real en cada planta.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.18,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Plataforma corporativa del Grupo Darnel para rutinas Standard Work, auditoría visual 5S y seguimiento multiplanta.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _HeroFeatureRow(
                        icon: Icons.fact_check_rounded,
                        title: 'Rutinas & Estándar 5S',
                        subtitle: 'Actividades diarias, subtareas y control fotográfico por turno.',
                      ),
                      const SizedBox(height: 14),
                      _HeroFeatureRow(
                        icon: Icons.factory_rounded,
                        title: 'Control Multiplanta en Vivo',
                        subtitle: 'Extrusa, Termoformado, Impresión, Sellado y Bodega sincronizados.',
                      ),
                      const SizedBox(height: 14),
                      _HeroFeatureRow(
                        icon: Icons.devices_rounded,
                        title: 'Web, Android APK & iPhone PWA',
                        subtitle: 'Acceso seguro SSL desde cualquier dispositivo autorizado.',
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Panel Derecho: Tarjeta Limpia Estilo Apple
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildAppleLoginCard(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 215,
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
                        _navy.withValues(alpha: 0.88),
                        const Color(0xFF0A192F).withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBrandBadge(),
                          IconButton(
                            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
                            tooltip: 'Guía del Sistema',
                            onPressed: () => HelpGuideModal.show(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Track60Logo(size: 38, isDark: true),
                      const SizedBox(height: 8),
                      Text(
                        'Estandarización y Seguimiento Operativo Multiplanta',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.82)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildAppleLoginCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 13),
          SizedBox(width: 6),
          Text(
            'GRUPO DARNEL · STANDARD WORK',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleLoginCard(BuildContext context) {
    final activeController = _isDirectorMode ? _pinController : _cedulaController;
    final obscure = _isDirectorMode ? !_obscureInput : _obscureInput;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                _isDirectorMode
                    ? 'Acceso con PIN para Supervisores, Admins y Directivos.'
                    : 'Ingresa con tu número de cédula de colaborador.',
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 18),

              // Selector Segmentado estilo iOS
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _SegmentOption(
                      label: 'Colaborador (Cédula)',
                      icon: Icons.badge_outlined,
                      selected: !_isDirectorMode,
                      onTap: () => setState(() {
                        _isDirectorMode = false;
                        _obscureInput = false;
                        _errorMessage = null;
                      }),
                    ),
                    _SegmentOption(
                      label: 'Directivo (PIN)',
                      icon: Icons.shield_outlined,
                      selected: _isDirectorMode,
                      onTap: () => setState(() {
                        _isDirectorMode = true;
                        _obscureInput = false;
                        _errorMessage = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: activeController,
                keyboardType: TextInputType.number,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitLogin(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _ink),
                decoration: InputDecoration(
                  labelText: _isDirectorMode ? 'PIN de Seguridad' : 'Número de Cédula',
                  hintText: _isDirectorMode ? 'Ej. ••••••' : 'Ej. 1023456789',
                  prefixIcon: Icon(_isDirectorMode ? Icons.lock_outline_rounded : Icons.badge_outlined, color: _blue, size: 20),
                  suffixIcon: IconButton(
                    tooltip: obscure ? 'Mostrar' : 'Ocultar',
                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _muted, size: 20),
                    onPressed: () => setState(() => _obscureInput = !_obscureInput),
                  ),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _blue, width: 1.5),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _red.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: _red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: _red, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDirectorMode ? _navy : _blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                      : Text(
                          _isDirectorMode ? 'Ingresar con PIN' : 'Ingresar a TRACK60',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 12),

              // Accesos secundarios limpios: Instalar PWA & Guía
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => IosPwaInstallGuideModal.show(context),
                    icon: const Icon(Icons.install_mobile_rounded, size: 17, color: _blue),
                    label: const Text('Instalar App (PWA)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _blue)),
                  ),
                  TextButton.icon(
                    onPressed: () => HelpGuideModal.show(context),
                    icon: const Icon(Icons.help_outline_rounded, size: 17, color: _muted),
                    label: const Text('Ayuda', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF34C759)),
            SizedBox(width: 6),
            Text(
              'Conexión Segura SSL · Grupo Darnel',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? const Color(0xFF007AFF) : const Color(0xFF86868B)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? const Color(0xFF1D1D1F) : const Color(0xFF86868B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HeroFeatureRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
