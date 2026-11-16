
import 'dart:convert';

/// ========================================================
/// MODELO: PERFIL DE USUARIO & JERARQUÍA EMPRESARIAL
/// ========================================================
class UserProfile {
  final String id;
  final String cedula;
  final String nombre;
  final String cargo;
  final String area;
  final String iniciales;
  final String email;
  final bool activo;
  final String fechaRegistro;
  final String observaciones;
  final String rol;      // 'superadmin', 'admin_planta', 'supervisor', 'operador'
  final String plantId;  // 'ALL' para Superadmin, o ID específico de planta
  final String pin;      // PIN de acceso numérico (para Superadmin, Admins de planta y Supervisores)

  const UserProfile({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.cargo,
    required this.area,
    required this.iniciales,
    this.email = '',
    this.activo = true,
    this.fechaRegistro = '2026-10-01',
    this.observaciones = '',
    required this.rol,
    required this.plantId,
    this.pin = '',
  });

  bool get isUltraAdmin => rol == 'ultra_admin';
  bool get isSuperAdmin => rol == 'superadmin';
  bool get isPlantAdmin => rol == 'admin_planta';
  bool get isSupervisor => rol == 'supervisor';
  bool get isOperator => rol == 'operador';

  UserProfile copyWith({
    String? id,
    String? cedula,
    String? nombre,
    String? cargo,
    String? area,
    String? iniciales,
    String? email,
    bool? activo,
    String? fechaRegistro,
    String? observaciones,
    String? rol,
    String? plantId,
    String? pin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombre: nombre ?? this.nombre,
      cargo: cargo ?? this.cargo,
      area: area ?? this.area,
      iniciales: iniciales ?? this.iniciales,
      email: email ?? this.email,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      observaciones: observaciones ?? this.observaciones,
      rol: rol ?? this.rol,
      plantId: plantId ?? this.plantId,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombre': nombre,
      'cargo': cargo,
      'area': area,
      'iniciales': iniciales,
      'email': email,
      'activo': activo ? 1 : 0,
      'fechaRegistro': fechaRegistro,
      'observaciones': observaciones,
      'rol': rol,
      'plantId': plantId,
      'pin': pin,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      cedula: map['cedula']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      cargo: map['cargo']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      iniciales: map['iniciales']?.toString() ?? 'U',
      email: map['email']?.toString() ?? '',
      activo: (map['activo'] == 1 || map['activo'] == true),
      fechaRegistro: map['fechaRegistro']?.toString() ?? '2026-10-01',
      observaciones: map['observaciones']?.toString() ?? '',
      rol: map['rol']?.toString() ?? 'operador',
      plantId: map['plantId']?.toString() ?? 'PL-EXTRUSA',
      pin: map['pin']?.toString() ?? '',
    );
  }
}

/// ========================================================
/// MODELO: PLANTA INDUSTRIAL
/// ========================================================
class PlantModel {
  final String id;
  final String codigo;
  final String nombre;
  final String ubicacion;
  final String adminId;
  final bool activa;

  const PlantModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.ubicacion,
    required this.adminId,
    this.activa = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'ubicacion': ubicacion,
      'adminId': adminId,
      'activa': activa ? 1 : 0,
    };
  }

  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      id: map['id']?.toString() ?? '',
      codigo: map['codigo']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      ubicacion: map['ubicacion']?.toString() ?? '',
      adminId: map['adminId']?.toString() ?? '',
      activa: (map['activa'] == 1 || map['activa'] == true),
    );
  }
}

/// ========================================================
/// MODELO: DEFINICIÓN DE ACTIVIDAD OPERATIVA
/// ========================================================
class ActivityModel {
  final int? id;
  final String plantId;
  final String userId;
  final String nombre;
  final String descripcion;
  final String area;
  final String category;
  final String timeStart;
  final String timeEnd;
  final bool fija;
  final String dias; // Ej. "1,2,3,4,5"
  final String prioridad;
  final bool reqFoto;
  final bool reqMedicion;
  final bool reqComentario;
  final bool esGlobal;
  final String tipoActividad; // 'ejecucion' o 'registro'
  final bool requierePlanAccion;
  final bool planAccionObligatorio;
  final String instrucciones;
  final String criteriosCumplimiento;

  const ActivityModel({
    this.id,
    required this.plantId,
    required this.userId,
    required this.nombre,
    required this.descripcion,
    required this.area,
    required this.category,
    required this.timeStart,
    required this.timeEnd,
    this.fija = false,
    this.dias = '1,2,3,4,5',
    this.prioridad = 'Media',
    this.reqFoto = false,
    this.reqMedicion = false,
    this.reqComentario = false,
    this.esGlobal = false,
    this.tipoActividad = 'ejecucion',
    this.requierePlanAccion = false,
    this.planAccionObligatorio = false,
    this.instrucciones = '',
    this.criteriosCumplimiento = '',
  });

  bool get esRegistro => tipoActividad == 'registro';
  bool get esEjecucion => tipoActividad != 'registro';
  String get categoria => category;

  List<int> get diasList {
    return dias.split(',').map((s) => int.tryParse(s.trim()) ?? 1).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'plantId': plantId,
      'userId': userId,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'category': category,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'fija': fija ? 1 : 0,
      'dias': dias,
      'prioridad': prioridad,
      'reqFoto': reqFoto ? 1 : 0,
      'reqMedicion': reqMedicion ? 1 : 0,
      'reqComentario': reqComentario ? 1 : 0,
      'esGlobal': esGlobal ? 1 : 0,
      'tipoActividad': tipoActividad,
      'requierePlanAccion': requierePlanAccion ? 1 : 0,
      'planAccionObligatorio': planAccionObligatorio ? 1 : 0,
      'instrucciones': instrucciones,
      'criteriosCumplimiento': criteriosCumplimiento,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as int?,
      plantId: map['plantId']?.toString() ?? 'PL-EXTRUSA',
      userId: map['userId']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      area: map['area']?.toString() ?? 'General',
      category: map['category']?.toString() ?? 'Operación',
      timeStart: map['timeStart']?.toString() ?? '08:00',
      timeEnd: map['timeEnd']?.toString() ?? '09:00',
      fija: (map['fija'] == 1 || map['fija'] == true),
      dias: map['dias']?.toString() ?? '1,2,3,4,5',
      prioridad: map['prioridad']?.toString() ?? 'Media',
      reqFoto: (map['reqFoto'] == 1 || map['reqFoto'] == true),
      reqMedicion: (map['reqMedicion'] == 1 || map['reqMedicion'] == true),
      reqComentario: (map['reqComentario'] == 1 || map['reqComentario'] == true),
      esGlobal: (map['esGlobal'] == 1 || map['esGlobal'] == true),
      tipoActividad: map['tipoActividad']?.toString() ?? 'ejecucion',
      requierePlanAccion: (map['requierePlanAccion'] == 1 || map['requierePlanAccion'] == true),
      planAccionObligatorio: (map['planAccionObligatorio'] == 1 || map['planAccionObligatorio'] == true),
      instrucciones: map['instrucciones']?.toString() ?? '',
      criteriosCumplimiento: map['criteriosCumplimiento']?.toString() ?? '',
    );
  }

  ActivityModel copyWith({
    int? id,
    String? plantId,
    String? userId,
    String? nombre,
    String? descripcion,
    String? area,
    String? category,
    String? timeStart,
    String? timeEnd,
    bool? fija,
    String? dias,
    String? prioridad,
    bool? reqFoto,
    bool? reqMedicion,
    bool? reqComentario,
    bool? esGlobal,
    String? tipoActividad,
    bool? requierePlanAccion,
    bool? planAccionObligatorio,
    String? instrucciones,
    String? criteriosCumplimiento,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      area: area ?? this.area,
      category: category ?? this.category,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      fija: fija ?? this.fija,
      dias: dias ?? this.dias,
      prioridad: prioridad ?? this.prioridad,
      reqFoto: reqFoto ?? this.reqFoto,
      reqMedicion: reqMedicion ?? this.reqMedicion,
      reqComentario: reqComentario ?? this.reqComentario,
      esGlobal: esGlobal ?? this.esGlobal,
      tipoActividad: tipoActividad ?? this.tipoActividad,
      requierePlanAccion: requierePlanAccion ?? this.requierePlanAccion,
      planAccionObligatorio: planAccionObligatorio ?? this.planAccionObligatorio,
      instrucciones: instrucciones ?? this.instrucciones,
      criteriosCumplimiento: criteriosCumplimiento ?? this.criteriosCumplimiento,
    );
  }
}

/// ========================================================
/// MODELO: INSTANCIA DIARIA DE ACTIVIDAD
/// ========================================================
class ActivityInstance {
  final int? id;
  final int activityId;
  final String userId;
  final String plantId;
  final String weekKey; // Ej. "W1", "W2"
  final String nombre;
  final String descripcion;
  final String area;
  final String category;
  final String timeStart;
  final String timeEnd;
  final String prioridad;
  final int day;       // 1 = Lun, 5 = Vie
  final int orig;      // Día original asignado
  final bool fija;
  final bool done;
  final String state;  // 'Pendiente', 'Reportada', 'Aprobada', 'RequiereCorreccion', 'Reprogramada'
  final DateTime? completedAt;
  final String? observaciones;
  final String? motivoNoRealizada;
  final int subtasksTotal;
  final int subtasksReported;
  final int subtasksApproved;
  final String tipoActividad; // 'ejecucion' o 'registro'
  final bool requierePlanAccion;
  final bool planAccionObligatorio;
  final String instrucciones;
  final String criteriosCumplimiento;
  final bool reqFoto;
  final bool reqMedicion;
  final bool reqComentario;

  const ActivityInstance({
    this.id,
    required this.activityId,
    required this.userId,
    required this.plantId,
    required this.weekKey,
    required this.nombre,
    required this.descripcion,
    this.area = 'General',
    this.category = 'Operación',
    this.timeStart = '08:00',
    this.timeEnd = '09:00',
    this.prioridad = 'Media',
    required this.day,
    required this.orig,
    required this.fija,
    this.done = false,
    this.state = 'Pendiente',
    this.completedAt,
    this.observaciones,
    this.motivoNoRealizada,
    this.subtasksTotal = 0,
    this.subtasksReported = 0,
    this.subtasksApproved = 0,
    this.tipoActividad = 'ejecucion',
    this.requierePlanAccion = false,
    this.planAccionObligatorio = false,
    this.instrucciones = '',
    this.criteriosCumplimiento = '',
    this.reqFoto = false,
    this.reqMedicion = false,
    this.reqComentario = false,
  });

  bool get esRegistro => tipoActividad == 'registro';
  bool get esEjecucion => tipoActividad != 'registro';
  String get categoria => category;

  bool get isReprogramada => state == 'Reprogramada' || (orig != day);

  double get executionProgress {
    if (subtasksTotal > 0) {
      return (subtasksReported / subtasksTotal).clamp(0.0, 1.0);
    }
    return done ? 1.0 : 0.0;
  }

  double get validationProgress {
    if (subtasksTotal > 0) {
      return (subtasksApproved / subtasksTotal).clamp(0.0, 1.0);
    }
    return (done && state == 'Aprobada') ? 1.0 : 0.0;
  }

  ActivityInstance copyWith({
    int? id,
    int? activityId,
    String? userId,
    String? plantId,
    String? weekKey,
    String? nombre,
    String? descripcion,
    String? area,
    String? category,
    String? timeStart,
    String? timeEnd,
    String? prioridad,
    int? day,
    int? orig,
    bool? fija,
    bool? done,
    String? state,
    DateTime? completedAt,
    String? observaciones,
    String? motivoNoRealizada,
    int? subtasksTotal,
    int? subtasksReported,
    int? subtasksApproved,
    String? tipoActividad,
    bool? requierePlanAccion,
    bool? planAccionObligatorio,
    String? instrucciones,
    String? criteriosCumplimiento,
    bool? reqFoto,
    bool? reqMedicion,
    bool? reqComentario,
  }) {
    return ActivityInstance(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      plantId: plantId ?? this.plantId,
      weekKey: weekKey ?? this.weekKey,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      area: area ?? this.area,
      category: category ?? this.category,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      prioridad: prioridad ?? this.prioridad,
      day: day ?? this.day,
      orig: orig ?? this.orig,
      fija: fija ?? this.fija,
      done: done ?? this.done,
      state: state ?? this.state,
      completedAt: completedAt ?? this.completedAt,
      observaciones: observaciones ?? this.observaciones,
      motivoNoRealizada: motivoNoRealizada ?? this.motivoNoRealizada,
      subtasksTotal: subtasksTotal ?? this.subtasksTotal,
      subtasksReported: subtasksReported ?? this.subtasksReported,
      subtasksApproved: subtasksApproved ?? this.subtasksApproved,
      tipoActividad: tipoActividad ?? this.tipoActividad,
      requierePlanAccion: requierePlanAccion ?? this.requierePlanAccion,
      planAccionObligatorio: planAccionObligatorio ?? this.planAccionObligatorio,
      instrucciones: instrucciones ?? this.instrucciones,
      criteriosCumplimiento: criteriosCumplimiento ?? this.criteriosCumplimiento,
      reqFoto: reqFoto ?? this.reqFoto,
      reqMedicion: reqMedicion ?? this.reqMedicion,
      reqComentario: reqComentario ?? this.reqComentario,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'activityId': activityId,
      'userId': userId,
      'plantId': plantId,
      'weekKey': weekKey,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'category': category,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'prioridad': prioridad,
      'day': day,
      'orig': orig,
      'fija': fija ? 1 : 0,
      'done': done ? 1 : 0,
      'state': state,
      'completedAt': completedAt?.toIso8601String(),
      'observaciones': observaciones,
      'motivoNoRealizada': motivoNoRealizada,
      'subtasksTotal': subtasksTotal,
      'subtasksReported': subtasksReported,
      'subtasksApproved': subtasksApproved,
      'tipoActividad': tipoActividad,
      'requierePlanAccion': requierePlanAccion ? 1 : 0,
      'planAccionObligatorio': planAccionObligatorio ? 1 : 0,
      'instrucciones': instrucciones,
      'criteriosCumplimiento': criteriosCumplimiento,
      'reqFoto': reqFoto ? 1 : 0,
      'reqMedicion': reqMedicion ? 1 : 0,
      'reqComentario': reqComentario ? 1 : 0,
    };
  }

  factory ActivityInstance.fromMap(Map<String, dynamic> map) {
    return ActivityInstance(
      id: map['id'] as int?,
      activityId: map['activityId'] as int? ?? 0,
      userId: map['userId']?.toString() ?? '',
      plantId: map['plantId']?.toString() ?? 'PL-EXTRUSA',
      weekKey: map['weekKey']?.toString() ?? 'W1',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      area: map['area']?.toString() ?? 'General',
      category: map['category']?.toString() ?? 'Operación',
      timeStart: map['timeStart']?.toString() ?? '08:00',
      timeEnd: map['timeEnd']?.toString() ?? '09:00',
      prioridad: map['prioridad']?.toString() ?? 'Media',
      day: map['day'] as int? ?? 1,
      orig: map['orig'] as int? ?? 1,
      fija: (map['fija'] == 1 || map['fija'] == true),
      done: (map['done'] == 1 || map['done'] == true),
      state: map['state']?.toString() ?? 'Pendiente',
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt']) : null,
      observaciones: map['observaciones']?.toString(),
      motivoNoRealizada: map['motivoNoRealizada']?.toString(),
      subtasksTotal: map['subtasksTotal'] as int? ?? 0,
      subtasksReported: map['subtasksReported'] as int? ?? 0,
      subtasksApproved: map['subtasksApproved'] as int? ?? 0,
      tipoActividad: map['tipoActividad']?.toString() ?? 'ejecucion',
      requierePlanAccion: (map['requierePlanAccion'] == 1 || map['requierePlanAccion'] == true),
      planAccionObligatorio: (map['planAccionObligatorio'] == 1 || map['planAccionObligatorio'] == true),
      instrucciones: map['instrucciones']?.toString() ?? '',
      criteriosCumplimiento: map['criteriosCumplimiento']?.toString() ?? '',
      reqFoto: (map['reqFoto'] == 1 || map['reqFoto'] == true),
      reqMedicion: (map['reqMedicion'] == 1 || map['reqMedicion'] == true),
      reqComentario: (map['reqComentario'] == 1 || map['reqComentario'] == true),
    );
  }
}

/// ========================================================
/// MODELO: SUBTAREA OPERATIVA PASO A PASO
/// ========================================================
class ActivitySubtaskModel {
  final int? id;
  final int activityId;
  final int orden;
  final String nombre;
  final String descripcion;
  final String instruccion;
  final bool esObligatoria;
  final bool requiereFoto;
  final bool requiereComentario;
  final bool requiereMedicion;
  final String unidadMedida;
  final double? valorMinimo;
  final double? valorMaximo;

  const ActivitySubtaskModel({
    this.id,
    required this.activityId,
    this.orden = 0,
    required this.nombre,
    this.descripcion = '',
    this.instruccion = '',
    this.esObligatoria = true,
    this.requiereFoto = false,
    this.requiereComentario = false,
    this.requiereMedicion = false,
    this.unidadMedida = '',
    this.valorMinimo,
    this.valorMaximo,
  });

  ActivitySubtaskModel copyWith({
    int? id,
    int? activityId,
    int? orden,
    String? nombre,
    String? descripcion,
    String? instruccion,
    bool? esObligatoria,
    bool? requiereFoto,
    bool? requiereComentario,
    bool? requiereMedicion,
    String? unidadMedida,
    double? valorMinimo,
    double? valorMaximo,
  }) {
    return ActivitySubtaskModel(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      orden: orden ?? this.orden,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      instruccion: instruccion ?? this.instruccion,
      esObligatoria: esObligatoria ?? this.esObligatoria,
      requiereFoto: requiereFoto ?? this.requiereFoto,
      requiereComentario: requiereComentario ?? this.requiereComentario,
      requiereMedicion: requiereMedicion ?? this.requiereMedicion,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      valorMinimo: valorMinimo ?? this.valorMinimo,
      valorMaximo: valorMaximo ?? this.valorMaximo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'activityId': activityId,
      'orden': orden,
      'nombre': nombre,
      'descripcion': descripcion,
      'instruccion': instruccion,
      'esObligatoria': esObligatoria ? 1 : 0,
      'requiereFoto': requiereFoto ? 1 : 0,
      'requiereComentario': requiereComentario ? 1 : 0,
      'requiereMedicion': requiereMedicion ? 1 : 0,
      'unidadMedida': unidadMedida,
      'valorMinimo': valorMinimo,
      'valorMaximo': valorMaximo,
    };
  }

  factory ActivitySubtaskModel.fromMap(Map<String, dynamic> map) {
    return ActivitySubtaskModel(
      id: map['id'] as int?,
      activityId: map['activityId'] as int? ?? 0,
      orden: map['orden'] as int? ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      instruccion: map['instruccion']?.toString() ?? '',
      esObligatoria: (map['esObligatoria'] == 1 || map['esObligatoria'] == true),
      requiereFoto: (map['requiereFoto'] == 1 || map['requiereFoto'] == true),
      requiereComentario: (map['requiereComentario'] == 1 || map['requiereComentario'] == true),
      requiereMedicion: (map['requiereMedicion'] == 1 || map['requiereMedicion'] == true),
      unidadMedida: map['unidadMedida']?.toString() ?? '',
      valorMinimo: map['valorMinimo'] != null ? (map['valorMinimo'] as num).toDouble() : null,
      valorMaximo: map['valorMaximo'] != null ? (map['valorMaximo'] as num).toDouble() : null,
    );
  }
}

/// ========================================================
/// MODELO: EJECUCIÓN & EVIDENCIA DE SUBTAREA
/// ========================================================
class SubtaskExecutionModel {
  final int? id;
  final int subtaskId;
  final int instanceId;
  final String userId;
  final bool reportada;
  final bool aprobada;
  final String? fotoPath;
  final String? comentario;
  final double? valorMedido;
  final DateTime? fechaReporte;
  final DateTime? fechaValidacion;
  final String? revisorId;
  final String? motivoRechazo;

  const SubtaskExecutionModel({
    this.id,
    required this.subtaskId,
    required this.instanceId,
    required this.userId,
    this.reportada = false,
    this.aprobada = false,
    this.fotoPath,
    this.comentario,
    this.valorMedido,
    this.fechaReporte,
    this.fechaValidacion,
    this.revisorId,
    this.motivoRechazo,
  });

  bool get requiresCorrection => !aprobada && motivoRechazo != null && motivoRechazo!.isNotEmpty;

  SubtaskExecutionModel copyWith({
    int? id,
    int? subtaskId,
    int? instanceId,
    String? userId,
    bool? reportada,
    bool? aprobada,
    String? fotoPath,
    String? comentario,
    double? valorMedido,
    DateTime? fechaReporte,
    DateTime? fechaValidacion,
    String? revisorId,
    String? motivoRechazo,
  }) {
    return SubtaskExecutionModel(
      id: id ?? this.id,
      subtaskId: subtaskId ?? this.subtaskId,
      instanceId: instanceId ?? this.instanceId,
      userId: userId ?? this.userId,
      reportada: reportada ?? this.reportada,
      aprobada: aprobada ?? this.aprobada,
      fotoPath: fotoPath ?? this.fotoPath,
      comentario: comentario ?? this.comentario,
      valorMedido: valorMedido ?? this.valorMedido,
      fechaReporte: fechaReporte ?? this.fechaReporte,
      fechaValidacion: fechaValidacion ?? this.fechaValidacion,
      revisorId: revisorId ?? this.revisorId,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subtaskId': subtaskId,
      'instanceId': instanceId,
      'userId': userId,
      'reportada': reportada ? 1 : 0,
      'aprobada': aprobada ? 1 : 0,
      'fotoPath': fotoPath,
      'comentario': comentario,
      'valorMedido': valorMedido,
      'fechaReporte': fechaReporte?.toIso8601String(),
      'fechaValidacion': fechaValidacion?.toIso8601String(),
      'revisorId': revisorId,
      'motivoRechazo': motivoRechazo,
    };
  }

  factory SubtaskExecutionModel.fromMap(Map<String, dynamic> map) {
    return SubtaskExecutionModel(
      id: map['id'] as int?,
      subtaskId: map['subtaskId'] as int? ?? 0,
      instanceId: map['instanceId'] as int? ?? 0,
      userId: map['userId']?.toString() ?? '',
      reportada: (map['reportada'] == 1 || map['reportada'] == true),
      aprobada: (map['aprobada'] == 1 || map['aprobada'] == true),
      fotoPath: map['fotoPath']?.toString(),
      comentario: map['comentario']?.toString(),
      valorMedido: map['valorMedido'] != null ? (map['valorMedido'] as num).toDouble() : null,
      fechaReporte: map['fechaReporte'] != null ? DateTime.tryParse(map['fechaReporte']) : null,
      fechaValidacion: map['fechaValidacion'] != null ? DateTime.tryParse(map['fechaValidacion']) : null,
      revisorId: map['revisorId']?.toString(),
      motivoRechazo: map['motivoRechazo']?.toString(),
    );
  }
}

/// ========================================================
/// MODELO: NOTIFICACIÓN DE PLATAFORMA
/// ========================================================
class NotificationModel {
  final int? id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'corporate_assignment', 'plant_assignment', 'correction', 'alert'
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      type: map['type']?.toString() ?? 'alert',
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) ?? DateTime.now() : DateTime.now(),
      isRead: (map['isRead'] == 1 || map['isRead'] == true),
    );
  }

  NotificationModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// ========================================================
/// MODELO: HISTORIAL DE AUDITORÍA INMUTABLE
/// ========================================================
class AuditLogModel {
  final int? id;
  final String userId;
  final String action;
  final String entity;
  final int? entityId;
  final String details;
  final DateTime timestamp;

  const AuditLogModel({
    this.id,
    required this.userId,
    required this.action,
    required this.entity,
    this.entityId,
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
      userId: map['userId']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      entity: map['entity']?.toString() ?? '',
      entityId: map['entityId'] as int?,
      details: map['details']?.toString() ?? '',
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) ?? DateTime.now() : DateTime.now(),
    );
  }
}

/// ========================================================
/// MODELO: LOG DE REPROGRAMACIÓN JUSTIFICADA
/// ========================================================
class ReprogrammingLogModel {
  final int? id;
  final int instanceId;
  final String userId;
  final int fromDay;
  final int toDay;
  final String motivo;
  final DateTime timestamp;
  final String status; // 'Pendiente', 'Aprobada', 'Rechazada'

  const ReprogrammingLogModel({
    this.id,
    required this.instanceId,
    required this.userId,
    required this.fromDay,
    required this.toDay,
    required this.motivo,
    required this.timestamp,
    this.status = 'Pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'instanceId': instanceId,
      'userId': userId,
      'fromDay': fromDay,
      'toDay': toDay,
      'motivo': motivo,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory ReprogrammingLogModel.fromMap(Map<String, dynamic> map) {
    return ReprogrammingLogModel(
      id: map['id'] as int?,
      instanceId: map['instanceId'] as int? ?? 0,
      userId: map['userId']?.toString() ?? '',
      fromDay: map['fromDay'] as int? ?? 1,
      toDay: map['toDay'] as int? ?? 1,
      motivo: map['motivo']?.toString() ?? '',
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) ?? DateTime.now() : DateTime.now(),
      status: map['status']?.toString() ?? 'Pendiente',
    );
  }
}

/// ========================================================
/// MODELO: PROPLAN (COMPROMISO / PLAN DE ACCIÓN REUNIÓN DIARIA)
/// ========================================================
class ProPlanModel {
  final int? id;
  final String plantId;
  final String plan;
  final String responsable;
  final String area;
  final String fechaCompromiso;
  final String estado; // 'Pendiente', 'En Proceso', 'En Revisión', 'Cumplido', 'Vencido'
  final String? evidencia;
  final String? comentarios;
  final String creadoPor;
  final DateTime fechaCreacion;
  final int? activityInstanceId;
  final int? activityId;
  final String? activityNombre;
  final String? descripcionSituacion;
  final double porcentajeAvance;
  final bool requiereRevision;
  final String? revisorId;

  const ProPlanModel({
    this.id,
    required this.plantId,
    required this.plan,
    required this.responsable,
    required this.area,
    required this.fechaCompromiso,
    this.estado = 'Pendiente',
    this.evidencia,
    this.comentarios,
    required this.creadoPor,
    required this.fechaCreacion,
    this.activityInstanceId,
    this.activityId,
    this.activityNombre,
    this.descripcionSituacion,
    this.porcentajeAvance = 0.0,
    this.requiereRevision = false,
    this.revisorId,
  });

  bool get isVencido {
    if (estado == 'Cumplido') return false;
    try {
      final compDate = DateTime.parse(fechaCompromiso);
      return DateTime.now().isAfter(compDate.add(const Duration(days: 1)));
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'plantId': plantId,
      'plan': plan,
      'responsable': responsable,
      'area': area,
      'fechaCompromiso': fechaCompromiso,
      'estado': estado,
      'evidencia': evidencia,
      'comentarios': comentarios,
      'creadoPor': creadoPor,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'activityInstanceId': activityInstanceId,
      'activityId': activityId,
      'activityNombre': activityNombre,
      'descripcionSituacion': descripcionSituacion,
      'porcentajeAvance': porcentajeAvance,
      'requiereRevision': requiereRevision ? 1 : 0,
      'revisorId': revisorId,
    };
  }

  factory ProPlanModel.fromMap(Map<String, dynamic> map) {
    return ProPlanModel(
      id: map['id'] as int?,
      plantId: map['plantId']?.toString() ?? 'PL-EXTRUSA',
      plan: map['plan']?.toString() ?? '',
      responsable: map['responsable']?.toString() ?? '',
      area: map['area']?.toString() ?? 'Operaciones',
      fechaCompromiso: map['fechaCompromiso']?.toString() ?? '',
      estado: map['estado']?.toString() ?? 'Pendiente',
      evidencia: map['evidencia']?.toString(),
      comentarios: map['comentarios']?.toString(),
      creadoPor: map['creadoPor']?.toString() ?? 'Admin',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion']) ?? DateTime.now()
          : DateTime.now(),
      activityInstanceId: map['activityInstanceId'] as int?,
      activityId: map['activityId'] as int?,
      activityNombre: map['activityNombre']?.toString(),
      descripcionSituacion: map['descripcionSituacion']?.toString(),
      porcentajeAvance: (map['porcentajeAvance'] as num?)?.toDouble() ?? 0.0,
      requiereRevision: (map['requiereRevision'] == 1 || map['requiereRevision'] == true),
      revisorId: map['revisorId']?.toString(),
    );
  }

  ProPlanModel copyWith({
    int? id,
    String? plantId,
    String? plan,
    String? responsable,
    String? area,
    String? fechaCompromiso,
    String? estado,
    String? evidencia,
    String? comentarios,
    String? creadoPor,
    DateTime? fechaCreacion,
    int? activityInstanceId,
    int? activityId,
    String? activityNombre,
    String? descripcionSituacion,
    double? porcentajeAvance,
    bool? requiereRevision,
    String? revisorId,
  }) {
    return ProPlanModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      plan: plan ?? this.plan,
      responsable: responsable ?? this.responsable,
      area: area ?? this.area,
      fechaCompromiso: fechaCompromiso ?? this.fechaCompromiso,
      estado: estado ?? this.estado,
      evidencia: evidencia ?? this.evidencia,
      comentarios: comentarios ?? this.comentarios,
      creadoPor: creadoPor ?? this.creadoPor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activityInstanceId: activityInstanceId ?? this.activityInstanceId,
      activityId: activityId ?? this.activityId,
      activityNombre: activityNombre ?? this.activityNombre,
      descripcionSituacion: descripcionSituacion ?? this.descripcionSituacion,
      porcentajeAvance: porcentajeAvance ?? this.porcentajeAvance,
      requiereRevision: requiereRevision ?? this.requiereRevision,
      revisorId: revisorId ?? this.revisorId,
    );
  }
}

/// ========================================================
/// MODELO: REGISTRO DE INFORMACIÓN / REUNIÓN / NOVEDAD
/// ========================================================
class MeetingRecordModel {
  final int? id;
  final int instanceId;
  final int activityId;
  final String plantId;
  final String usuarioId;
  final String usuarioNombre;
  final String titulo;
  final String fecha;
  final String descripcion;
  final String participantes;
  final String observaciones;
  final String compromisos;
  final String responsablesCompromisos;
  final String fechaCumplimientoCompromisos;
  final String? fotoOAdjuntoPath;
  final DateTime fechaRegistro;

  const MeetingRecordModel({
    this.id,
    required this.instanceId,
    required this.activityId,
    required this.plantId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.titulo,
    required this.fecha,
    required this.descripcion,
    this.participantes = '',
    this.observaciones = '',
    this.compromisos = '',
    this.responsablesCompromisos = '',
    this.fechaCumplimientoCompromisos = '',
    this.fotoOAdjuntoPath,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'instanceId': instanceId,
      'activityId': activityId,
      'plantId': plantId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'titulo': titulo,
      'fecha': fecha,
      'descripcion': descripcion,
      'participantes': participantes,
      'observaciones': observaciones,
      'compromisos': compromisos,
      'responsablesCompromisos': responsablesCompromisos,
      'fechaCumplimientoCompromisos': fechaCumplimientoCompromisos,
      'fotoOAdjuntoPath': fotoOAdjuntoPath,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory MeetingRecordModel.fromMap(Map<String, dynamic> map) {
    return MeetingRecordModel(
      id: map['id'] as int?,
      instanceId: map['instanceId'] as int? ?? 0,
      activityId: map['activityId'] as int? ?? 0,
      plantId: map['plantId']?.toString() ?? '',
      usuarioId: map['usuarioId']?.toString() ?? '',
      usuarioNombre: map['usuarioNombre']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      fecha: map['fecha']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      participantes: map['participantes']?.toString() ?? '',
      observaciones: map['observaciones']?.toString() ?? '',
      compromisos: map['compromisos']?.toString() ?? '',
      responsablesCompromisos: map['responsablesCompromisos']?.toString() ?? '',
      fechaCumplimientoCompromisos: map['fechaCumplimientoCompromisos']?.toString() ?? '',
      fotoOAdjuntoPath: map['fotoOAdjuntoPath']?.toString(),
      fechaRegistro: map['fechaRegistro'] != null
          ? DateTime.tryParse(map['fechaRegistro']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MeetingRecordModel copyWith({
    int? id,
    int? instanceId,
    int? activityId,
    String? plantId,
    String? usuarioId,
    String? usuarioNombre,
    String? titulo,
    String? fecha,
    String? descripcion,
    String? participantes,
    String? observaciones,
    String? compromisos,
    String? responsablesCompromisos,
    String? fechaCumplimientoCompromisos,
    String? fotoOAdjuntoPath,
    DateTime? fechaRegistro,
  }) {
    return MeetingRecordModel(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      activityId: activityId ?? this.activityId,
      plantId: plantId ?? this.plantId,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      participantes: participantes ?? this.participantes,
      observaciones: observaciones ?? this.observaciones,
      compromisos: compromisos ?? this.compromisos,
      responsablesCompromisos: responsablesCompromisos ?? this.responsablesCompromisos,
      fechaCumplimientoCompromisos: fechaCumplimientoCompromisos ?? this.fechaCumplimientoCompromisos,
      fotoOAdjuntoPath: fotoOAdjuntoPath ?? this.fotoOAdjuntoPath,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}

/// ========================================================
/// MODELO: ESTÁNDAR VISUAL / FOTO MODELO DEL SUPERVISOR
/// ========================================================
class PlantPhotoStandardModel {
  final int? id;
  final String plantId;
  final String supervisorId;
  final String titulo;
  final String descripcion;
  final String fotoPath;
  final String area;
  final DateTime fechaRegistro;

  const PlantPhotoStandardModel({
    this.id,
    required this.plantId,
    required this.supervisorId,
    required this.titulo,
    required this.descripcion,
    required this.fotoPath,
    required this.area,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'plantId': plantId,
      'supervisorId': supervisorId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fotoPath': fotoPath,
      'area': area,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory PlantPhotoStandardModel.fromMap(Map<String, dynamic> map) {
    return PlantPhotoStandardModel(
      id: map['id'] as int?,
      plantId: map['plantId']?.toString() ?? '',
      supervisorId: map['supervisorId']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      fotoPath: map['fotoPath']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      fechaRegistro: map['fechaRegistro'] != null
          ? DateTime.tryParse(map['fechaRegistro']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  PlantPhotoStandardModel copyWith({
    int? id,
    String? plantId,
    String? supervisorId,
    String? titulo,
    String? descripcion,
    String? fotoPath,
    String? area,
    DateTime? fechaRegistro,
  }) {
    return PlantPhotoStandardModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      supervisorId: supervisorId ?? this.supervisorId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fotoPath: fotoPath ?? this.fotoPath,
      area: area ?? this.area,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}

/// ========================================================
/// MODELO: SOLICITUD DE TAREA EXCEPCIONAL (>10 TAREAS)
/// ========================================================
class ExtraTaskRequestModel {
  final int? id;
  final String plantId;
  final String adminId;
  final String nombre;
  final String descripcion;
  final String area;
  final String prioridad; // 'Baja', 'Media', 'Alta'
  final String justificacion;
  final String dias;
  final String timeStart;
  final String timeEnd;
  final String estado; // 'Pendiente', 'Aprobada', 'Rechazada'
  final String? motivoRechazo;
  final DateTime fechaSolicitud;

  const ExtraTaskRequestModel({
    this.id,
    required this.plantId,
    required this.adminId,
    required this.nombre,
    required this.descripcion,
    required this.area,
    required this.prioridad,
    required this.justificacion,
    required this.dias,
    required this.timeStart,
    required this.timeEnd,
    this.estado = 'Pendiente',
    this.motivoRechazo,
    required this.fechaSolicitud,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'plantId': plantId,
      'adminId': adminId,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'prioridad': prioridad,
      'justificacion': justificacion,
      'dias': dias,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'estado': estado,
      'motivoRechazo': motivoRechazo,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
    };
  }

  factory ExtraTaskRequestModel.fromMap(Map<String, dynamic> map) {
    return ExtraTaskRequestModel(
      id: map['id'] as int?,
      plantId: map['plantId']?.toString() ?? '',
      adminId: map['adminId']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      prioridad: map['prioridad']?.toString() ?? 'Media',
      justificacion: map['justificacion']?.toString() ?? '',
      dias: map['dias']?.toString() ?? '1,2,3,4,5',
      timeStart: map['timeStart']?.toString() ?? '08:00',
      timeEnd: map['timeEnd']?.toString() ?? '09:00',
      estado: map['estado']?.toString() ?? 'Pendiente',
      motivoRechazo: map['motivoRechazo']?.toString(),
      fechaSolicitud: map['fechaSolicitud'] != null
          ? DateTime.tryParse(map['fechaSolicitud']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ExtraTaskRequestModel copyWith({
    int? id,
    String? plantId,
    String? adminId,
    String? nombre,
    String? descripcion,
    String? area,
    String? prioridad,
    String? justificacion,
    String? dias,
    String? timeStart,
    String? timeEnd,
    String? estado,
    String? motivoRechazo,
    DateTime? fechaSolicitud,
  }) {
    return ExtraTaskRequestModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      adminId: adminId ?? this.adminId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      area: area ?? this.area,
      prioridad: prioridad ?? this.prioridad,
      justificacion: justificacion ?? this.justificacion,
      dias: dias ?? this.dias,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      estado: estado ?? this.estado,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
    );
  }
}

/// ========================================================
/// MODELO: PLANTILLA DE ACTIVIDAD ESTÁNDAR (TEMPLATES)
/// ========================================================
class ActivityTemplateModel {
  final int? id;
  final String nombre;
  final String descripcion;
  final String area;
  final String category;
  final String prioridad;
  final bool fija;
  final bool reqFoto;
  final bool reqMedicion;
  final bool reqComentario;
  final String tipoActividad; // 'ejecucion' o 'registro'
  final bool requierePlanAccion;
  final bool planAccionObligatorio;
  final String instrucciones;
  final String criteriosCumplimiento;
  final String subtareasJson; // JSON string con lista de subtareas
  final String fechaCreacion;

  const ActivityTemplateModel({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.area,
    this.category = 'Operación',
    this.prioridad = 'Alta',
    this.fija = false,
    this.reqFoto = false,
    this.reqMedicion = false,
    this.reqComentario = true,
    this.tipoActividad = 'ejecucion',
    this.requierePlanAccion = false,
    this.planAccionObligatorio = false,
    this.instrucciones = '',
    this.criteriosCumplimiento = '',
    this.subtareasJson = '[]',
    required this.fechaCreacion,
  });

  bool get esRegistro => tipoActividad == 'registro';
  bool get esEjecucion => tipoActividad != 'registro';

  String get categoria => category;
  List<ActivitySubtaskModel> get subtasks {
    try {
      final List dec = jsonDecode(subtareasJson) as List? ?? [];
      return dec.map((m) => ActivitySubtaskModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'category': category,
      'prioridad': prioridad,
      'fija': fija ? 1 : 0,
      'reqFoto': reqFoto ? 1 : 0,
      'reqMedicion': reqMedicion ? 1 : 0,
      'reqComentario': reqComentario ? 1 : 0,
      'tipoActividad': tipoActividad,
      'requierePlanAccion': requierePlanAccion ? 1 : 0,
      'planAccionObligatorio': planAccionObligatorio ? 1 : 0,
      'instrucciones': instrucciones,
      'criteriosCumplimiento': criteriosCumplimiento,
      'subtareasJson': subtareasJson,
      'fechaCreacion': fechaCreacion,
    };
  }

  factory ActivityTemplateModel.fromMap(Map<String, dynamic> map) {
    return ActivityTemplateModel(
      id: map['id'] as int?,
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      area: map['area']?.toString() ?? 'General',
      category: map['category']?.toString() ?? 'Operación',
      prioridad: map['prioridad']?.toString() ?? 'Alta',
      fija: (map['fija'] == 1 || map['fija'] == true),
      reqFoto: (map['reqFoto'] == 1 || map['reqFoto'] == true),
      reqMedicion: (map['reqMedicion'] == 1 || map['reqMedicion'] == true),
      reqComentario: (map['reqComentario'] == 1 || map['reqComentario'] == true),
      tipoActividad: map['tipoActividad']?.toString() ?? 'ejecucion',
      requierePlanAccion: (map['requierePlanAccion'] == 1 || map['requierePlanAccion'] == true),
      planAccionObligatorio: (map['planAccionObligatorio'] == 1 || map['planAccionObligatorio'] == true),
      instrucciones: map['instrucciones']?.toString() ?? '',
      criteriosCumplimiento: map['criteriosCumplimiento']?.toString() ?? '',
      subtareasJson: map['subtareasJson']?.toString() ?? '[]',
      fechaCreacion: map['fechaCreacion']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  ActivityTemplateModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? area,
    String? category,
    String? prioridad,
    bool? fija,
    bool? reqFoto,
    bool? reqMedicion,
    bool? reqComentario,
    String? tipoActividad,
    bool? requierePlanAccion,
    bool? planAccionObligatorio,
    String? instrucciones,
    String? criteriosCumplimiento,
    String? subtareasJson,
    String? fechaCreacion,
  }) {
    return ActivityTemplateModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      area: area ?? this.area,
      category: category ?? this.category,
      prioridad: prioridad ?? this.prioridad,
      fija: fija ?? this.fija,
      reqFoto: reqFoto ?? this.reqFoto,
      reqMedicion: reqMedicion ?? this.reqMedicion,
      reqComentario: reqComentario ?? this.reqComentario,
      tipoActividad: tipoActividad ?? this.tipoActividad,
      requierePlanAccion: requierePlanAccion ?? this.requierePlanAccion,
      planAccionObligatorio: planAccionObligatorio ?? this.planAccionObligatorio,
      instrucciones: instrucciones ?? this.instrucciones,
      criteriosCumplimiento: criteriosCumplimiento ?? this.criteriosCumplimiento,
      subtareasJson: subtareasJson ?? this.subtareasJson,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

class AccessLogEntry {
  final String id;
  final String? userId;
  final String userNombre;
  final String identifier;
  final String? rol;
  final String? plantId;
  final bool success;
  final String? failureReason;
  final String ipAddress;
  final String city;
  final String region;
  final String country;
  final String isp;
  final String deviceType;
  final String os;
  final String browser;
  final String userAgent;
  final DateTime createdAt;

  const AccessLogEntry({
    required this.id,
    this.userId,
    required this.userNombre,
    required this.identifier,
    this.rol,
    this.plantId,
    required this.success,
    this.failureReason,
    required this.ipAddress,
    required this.city,
    required this.region,
    required this.country,
    required this.isp,
    required this.deviceType,
    required this.os,
    required this.browser,
    required this.userAgent,
    required this.createdAt,
  });

  String get locationLabel {
    final parts = [city, region, country].where((e) => e.trim().isNotEmpty && e != 'Desconocida').toList();
    return parts.isEmpty ? 'Ubicación no disponible' : parts.join(', ');
  }

  factory AccessLogEntry.fromMap(Map<String, dynamic> map) {
    return AccessLogEntry(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString(),
      userNombre: map['userNombre']?.toString() ?? 'Desconocido',
      identifier: map['identifier']?.toString() ?? '-',
      rol: map['rol']?.toString(),
      plantId: map['plantId']?.toString(),
      success: map['success'] == true,
      failureReason: map['failureReason']?.toString(),
      ipAddress: map['ipAddress']?.toString() ?? 'unknown',
      city: map['city']?.toString() ?? 'Desconocida',
      region: map['region']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      isp: map['isp']?.toString() ?? '',
      deviceType: map['deviceType']?.toString() ?? 'Desconocido',
      os: map['os']?.toString() ?? 'Otro',
      browser: map['browser']?.toString() ?? 'Navegador',
      userAgent: map['userAgent']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
