import 'package:flutter/material.dart';

class HelpGuideModal extends StatelessWidget {
  const HelpGuideModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HelpGuideModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.help_outline_rounded, color: Color(0xFF002F6C), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Guía Operativa TRACK60 V2',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildGuideItem(
                  icon: Icons.person_outline,
                  color: const Color(0xFF0284C7),
                  title: '1. Ingreso de Colaboradores',
                  desc: 'Ingresa directamente con tu número de cédula para ver tus actividades asignadas de la semana.',
                ),
                _buildGuideItem(
                  icon: Icons.security_rounded,
                  color: const Color(0xFF002F6C),
                  title: '2. Acceso Directivo y Supervisión (PIN)',
                  desc: 'Los Administradores y Supervisores ingresan con su PIN de seguridad de 4 dígitos para acceder a sus tableros de control.',
                ),
                _buildGuideItem(
                  icon: Icons.checklist_rounded,
                  color: const Color(0xFF16A34A),
                  title: '3. Ejecución de Subtareas y Evidencias',
                  desc: 'Toca una actividad para desplegar sus subtareas. Si requiere fotografía o medición, tómala directamente con la cámara o galería.',
                ),
                _buildGuideItem(
                  icon: Icons.lock_clock_rounded,
                  color: const Color(0xFFDC2626),
                  title: '4. Actividades Fijas vs Flexibles',
                  desc: 'Las actividades Fijas son estándares inmutables. Las actividades Flexibles pueden solicitar reprogramación justificada.',
                ),
                _buildGuideItem(
                  icon: Icons.verified_user_rounded,
                  color: const Color(0xFF7C3AED),
                  title: '5. Auditoría de Piso por Supervisión',
                  desc: 'El supervisor audita las fotos y comentarios en la bandeja de piso, aprobando o solicitando correcciones técnicas.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

