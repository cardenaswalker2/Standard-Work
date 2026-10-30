import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/services/standard_work_provider.dart';
import '../login/login_screen.dart';
import '../indicators/indicators_screen.dart';
import '../calendar/calendar_screen.dart';
import '../reports/reports_screen.dart';
import '../history/history_screen.dart';
import '../backup/backup_screen.dart';
import '../planning/four_weeks_planning_screen.dart';

class UserMenuSheet extends StatelessWidget {
  const UserMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final user = provider.currentProfile;

    if (user == null) return const SizedBox.shrink();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.txt,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.cargo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gris,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.gris),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borde),
          const SizedBox(height: 12),

          // Secciones añadidas de valor empresarial
          ListTile(
            leading: const Icon(Icons.view_week_outlined, color: AppColors.azul),
            title: const Text('Planificación 4 Semanas (Excel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.azul)),
            subtitle: const Text('ST - WR YONNY LOPEZ · 270 actividades', style: TextStyle(fontSize: 11, color: AppColors.gris)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FourWeeksPlanningScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined, color: AppColors.azul),
            title: const Text('Centro de Indicadores y Gráficos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const IndicatorsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined, color: AppColors.azul2),
            title: const Text('Calendario y Programación', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.verde),
            title: const Text('Reportes de Cumplimiento (PDF / CSV)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.azul),
            title: const Text('Historial de Ejecuciones y Trazabilidad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined, color: AppColors.morado),
            title: const Text('Copia de Seguridad y Restauración (JSON)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
            },
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borde),
          const SizedBox(height: 10),

          // Sección de Simulación y Demo (del HTML original)
          const Text(
            '🧪 Simular día de hoy (demo)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gris,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borde, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: provider.hoy,
                isExpanded: true,
                items: List.generate(5, (i) {
                  return DropdownMenuItem<int>(
                    value: i + 1,
                    child: Text(
                      DateUtilsHelper.diasCompletos[i],
                      style: const TextStyle(fontSize: 14, color: AppColors.txt),
                    ),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    provider.setSimulatedHoy(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Día simulado: ${DateUtilsHelper.diasCompletos[val - 1]}')),
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Opciones de Reinicio y Logout idénticas al HTML
          InkWell(
            onTap: () async {
              await provider.resetData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos reiniciados')),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Icon(Icons.refresh, color: AppColors.txt, size: 20),
                  SizedBox(width: 10),
                  Text(
                    '↺ Reiniciar datos ficticios',
                    style: TextStyle(fontSize: 14, color: AppColors.txt),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              provider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.rojo, size: 20),
                  SizedBox(width: 10),
                  Text(
                    '⎋ Cambiar de usuario',
                    style: TextStyle(fontSize: 14, color: AppColors.rojo, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cerrar', style: TextStyle(color: AppColors.gris, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
