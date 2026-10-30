import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';

class IndicatorsScreen extends StatefulWidget {
  const IndicatorsScreen({super.key});

  @override
  State<IndicatorsScreen> createState() => _IndicatorsScreenState();
}

class _IndicatorsScreenState extends State<IndicatorsScreen> {
  String _selectedAreaFilter = 'TODAS';
  String _selectedCategoryFilter = 'TODAS';
  int _selectedDayFilter = 0; // 0: Todos los días

  void _showActivityListModal(BuildContext context, String title, List<ActivityInstance> acts, UserProfile? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 18,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).padding.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.txt,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.azul.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${acts.length} registros',
                      style: const TextStyle(
                        color: AppColors.azul,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Datos reales extraídos directamente de SQLite',
                style: TextStyle(fontSize: 11, color: AppColors.gris),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Expanded(
                child: acts.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay actividades para este criterio.',
                          style: TextStyle(color: AppColors.gris),
                        ),
                      )
                    : ListView.separated(
                        itemCount: acts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final a = acts[index];
                          final diaNombre = DateUtilsHelper.diasCortos[a.day - 1];

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borde),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: a.done ? AppColors.verdeBg : AppColors.rojoBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    a.done ? Icons.check : Icons.hourglass_top,
                                    size: 14,
                                    color: a.done ? AppColors.verde : AppColors.rojo,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.nombre,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          decoration: a.done ? TextDecoration.lineThrough : null,
                                          color: a.done ? AppColors.gris : AppColors.txt,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            '$diaNombre · ${a.timeStart} - ${a.timeEnd}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.gris),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '· ${a.area.isNotEmpty ? a.area : (user?.area ?? "Planta")}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.azul, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      if (a.observaciones != null && a.observaciones!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Obs: ${a.observaciones}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.azul),
                                          ),
                                        ),
                                      if (a.motivoNoRealizada != null && a.motivoNoRealizada!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Motivo: ${a.motivoNoRealizada}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.rojo),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final user = provider.currentProfile;
    final allInstances = provider.instances;

    // Obtener áreas dinámicas reales
    final Set<String> areasSet = {'TODAS'};
    for (final i in allInstances) {
      if (i.area.isNotEmpty) areasSet.add(i.area);
    }
    if (user != null && user.area.isNotEmpty) areasSet.add(user.area);

    // Obtener categorías dinámicas reales
    final Set<String> categoriesSet = {'TODAS'};
    for (final i in allInstances) {
      if (i.category.isNotEmpty) categoriesSet.add(i.category);
    }

    // Filtrar instancias de acuerdo a los filtros de la pantalla
    final filteredInstances = allInstances.where((i) {
      if (_selectedAreaFilter != 'TODAS' && i.area != _selectedAreaFilter) {
        return false;
      }
      if (_selectedCategoryFilter != 'TODAS' && i.category != _selectedCategoryFilter) {
        return false;
      }
      if (_selectedDayFilter > 0 && i.day != _selectedDayFilter) {
        return false;
      }
      return true;
    }).toList();

    // Métricas operativas calculadas sin datos ficticios
    final int ejecutadas = filteredInstances.where((i) => i.done).length;
    final int pendientesJornada = filteredInstances.where((i) => !i.done && i.day <= provider.hoy).length;
    final int actividadesFijas = filteredInstances.where((i) => i.fija).length;
    final int requierenAtencion = filteredInstances.where((i) => !i.done && (i.day < provider.hoy || (i.motivoNoRealizada != null && i.motivoNoRealizada!.isNotEmpty))).length;
    final int proximasJornada = filteredInstances.where((i) => !i.done && i.day >= provider.hoy).length;

    // Fórmula estricta de cumplimiento: ejecutadas / evaluables (días transcurridos hasta hoy)
    final int evaluablesHastaHoy = filteredInstances.where((i) => i.day <= provider.hoy).length;
    final double cumplimientoReal = evaluablesHastaHoy > 0 ? ((ejecutadas / evaluablesHastaHoy) * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Centro de Indicadores'),
        backgroundColor: AppColors.azul,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Ejecutiva Corporativa
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.gradienteHeader,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.azul.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nombre ?? 'Yonny López',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${user?.cargo} · ${user?.area}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Semana ${provider.currentWeekKey}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Cumplimiento',
                        value: '${cumplimientoReal.clamp(0, 100).round()}%',
                        color: AppColors.barraVerde,
                      ),
                      _StatColumn(
                        label: 'Realizadas',
                        value: '$ejecutadas',
                        color: Colors.white,
                      ),
                      _StatColumn(
                        label: 'Pendientes',
                        value: '$pendientesJornada',
                        color: const Color(0xFFFCA5A5),
                      ),
                      _StatColumn(
                        label: 'Evaluables',
                        value: '$evaluablesHastaHoy',
                        color: const Color(0xFFBAE6FD),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Barra de Filtros Interactivos
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_list, size: 16, color: AppColors.azul),
                      SizedBox(width: 6),
                      Text(
                        'Filtros de Control Operativo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.txt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Filtro Área
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedAreaFilter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Área',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: areasSet.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() => _selectedAreaFilter = v ?? 'TODAS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filtro Categoría
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategoryFilter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: categoriesSet.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setState(() => _selectedCategoryFilter = v ?? 'TODAS'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Selector de Día (Todos o Lunes..Viernes)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Todos los Días', style: TextStyle(fontSize: 11)),
                          selected: _selectedDayFilter == 0,
                          selectedColor: AppColors.azul,
                          labelStyle: TextStyle(color: _selectedDayFilter == 0 ? Colors.white : AppColors.txt, fontWeight: FontWeight.bold),
                          onSelected: (_) => setState(() => _selectedDayFilter = 0),
                        ),
                        ...List.generate(5, (idx) {
                          final day = idx + 1;
                          final isSel = _selectedDayFilter == day;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                              label: Text(DateUtilsHelper.diasCortos[idx], style: const TextStyle(fontSize: 11)),
                              selected: isSel,
                              selectedColor: AppColors.azul,
                              labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.txt, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() => _selectedDayFilter = day),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tarjetas Interactivas de Indicadores Operativos
            const Text(
              'Indicadores Operativos Reales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.txt,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Toca cualquier tarjeta para auditar las actividades correspondientes',
              style: TextStyle(fontSize: 12, color: AppColors.gris),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _InteractiveMetricCard(
                  title: 'Cumplimiento',
                  value: '${cumplimientoReal.round()}%',
                  subtitle: '$ejecutadas de $evaluablesHastaHoy evaluables',
                  icon: Icons.trending_up,
                  color: AppColors.verde,
                  onTap: () => _showActivityListModal(
                    context,
                    'Actividades Evaluables para Cumplimiento',
                    filteredInstances.where((i) => i.day <= provider.hoy).toList(),
                    user,
                  ),
                ),
                _InteractiveMetricCard(
                  title: 'Ejecutadas',
                  value: '$ejecutadas',
                  subtitle: 'Realizadas con éxito',
                  icon: Icons.check_circle_outline,
                  color: AppColors.azul,
                  onTap: () => _showActivityListModal(
                    context,
                    'Actividades Ejecutadas',
                    filteredInstances.where((i) => i.done).toList(),
                    user,
                  ),
                ),
                _InteractiveMetricCard(
                  title: 'Pendientes',
                  value: '$pendientesJornada',
                  subtitle: 'Atrasadas o de hoy',
                  icon: Icons.pending_actions,
                  color: AppColors.rojo,
                  onTap: () => _showActivityListModal(
                    context,
                    'Actividades Pendientes de la Jornada',
                    filteredInstances.where((i) => !i.done && i.day <= provider.hoy).toList(),
                    user,
                  ),
                ),
                _InteractiveMetricCard(
                  title: 'Requieren Atención',
                  value: '$requierenAtencion',
                  subtitle: 'Atrasadas o con motivos',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange.shade800,
                  onTap: () => _showActivityListModal(
                    context,
                    'Actividades que Requieren Atención',
                    filteredInstances.where((i) => !i.done && (i.day < provider.hoy || (i.motivoNoRealizada != null && i.motivoNoRealizada!.isNotEmpty))).toList(),
                    user,
                  ),
                ),
                _InteractiveMetricCard(
                  title: 'Actividades Fijas',
                  value: '$actividadesFijas',
                  subtitle: 'Obligatorias diarias',
                  icon: Icons.push_pin_outlined,
                  color: const Color(0xFF6366F1),
                  onTap: () => _showActivityListModal(
                    context,
                    'Actividades Fijas Obligatorias',
                    filteredInstances.where((i) => i.fija).toList(),
                    user,
                  ),
                ),
                _InteractiveMetricCard(
                  title: 'Próximas Jornada',
                  value: '$proximasJornada',
                  subtitle: 'Programadas activas',
                  icon: Icons.schedule,
                  color: const Color(0xFF0284C7),
                  onTap: () => _showActivityListModal(
                    context,
                    'Próximas Actividades Programadas',
                    filteredInstances.where((i) => !i.done && i.day >= provider.hoy).toList(),
                    user,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Gráfico Interactivo de Cumplimiento por Día Laboral (fl_chart)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cumplimiento por Día Laboral (L-V)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.txt),
                        ),
                        Icon(Icons.bar_chart, color: AppColors.azul, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Barras: Realizadas (Verde) frente a Programadas (Gris)',
                      style: TextStyle(fontSize: 11, color: AppColors.gris),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                                return;
                              }
                              final dayIndex = barTouchResponse.spot!.touchedBarGroupIndex + 1;
                              _showActivityListModal(
                                context,
                                'Actividades de ${DateUtilsHelper.diasCompletos[dayIndex - 1]}',
                                filteredInstances.where((i) => i.day == dayIndex).toList(),
                                user,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < 5) {
                                    return Text(DateUtilsHelper.diasCortos[idx], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(5, (idx) {
                            final day = idx + 1;
                            final total = filteredInstances.where((i) => i.day == day).length.toDouble();
                            final done = filteredInstances.where((i) => i.day == day && i.done).length.toDouble();

                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: total,
                                  color: Colors.grey.shade300,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                BarChartRodData(
                                  toY: done,
                                  color: AppColors.verde,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Distribución Oficial de Tiempos por Categoría (ST - WR YONNY LOPEZ.xlsb)
            if (provider.categoryDistributions.isNotEmpty) ...[
              const Text(
                'Distribución Oficial por Categoría (Excel ST-WR)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.txt,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Matriz de distribución porcentual de tiempo en ST - WR YONNY LOPEZ.xlsb',
                style: TextStyle(fontSize: 12, color: AppColors.gris),
              ),
              const SizedBox(height: 12),
              ...provider.categoryDistributions.map((cat) {
                final color = Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')));
                return InkWell(
                  onTap: () {
                    final matching = filteredInstances.where((i) => i.category.toLowerCase() == cat.categoria.toLowerCase()).toList();
                    _showActivityListModal(context, 'Categoría: ${cat.categoria}', matching, user);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borde),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat.categoria,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.txt,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${cat.porcentaje}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: cat.porcentaje / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.borde,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _InteractiveMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.gris),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.txt,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.gris,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
