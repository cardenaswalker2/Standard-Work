import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class ProPlanesExcelService {
  ProPlanesExcelService._();
  static final ProPlanesExcelService instance = ProPlanesExcelService._();

  /// Exporta los ProPlanes a un archivo CSV estructurado idéntico al Excel de SharePoint y lo comparte
  Future<File> exportAndShareProPlanes({String? plantId}) async {
    final plans = await DatabaseHelper.instance.getProPlans(plantId: plantId);

    final sb = StringBuffer();
    // Cabecera exacta solicitada
    sb.writeln('ID;Plan/Compromiso;Responsable;Area;FechaCompromiso;Estado;Evidencia;Comentarios;Planta');

    for (final p in plans) {
      final planEscaped = p.plan.replaceAll(';', ',').replaceAll('\n', ' ');
      final respEscaped = p.responsable.replaceAll(';', ',');
      final areaEscaped = p.area.replaceAll(';', ',');
      final comEscaped = (p.comentarios ?? '').replaceAll(';', ',').replaceAll('\n', ' ');
      final evidEscaped = (p.evidencia ?? '').replaceAll(';', ',');

      sb.writeln('${p.id ?? 0};$planEscaped;$respEscaped;$areaEscaped;${p.fechaCompromiso};${p.estado};$evidEscaped;$comEscaped;${p.plantId}');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/proplanes_export.csv');
    await file.writeAsString(sb.toString(), encoding: SystemEncoding());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Reporte Oficial PROPLANES · Grupo Darnel',
      text: 'Adjunto se envía el reporte consolidado de compromisos operativos y planes de acción PROPLANES.',
    );

    return file;
  }
}
