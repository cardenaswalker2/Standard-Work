import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/services/standard_work_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isGeneratingCsv = false;
  bool _isGeneratingPdf = false;
  bool _isGeneratingExcelCsv = false;

  /// Helper para escapar celdas CSV garantizando compatibilidad con Excel en español
  String _csvEscape(dynamic value) {
    if (value == null) return '""';
    final str = value.toString().replaceAll('"', '""');
    return '"$str"';
  }

  Future<void> _exportExcelScheduleCSV() async {
    setState(() => _isGeneratingExcelCsv = true);
    final provider = context.read<StandardWorkProvider>();
    final activities = provider.excelActivities;

    try {
      final StringBuffer csv = StringBuffer();
      // Byte Order Mark (BOM) UTF-8 (\uFEFF) para que Excel abra sin corromper tildes
      csv.write('\uFEFF');
      
      // Separador oficial punto y coma (;) para Excel regional español
      csv.writeln('Standard Work - Darnel Group - Programacion 4 Semanas;;;;;;;;;;;;');
      csv.writeln('Archivo de Origen;ST - WR YONNY LOPEZ.xlsb;;;;;;;;;;;');
      csv.writeln('Responsable;Yonny López (Jefe de Planta / Operaciones Extrusa);;;;;;;;;;;');
      csv.writeln('Área;Planta Extrusa;;;;;;;;;;;');
      csv.writeln('Total Actividades Programadas;${activities.length};;;;;;;;;;;');
      csv.writeln('Fecha de Generación;${DateTime.now().toString().substring(0, 19)};;;;;;;;;;;');
      csv.writeln(';;;;;;;;;;;;');
      csv.writeln('ID;Semana;Día;Nombre Día;Hora Inicio;Hora Fin;Duración (min);Actividad;Categoría;Fija;Hoja Excel;Celda Excel;Nombre Original');

      for (final a in activities) {
        final fijaStr = a.isFixed ? 'SÍ' : 'NO';
        csv.writeln(
          '${a.id};'
          '${a.weekNumber};'
          '${a.dayOfWeek};'
          '${_csvEscape(a.dayName)};'
          '${_csvEscape(a.timeStart)};'
          '${_csvEscape(a.timeEnd)};'
          '${a.durationMinutes};'
          '${_csvEscape(a.activityName)};'
          '${_csvEscape(a.category)};'
          '${_csvEscape(fijaStr)};'
          '${_csvEscape(a.excelSheet)};'
          '${_csvEscape(a.excelCell)};'
          '${_csvEscape(a.originalName)}'
        );
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Programacion_4_Semanas_Yonny_Lopez.csv');
      await file.writeAsString(csv.toString());

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Programación 4 Semanas ST - WR YONNY LOPEZ · Darnel Group (Excel CSV UTF-8)',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar CSV de 4 semanas: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingExcelCsv = false);
    }
  }

  Future<void> _exportCSV() async {
    setState(() => _isGeneratingCsv = true);
    final provider = context.read<StandardWorkProvider>();
    final user = provider.currentProfile;
    final instances = provider.instances;

    try {
      final StringBuffer csv = StringBuffer();
      // Byte Order Mark (BOM) UTF-8 (\uFEFF)
      csv.write('\uFEFF');

      // Metadatos y encabezados con delimitador punto y coma
      csv.writeln('Standard Work - Darnel Group - Matriz de Seguimiento Semanal;;;;;;;;;;');
      csv.writeln('Usuario;${user?.nombre ?? ""};;;;;;;;;');
      csv.writeln('Cargo;${user?.cargo ?? ""};;;;;;;;;');
      csv.writeln('Área;${user?.area ?? ""};;;;;;;;;');
      csv.writeln('Semana Evaluada;${provider.currentWeekKey};;;;;;;;;');
      csv.writeln('Fecha de Generación;${DateTime.now().toString().substring(0, 19)};;;;;;;;;');
      csv.writeln(';;;;;;;;;;');
      csv.writeln('ID;Día Num;Día Nombre;Actividad;Área;Categoría;Horario;Tipo;Estado;Fecha Ejecución;Observaciones;Motivo Incumplimiento');

      for (final i in instances) {
        final diaNombre = DateUtilsHelper.diasCompletos[i.day - 1];
        final tipo = i.fija ? 'Fija Obligatoria' : 'Ordinaria';
        final estado = i.done ? 'Realizada' : 'Pendiente';
        final fechaCompletado = i.completedAt != null ? i.completedAt.toString().substring(0, 19) : 'No completada';
        final horario = '${i.timeStart} - ${i.timeEnd}';

        csv.writeln(
          '${i.id};'
          '${i.day};'
          '${_csvEscape(diaNombre)};'
          '${_csvEscape(i.nombre)};'
          '${_csvEscape(i.area.isNotEmpty ? i.area : (user?.area ?? "Planta"))};'
          '${_csvEscape(i.category)};'
          '${_csvEscape(horario)};'
          '${_csvEscape(tipo)};'
          '${_csvEscape(estado)};'
          '${_csvEscape(fechaCompletado)};'
          '${_csvEscape(i.observaciones ?? "")};'
          '${_csvEscape(i.motivoNoRealizada ?? "")}'
        );
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Reporte_Standard_Work_${provider.currentWeekKey}.csv');
      await file.writeAsString(csv.toString());

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Reporte de Cumplimiento Standard Work · Darnel Group (Excel CSV UTF-8)',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar CSV: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingCsv = false);
    }
  }

  Future<void> _exportPDF() async {
    setState(() => _isGeneratingPdf = true);
    final provider = context.read<StandardWorkProvider>();
    final user = provider.currentProfile;
    final instances = provider.instances;

    try {
      final pdf = pw.Document();

      final int totalEvaluables = instances.where((i) => i.day <= provider.hoy).length;
      final int realizadas = instances.where((i) => i.done).length;
      final int pendientes = instances.where((i) => !i.done && i.day <= provider.hoy).length;
      final int noRealizadasConMotivo = instances.where((i) => !i.done && i.motivoNoRealizada != null && i.motivoNoRealizada!.isNotEmpty).length;
      final int programadasFuturas = instances.where((i) => i.day > provider.hoy).length;

      final double cumplimiento = totalEvaluables > 0 ? ((realizadas / totalEvaluables) * 100) : 0.0;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          header: (pw.Context ctx) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.only(bottom: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('002F6C'), width: 1.5)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'DARNEL GROUP · STANDARD WORK OPERATIVO',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('002F6C'),
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                    style: pw.TextStyle(color: PdfColor.fromHex('64748B'), fontSize: 9),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context ctx) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 12),
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('E2E8F0'), width: 1)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Documento generado localmente · Base SQLite · Sin datos ficticios',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('64748B'), fontStyle: pw.FontStyle.italic),
                  ),
                  pw.Text(
                    'Semana: ${provider.currentWeekKey} | Fecha: ${DateTime.now().toString().substring(0, 16)}',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('64748B')),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context ctx) {
            return [
              // Encabezado Principal Corporativo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORME EJECUTIVO DE CUMPLIMIENTO',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('002F6C'),
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Auditoría y Adherencia de Trabajo Estándar Industrial',
                        style: pw.TextStyle(color: PdfColor.fromHex('64748B'), fontSize: 11),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('002F6C'),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'SEMANA ${provider.currentWeekKey}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // Panel de Datos del Perfil y Métricas
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColor.fromHex('CBD5E1')),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Responsable: ${user?.nombre ?? "Yonny López"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.SizedBox(height: 3),
                          pw.Text('Cargo: ${user?.cargo ?? "Jefe de Planta"}', style: const pw.TextStyle(fontSize: 9.5)),
                          pw.Text('Área: ${user?.area ?? "Planta Extrusa"}', style: const pw.TextStyle(fontSize: 9.5)),
                          pw.Text('Fecha Emisión: ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 9.5)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: cumplimiento >= 80 ? PdfColor.fromHex('ECFDF3') : PdfColor.fromHex('FEF2F2'),
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(
                            color: cumplimiento >= 80 ? PdfColor.fromHex('16A34A') : PdfColor.fromHex('DC2626'),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              '${cumplimiento.round()}%',
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: cumplimiento >= 80 ? PdfColor.fromHex('16A34A') : PdfColor.fromHex('DC2626'),
                              ),
                            ),
                            pw.Text('Cumplimiento Real', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '$realizadas de $totalEvaluables evaluables',
                              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // Resumen de Indicadores
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('E2E8F0')), borderRadius: pw.BorderRadius.circular(6)),
                      child: pw.Column(
                        children: [
                          pw.Text('$realizadas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColor.fromHex('16A34A'))),
                          pw.Text('Ejecutadas', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('E2E8F0')), borderRadius: pw.BorderRadius.circular(6)),
                      child: pw.Column(
                        children: [
                          pw.Text('$pendientes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColor.fromHex('DC2626'))),
                          pw.Text('Pendientes', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('E2E8F0')), borderRadius: pw.BorderRadius.circular(6)),
                      child: pw.Column(
                        children: [
                          pw.Text('$noRealizadasConMotivo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColor.fromHex('EA580C'))),
                          pw.Text('Con Incidencias', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('E2E8F0')), borderRadius: pw.BorderRadius.circular(6)),
                      child: pw.Column(
                        children: [
                          pw.Text('$programadasFuturas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColor.fromHex('0284C7'))),
                          pw.Text('Programadas', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Text('Detalle Tabular de Actividades Evaluadas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColor.fromHex('002F6C'))),
              pw.SizedBox(height: 8),

              // Tabla de Actividades con saltos limpios y encabezado repetido
              pw.TableHelper.fromTextArray(
                headers: ['Día', 'Horario', 'Actividad', 'Área / Cat', 'Estado', 'Incidencias / Observaciones'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('002F6C')),
                cellStyle: const pw.TextStyle(fontSize: 7.5),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FixedColumnWidth(55),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FixedColumnWidth(45),
                  5: const pw.FlexColumnWidth(2.5),
                },
                data: instances.map((item) {
                  final dia = DateUtilsHelper.diasCortos[item.day - 1];
                  final st = item.done ? 'Realizada' : 'Pendiente';
                  final areaCat = '${item.area.isNotEmpty ? item.area : (user?.area ?? "Planta")}\n${item.category}';
                  final horario = '${item.timeStart} - ${item.timeEnd}';
                  final notas = item.observaciones != null && item.observaciones!.isNotEmpty
                      ? 'Obs: ${item.observaciones}'
                      : (item.motivoNoRealizada != null && item.motivoNoRealizada!.isNotEmpty
                          ? 'Motivo: ${item.motivoNoRealizada}'
                          : '-');
                  return [dia, horario, item.nombre, areaCat, st, notas];
                }).toList(),
              ),
            ];
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Reporte_Standard_Work_${provider.currentWeekKey}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Informe Gerencial PDF Standard Work · Darnel Group',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final user = provider.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Cumplimiento'),
        backgroundColor: AppColors.azul,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tarjeta Reporte PDF Oficial
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.rojo, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Informe Oficial en PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Formato gerencial · ${user?.nombre}', style: const TextStyle(fontSize: 12, color: AppColors.gris)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Genera un documento PDF corporativo con logotipo, datos de la línea/área, tabla estructurada de adherencia operativa de Lunes a Viernes y observaciones de planta.',
                      style: TextStyle(fontSize: 13, color: AppColors.txt),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isGeneratingPdf
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(_isGeneratingPdf ? 'Generando PDF...' : 'Generar y Compartir PDF'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.azul),
                        onPressed: _isGeneratingPdf ? null : _exportPDF,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Tarjeta Reporte CSV para Excel con BOM y Delimitador punto y coma
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.table_chart_outlined, color: AppColors.verde, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Matriz Tabular en CSV (Compatible con Excel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Semana: ${provider.currentWeekKey} · UTF-8 con BOM y delimitador ;', style: const TextStyle(fontSize: 12, color: AppColors.gris)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Exporta el consolidado semanal en formato plano con codificación UTF-8 con BOM y punto y coma (;), abriendo directamente en Excel con columnas y acentos perfectos.',
                      style: TextStyle(fontSize: 13, color: AppColors.txt),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isGeneratingCsv
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.download_for_offline_outlined),
                        label: Text(_isGeneratingCsv ? 'Generando CSV...' : 'Generar y Compartir CSV para Excel'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde),
                        onPressed: _isGeneratingCsv ? null : _exportCSV,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Tarjeta Exportación de Programación Completa de 4 Semanas del Excel
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.view_week_outlined, color: AppColors.azul, size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Programación 4 Semanas · ST - WR YONNY LOPEZ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Fuente: ST - WR YONNY LOPEZ.xlsb · 270 registros', style: TextStyle(fontSize: 12, color: AppColors.gris)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Exporta todas las 270 actividades estructuradas de las 4 semanas con franjas horarias exactas, categorías, celdas de origen y trazabilidad completa.',
                      style: TextStyle(fontSize: 13, color: AppColors.txt),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isGeneratingExcelCsv
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.table_view_outlined),
                        label: Text(_isGeneratingExcelCsv ? 'Exportando...' : 'Exportar 4 Semanas a CSV (Excel UTF-8)'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.azul),
                        onPressed: _isGeneratingExcelCsv ? null : _exportExcelScheduleCSV,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
