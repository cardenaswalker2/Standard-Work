import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';
import '../activities/add_activity_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = 1; // 1: Lunes, ..., 5: Viernes
  String _viewMode = 'SEMANA'; // 'SEMANA', 'MES'
  String _selectedCategory = 'TODAS';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    _selectedDay = provider.hoy.clamp(1, 5);
  }

  void _showActivityDetail(BuildContext context, ActivityInstance act, UserProfile? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: act.done ? AppColors.verdeBg : AppColors.rojoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      act.done ? Icons.check_circle : Icons.schedule,
                      color: act.done ? AppColors.verde : AppColors.rojo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.nombre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.txt),
                        ),
                        Text(
                          act.fija ? '📌 Actividad fija obligatoria' : 'Actividad ordinaria',
                          style: const TextStyle(fontSize: 12, color: AppColors.gris),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _itemInfo(Icons.calendar_today, 'Día', DateUtilsHelper.diasCompletos[act.day - 1]),
              _itemInfo(Icons.access_time, 'Horario', '${act.timeStart} - ${act.timeEnd}'),
              _itemInfo(Icons.business, 'Área', act.area.isNotEmpty ? act.area : (user?.area ?? 'No asignada')),
              _itemInfo(Icons.category, 'Categoría', act.category),
              if (act.descripcion.isNotEmpty)
                _itemInfo(Icons.notes, 'Descripción', act.descripcion),
              if (act.observaciones != null && act.observaciones!.isNotEmpty)
                _itemInfo(Icons.comment, 'Observación', act.observaciones!),
              if (act.motivoNoRealizada != null && act.motivoNoRealizada!.isNotEmpty)
                _itemInfo(Icons.warning_amber, 'Motivo incumplimiento', act.motivoNoRealizada!),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azul,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cerrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _itemInfo(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.azul),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gris)),
          Expanded(child: Text(val, style: const TextStyle(fontSize: 12, color: AppColors.txt))),
        ],
      ),
    );
  }

  void _openAddActivity(BuildContext context, StandardWorkProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddActivitySheet(
        initialDay: _selectedDay,
        initialArea: provider.currentProfile?.area,
        onSave: ({
          required nombre,
          required descripcion,
          required days,
          required area,
          required category,
          required timeStart,
          required timeEnd,
          required isFixed,
        }) async {
          final msg = await provider.addNewActivity(
            nombre: nombre,
            descripcion: descripcion,
            days: days,
            area: area,
            category: category,
            timeStart: timeStart,
            timeEnd: timeEnd,
            isFixed: isFixed,
          );
          if (context.mounted && msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: AppColors.azul),
            );
          }
        },
      ),
    );
  }

  Widget _buildViewToggleItem(String label, String value) {
    final isSelected = _viewMode == value;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.azul : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.gris,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final instances = provider.instances;
    final user = provider.currentProfile;

    final categories = [
      'TODAS',
      'Operación y Ejecución',
      'Resultados y Productividad',
      'Liderazgo y Desarrollo de Personas',
      'Proyectos y Mejora Continua',
      'Calidad e Inocuidad',
      'Seguridad',
      'Administración',
    ];

    final dayActs = instances.where((i) {
      if (i.day != _selectedDay) return false;
      if (_selectedCategory != 'TODAS' && i.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('Calendario Laboral'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDay = provider.hoy.clamp(1, 5);
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.today, color: Colors.white, size: 16),
              label: const Text('Hoy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.azul,
        onPressed: () => _openAddActivity(context, provider),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Selector de Semana y Modos de Vista
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Semana ${provider.currentWeekKey} · Lunes a Viernes',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.txt),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Perfil: ${user?.nombre ?? "Operativo"} · ${user?.area ?? "Planta"}',
                            style: const TextStyle(fontSize: 11, color: AppColors.gris),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Selector de Vista Compacto y Elegante (Semana / Mes)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildViewToggleItem('Semana', 'SEMANA'),
                          _buildViewToggleItem('Mes', 'MES'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selector de días interactivo tipo barra de calendario
                Row(
                  children: List.generate(5, (index) {
                    final dayNum = index + 1;
                    final isSelected = dayNum == _selectedDay;
                    final isToday = dayNum == provider.hoy;
                    final totalDay = instances.where((i) => i.day == dayNum).length;
                    final doneDay = instances.where((i) => i.day == dayNum && i.done).length;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDay = dayNum),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.azul
                                : (isToday ? const Color(0xFFEFF6FF) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.azul
                                  : (isToday ? AppColors.azul.withValues(alpha: 0.5) : AppColors.borde),
                              width: isToday ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateUtilsHelper.diasCortos[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.gris,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Día $dayNum',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.txt,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Indicador visual de cumplimiento del día
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : (doneDay == totalDay && totalDay > 0
                                          ? AppColors.verdeBg
                                          : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$doneDay/$totalDay',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (doneDay == totalDay && totalDay > 0
                                            ? AppColors.verde
                                            : AppColors.gris),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 10),

                // Filtro por Categoría
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : AppColors.txt,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AppColors.azul,
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Header de la jornada seleccionada
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agenda de ${DateUtilsHelper.diasCompletos[_selectedDay - 1]} (${dayActs.length} tareas)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.txt),
                ),
                Text(
                  _selectedDay == provider.hoy ? '📌 Día en curso (Hoy)' : 'Día programado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _selectedDay == provider.hoy ? AppColors.azul : AppColors.gris,
                  ),
                ),
              ],
            ),
          ),

          // Lista de Actividades de la fecha seleccionada
          Expanded(
            child: dayActs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 50, color: AppColors.gris.withValues(alpha: 0.4)),
                        const SizedBox(height: 10),
                        const Text(
                          'No hay actividades programadas para este filtro',
                          style: TextStyle(color: AppColors.gris),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _openAddActivity(context, provider),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Crear Actividad para este Día'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azul,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayActs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final act = dayActs[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showActivityDetail(context, act, user),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icono de estado
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: act.done ? AppColors.verdeBg : AppColors.rojoBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    act.done ? Icons.check : Icons.hourglass_top,
                                    color: act.done ? AppColors.verde : AppColors.rojo,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              act.nombre,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: act.done ? AppColors.gris : AppColors.txt,
                                                decoration: act.done ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                          ),
                                          if (act.fija)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Fija',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.azul,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        act.descripcion,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: AppColors.gris),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 12, color: AppColors.gris),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${act.timeStart} - ${act.timeEnd}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.gris),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.category_outlined, size: 12, color: AppColors.gris),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              act.category,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 11, color: AppColors.gris),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
