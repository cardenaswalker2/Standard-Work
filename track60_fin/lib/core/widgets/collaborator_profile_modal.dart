import 'package:flutter/material.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';

class CollaboratorProfileModal extends StatelessWidget {
  final UserProfile user;
  final List<ActivityInstance> userInstances;
  final StandardWorkProvider provider;

  const CollaboratorProfileModal({
    super.key,
    required this.user,
    required this.userInstances,
    required this.provider,
  });

  static void show(BuildContext context, UserProfile user, List<ActivityInstance> userInstances, StandardWorkProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollaboratorProfileModal(
        user: user,
        userInstances: userInstances,
        provider: provider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = userInstances.length;
    final done = userInstances.where((i) => i.done).length;
    final progress = total > 0 ? (done / total) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Encabezado
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF002F6C),
                  child: Text(user.iniciales, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${user.cargo} · Cédula: ${user.cedula}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('Planta: ${user.plantId} · Área: ${user.area}', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // Métricas de Desempeño
            const Text('Desempeño y Cumplimiento Operativo:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cumplimiento', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text('$percentage%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tareas Asignadas', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text('$done / $total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Listado de Actividades
            const Text('Actividades en Estándar:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (userInstances.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Sin actividades asignadas en este momento.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              )
            else
              ...userInstances.map((ins) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: ins.done ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ins.done ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(ins.done ? Icons.check_circle : Icons.circle_outlined, size: 16, color: ins.done ? const Color(0xFF16A34A) : Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ins.nombre,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: ins.done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text('${ins.timeStart} - ${ins.timeEnd}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                  )),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002F6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cerrar Expediente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

