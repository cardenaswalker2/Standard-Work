import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';

class ActivityCardWidget extends StatelessWidget {
  final ActivityInstance instance;
  final bool isFuture;
  final int indicatorMonth;
  final int indicatorYear;
  final String currentMonthName;
  final int currentYear;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMove;

  const ActivityCardWidget({
    super.key,
    required this.instance,
    required this.isFuture,
    required this.indicatorMonth,
    required this.indicatorYear,
    required this.currentMonthName,
    required this.currentYear,
    required this.onTap,
    this.onLongPress,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    // Definición de colores según estado
    Color borderColor;
    Color backgroundColor;
    Color stateTextColor;
    Color stateBgColor;
    String stateLabel;

    if (isFuture) {
      borderColor = AppColors.borde;
      backgroundColor = Colors.white;
      stateTextColor = Colors.white;
      stateBgColor = AppColors.gris;
      stateLabel = 'Programada';
    } else if (instance.done) {
      borderColor = AppColors.verde;
      backgroundColor = AppColors.verdeBg;
      stateTextColor = Colors.white;
      stateBgColor = AppColors.verde;
      stateLabel = '✔ Realizada';
    } else {
      borderColor = AppColors.rojo;
      backgroundColor = AppColors.rojoBg;
      stateTextColor = Colors.white;
      stateBgColor = AppColors.rojo;
      stateLabel = '✖ Pendiente';
    }

    final bool canMove = !instance.fija && instance.day < 5 && !instance.done && !isFuture;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: isFuture ? 1.5 : 2.5,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fila Superior: Indicador del Mes + Badge de Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Indicador del mes ($currentMonthName): $indicatorMonth%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isFuture
                            ? AppColors.gris
                            : (instance.done ? AppColors.verde : AppColors.rojo),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: stateBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: stateTextColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Nombre de la Actividad (Centrado y en negrita)
                Text(
                  instance.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.txt,
                  ),
                ),

                const SizedBox(height: 3),

                // Descripción
                Text(
                  instance.descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gris,
                  ),
                ),

                const SizedBox(height: 6),

                // Fila Inferior: Indicador del Año + Badges (Fija, Movida, Mover)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Indicador del año $currentYear: $indicatorYear%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gris,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (instance.orig != instance.day) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Desde ${DateUtilsHelper.diasCompletos[instance.orig - 1]}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.azul2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (instance.fija)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '📌 Diaria L-V',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.azul,
                              ),
                            ),
                          )
                        else if (canMove && onMove != null)
                          InkWell(
                            onTap: onMove,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '⇄ Mover',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.azul,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
