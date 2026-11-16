import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

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
}
