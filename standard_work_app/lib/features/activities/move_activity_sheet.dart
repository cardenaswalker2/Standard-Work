import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';

class MoveActivitySheet extends StatelessWidget {
  final ActivityInstance instance;
  final Function(int) onMoveSelected;

  const MoveActivitySheet({
    super.key,
    required this.instance,
    required this.onMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Generar opciones de días posteriores dentro de la semana laboral (hasta el viernes = 5)
    final List<int> futureDays = [];
    for (int d = instance.day + 1; d <= 5; d++) {
      futureDays.add(d);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mover "${instance.nombre}"',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.txt,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppColors.gris),
              children: [
                const TextSpan(text: 'Está en '),
                TextSpan(
                  text: DateUtilsHelper.diasCompletos[instance.day - 1],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const TextSpan(
                    text: '. Solo puedes moverla a un día posterior (lunes a viernes).'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Botones con los días posteriores
          if (futureDays.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No hay días posteriores disponibles en esta semana laboral.',
                  style: TextStyle(color: AppColors.rojo, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: futureDays.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onMoveSelected(d);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borde, width: 1.5),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '→ ${DateUtilsHelper.diasCompletos[d - 1]}',
                        style: const TextStyle(
                          color: AppColors.azul,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.gris, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
