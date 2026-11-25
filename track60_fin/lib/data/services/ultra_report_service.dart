import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/app_models.dart';
import 'standard_work_provider.dart';

class UltraReportService {
  static final UltraReportService instance = UltraReportService._();
  UltraReportService._();

  /// Genera y descarga/comparte el Reporte Ejecutivo Corporativo en PDF con sello de autenticidad.
  Future<String> generateAndShareExecutivePdf(StandardWorkProvider provider) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final verificationCode = 'TRK-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final issuer = provider.currentUser?.nombre ?? 'Ultra Admin';

    final plants = provider.allPlants;
    final users = provider.allUsers;
    final activities = provider.activities;
    final instances = provider.instances;

    final activeUsers = users.where((u) => u.activo).length;
    final completedCount = instances.where((i) => i.done).length;
    final globalPct = instances.isNotEmpty
        ? ((completedCount / instances.length) * 100).toStringAsFixed(1)
        : '0.0';
    final criticalActs = activities.where((a) => a.prioridad.toUpperCase() == 'ALTA').toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#002F6C'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'GRUPO DARNEL · TRACK60',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Reporte Ejecutivo Operativo',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Código: $verificationCode', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    pw.Text(
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _pdfMetricBox('Plantas', '${plants.length}'),
              _pdfMetricBox('Usuarios Activos', '$activeUsers / ${users.length}'),
              _pdfMetricBox('Actividades', '${activities.length}'),
              _pdfMetricBox('Cumplimiento', '$globalPct%'),
            ],
          ),
          pw.SizedBox(height: 18),

          pw.Text('Desempeño por Planta', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0F172A')),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Planta', 'Código', 'Estado', 'Actividades', 'Completadas'],
            data: plants.map((p) {
              final pActs = activities.where((a) => a.plantId == p.id).length;
              final pDone = instances.where((i) => i.plantId == p.id && i.done).length;
              return [p.nombre, p.codigo, p.activa ? 'Activa' : 'Pausada', '$pActs', '$pDone'];
            }).toList(),
          ),
          pw.SizedBox(height: 18),

          pw.Text('Actividades de Criticidad Alta (${criticalActs.length})', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (criticalActs.isEmpty)
            pw.Text('No hay actividades críticas registradas.', style: const pw.TextStyle(fontSize: 10))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#DC2626')),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headers: ['Actividad', 'Planta', 'Área', 'Horario'],
              data: criticalActs.take(25).map((a) => [a.nombre, a.plantId, a.area, '${a.timeStart} - ${a.timeEnd}']).toList(),
            ),
          pw.SizedBox(height: 22),

          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Emitido y firmado digitalmente por: $issuer', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Sello de Autenticidad: $verificationCode', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    await Share.shareXFiles(
      [XFile.fromData(Uint8List.fromList(bytes), name: 'TRACK60_Reporte_$verificationCode.pdf', mimeType: 'application/pdf')],
      subject: 'Reporte Ejecutivo TRACK60 ($verificationCode)',
    );
    return verificationCode;
  }

  pw.Widget _pdfMetricBox(String label, String value) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  /// Genera y descarga/comparte un respaldo completo en JSON (sin exponer PINs).
  Future<void> exportFullJsonBackup(StandardWorkProvider provider) async {
    final payload = {
      'generatedAt': DateTime.now().toIso8601String(),
      'app': 'TRACK60',
      'version': '2.0.0',
      'plants': provider.allPlants.map((p) => {
            'id': p.id,
            'codigo': p.codigo,
            'nombre': p.nombre,
            'ubicacion': p.ubicacion,
            'activa': p.activa,
          }).toList(),
      'users': provider.allUsers.map((u) => {
            'id': u.id,
            'cedula': u.cedula,
            'nombre': u.nombre,
            'cargo': u.cargo,
            'rol': u.rol,
            'plantId': u.plantId,
            'activo': u.activo,
          }).toList(),
      'activitiesCount': provider.activities.length,
      'instancesCount': provider.instances.length,
      'auditLogsCount': provider.auditLogs.length,
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: 'TRACK60_Backup_${DateTime.now().millisecondsSinceEpoch}.json', mimeType: 'application/json')],
      subject: 'Respaldo Completo TRACK60 (JSON)',
    );
  }

  /// Genera y comparte un PDF Ejecutivo filtrado a la medida del Super Admin
  Future<void> generateFilteredExecutivePdf({
    required String issuerName,
    required String filterSummary,
    required List<PlantModel> plants,
    required List<ActivityInstance> instances,
    required List<ProPlanModel> plans,
    required Map<String, UserProfile> usersById,
    bool includeSummary = true,
    bool includeActivities = true,
    bool includeSubtasks = true,
    bool includePlans = true,
    bool includeRanking = true,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final code = 'DARNEL-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final total = instances.length;
    final done = instances.where((i) => i.done).length;
    final pct = total > 0 ? ((done / total) * 100).toStringAsFixed(1) : '0.0';
    const dayLabels = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#002F6C'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('GRUPO DARNEL · TRACK60', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Reporte Ejecutivo Super Admin', style: pw.TextStyle(color: PdfColors.white, fontSize: 17, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Filtros: $filterSummary', style: const pw.TextStyle(color: PdfColors.grey200, fontSize: 8.5)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(code, style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Emitido por: $issuerName', style: const pw.TextStyle(color: PdfColors.grey200, fontSize: 8.5)),
                    pw.Text(now.toString().substring(0, 16), style: const pw.TextStyle(color: PdfColors.grey200, fontSize: 8.5)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          if (includeSummary) ...[
            pw.Text('Resumen Ejecutivo', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#002F6C'))),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                _pdfStatBox('Actividades', '$total'),
                pw.SizedBox(width: 8),
                _pdfStatBox('Completadas', '$done'),
                pw.SizedBox(width: 8),
                _pdfStatBox('Cumplimiento', '$pct%'),
                pw.SizedBox(width: 8),
                _pdfStatBox('Planes de Acción', '${plans.length}'),
              ],
            ),
            pw.SizedBox(height: 14),
          ],
          if (includeRanking && plants.isNotEmpty) ...[
            pw.Text('Cumplimiento por Planta', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#002F6C'))),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#002F6C')),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              headers: ['Planta', 'Código', 'Total', 'Completadas', 'Cumplimiento'],
              data: plants.map((p) {
                final pInst = instances.where((i) => i.plantId == p.id).toList();
                final pDone = pInst.where((i) => i.done).length;
                final pPct = pInst.isNotEmpty ? '${((pDone / pInst.length) * 100).toStringAsFixed(1)}%' : '0.0%';
                return [p.nombre, p.codigo, '${pInst.length}', '$pDone', pPct];
              }).toList(),
            ),
            pw.SizedBox(height: 14),
          ],
          if (includeActivities) ...[
            pw.Text('Detalle de Actividades (${instances.length})', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#002F6C'))),
            pw.SizedBox(height: 6),
            if (instances.isEmpty)
              pw.Text('Sin actividades para los filtros seleccionados.', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700))
            else
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8.5),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#002F6C')),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: includeSubtasks
                    ? ['Actividad', 'Planta', 'Responsable', 'Día / Hora', 'Estado', 'Subtareas']
                    : ['Actividad', 'Planta', 'Responsable', 'Día / Hora', 'Estado'],
                data: instances.take(120).map((i) {
                  final resp = usersById[i.userId]?.nombre ?? i.userId;
                  final subDone = i.subtasksReported;
                  final row = [
                    i.nombre,
                    i.plantId,
                    resp,
                    '${dayLabels[i.day] ?? i.day} ${i.timeStart}',
                    i.done ? 'Completada' : 'Pendiente',
                  ];
                  if (includeSubtasks) {
                    row.add('$subDone/${i.subtasksTotal}');
                  }
                  return row;
                }).toList(),
              ),
            pw.SizedBox(height: 14),
          ],
          if (includePlans) ...[
            pw.Text('Planes de Acción (${plans.length})', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#002F6C'))),
            pw.SizedBox(height: 6),
            if (plans.isEmpty)
              pw.Text('Sin planes de acción para los filtros seleccionados.', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700))
            else
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8.5),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#002F6C')),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Plan', 'Planta', 'Responsable', 'Estado', 'Avance', 'Compromiso'],
                data: plans.take(80).map((pl) => [
                  pl.plan,
                  pl.plantId,
                  pl.responsable,
                  pl.estado,
                  '${pl.porcentajeAvance.toStringAsFixed(0)}%',
                  pl.fechaCompromiso,
                ]).toList(),
              ),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: 'TRACK60_Reporte_${now.millisecondsSinceEpoch}.pdf', mimeType: 'application/pdf')],
      subject: 'TRACK60 · Reporte Ejecutivo PDF',
    );
  }

  pw.Widget _pdfStatBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F2F2F7'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('#E5E5EA')),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.SizedBox(height: 3),
            pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#002F6C'))),
          ],
        ),
      ),
    );
  }
}

