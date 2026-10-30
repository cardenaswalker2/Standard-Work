/// Modelo estructurado para actividades importadas directamente desde ST - WR YONNY LOPEZ.xlsb
class ExcelScheduleActivity {
  final int id;
  final int weekNumber; // 1, 2, 3, 4
  final int dayOfWeek; // 1: Lunes, 2: Martes, 3: Miércoles, 4: Jueves, 5: Viernes
  final String dayName;
  final String timeStart; // "07:00"
  final String timeEnd; // "07:30"
  final int durationMinutes;
  final String activityName;
  final String originalName;
  final String category;
  final bool isFixed;
  final String excelSheet;
  final int excelRow;
  final int excelCol;
  final String excelCell;

  const ExcelScheduleActivity({
    required this.id,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.dayName,
    required this.timeStart,
    required this.timeEnd,
    required this.durationMinutes,
    required this.activityName,
    required this.originalName,
    required this.category,
    required this.isFixed,
    required this.excelSheet,
    required this.excelRow,
    required this.excelCol,
    required this.excelCell,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekNumber': weekNumber,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'durationMinutes': durationMinutes,
      'activityName': activityName,
      'originalName': originalName,
      'category': category,
      'isFixed': isFixed ? 1 : 0,
      'excelSheet': excelSheet,
      'excelRow': excelRow,
      'excelCol': excelCol,
      'excelCell': excelCell,
    };
  }

  factory ExcelScheduleActivity.fromMap(Map<String, dynamic> map) {
    return ExcelScheduleActivity(
      id: map['id'] as int,
      weekNumber: map['weekNumber'] as int,
      dayOfWeek: map['dayOfWeek'] as int,
      dayName: map['dayName'] as String,
      timeStart: map['timeStart'] as String,
      timeEnd: map['timeEnd'] as String,
      durationMinutes: map['durationMinutes'] as int? ?? 30,
      activityName: map['activityName'] as String,
      originalName: map['originalName'] as String? ?? map['activityName'] as String,
      category: map['category'] as String? ?? 'General',
      isFixed: (map['isFixed'] is int) ? (map['isFixed'] as int) == 1 : (map['isFixed'] as bool? ?? false),
      excelSheet: map['excelSheet'] as String? ?? 'Weekly Review',
      excelRow: map['excelRow'] as int? ?? 0,
      excelCol: map['excelCol'] as int? ?? 0,
      excelCell: map['excelCell'] as String? ?? '',
    );
  }
}

/// Tarea de seguimiento extraída de la hoja 'Actividades'
class FollowupTask {
  final int id;
  final String tema;
  final String area;
  final String responsable;
  final String seguimiento;
  final String excelSheet;
  final int excelRow;

  const FollowupTask({
    required this.id,
    required this.tema,
    required this.area,
    required this.responsable,
    required this.seguimiento,
    required this.excelSheet,
    required this.excelRow,
  });

  factory FollowupTask.fromMap(Map<String, dynamic> map) {
    return FollowupTask(
      id: map['id'] as int,
      tema: map['tema'] as String? ?? '',
      area: map['area'] as String? ?? '',
      responsable: map['responsable'] as String? ?? '',
      seguimiento: map['seguimiento'] as String? ?? '',
      excelSheet: map['excelSheet'] as String? ?? 'Actividades',
      excelRow: map['excelRow'] as int? ?? 0,
    );
  }
}

/// Distribución de tiempos por categoría oficial
class CategoryDistribution {
  final String categoria;
  final int porcentaje;
  final String colorHex;

  const CategoryDistribution({
    required this.categoria,
    required this.porcentaje,
    required this.colorHex,
  });

  factory CategoryDistribution.fromMap(Map<String, dynamic> map) {
    return CategoryDistribution(
      categoria: map['categoria'] as String,
      porcentaje: map['porcentaje'] as int,
      colorHex: map['colorHex'] as String,
    );
  }
}
