import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';

class WeekSelectorWidget extends StatelessWidget {
  final int selectedDay;
  final int hoy;
  final List<ActivityInstance> allInstances;
  final Function(int) onSelectDay;

  const WeekSelectorWidget({
    super.key,
    required this.selectedDay,
    required this.hoy,
    required this.allInstances,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        children: List.generate(5, (index) {
          final int dayNum = index + 1;
          final bool isSelected = dayNum == selectedDay;
          final bool isToday = dayNum == hoy;

          // Calcular estado del punto (dot)
          final dayInstances = allInstances.where((i) => i.day == dayNum).toList();
          Color dotColor = const Color(0xFFCBD5E1);

          if (dayNum <= hoy && dayInstances.isNotEmpty) {
            final allDone = dayInstances.every((i) => i.done);
            dotColor = allDone ? AppColors.verde : AppColors.rojo;
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 3,
                right: index == 4 ? 0 : 3,
              ),
              child: GestureDetector(
                onTap: () => onSelectDay(dayNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.azul : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.azul
                          : (isToday ? AppColors.azul2 : AppColors.borde),
                      width: isToday && !isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.azul.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Punto indicador en la esquina superior derecha
                      Positioned(
                        top: 1,
                        right: 6,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateUtilsHelper.diasCortos[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.txt,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isToday
                                ? 'Hoy · ${dayInstances.length}'
                                : '${DateUtilsHelper.diasCompletos[index].substring(0, 3)} · ${dayInstances.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : AppColors.gris,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
