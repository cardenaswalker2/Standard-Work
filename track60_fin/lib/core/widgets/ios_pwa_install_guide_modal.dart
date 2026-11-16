import 'package:flutter/material.dart';
import '../utils/pwa_install_helper.dart';

class IosPwaInstallGuideModal extends StatefulWidget {
  const IosPwaInstallGuideModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const IosPwaInstallGuideModal(),
    );
  }

  @override
  State<IosPwaInstallGuideModal> createState() => _IosPwaInstallGuideModalState();
}

class _IosPwaInstallGuideModalState extends State<IosPwaInstallGuideModal> {
  bool _installing = false;

  @override
  Widget build(BuildContext context) {
    final canInstall = PwaInstallHelper.canInstallDirectly();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(22),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.apple_rounded, color: Color(0xFF002F6C), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instalar como App (PWA)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                      ),
                      Text(
                        'Ejecución como App independiente en tu dispositivo',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (canInstall) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF007AFF).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instalación directa disponible en este navegador',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF002F6C)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pulsa el botón para abrir el aviso oficial de instalación en tu pantalla de inicio o escritorio.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _installing
                            ? null
                            : () async {
                                setState(() => _installing = true);
                                final ok = await PwaInstallHelper.promptInstall();
                                if (mounted) {
                                  setState(() => _installing = false);
                                  if (ok) Navigator.pop(context);
                                }
                              },
                        icon: const Icon(Icons.download_for_offline_rounded, size: 19),
                        label: Text(_installing ? 'Abriendo instalador...' : 'Instalar App TRACK60 Ahora'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Si usas iPhone (Safari), Apple requiere estos 3 sencillos pasos para agregarla a tu pantalla de inicio:',
              style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 18),
            _buildStepCard(
              step: '1',
              title: 'Toca el botón Compartir de Safari',
              desc: 'En la barra inferior de Safari, pulsa el icono del cuadrado con una flecha hacia arriba.',
              icon: Icons.ios_share_rounded,
              iconColor: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              step: '2',
              title: 'Selecciona "Agregar a pantalla de inicio"',
              desc: 'Desplázate hacia abajo en el menú de opciones y toca "Agregar a pantalla de inicio" (o "Add to Home Screen").',
              icon: Icons.add_box_outlined,
              iconColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              step: '3',
              title: 'Pulsa "Agregar" y ¡listo!',
              desc: 'Aparecerá el icono oficial de Darnel Standard Work en tu pantalla de inicio. Al abrirlo, funcionará como App nativa a pantalla completa.',
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF16A34A),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF002F6C).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF002F6C).withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded, color: Color(0xFF002F6C), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No requiere permisos de desarrollador ni descargas externas. Seguridad garantizada por Darnel TI.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF002F6C), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002F6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Entendido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Text(step, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3)),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 22),
        ],
      ),
    );
  }
}

