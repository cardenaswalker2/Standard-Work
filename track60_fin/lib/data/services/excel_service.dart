import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/app_models.dart';

class ExcelService {
  static final ExcelService instance = ExcelService._init();
  ExcelService._init();

  /// Genera un dump consolidado en formato CSV de todas las tablas empresariales
  Future<String> generateConsolidatedCsv() async {
    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers();
    final plants = await dbHelper.getAllPlants();
    final activities = await dbHelper.getAllActivities();
    final auditLogs = await dbHelper.getAuditLogs();

    final StringBuffer buffer = StringBuffer();

    // 1. Plantas
    buffer.writeln('=== PLANTAS ===');
    buffer.writeln('ID,Codigo,Nombre,Ubicacion,AdminID,Activa');
    for (final p in plants) {
      buffer.writeln('${p.id},"${p.codigo}","${p.nombre}","${p.ubicacion}","${p.adminId}",${p.activa ? 1 : 0}');
    }
    buffer.writeln();

    // 2. Usuarios y Roles
    buffer.writeln('=== USUARIOS Y ROLES ===');
    buffer.writeln('ID,Cedula,Nombre,Cargo,Area,Rol,PlantaID,Activo,PIN');
    for (final u in users) {
      buffer.writeln('${u.id},"${u.cedula}","${u.nombre}","${u.cargo}","${u.area}","${u.rol}","${u.plantId}",${u.activo ? 1 : 0},"${u.pin}"');
    }
    buffer.writeln();

    // 3. Catálogo de Actividades
    buffer.writeln('=== ACTIVIDADES MAESTRAS ===');
    buffer.writeln('ID,PlantaID,ResponsableID,Nombre,Descripcion,Area,Categoria,HoraInicio,HoraFin,EsFija,Dias,Prioridad,ReqFoto,ReqMedicion,ReqComentario');
    for (final a in activities) {
      buffer.writeln('${a.id},"${a.plantId}","${a.userId}","${a.nombre}","${a.descripcion}","${a.area}","${a.category}","${a.timeStart}","${a.timeEnd}",${a.fija ? 1 : 0},"${a.dias}","${a.prioridad}",${a.reqFoto ? 1 : 0},${a.reqMedicion ? 1 : 0},${a.reqComentario ? 1 : 0}');
    }
    buffer.writeln();

    // 4. Registro de Auditoría
    buffer.writeln('=== AUDITORIA Y TRAZABILIDAD ===');
    buffer.writeln('ID,UsuarioID,Accion,Entidad,EntidadID,Detalles,Timestamp');
    for (final log in auditLogs) {
      buffer.writeln('${log.id},"${log.userId}","${log.action}","${log.entity}",${log.entityId ?? ""},"${log.details.replaceAll('"', '""')}","${log.timestamp}"');
    }

    return buffer.toString();
  }

  /// Exporta el archivo consolidado a disco y abre el diálogo nativo para compartir/enviar
  Future<String> exportAndShare() async {
    final csvContent = await generateConsolidatedCsv();
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/track60_export_$timestamp.csv');
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TRACK60 V2 - Exportación de Datos Operativos',
      text: 'Reporte consolidado de datos operativos, plantas y actividades TRACK60.',
    );

    return file.path;
  }

  /// Exporta un reporte filtrado a la medida compatible con Excel (UTF-8 BOM) en Web y Móvil
  Future<void> exportFilteredReport({
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
    String q(String s) => '"${s.replaceAll('"', '""')}"';
    final buf = StringBuffer('\uFEFF');

    buf.writeln('GRUPO DARNEL - REPORTE EJECUTIVO TRACK60');
    buf.writeln('Filtros,${q(filterSummary)}');
    buf.writeln('Fecha,${q(DateTime.now().toString().substring(0, 16))}');
    buf.writeln();

    if (includeSummary) {
      final total = instances.length;
      final done = instances.where((i) => i.done).length;
      final pct = total > 0 ? ((done / total) * 100).toStringAsFixed(1) : '0.0';
      buf.writeln('=== RESUMEN EJECUTIVO ===');
      buf.writeln('Total Actividades,Completadas,Pendientes,Cumplimiento %,Planes de Accion');
      buf.writeln('$total,$done,${total - done},$pct%,${plans.length}');
      buf.writeln();
    }

    if (includeRanking && plants.isNotEmpty) {
      buf.writeln('=== RANKING POR PLANTA ===');
      buf.writeln('Planta,Codigo,Total Tareas,Completadas,Cumplimiento %');
      for (final p in plants) {
        final pInst = instances.where((i) => i.plantId == p.id).toList();
        final pDone = pInst.where((i) => i.done).length;
        final pPct = pInst.isNotEmpty ? ((pDone / pInst.length) * 100).toStringAsFixed(1) : '0.0';
        buf.writeln('${q(p.nombre)},${q(p.codigo)},${pInst.length},$pDone,$pPct%');
      }
      buf.writeln();
    }

    if (includeActivities) {
      buf.writeln('=== DETALLE DE ACTIVIDADES ===');
      buf.writeln(
        includeSubtasks
            ? 'Actividad,Planta,Area,Categoria,Responsable,Dia,Horario,Prioridad,Estado,Subtareas Completadas,Plan Obligatorio'
            : 'Actividad,Planta,Area,Categoria,Responsable,Dia,Horario,Prioridad,Estado,Plan Obligatorio',
      );
      const days = {1: 'Lun', 2: 'Mar', 3: 'Mie', 4: 'Jue', 5: 'Vie', 6: 'Sab'};
      for (final i in instances) {
        final resp = usersById[i.userId]?.nombre ?? i.userId;
        final status = i.done ? 'Completada' : 'Pendiente';
        final subDone = i.subtasksReported;
        final subTot = i.subtasksTotal;
        final base =
            '${q(i.nombre)},${q(i.plantId)},${q(i.area)},${q(i.category)},${q(resp)},${days[i.day] ?? i.day},${q("${i.timeStart}-${i.timeEnd}")},${q(i.prioridad)},$status';
        if (includeSubtasks) {
          buf.writeln('$base,"$subDone/$subTot",${i.planAccionObligatorio ? "Si" : "No"}');
        } else {
          buf.writeln('$base,${i.planAccionObligatorio ? "Si" : "No"}');
        }
      }
      buf.writeln();
    }

    if (includePlans) {
      buf.writeln('=== PLANES DE ACCION ===');
      buf.writeln('Titulo,Planta,Area,Responsable,Estado,Avance %,Fecha Compromiso');
      for (final pl in plans) {
        buf.writeln(
          '${q(pl.plan)},${q(pl.plantId)},${q(pl.area)},${q(pl.responsable)},${q(pl.estado)},${pl.porcentajeAvance.toStringAsFixed(0)}%,${q(pl.fechaCompromiso)}',
        );
      }
    }

    final bytes = Uint8List.fromList(utf8.encode(buf.toString()));
    final ts = DateTime.now().millisecondsSinceEpoch;
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: 'TRACK60_Reporte_$ts.csv', mimeType: 'text/csv')],
      subject: 'TRACK60 · Reporte Ejecutivo Excel',
      text: 'Reporte operativo generado desde Torre de Control Super Admin.',
    );
  }
}
