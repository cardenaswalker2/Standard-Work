import 'dart:convert';

/// Perfil operativo de Darnel Group
class UserProfile {
  final String id; // 'X', 'Y', 'Z'
  final String nombre;
  final String cargo;
  final String area;
  final String iniciales;

  const UserProfile({
    required this.id,
    required this.nombre,
    required this.cargo,
    required this.area,
    required this.iniciales,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cargo': cargo,
      'area': area,
      'iniciales': iniciales,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      cargo: map['cargo'] as String,
      area: map['area'] as String,
      iniciales: map['iniciales'] as String,
    );
  }
}

/// Definición de una Actividad en el sistema
class ActivityModel {
  final int? id;
  final String userId;
  final String nombre;
  final String descripcion;
  final String dias; // JSON string con lista de días [1,2,3,4,5]
  final bool fija; // Obligatoria e inamovible (Visual Room, Gemba)
  final String area;
  final String category;
  final String timeStart;
  final String timeEnd;
  final bool activa; // Para borrado lógico / archivo

  const ActivityModel({
    this.id,
    required this.userId,
    required this.nombre,
    required this.descripcion,
    required this.dias,
    this.fija = false,
    required this.area,
    this.category = 'General',
    this.timeStart = '08:00',
    this.timeEnd = '08:30',
    this.activa = true,
  });

  List<int> get diasList {
    try {
      final decoded = jsonDecode(dias);
      if (decoded is List) {
        return decoded.map((e) => (e as num).toInt()).toList();
      }
    } catch (_) {}
    return [1];
  }

  ActivityModel copyWith({
    int? id,
    String? userId,
    String? nombre,
    String? descripcion,
    String? dias,
    bool? fija,
    String? area,
    String? category,
    String? timeStart,
    String? timeEnd,
    bool? activa,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      dias: dias ?? this.dias,
      fija: fija ?? this.fija,
      area: area ?? this.area,
      category: category ?? this.category,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      activa: activa ?? this.activa,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'nombre': nombre,
      'descripcion': descripcion,
      'dias': dias,
      'fija': fija ? 1 : 0,
      'area': area,
      'category': category,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'activa': activa ? 1 : 0,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      dias: map['dias'] as String,
      fija: (map['fija'] as int) == 1,
      area: map['area'] as String? ?? 'General',
      category: map['category'] as String? ?? 'General',
      timeStart: map['timeStart'] as String? ?? '08:00',
      timeEnd: map['timeEnd'] as String? ?? '08:30',
      activa: (map['activa'] as int? ?? 1) == 1,
    );
  }
}

/// Instancia de ejecución de una actividad en una semana y día específicos
class ActivityInstance {
  final int? id;
  final int activityId;
  final String userId;
  final String weekKey; // ej. "2026-W44"
  final String nombre;
  final String descripcion;
  final String area;
  final String category;
  final String timeStart;
  final String timeEnd;
  final int day; // Día asignado actual (1: Lunes, ..., 5: Viernes)
  final int orig; // Día original de la semana
  final bool fija;
  final bool done;
  final DateTime? completedAt;
  final String? observaciones;
  final String? motivoNoRealizada;

  const ActivityInstance({
    this.id,
    required this.activityId,
    required this.userId,
    required this.weekKey,
    required this.nombre,
    required this.descripcion,
    this.area = 'General',
    this.category = 'General',
    this.timeStart = '08:00',
    this.timeEnd = '08:30',
    required this.day,
    required this.orig,
    required this.fija,
    this.done = false,
    this.completedAt,
    this.observaciones,
    this.motivoNoRealizada,
  });

  ActivityInstance copyWith({
    int? id,
    int? activityId,
    String? userId,
    String? weekKey,
    String? nombre,
    String? descripcion,
    String? area,
    String? category,
    String? timeStart,
    String? timeEnd,
    int? day,
    int? orig,
    bool? fija,
    bool? done,
    DateTime? completedAt,
    String? observaciones,
    String? motivoNoRealizada,
  }) {
    return ActivityInstance(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      weekKey: weekKey ?? this.weekKey,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      area: area ?? this.area,
      category: category ?? this.category,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      day: day ?? this.day,
      orig: orig ?? this.orig,
      fija: fija ?? this.fija,
      done: done ?? this.done,
      completedAt: completedAt ?? this.completedAt,
      observaciones: observaciones ?? this.observaciones,
      motivoNoRealizada: motivoNoRealizada ?? this.motivoNoRealizada,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'activityId': activityId,
      'userId': userId,
      'weekKey': weekKey,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'category': category,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'day': day,
      'orig': orig,
      'fija': fija ? 1 : 0,
      'done': done ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'observaciones': observaciones,
      'motivoNoRealizada': motivoNoRealizada,
    };
  }

  factory ActivityInstance.fromMap(Map<String, dynamic> map) {
    return ActivityInstance(
      id: map['id'] as int?,
      activityId: map['activityId'] as int,
      userId: map['userId'] as String,
      weekKey: map['weekKey'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      area: map['area'] as String? ?? 'General',
      category: map['category'] as String? ?? 'General',
      timeStart: map['timeStart'] as String? ?? '08:00',
      timeEnd: map['timeEnd'] as String? ?? '08:30',
      day: map['day'] as int,
      orig: map['orig'] as int,
      fija: (map['fija'] as int) == 1,
      done: (map['done'] as int) == 1,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
      observaciones: map['observaciones'] as String?,
      motivoNoRealizada: map['motivoNoRealizada'] as String?,
    );
  }
}

/// Registro Histórico consolidado para indicadores acumulados del mes y año
class ActivityHistory {
  final String userId;
  final String activityName;
  final int mD; // Mes Realizadas (acumulado histórico previo)
  final int mT; // Mes Totales (acumulado histórico previo)
  final int yD; // Año Realizadas (acumulado histórico previo)
  final int yT; // Año Totales (acumulado histórico previo)

  const ActivityHistory({
    required this.userId,
    required this.activityName,
    required this.mD,
    required this.mT,
    required this.yD,
    required this.yT,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'activityName': activityName,
      'mD': mD,
      'mT': mT,
      'yD': yD,
      'yT': yT,
    };
  }

  factory ActivityHistory.fromMap(Map<String, dynamic> map) {
    return ActivityHistory(
      userId: map['userId'] as String,
      activityName: map['activityName'] as String,
      mD: map['mD'] as int? ?? 0,
      mT: map['mT'] as int? ?? 0,
      yD: map['yD'] as int? ?? 0,
      yT: map['yT'] as int? ?? 0,
    );
  }
}

/// Registro de Auditoría Local para Trazabilidad
class AuditLogModel {
  final int? id;
  final String userId;
  final String action; // 'CREATE', 'UPDATE', 'TOGGLE', 'MOVE', 'ARCHIVE'
  final String entity; // 'activity', 'instance'
  final int entityId;
  final String details;
  final DateTime timestamp;

  const AuditLogModel({
    this.id,
    required this.userId,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      action: map['action'] as String,
      entity: map['entity'] as String,
      entityId: map['entityId'] as int,
      details: map['details'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

