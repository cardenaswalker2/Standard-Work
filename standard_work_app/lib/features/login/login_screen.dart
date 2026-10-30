import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/darnel_logo.dart';
import '../../data/services/standard_work_provider.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedProfileId;
  bool _isLoggingIn = false;

  Future<void> _handleProfileTap(String profileId, StandardWorkProvider provider) async {
    // Si ya está procesando una pulsación, ignorar toques repetitivos inmediatamente
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _selectedProfileId = profileId;
    });

    try {
      await provider.login(profileId);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
          _selectedProfileId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final profiles = provider.profiles;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteLogin,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const DarnelLogoWidget(height: 34),
                const SizedBox(height: 22),
                const Text(
                  'Standard Work',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Darnel Group · Trabajo estándar de lunes a viernes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 34),

                // Lista de Perfiles Operativos siempre visible y reactiva al primer toque
                Expanded(
                  child: ListView.separated(
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = profiles[index];
                      final isSelected = _selectedProfileId == p.id;

                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.24)
                                : Colors.white.withOpacity(0.12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.65)
                                  : Colors.white.withOpacity(0.25),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: _isLoggingIn
                                ? null
                                : () => _handleProfileTap(p.id, provider),
                            borderRadius: BorderRadius.circular(16),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.white.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Avatar redondo
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      p.iniciales,
                                      style: const TextStyle(
                                        color: AppColors.morado,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Datos del usuario
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.nombre,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${p.cargo} · 10 actividades',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Indicador de carga específico en la tarjeta seleccionada o flecha
                                  if (isSelected && _isLoggingIn)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 14,
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

                // Pie de página oficial
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: Text(
                      'Darnel Group · Base de datos SQLite local · Persistencia 100% Offline',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
