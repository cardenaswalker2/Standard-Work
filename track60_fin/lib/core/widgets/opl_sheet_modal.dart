import 'package:flutter/material.dart';
import '../../data/models/app_models.dart';

class OplSheetModal extends StatelessWidget {
  final ActivityInstance instance;

  const OplSheetModal({super.key, required this.instance});

  static void show(BuildContext context, ActivityInstance instance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OplSheetModal(instance: instance),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escoge una foto ilustrativa según id
    final photoIndex = (instance.activityId % 12) + 1;
    final photoAsset = 'assets/images/fotos_track60/${photoIndex}F.jpg';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header OPL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF002F6C), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTÁNDAR OPERACIONAL DARNEL',
                          style: TextStyle(color: Color(0xFF002F6C), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                        Text(
                          'OPL: ${instance.nombre}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Fotografía / Diagrama de Referencia
            const Text(
              '1. Referencia Visual del Procedimiento Estándar:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Image.asset(
                      photoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_rounded, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 14),
                          SizedBox(width: 4),
                          Text('Estándar Dorado 100% Conforme', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Elementos de Protección Personal (EPP Obligatorio)
            const Text(
              '2. EPP Requerido para esta Operación:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildEppBadge(Icons.visibility_rounded, 'Gafas ANSI'),
                const SizedBox(width: 8),
                _buildEppBadge(Icons.hearing_rounded, 'Tapones 27dB'),
                const SizedBox(width: 8),
                _buildEppBadge(Icons.pan_tool_rounded, 'Guantes Nitrilo'),
                const SizedBox(width: 8),
                _buildEppBadge(Icons.hiking_rounded, 'Botas Dieléctricas'),
              ],
            ),
            const SizedBox(height: 16),

            // Puntos Críticos y Reglas de Oro
            const Text(
              '3. Reglas de Oro y Criterios de Calidad:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            _buildRuleItem('1', 'Verificar calibración en cero antes de iniciar toma de mediciones.'),
            _buildRuleItem('2', 'Capturar fotografía con buena iluminación donde se aprecie el detalle técnico.'),
            _buildRuleItem('3', 'Si detecta material no conforme (RMNC), detenga el flujo y alerte a calidad.'),
            _buildRuleItem('4', 'Mantener despejada la zona de tránsito según estándar 5S.'),
            const SizedBox(height: 20),

            // Botón de Confirmación
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 18),
                label: const Text('ENTENDIDO · PROCEDER A EJECUTAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002F6C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEppBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF002F6C)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRuleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFF0284C7),
            child: Text(number, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}
