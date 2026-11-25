import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// ========================================================
/// HERO INDUSTRIAL HEADER CON GLASSMORPHISM Y FONDO REAL
/// ========================================================
class IndustrialHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String plantTag;
  final IconData tagIcon;
  final String imageAsset;
  final List<Widget> actions;
  final double height;

  const IndustrialHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.plantTag,
    this.tagIcon = Icons.factory_rounded,
    this.imageAsset = 'assets/images/darnel_planta.jpg',
    this.actions = const [],
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imageAsset),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF002F6C).withValues(alpha: 0.88),
                  const Color(0xFF002F6C).withValues(alpha: 0.95),
                  const Color(0xFF0F172A).withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF7DD3FC), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tagIcon, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            plantTag.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(children: actions),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ========================================================
/// VELOCÍMETRO / TACÓMETRO DE LAS 10 TAREAS DIARIAS
/// ========================================================
class DailyTasksGaugeCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final String shiftName;

  const DailyTasksGaugeCard({
    super.key,
    required this.completedTasks,
    this.totalTasks = 10,
    this.shiftName = 'Turno 1 - Extrusión',
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? (completedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    Color statusColor;
    String statusText;
    if (percentage >= 100) {
      statusColor = const Color(0xFF16A34A);
      statusText = '¡Meta del Turno Cumplida!';
    } else if (percentage >= 70) {
      statusColor = const Color(0xFF0284C7);
      statusText = 'Ritmo Óptimo de Turno';
    } else if (percentage >= 40) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'En Progreso Operativo';
    } else {
      statusColor = const Color(0xFFDC2626);
      statusText = 'Atención: Ritmo Bajo';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002F6C).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
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
                    child: const Icon(Icons.speed_rounded, color: Color(0xFF002F6C), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CUMPLIMIENTO DE 10 TAREAS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                      ),
                      Text(
                        shiftName,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completedTasks',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'de $totalTasks Tareas',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, color: statusColor, size: 15),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ========================================================
/// GRÁFICA DE LÍNEA: TENDENCIA SEMANAL (LUNES A VIERNES)
/// ========================================================
class WeeklyTrendLineCard extends StatelessWidget {
  final List<double> values;
  final String title;
  final String subtitle;
  final void Function(int dayIndex)? onDayTap;

  const WeeklyTrendLineCard({
    super.key,
    required this.values,
    this.title = 'Tendencia Semanal de Cumplimiento',
    this.subtitle = 'Toca un día para ver el detalle real (Lun–Vie)',
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeValues = values.length >= 5
        ? values.take(5).toList()
        : [...values, ...List.filled(5 - values.length, 0.0)];
    final spots = List.generate(
      safeValues.length,
      (index) => FlSpot(index.toDouble(), safeValues[index].clamp(0.0, 100.0)),
    );

    final nonZero = safeValues.where((v) => v > 0).toList();
    final hasData = nonZero.isNotEmpty;
    final double delta = safeValues.length >= 2 ? (safeValues.last - safeValues.first) : 0.0;
    final deltaStr = !hasData
        ? 'Sin datos'
        : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%';
    final deltaColor = !hasData
        ? const Color(0xFF64748B)
        : (delta >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Column(
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
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      !hasData
                          ? Icons.remove_rounded
                          : (delta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded),
                      color: deltaColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(deltaStr, style: TextStyle(color: deltaColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchCallback: (event, resp) {
                    if (event is FlTapUpEvent && resp?.lineBarSpots != null && resp!.lineBarSpots!.isNotEmpty) {
                      onDayTap?.call(resp.lineBarSpots!.first.x.toInt());
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1D1D1F),
                    tooltipBorderRadius: BorderRadius.circular(10),
                    getTooltipItems: (touchedSpots) {
                      const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt().clamp(0, 4);
                        return LineTooltipItem(
                          '${days[idx]}\n${spot.y.toStringAsFixed(1)}%',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFF2F2F7),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 25,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}%',
                        style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
                        final idx = val.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              days[idx],
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF3A3A3C)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.32,
                    color: const Color(0xFF007AFF),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4.5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: const Color(0xFF007AFF),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF007AFF).withValues(alpha: 0.25),
                          const Color(0xFF007AFF).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ========================================================
/// RADAR / SPIDER CHART PARA CUMPLIMIENTO 5S Y AUDITORÍA
/// ========================================================
class Radar5SChartCard extends StatelessWidget {
  final Map<String, double> scores; // Calidad, Seguridad, 5S Piso, OEE, Disciplina (0-100)
  final void Function(String pillar, double score)? onPillarTap;

  const Radar5SChartCard({
    super.key,
    required this.scores,
    this.onPillarTap,
  });

  @override
  Widget build(BuildContext context) {
    final avgNum = scores.isNotEmpty
        ? (scores.values.reduce((a, b) => a + b) / scores.length)
        : 0.0;
    final avgScore = avgNum.toStringAsFixed(1);
    final avgColor = avgNum >= 80
        ? const Color(0xFF34C759)
        : (avgNum >= 50 ? const Color(0xFF007AFF) : (avgNum > 0 ? const Color(0xFFFF3B30) : const Color(0xFF64748B)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.radar_rounded, color: Color(0xFF007AFF), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Radar 5S & Disciplina',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                          ),
                          Text(
                            'Toca un pilar para ver detalle',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: avgColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: avgColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: avgColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Promedio: $avgScore%',
                      style: TextStyle(color: avgColor, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;

              final radarGraphic = SizedBox(
                height: 220,
                child: CustomPaint(
                  size: const Size(double.infinity, 220),
                  painter: _RadarChartPainter(scores),
                ),
              );

              final scorecard = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _scorecardRow('Calidad', scores['Calidad'] ?? 0.0, Icons.verified_outlined, const Color(0xFF007AFF), 'Inspecciones y tolerancias'),
                  const SizedBox(height: 8),
                  _scorecardRow('Seguridad', scores['Seguridad'] ?? 0.0, Icons.health_and_safety_rounded, const Color(0xFF34C759), 'EHS, EPP y guardas'),
                  const SizedBox(height: 8),
                  _scorecardRow('5S Piso', scores['5S Piso'] ?? 0.0, Icons.cleaning_services_rounded, const Color(0xFFFF9500), 'Rondas Gemba Walk reales'),
                  const SizedBox(height: 8),
                  _scorecardRow('OEE', scores['OEE'] ?? 0.0, Icons.precision_manufacturing_rounded, const Color(0xFFAF52DE), 'Estándares fijos de línea'),
                  const SizedBox(height: 8),
                  _scorecardRow('Disciplina', scores['Disciplina'] ?? 0.0, Icons.timer_outlined, const Color(0xFF002F6C), 'Cumplimiento global real'),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: radarGraphic),
                    const SizedBox(width: 20),
                    Expanded(flex: 6, child: scorecard),
                  ],
                );
              }

              return Column(
                children: [
                  radarGraphic,
                  const SizedBox(height: 16),
                  scorecard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _scorecardRow(String name, double val, IconData icon, Color color, String desc) {
    final intVal = val.round();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPillarTap == null ? null : () => onPillarTap!(name, val),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5EA)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                    Text(desc, style: const TextStyle(fontSize: 10, color: Color(0xFF86868B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$intVal%',
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> scores;

  _RadarChartPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 30;
    final keys = scores.keys.toList();
    final count = keys.length;
    if (count == 0) return;

    final webPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final webBgPaint = Paint()
      ..color = const Color(0xFFF8FAFC).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Anillos concéntricos poligonales (20%, 40%, 60%, 80%, 100%)
    for (int ring = 5; ring >= 1; ring--) {
      final r = radius * (ring / 5);
      final ringPath = Path();
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * math.pi / count) - (math.pi / 2);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      if (ring == 5) canvas.drawPath(ringPath, webBgPaint);
      canvas.drawPath(ringPath, webPaint);
    }

    // Ejes radiales y etiquetas
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), webPaint);

      final val = (scores[keys[i]] ?? 0.0).toInt();
      final labelOffset = Offset(
        center.dx + (radius + 18) * math.cos(angle),
        center.dy + (radius + 18) * math.sin(angle),
      );
      textPainter.text = TextSpan(
        children: [
          TextSpan(text: '${keys[i]}\n', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          TextSpan(text: '$val%', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
        ],
      );
      textPainter.textAlign = TextAlign.center;
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelOffset.dx - textPainter.width / 2, labelOffset.dy - textPainter.height / 2),
      );
    }

    // Polígono de datos
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF002F6C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pointPaint = Paint()
      ..color = const Color(0xFF002F6C)
      ..style = PaintingStyle.fill;
    final pointInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final points = <Offset>[];

    for (int i = 0; i < count; i++) {
      final val = (scores[keys[i]] ?? 0.0) / 100.0;
      final r = radius * val.clamp(0.0, 1.0);
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      points.add(Offset(x, y));
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Dibujar vértices destacados
    for (final pt in points) {
      canvas.drawCircle(pt, 5.0, pointPaint);
      canvas.drawCircle(pt, 2.5, pointInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ========================================================
/// GRÁFICA DE DONA / PIE CHART: CRITICIDAD DE ACTIVIDADES
/// ========================================================
class CriticalityPieChartCard extends StatelessWidget {
  final int alta;
  final int media;
  final int baja;
  final void Function(String criticality)? onSegmentTap;

  const CriticalityPieChartCard({
    super.key,
    required this.alta,
    required this.media,
    required this.baja,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = (alta + media + baja).clamp(1, 9999);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002F6C).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pie_chart_rounded, color: Color(0xFF002F6C), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESGLOSE POR CRITICIDAD',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF002F6C), letterSpacing: 0.3),
                      ),
                      Text(
                        'Distribución de riesgo en planta',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF002F6C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF002F6C).withValues(alpha: 0.2)),
                ),
                child: Text(
                  '$total Actividades',
                  style: const TextStyle(color: Color(0xFF002F6C), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 480;

              final donutWidget = SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        sections: [
                          PieChartSectionData(
                            value: alta > 0 ? alta.toDouble() : 0.1,
                            color: const Color(0xFFDC2626),
                            radius: 26,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: media > 0 ? media.toDouble() : 0.1,
                            color: const Color(0xFFF59E0B),
                            radius: 26,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: baja > 0 ? baja.toDouble() : 0.1,
                            color: const Color(0xFF0284C7),
                            radius: 26,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF002F6C)),
                        ),
                        const Text(
                          'TOTAL',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final legendWidget = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onSegmentTap != null ? () => onSegmentTap!('ALTA') : null,
                    child: _legendCard('Crítica / Alta', alta, total, const Color(0xFFDC2626), 'Riesgo alto de paro o seguridad'),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onSegmentTap != null ? () => onSegmentTap!('MEDIA') : null,
                    child: _legendCard('Media', media, total, const Color(0xFFF59E0B), 'Control de calidad y tolerancias'),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onSegmentTap != null ? () => onSegmentTap!('BAJA') : null,
                    child: _legendCard('Baja / Estándar', baja, total, const Color(0xFF0284C7), 'Rutinas operativas estándar'),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    donutWidget,
                    const SizedBox(width: 20),
                    Expanded(child: legendWidget),
                  ],
                );
              }

              return Column(
                children: [
                  donutWidget,
                  const SizedBox(height: 16),
                  legendWidget,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _legendCard(String label, int count, int total, Color color, String subtitle) {
    final pct = ((count / total) * 100).toInt();
    final progress = (count / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count ($pct%)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// ========================================================
/// GRÁFICA DE DONA / ESTADO DE EJECUCIÓN OPERATIVA
/// ========================================================
class TaskStatusDoughnutCard extends StatelessWidget {
  final int completadas;
  final int pendientes;
  final int vencidas;
  final String title;
  final String subtitle;
  final void Function(String status)? onSegmentTap;

  const TaskStatusDoughnutCard({
    super.key,
    required this.completadas,
    required this.pendientes,
    required this.vencidas,
    this.title = 'ESTADO DE CUMPLIMIENTO OPERATIVO',
    this.subtitle = 'Distribución del ciclo de turnos actual',
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = (completadas + pendientes + vencidas).clamp(1, 9999);
    final compPct = ((completadas / total) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002F6C).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
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
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$compPct% Cumplido',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 28,
                        sections: [
                          PieChartSectionData(
                            value: completadas.toDouble(),
                            color: const Color(0xFF16A34A),
                            radius: 26,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: pendientes.toDouble(),
                            color: const Color(0xFF0284C7),
                            radius: 26,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: vencidas.toDouble(),
                            color: const Color(0xFFDC2626),
                            radius: 26,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$compPct%',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                        ),
                        const Text(
                          'GLOBAL',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onSegmentTap != null ? () => onSegmentTap!('COMPLETADA') : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: _legendRow('Completadas', completadas, total, const Color(0xFF16A34A)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onSegmentTap != null ? () => onSegmentTap!('PENDIENTE') : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: _legendRow('En Progreso / Pendientes', pendientes, total, const Color(0xFF0284C7)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onSegmentTap != null ? () => onSegmentTap!('VENCIDA') : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: _legendRow('Vencidas / Novedad', vencidas, total, const Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String label, int count, int total, Color color) {
    final pct = ((count / total) * 100).toInt();
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
        ),
        Text(
          '$count ($pct%)',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

/// ========================================================
/// TARJETA COMPARATIVA: ANTES VS DESPUÉS (FOTO MODELO VS EVIDENCIA)
/// ========================================================
class VisualStandardComparisonDialog extends StatelessWidget {
  final String standardTitle;
  final String standardDesc;
  final String modelPhotoPath;
  final String operatorPhotoPath;
  final String operatorName;
  final VoidCallback onApprove;
  final Function(String) onReject;

  const VisualStandardComparisonDialog({
    super.key,
    required this.standardTitle,
    required this.standardDesc,
    required this.modelPhotoPath,
    required this.operatorPhotoPath,
    required this.operatorName,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final rejectCtrl = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.compare_rounded, color: Color(0xFF002F6C), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Comparación de Calidad',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                standardTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              Text(
                'Criterio 5S: $standardDesc',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⭐ FOTO MODELO (SUPERVISOR)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              modelPhotoPath.isNotEmpty ? modelPhotoPath : 'assets/images/standard_work_fondo.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '📸 EVIDENCIA ($operatorName)'.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              operatorPhotoPath.isNotEmpty ? operatorPhotoPath : 'assets/images/darnel_planta.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rejectCtrl,
                decoration: InputDecoration(
                  labelText: 'Observación Técnica (Requerida en caso de Rechazo)',
                  hintText: 'Ej. Falta retirar residuo plástico en la base del rodillo',
                  labelStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 18),
                      label: const Text('Rechazar', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (rejectCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Escribe el motivo del rechazo para guiar al operador')),
                          );
                          return;
                        }
                        onReject(rejectCtrl.text.trim());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      label: const Text('Aprobar 100%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        onApprove();
                        Navigator.pop(context);
                      },
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

/// ========================================================
/// GRÁFICA DE BARRAS: CUMPLIMIENTO SEMANAL DETALLADO (LUN-VIE)
/// ========================================================
class WeeklyComplianceBarChartCard extends StatelessWidget {
  final List<double> dailyPercentages; // 5 values for Mon-Fri
  final String title;
  final String subtitle;

  const WeeklyComplianceBarChartCard({
    super.key,
    required this.dailyPercentages,
    this.title = 'Cumplimiento por Jornada Semanal',
    this.subtitle = 'Comparativo de efectividad de Lunes a Viernes',
  });

  @override
  Widget build(BuildContext context) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002F6C).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF002F6C), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF002F6C), letterSpacing: 0.3),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flag_rounded, color: Color(0xFF002F6C), size: 12),
                    SizedBox(width: 4),
                    Text('Meta: 95%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002F6C))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0F172A),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${days[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)}%',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[idx],
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: val == 95 ? const Color(0xFFDC2626).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                    strokeWidth: val == 95 ? 1.5 : 1.0,
                    dashArray: val == 95 ? [4, 4] : null,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(5, (i) {
                  final val = i < dailyPercentages.length ? dailyPercentages[i] : 90.0;
                  final isAboveMeta = val >= 95.0;
                  final color = isAboveMeta
                      ? const Color(0xFF16A34A)
                      : val >= 85.0
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFF59E0B);

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val.clamp(0.0, 100.0),
                        color: color,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: const Color(0xFFF1F5F9),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF16A34A), '≥ 95% Meta Cumplida'),
              const SizedBox(width: 14),
              _legendDot(const Color(0xFF0284C7), '85-94% En Rango'),
              const SizedBox(width: 14),
              _legendDot(const Color(0xFFF59E0B), '< 85% Novedad'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// ========================================================
/// TABLERO DE RANKING Y RENDIMIENTO DE EQUIPO
/// ========================================================
class TeamPerformanceRankingCard extends StatelessWidget {
  final List<Map<String, dynamic>> performers;

  const TeamPerformanceRankingCard({
    super.key,
    required this.performers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002F6C).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.military_tech_rounded, color: Color(0xFF002F6C), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESEMPEÑO DEL EQUIPO EN PISO',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF002F6C), letterSpacing: 0.3),
                      ),
                      Text(
                        'Cumplimiento de estándares de trabajo por colaborador',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Top Planta', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: performers.take(4).length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = performers[i];
              final name = p['name'] as String? ?? 'Colaborador';
              final role = p['role'] as String? ?? 'Operador';
              final pct = (p['compliance'] as num? ?? 95.0).toDouble();
              final done = (p['done'] as int? ?? 10);
              final total = (p['total'] as int? ?? 10);

              final medals = ['🥇', '🥈', '🥉', '⭐'];
              final medal = i < medals.length ? medals[i] : '•';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(medal, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          Text('$role · $done de $total tareas', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (pct / 100.0).clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                pct >= 95 ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (pct >= 95 ? const Color(0xFF16A34A) : const Color(0xFF0284C7)).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: pct >= 95 ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
