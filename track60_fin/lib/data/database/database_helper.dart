import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // --- WEB IN-MEMORY STORE (PARA COMPATIBILIDAD NAVEGADOR SIN SQLITE NATIVO) ---
  bool _webInitialized = false;
  final List<UserProfile> _webUsers = [];
  final List<PlantModel> _webPlants = [];
  final List<ActivityModel> _webActivities = [];
  final List<ActivitySubtaskModel> _webSubtasks = [];
  final List<ActivityInstance> _webInstances = [];
  final List<SubtaskExecutionModel> _webExecutions = [];
  final List<ProPlanModel> _webProPlans = [];
  final List<NotificationModel> _webNotifications = [];
  final List<AuditLogModel> _webAuditLogs = [];
  final List<PlantPhotoStandardModel> _webPhotoStandards = [];
  final List<ExtraTaskRequestModel> _webExtraRequests = [];
  final List<MeetingRecordModel> _webMeetingRecords = [];
  final List<ActivityTemplateModel> _webTemplates = [];

  DatabaseHelper._init();

  Future<void>? _webInitFuture;

  Future<void> _ensureWebInitialized() async {
    if (!kIsWeb) return;
    if (_webInitialized) return;
    _webInitFuture ??= _doEnsureWebInitialized();
    await _webInitFuture;
  }

  Future<void> _doEnsureWebInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedInstances = prefs.getString('web_instances_v1');
      final savedUsers = prefs.getString('web_users_v1');

      if (savedUsers != null && savedInstances != null) {
        // Cargar estado persistente previo del navegador
        final List uList = jsonDecode(savedUsers);
        _webUsers.clear();
        _webUsers.addAll(uList.map((m) => UserProfile.fromMap(m)));

        final List iList = jsonDecode(savedInstances);
        _webInstances.clear();
        _webInstances.addAll(iList.map((m) => ActivityInstance.fromMap(m)));

        final savedPlants = prefs.getString('web_plants_v1');
        if (savedPlants != null) {
          final List plList = jsonDecode(savedPlants);
          _webPlants.clear();
          _webPlants.addAll(plList.map((m) => PlantModel.fromMap(m)));
        }

        final savedActivities = prefs.getString('web_activities_v1');
        if (savedActivities != null) {
          final List aList = jsonDecode(savedActivities);
          _webActivities.clear();
          _webActivities.addAll(aList.map((m) => ActivityModel.fromMap(m)));
        }

        final savedProPlans = prefs.getString('web_proplans_v1');
        if (savedProPlans != null) {
          final List pList = jsonDecode(savedProPlans);
          _webProPlans.clear();
          _webProPlans.addAll(pList.map((m) => ProPlanModel.fromMap(m)));
        }

        final savedStandards = prefs.getString('web_photo_standards_v1');
        if (savedStandards != null) {
          final List sList = jsonDecode(savedStandards);
          _webPhotoStandards.clear();
          _webPhotoStandards.addAll(sList.map((m) => PlantPhotoStandardModel.fromMap(m)));
        }

        final savedExecutions = prefs.getString('web_executions_v1');
        if (savedExecutions != null) {
          final List eList = jsonDecode(savedExecutions);
          _webExecutions.clear();
          _webExecutions.addAll(eList.map((m) => SubtaskExecutionModel.fromMap(m)));
        }

        final savedExtra = prefs.getString('web_extra_requests_v1');
        if (savedExtra != null) {
          final List exList = jsonDecode(savedExtra);
          _webExtraRequests.clear();
          _webExtraRequests.addAll(exList.map((m) => ExtraTaskRequestModel.fromMap(m)));
        }

        final savedSubtasks = prefs.getString('web_subtasks_v1');
        if (savedSubtasks != null) {
          final List stList = jsonDecode(savedSubtasks);
          _webSubtasks.clear();
          _webSubtasks.addAll(stList.map((m) => ActivitySubtaskModel.fromMap(m)));
        }

        final savedNotifications = prefs.getString('web_notifications_v1');
        if (savedNotifications != null) {
          final List nList = jsonDecode(savedNotifications);
          _webNotifications.clear();
          _webNotifications.addAll(nList.map((m) => NotificationModel.fromMap(m)));
        }

        final savedMeetings = prefs.getString('web_meetings_v1');
        if (savedMeetings != null) {
          final List mList = jsonDecode(savedMeetings);
          _webMeetingRecords.clear();
          _webMeetingRecords.addAll(mList.map((m) => MeetingRecordModel.fromMap(m)));
        }

        final savedTemplates = prefs.getString('web_templates_v1');
        if (savedTemplates != null) {
          final List tList = jsonDecode(savedTemplates);
          _webTemplates.clear();
          _webTemplates.addAll(tList.map((m) => ActivityTemplateModel.fromMap(m)));
        }

        // Purga única de registros demo sembrados en versiones anteriores (conserva todo lo creado por el usuario)
        final purgedV2 = prefs.getBool('track60_demo_purged_v2') ?? false;
        if (!purgedV2) {
          const demoActivityTitle = 'Auditoría Mensual de Seguridad EHS Grupo Darnel';
          _webActivities.removeWhere((a) => a.nombre == demoActivityTitle);
          _webInstances.removeWhere((i) =>
              i.nombre == demoActivityTitle ||
              i.userId == 'ALL' ||
              i.userId == 'AR' ||
              i.userId == 'DM');
          _webProPlans.removeWhere((p) =>
              p.plan == 'Alineación de sensor de tensión en cabezal 02' ||
              p.plan == 'Limpieza de tolva de resina virgen');
          _webPhotoStandards.removeWhere((s) => s.titulo == 'Bobina Alineada y Sin Arrugas');
          _webNotifications.removeWhere((n) =>
              n.title == 'Bienvenida a TRACK60' || n.title == 'Actividad Corporativa Global');
          await prefs.setBool('track60_demo_purged_v2', true);
          await _persistWebState();
        }

        // Blindaje de PINs y Roles directivos para evitar bloqueos por caché desactualizada
        for (int i = 0; i < _webUsers.length; i++) {
          final u = _webUsers[i];
          if (u.id == 'JAVIER' || u.id == 'JJ' || u.isSuperAdmin) {
            _webUsers[i] = u.copyWith(id: 'JAVIER', pin: '1428', rol: 'superadmin');
          } else if (u.id == 'YL') {
            _webUsers[i] = u.copyWith(pin: '1234', rol: 'admin_planta');
          } else if (u.id == 'RG') {
            _webUsers[i] = u.copyWith(pin: '5678', rol: 'admin_planta');
          } else if (u.id == 'CM') {
            _webUsers[i] = u.copyWith(pin: '3344', rol: 'supervisor');
          } else if (u.id == 'MC') {
            _webUsers[i] = u.copyWith(pin: '7788', rol: 'supervisor');
          }
        }

        if (!_webUsers.any((u) => u.isSuperAdmin || u.id == 'JAVIER')) {
          _webUsers.insert(0, const UserProfile(
            id: 'JAVIER',
            cedula: '0000000001',
            nombre: 'Javier Julio',
            cargo: 'Superadministrador General',
            area: 'Dirección Corporativa',
            iniciales: 'JJ',
            email: 'javier.julio@darnel.com',
            activo: true,
            rol: 'superadmin',
            plantId: 'ALL',
            pin: '1428',
          ));
        }

        _webInitialized = true;
        return;
      }

      final jsonString = await rootBundle.loadString('assets/data/track60_data_inicial.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (data['users'] is List) {
        for (final u in data['users']) {
          _webUsers.add(UserProfile(
            id: u['ID'],
            cedula: u['Cédula'],
            nombre: u['Nombre'],
            cargo: u['Cargo'],
            area: u['Área'],
            iniciales: u['Nombre'].toString().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase(),
            email: u['Email'] ?? '',
            activo: u['Activo'] == 1,
            fechaRegistro: '2026-10-01',
            observaciones: '',
            rol: u['Rol'],
            plantId: u['PlantaID'],
            pin: u['PIN'] ?? '',
          ));
        }
      }

      if (data['plants'] is List) {
        for (final p in data['plants']) {
          _webPlants.add(PlantModel(
            id: p['id'],
            codigo: p['codigo'],
            nombre: p['nombre'],
            ubicacion: p['ubicacion'],
            adminId: p['adminId'],
            activa: p['activa'] == 1,
          ));
        }
      }

      // Limpio de actividades, planes, fotos y notificaciones demo:
      // Todo lo operativo se crea desde Super Admin / Admin de Planta o se sincroniza desde la nube.

      // Guardar el estado inicial en el almacenamiento persistente del navegador
      await _persistWebState();
      _webInitialized = true;
    } catch (e) {
      debugPrint('Error en _ensureWebInitialized: $e');
    }
  }

  Future<void> _persistWebState() async {
    if (!kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('web_users_v1', jsonEncode(_webUsers.map((u) => u.toMap()).toList()));
      await prefs.setString('web_plants_v1', jsonEncode(_webPlants.map((p) => p.toMap()).toList()));
      await prefs.setString('web_activities_v1', jsonEncode(_webActivities.map((a) => a.toMap()).toList()));
      await prefs.setString('web_subtasks_v1', jsonEncode(_webSubtasks.map((s) => s.toMap()).toList()));
      await prefs.setString('web_instances_v1', jsonEncode(_webInstances.map((i) => i.toMap()).toList()));
      await prefs.setString('web_proplans_v1', jsonEncode(_webProPlans.map((p) => p.toMap()).toList()));
      await prefs.setString('web_photo_standards_v1', jsonEncode(_webPhotoStandards.map((s) => s.toMap()).toList()));
      await prefs.setString('web_executions_v1', jsonEncode(_webExecutions.map((e) => e.toMap()).toList()));
      await prefs.setString('web_extra_requests_v1', jsonEncode(_webExtraRequests.map((r) => r.toMap()).toList()));
      await prefs.setString('web_notifications_v1', jsonEncode(_webNotifications.map((n) => n.toMap()).toList()));
      await prefs.setString('web_meetings_v1', jsonEncode(_webMeetingRecords.map((m) => m.toMap()).toList()));
      await prefs.setString('web_templates_v1', jsonEncode(_webTemplates.map((t) => t.toMap()).toList()));
    } catch (e) {
      debugPrint('Error al persistir estado web: $e');
    }
  }

  void _seedDefaultTemplatesWeb() {
    if (_webTemplates.isNotEmpty) return;
    _webTemplates.addAll([
      ActivityTemplateModel(
        id: 1,
        nombre: 'Auditoría 5S de Estación & Despeje Operacional',
        descripcion: 'Verificación exhaustiva de orden, limpieza, rotulación y despeje de estación de trabajo.',
        area: 'Producción',
        category: 'Calidad & 5S',
        prioridad: 'Alta',
        fija: true,
        reqFoto: true,
        reqMedicion: false,
        reqComentario: true,
        tipoActividad: 'ejecucion',
        requierePlanAccion: false,
        planAccionObligatorio: false,
        instrucciones: 'Fotografiar estación antes y después del turno. Reportar cualquier desviación.',
        criteriosCumplimiento: 'Cero residuos en suelo, herramientas rotuladas en su sombra.',
        subtareasJson: jsonEncode([
          {'orden': 1, 'nombre': 'Despeje de piso y retiro de material no conforme', 'reqFoto': 1, 'reqMed': 0},
          {'orden': 2, 'nombre': 'Limpieza de cabezal y calandrias', 'reqFoto': 1, 'reqMed': 0},
          {'orden': 3, 'nombre': 'Verificación de panel de control y parada de emergencia', 'reqFoto': 0, 'reqMed': 0},
        ]),
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
      ActivityTemplateModel(
        id: 2,
        nombre: 'Inspección Pre-Operacional de Extrusora / Termoformadora',
        descripcion: 'Control de presiones hidráulicas, temperaturas de zonas y tolerancias mecánicas.',
        area: 'Mantenimiento & Producción',
        category: 'Operación',
        prioridad: 'Crítica',
        fija: true,
        reqFoto: true,
        reqMedicion: true,
        reqComentario: true,
        tipoActividad: 'ejecucion',
        requierePlanAccion: true,
        planAccionObligatorio: false,
        instrucciones: 'Medir presión de bomba y espesor de lámina de arranque.',
        criteriosCumplimiento: 'Presión entre 120-150 bar, temperatura nominal +/- 2°C.',
        subtareasJson: jsonEncode([
          {'orden': 1, 'nombre': 'Medición de presión hidráulica (bar)', 'reqFoto': 0, 'reqMed': 1, 'min': 120.0, 'max': 150.0, 'unidad': 'bar'},
          {'orden': 2, 'nombre': 'Inspección visual de lubricación y fugas', 'reqFoto': 1, 'reqMed': 0},
        ]),
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
      ActivityTemplateModel(
        id: 3,
        nombre: 'Reunión de Cambio de Turno & Acuerdos Operativos',
        descripcion: 'Registro informativo de entregas de turno, metas cumplidas y novedades críticas.',
        area: 'Dirección de Planta',
        category: 'Gestión',
        prioridad: 'Media',
        fija: true,
        reqFoto: false,
        reqMedicion: false,
        reqComentario: true,
        tipoActividad: 'registro',
        requierePlanAccion: true,
        planAccionObligatorio: false,
        instrucciones: 'Anotar participantes, compromisos de mantenimiento y metas para el siguiente turno.',
        criteriosCumplimiento: 'Registro firmado digitalmente con compromisos y responsables asignados.',
        subtareasJson: '[]',
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
    ]);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('track60_fin_enterprise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      final db = await openDatabase(
        filePath,
        version: 1,
        onCreate: _createDB,
      );
      return db;
    }
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await _ensureSchemaAndSeed(db);
      },
    );
    await _ensureSchemaAndSeed(db);
    return db;
  }

  Future<void> _safeAddColumn(Database db, String table, String colDef) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $colDef');
    } catch (_) {}
  }

  Future<void> _ensureDirectorsInDb(Database db) async {
    final directors = [
      {
        'id': 'JAVIER',
        'cedula': '0000000001',
        'nombre': 'Javier Julio',
        'cargo': 'Superadministrador General',
        'area': 'Dirección Corporativa',
        'iniciales': 'JJ',
        'email': 'javier.julio@darnel.com',
        'activo': 1,
        'fechaRegistro': '2026-10-01',
        'observaciones': '',
        'rol': 'superadmin',
        'plantId': 'ALL',
        'pin': '1428',
      },
      {
        'id': 'YL',
        'cedula': '1098765432',
        'nombre': 'Yonny López',
        'cargo': 'Jefe de Planta / Operaciones',
        'area': 'Dirección de Planta',
        'iniciales': 'YL',
        'email': 'yonny.lopez@darnel.com',
        'activo': 1,
        'fechaRegistro': '2026-10-01',
        'observaciones': '',
        'rol': 'admin_planta',
        'plantId': 'PL-EXTRUSA',
        'pin': '1234',
      },
      {
        'id': 'RG',
        'cedula': '1087654321',
        'nombre': 'Roberto Gómez',
        'cargo': 'Jefe de Planta Termoformado',
        'area': 'Dirección de Planta',
        'iniciales': 'RG',
        'email': 'roberto.gomez@darnel.com',
        'activo': 1,
        'fechaRegistro': '2026-10-01',
        'observaciones': '',
        'rol': 'admin_planta',
        'plantId': 'PL-TERMO',
        'pin': '5678',
      },
      {
        'id': 'CM',
        'cedula': '1012345678',
        'nombre': 'Carlos Méndez',
        'cargo': 'Supervisor de Producción Extrusa',
        'area': 'Producción Extrusa',
        'iniciales': 'CM',
        'email': 'carlos.mendez@darnel.com',
        'activo': 1,
        'fechaRegistro': '2026-10-01',
        'observaciones': '',
        'rol': 'supervisor',
        'plantId': 'PL-EXTRUSA',
        'pin': '3344',
      },
      {
        'id': 'MC',
        'cedula': '1034567890',
        'nombre': 'Marcela Castro',
        'cargo': 'Supervisora de Calidad',
        'area': 'Calidad',
        'iniciales': 'MC',
        'email': 'marcela.castro@darnel.com',
        'activo': 1,
        'fechaRegistro': '2026-10-01',
        'observaciones': '',
        'rol': 'supervisor',
        'plantId': 'PL-TERMO',
        'pin': '7788',
      },
    ];

    for (final d in directors) {
      await db.insert('users', d, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _ensureSchemaAndSeed(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          cedula TEXT NOT NULL UNIQUE,
          nombre TEXT NOT NULL,
          cargo TEXT NOT NULL,
          area TEXT NOT NULL,
          iniciales TEXT NOT NULL,
          email TEXT DEFAULT '',
          activo INTEGER NOT NULL DEFAULT 1,
          fechaRegistro TEXT NOT NULL,
          observaciones TEXT DEFAULT '',
          rol TEXT NOT NULL,
          plantId TEXT NOT NULL,
          pin TEXT DEFAULT ''
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS plants (
          id TEXT PRIMARY KEY,
          codigo TEXT NOT NULL UNIQUE,
          nombre TEXT NOT NULL,
          ubicacion TEXT NOT NULL,
          adminId TEXT NOT NULL,
          activa INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId TEXT NOT NULL,
          userId TEXT NOT NULL,
          nombre TEXT NOT NULL,
          descripcion TEXT DEFAULT '',
          area TEXT NOT NULL,
          category TEXT NOT NULL,
          timeStart TEXT NOT NULL,
          timeEnd TEXT NOT NULL,
          fija INTEGER NOT NULL DEFAULT 0,
          dias TEXT NOT NULL,
          prioridad TEXT NOT NULL DEFAULT 'Media',
          reqFoto INTEGER NOT NULL DEFAULT 0,
          reqMedicion INTEGER NOT NULL DEFAULT 0,
          reqComentario INTEGER NOT NULL DEFAULT 0,
          esGlobal INTEGER NOT NULL DEFAULT 0,
          tipoActividad TEXT DEFAULT 'ejecucion',
          requierePlanAccion INTEGER DEFAULT 0,
          planAccionObligatorio INTEGER DEFAULT 0,
          instrucciones TEXT DEFAULT '',
          criteriosCumplimiento TEXT DEFAULT ''
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS instances (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          activityId INTEGER NOT NULL,
          userId TEXT NOT NULL,
          plantId TEXT NOT NULL,
          weekKey TEXT NOT NULL,
          nombre TEXT NOT NULL,
          descripcion TEXT DEFAULT '',
          area TEXT NOT NULL,
          category TEXT NOT NULL,
          timeStart TEXT NOT NULL,
          timeEnd TEXT NOT NULL,
          prioridad TEXT NOT NULL DEFAULT 'Media',
          day INTEGER NOT NULL,
          orig INTEGER NOT NULL,
          fija INTEGER NOT NULL DEFAULT 0,
          done INTEGER NOT NULL DEFAULT 0,
          state TEXT NOT NULL DEFAULT 'Pendiente',
          completedAt TEXT,
          observaciones TEXT,
          motivoNoRealizada TEXT,
          subtasksTotal INTEGER NOT NULL DEFAULT 0,
          subtasksReported INTEGER NOT NULL DEFAULT 0,
          subtasksApproved INTEGER NOT NULL DEFAULT 0,
          tipoActividad TEXT DEFAULT 'ejecucion',
          requierePlanAccion INTEGER DEFAULT 0,
          planAccionObligatorio INTEGER DEFAULT 0,
          instrucciones TEXT DEFAULT '',
          criteriosCumplimiento TEXT DEFAULT ''
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS subtasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          activityId INTEGER NOT NULL,
          orden INTEGER NOT NULL DEFAULT 0,
          nombre TEXT NOT NULL,
          descripcion TEXT DEFAULT '',
          instruccion TEXT DEFAULT '',
          esObligatoria INTEGER NOT NULL DEFAULT 1,
          requiereFoto INTEGER NOT NULL DEFAULT 0,
          requiereComentario INTEGER NOT NULL DEFAULT 0,
          requiereMedicion INTEGER NOT NULL DEFAULT 0,
          unidadMedida TEXT DEFAULT '',
          valorMinimo REAL,
          valorMaximo REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS subtask_executions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subtaskId INTEGER NOT NULL,
          instanceId INTEGER NOT NULL,
          userId TEXT NOT NULL,
          reportada INTEGER NOT NULL DEFAULT 0,
          aprobada INTEGER NOT NULL DEFAULT 0,
          fotoPath TEXT,
          comentario TEXT,
          valorMedido REAL,
          fechaReporte TEXT,
          fechaValidacion TEXT,
          revisorId TEXT,
          motivoRechazo TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          type TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reprogramming_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          instanceId INTEGER NOT NULL,
          userId TEXT NOT NULL,
          fromDay INTEGER NOT NULL,
          toDay INTEGER NOT NULL,
          motivo TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'Pendiente'
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS audit_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          action TEXT NOT NULL,
          entity TEXT NOT NULL,
          entityId INTEGER,
          details TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS proplanes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId TEXT NOT NULL,
          plan TEXT NOT NULL,
          responsable TEXT NOT NULL,
          area TEXT NOT NULL,
          fechaCompromiso TEXT NOT NULL,
          estado TEXT NOT NULL DEFAULT 'Pendiente',
          evidencia TEXT,
          comentarios TEXT,
          creadoPor TEXT NOT NULL,
          fechaCreacion TEXT NOT NULL,
          activityInstanceId INTEGER,
          activityId INTEGER,
          activityNombre TEXT,
          descripcionSituacion TEXT,
          porcentajeAvance REAL DEFAULT 0.0,
          requiereRevision INTEGER DEFAULT 0,
          revisorId TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS plant_photo_standards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId TEXT NOT NULL,
          supervisorId TEXT NOT NULL,
          titulo TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          fotoPath TEXT NOT NULL,
          area TEXT NOT NULL,
          fechaRegistro TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS extra_task_requests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plantId TEXT NOT NULL,
          adminId TEXT NOT NULL,
          nombre TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          area TEXT NOT NULL,
          prioridad TEXT NOT NULL,
          justificacion TEXT NOT NULL,
          dias TEXT NOT NULL,
          timeStart TEXT NOT NULL,
          timeEnd TEXT NOT NULL,
          estado TEXT NOT NULL DEFAULT 'Pendiente',
          motivoRechazo TEXT,
          fechaSolicitud TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meeting_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          instanceId INTEGER NOT NULL,
          activityId INTEGER NOT NULL,
          plantId TEXT NOT NULL,
          usuarioId TEXT NOT NULL,
          usuarioNombre TEXT NOT NULL,
          titulo TEXT NOT NULL,
          fecha TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          participantes TEXT DEFAULT '',
          observaciones TEXT DEFAULT '',
          compromisos TEXT DEFAULT '',
          responsablesCompromisos TEXT DEFAULT '',
          fechaCumplimientoCompromisos TEXT DEFAULT '',
          fotoOAdjuntoPath TEXT,
          fechaRegistro TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activity_templates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          descripcion TEXT DEFAULT '',
          area TEXT NOT NULL,
          category TEXT DEFAULT 'Operación',
          prioridad TEXT DEFAULT 'Alta',
          fija INTEGER DEFAULT 0,
          reqFoto INTEGER DEFAULT 0,
          reqMedicion INTEGER DEFAULT 0,
          reqComentario INTEGER DEFAULT 1,
          tipoActividad TEXT DEFAULT 'ejecucion',
          requierePlanAccion INTEGER DEFAULT 0,
          planAccionObligatorio INTEGER DEFAULT 0,
          instrucciones TEXT DEFAULT '',
          criteriosCumplimiento TEXT DEFAULT '',
          subtareasJson TEXT DEFAULT '[]',
          fechaCreacion TEXT NOT NULL
        )
      ''');

      // Columnas seguras en caso de esquemas previos
      await _safeAddColumn(db, 'users', 'pin TEXT DEFAULT ""');
      await _safeAddColumn(db, 'users', 'rol TEXT DEFAULT "operario"');
      await _safeAddColumn(db, 'users', 'plantId TEXT DEFAULT "PL-EXTRUSA"');
      await _safeAddColumn(db, 'users', 'email TEXT DEFAULT ""');
      await _safeAddColumn(db, 'users', 'observaciones TEXT DEFAULT ""');

      await _safeAddColumn(db, 'activities', 'tipoActividad TEXT DEFAULT "ejecucion"');
      await _safeAddColumn(db, 'activities', 'requierePlanAccion INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'activities', 'planAccionObligatorio INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'activities', 'instrucciones TEXT DEFAULT ""');
      await _safeAddColumn(db, 'activities', 'criteriosCumplimiento TEXT DEFAULT ""');

      await _safeAddColumn(db, 'instances', 'tipoActividad TEXT DEFAULT "ejecucion"');
      await _safeAddColumn(db, 'instances', 'requierePlanAccion INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'instances', 'planAccionObligatorio INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'instances', 'instrucciones TEXT DEFAULT ""');
      await _safeAddColumn(db, 'instances', 'criteriosCumplimiento TEXT DEFAULT ""');

      await _safeAddColumn(db, 'proplanes', 'activityInstanceId INTEGER');
      await _safeAddColumn(db, 'proplanes', 'activityId INTEGER');
      await _safeAddColumn(db, 'proplanes', 'activityNombre TEXT');
      await _safeAddColumn(db, 'proplanes', 'descripcionSituacion TEXT');
      await _safeAddColumn(db, 'proplanes', 'porcentajeAvance REAL DEFAULT 0.0');
      await _safeAddColumn(db, 'proplanes', 'requiereRevision INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'proplanes', 'revisorId TEXT');

      final countRes = await db.rawQuery('SELECT COUNT(*) FROM users');
      final count = Sqflite.firstIntValue(countRes) ?? 0;
      if (count == 0) {
        await _seedInitialData(db);
      }
      await _ensureDirectorsInDb(db);
    } catch (e) {
      debugPrint('Error en _ensureSchemaAndSeed: $e');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Usuarios
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        cedula TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        cargo TEXT NOT NULL,
        area TEXT NOT NULL,
        iniciales TEXT NOT NULL,
        email TEXT DEFAULT '',
        activo INTEGER NOT NULL DEFAULT 1,
        fechaRegistro TEXT NOT NULL,
        observaciones TEXT DEFAULT '',
        rol TEXT NOT NULL,
        plantId TEXT NOT NULL,
        pin TEXT DEFAULT ''
      )
    ''');

    // 2. Plantas
    await db.execute('''
      CREATE TABLE plants (
        id TEXT PRIMARY KEY,
        codigo TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        adminId TEXT NOT NULL,
        activa INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 3. Actividades (Definición Maestra)
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantId TEXT NOT NULL,
        userId TEXT NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT DEFAULT '',
        area TEXT NOT NULL,
        category TEXT NOT NULL,
        timeStart TEXT NOT NULL,
        timeEnd TEXT NOT NULL,
        fija INTEGER NOT NULL DEFAULT 0,
        dias TEXT NOT NULL,
        prioridad TEXT NOT NULL DEFAULT 'Media',
        reqFoto INTEGER NOT NULL DEFAULT 0,
        reqMedicion INTEGER NOT NULL DEFAULT 0,
        reqComentario INTEGER NOT NULL DEFAULT 0,
        esGlobal INTEGER NOT NULL DEFAULT 0,
        tipoActividad TEXT NOT NULL DEFAULT 'ejecucion',
        requierePlanAccion INTEGER NOT NULL DEFAULT 0,
        planAccionObligatorio INTEGER NOT NULL DEFAULT 0,
        instrucciones TEXT DEFAULT '',
        criteriosCumplimiento TEXT DEFAULT ''
      )
    ''');

    // 4. Instancias Diarias de Ejecución
    await db.execute('''
      CREATE TABLE instances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activityId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        plantId TEXT NOT NULL,
        weekKey TEXT NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT DEFAULT '',
        area TEXT NOT NULL,
        category TEXT NOT NULL,
        timeStart TEXT NOT NULL,
        timeEnd TEXT NOT NULL,
        prioridad TEXT NOT NULL,
        day INTEGER NOT NULL,
        orig INTEGER NOT NULL,
        fija INTEGER NOT NULL DEFAULT 0,
        done INTEGER NOT NULL DEFAULT 0,
        state TEXT NOT NULL DEFAULT 'Pendiente',
        completedAt TEXT,
        observaciones TEXT,
        motivoNoRealizada TEXT,
        subtasksTotal INTEGER NOT NULL DEFAULT 0,
        subtasksReported INTEGER NOT NULL DEFAULT 0,
        subtasksApproved INTEGER NOT NULL DEFAULT 0,
        tipoActividad TEXT NOT NULL DEFAULT 'ejecucion',
        requierePlanAccion INTEGER NOT NULL DEFAULT 0,
        planAccionObligatorio INTEGER NOT NULL DEFAULT 0,
        instrucciones TEXT DEFAULT '',
        criteriosCumplimiento TEXT DEFAULT ''
      )
    ''');

    // 5. Subtareas
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activityId INTEGER NOT NULL,
        orden INTEGER NOT NULL DEFAULT 0,
        nombre TEXT NOT NULL,
        descripcion TEXT DEFAULT '',
        instruccion TEXT DEFAULT '',
        esObligatoria INTEGER NOT NULL DEFAULT 1,
        requiereFoto INTEGER NOT NULL DEFAULT 0,
        requiereComentario INTEGER NOT NULL DEFAULT 0,
        requiereMedicion INTEGER NOT NULL DEFAULT 0,
        unidadMedida TEXT DEFAULT '',
        valorMinimo REAL,
        valorMaximo REAL
      )
    ''');

    // 6. Ejecuciones & Evidencias de Subtareas
    await db.execute('''
      CREATE TABLE subtask_executions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subtaskId INTEGER NOT NULL,
        instanceId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        reportada INTEGER NOT NULL DEFAULT 0,
        aprobada INTEGER NOT NULL DEFAULT 0,
        fotoPath TEXT,
        comentario TEXT,
        valorMedido REAL,
        fechaReporte TEXT,
        fechaValidacion TEXT,
        revisorId TEXT,
        motivoRechazo TEXT
      )
    ''');

    // 7. Notificaciones
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 8. Logs de Reprogramación
    await db.execute('''
      CREATE TABLE reprogramming_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        instanceId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        fromDay INTEGER NOT NULL,
        toDay INTEGER NOT NULL,
        motivo TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pendiente'
      )
    ''');

    // 9. Auditoría Inmutable
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        action TEXT NOT NULL,
        entity TEXT NOT NULL,
        entityId INTEGER,
        details TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 10. ProPlanes (Compromisos y Planes de Acción Reunión Diaria)
    await db.execute('''
      CREATE TABLE proplanes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantId TEXT NOT NULL,
        plan TEXT NOT NULL,
        responsable TEXT NOT NULL,
        area TEXT NOT NULL,
        fechaCompromiso TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'Pendiente',
        evidencia TEXT,
        comentarios TEXT,
        creadoPor TEXT NOT NULL,
        fechaCreacion TEXT NOT NULL,
        activityInstanceId INTEGER,
        activityId INTEGER,
        activityNombre TEXT,
        descripcionSituacion TEXT,
        porcentajeAvance REAL DEFAULT 0.0,
        requiereRevision INTEGER DEFAULT 0,
        revisorId TEXT
      )
    ''');

    // 11. Banco de Estándares Visuales de Planta (Gestionado por Supervisor)
    await db.execute('''
      CREATE TABLE plant_photo_standards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantId TEXT NOT NULL,
        supervisorId TEXT NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        fotoPath TEXT NOT NULL,
        area TEXT NOT NULL,
        fechaRegistro TEXT NOT NULL
      )
    ''');

    // 12. Solicitudes de Tareas Excepcionales (>10 tareas)
    await db.execute('''
      CREATE TABLE extra_task_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantId TEXT NOT NULL,
        adminId TEXT NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        area TEXT NOT NULL,
        prioridad TEXT NOT NULL,
        justificacion TEXT NOT NULL,
        dias TEXT NOT NULL,
        timeStart TEXT NOT NULL,
        timeEnd TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'Pendiente',
        motivoRechazo TEXT,
        fechaSolicitud TEXT NOT NULL
      )
    ''');

    // 13. Registros de Información / Reuniones / Novedades
    await db.execute('''
      CREATE TABLE meeting_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        instanceId INTEGER NOT NULL,
        activityId INTEGER NOT NULL,
        plantId TEXT NOT NULL,
        usuarioId TEXT NOT NULL,
        usuarioNombre TEXT NOT NULL,
        titulo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        participantes TEXT DEFAULT '',
        observaciones TEXT DEFAULT '',
        compromisos TEXT DEFAULT '',
        responsablesCompromisos TEXT DEFAULT '',
        fechaCumplimientoCompromisos TEXT DEFAULT '',
        fotoOAdjuntoPath TEXT,
        fechaRegistro TEXT NOT NULL
      )
    ''');

    // Sembrado inicial de datos desde assets
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/track60_data_inicial.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // 1. Sembrar Usuarios
      if (data['users'] is List) {
        for (final u in data['users']) {
          await db.insert('users', {
            'id': u['ID'],
            'cedula': u['Cédula'],
            'nombre': u['Nombre'],
            'cargo': u['Cargo'],
            'area': u['Área'],
            'iniciales': u['Nombre'].toString().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase(),
            'email': u['Email'],
            'activo': u['Activo'],
            'fechaRegistro': '2026-10-01',
            'observaciones': '',
            'rol': u['Rol'],
            'plantId': u['PlantaID'],
            'pin': u['PIN'] ?? '',
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // 2. Sembrar Plantas
      if (data['plants'] is List) {
        for (final p in data['plants']) {
          await db.insert('plants', {
            'id': p['id'],
            'codigo': p['codigo'],
            'nombre': p['nombre'],
            'ubicacion': p['ubicacion'],
            'adminId': p['adminId'],
            'activa': p['activa'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Sin actividades ni notificaciones demo: todo parte limpio desde cero.
    } catch (e) {
      // Ignorar o registrar error en inicialización
    }
  }

  // --- MÉTODOS DE CONSULTA Y OPERACIÓN ---

  Future<List<UserProfile>> getAllUsers() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return List.from(_webUsers);
    }
    final db = await database;
    final res = await db.query('users', orderBy: 'nombre ASC');
    return res.map((m) => UserProfile.fromMap(m)).toList();
  }

  Future<UserProfile?> getUserByCedula(String cedula) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final clean = cedula.trim();
      try {
        return _webUsers.firstWhere((u) => u.cedula == clean);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final res = await db.query('users', where: 'cedula = ?', whereArgs: [cedula.trim()]);
    if (res.isNotEmpty) return UserProfile.fromMap(res.first);
    return null;
  }

  Future<UserProfile?> getUserById(String id) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      try {
        return _webUsers.firstWhere((u) => u.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return UserProfile.fromMap(res.first);
    return null;
  }

  Future<void> insertUser(UserProfile user) => saveUser(user);

  Future<void> saveUser(UserProfile user) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webUsers.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _webUsers[idx] = user;
      } else {
        _webUsers.add(user);
      }
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PlantModel>> getAllPlants() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return List.from(_webPlants);
    }
    final db = await database;
    final res = await db.query('plants', orderBy: 'nombre ASC');
    return res.map((m) => PlantModel.fromMap(m)).toList();
  }

  Future<void> savePlant(PlantModel plant) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webPlants.indexWhere((p) => p.id == plant.id);
      if (idx != -1) {
        _webPlants[idx] = plant;
      } else {
        _webPlants.add(plant);
      }
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.insert('plants', plant.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ActivityInstance>> getInstancesForUserAndWeek(String userId, String weekKey) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webInstances.where((i) => i.userId == userId && i.weekKey == weekKey).toList();
    }
    final db = await database;
    final res = await db.query(
      'instances',
      where: 'userId = ? AND weekKey = ?',
      whereArgs: [userId, weekKey],
      orderBy: 'day ASC, timeStart ASC',
    );
    return res.map((m) => ActivityInstance.fromMap(m)).toList();
  }

  Future<List<ActivityInstance>> getInstancesForPlant(String plantId, String weekKey) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webInstances.where((i) => (i.plantId == plantId || i.plantId == "ALL") && i.weekKey == weekKey).toList();
    }
    final db = await database;
    final res = await db.query(
      'instances',
      where: '(plantId = ? OR plantId = "ALL") AND weekKey = ?',
      whereArgs: [plantId, weekKey],
      orderBy: 'day ASC, timeStart ASC',
    );
    return res.map((m) => ActivityInstance.fromMap(m)).toList();
  }

  Future<void> updateInstanceStatus(int id, bool done, {String? state, String? obs, String? motivo}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webInstances.indexWhere((i) => i.id == id);
      if (idx != -1) {
        _webInstances[idx] = _webInstances[idx].copyWith(
          done: done,
          state: state ?? (done ? 'Reportada' : 'Pendiente'),
          completedAt: done ? DateTime.now() : null,
          observaciones: obs,
          motivoNoRealizada: motivo,
        );
        _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update(
      'instances',
      {
        'done': done ? 1 : 0,
        'state': state ?? (done ? 'Reportada' : 'Pendiente'),
        'completedAt': done ? DateTime.now().toIso8601String() : null,
        if (obs != null) 'observaciones': obs,
        if (motivo != null) 'motivoNoRealizada': motivo,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateInstanceDay(int id, int newDay, String motivo) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webInstances.indexWhere((i) => i.id == id);
      if (idx != -1) {
        _webInstances[idx] = _webInstances[idx].copyWith(
          day: newDay,
          state: 'Reprogramada',
          motivoNoRealizada: motivo,
        );
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update(
      'instances',
      {
        'day': newDay,
        'state': 'Reprogramada',
        'motivoNoRealizada': motivo,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateInstance(ActivityInstance updated) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webInstances.indexWhere((i) => i.id == updated.id);
      if (idx != -1) {
        _webInstances[idx] = updated;
        await _persistWebState();
      }
      return;
    }
    if (updated.id == null) return;
    final db = await database;
    await db.update('instances', updated.toMap(), where: 'id = ?', whereArgs: [updated.id]);
  }

  Future<List<ActivitySubtaskModel>> getSubtasksForActivity(int activityId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webSubtasks.where((s) => s.activityId == activityId).toList();
    }
    final db = await database;
    final res = await db.query('subtasks', where: 'activityId = ?', whereArgs: [activityId], orderBy: 'orden ASC');
    return res.map((m) => ActivitySubtaskModel.fromMap(m)).toList();
  }

  Future<int> insertSubtask(ActivitySubtaskModel subtask) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webSubtasks.length + 1;
      _webSubtasks.add(subtask.copyWith(id: newId));
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('subtasks', subtask.toMap());
  }

  Future<List<SubtaskExecutionModel>> getSubtaskExecutionsForInstance(int instanceId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webExecutions.where((e) => e.instanceId == instanceId).toList();
    }
    final db = await database;
    final res = await db.query('subtask_executions', where: 'instanceId = ?', whereArgs: [instanceId]);
    return res.map((m) => SubtaskExecutionModel.fromMap(m)).toList();
  }

  Future<void> saveSubtaskExecution(SubtaskExecutionModel exec) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webExecutions.indexWhere((e) => e.id == exec.id && exec.id != null);
      if (idx != -1) {
        _webExecutions[idx] = exec;
      } else {
        _webExecutions.add(exec.copyWith(id: _webExecutions.length + 1));
      }
      final executions = _webExecutions.where((e) => e.instanceId == exec.instanceId).toList();
      final reported = executions.where((e) => e.reportada).length;
      final approved = executions.where((e) => e.aprobada).length;
      final insIdx = _webInstances.indexWhere((i) => i.id == exec.instanceId);
      if (insIdx != -1) {
        _webInstances[insIdx] = _webInstances[insIdx].copyWith(
          subtasksReported: reported,
          subtasksApproved: approved,
        );
      }
      await _persistWebState();
      return;
    }
    final db = await database;
    if (exec.id != null) {
      await db.update('subtask_executions', exec.toMap(), where: 'id = ?', whereArgs: [exec.id]);
    } else {
      await db.insert('subtask_executions', exec.toMap());
    }

    // Actualizar recuento de subtareas reportadas en la instancia
    final executions = await getSubtaskExecutionsForInstance(exec.instanceId);
    final reported = executions.where((e) => e.reportada).length;
    final approved = executions.where((e) => e.aprobada).length;

    await db.update(
      'instances',
      {
        'subtasksReported': reported,
        'subtasksApproved': approved,
      },
      where: 'id = ?',
      whereArgs: [exec.instanceId],
    );
  }

  Future<void> reviewSubtaskExecution({
    required int executionId,
    required bool aprobada,
    required String revisorId,
    String? motivoRechazo,
  }) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webExecutions.indexWhere((e) => e.id == executionId);
      if (idx != -1) {
        _webExecutions[idx] = _webExecutions[idx].copyWith(
          aprobada: aprobada,
          fechaValidacion: DateTime.now(),
          revisorId: revisorId,
          motivoRechazo: motivoRechazo,
        );
        final instanceId = _webExecutions[idx].instanceId;
        final executions = _webExecutions.where((e) => e.instanceId == instanceId).toList();
        final reported = executions.where((e) => e.reportada).length;
        final approved = executions.where((e) => e.aprobada).length;
        final insIdx = _webInstances.indexWhere((i) => i.id == instanceId);
        if (insIdx != -1) {
          _webInstances[insIdx] = _webInstances[insIdx].copyWith(
            subtasksReported: reported,
            subtasksApproved: approved,
          );
        }
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update(
      'subtask_executions',
      {
        'aprobada': aprobada ? 1 : 0,
        'fechaValidacion': DateTime.now().toIso8601String(),
        'revisorId': revisorId,
        'motivoRechazo': motivoRechazo,
      },
      where: 'id = ?',
      whereArgs: [executionId],
    );
  }

  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webNotifications.where((n) => n.userId == userId).toList();
    }
    final db = await database;
    final res = await db.query('notifications', where: 'userId = ?', whereArgs: [userId], orderBy: 'id DESC');
    return res.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<void> insertNotification(NotificationModel notif) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webNotifications.insert(0, notif.copyWith(id: _webNotifications.length + 1));
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.insert('notifications', notif.toMap());
  }

  Future<void> markNotificationAsRead(int id) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webNotifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _webNotifications[idx] = _webNotifications[idx].copyWith(isRead: true);
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('notifications', {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      for (int i = 0; i < _webNotifications.length; i++) {
        if (_webNotifications[i].userId == userId) {
          _webNotifications[i] = _webNotifications[i].copyWith(isRead: true);
        }
      }
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.update('notifications', {'isRead': 1}, where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> logAudit(AuditLogModel log) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webAuditLogs.insert(0, log);
      return;
    }
    final db = await database;
    await db.insert('audit_logs', log.toMap());
  }

  Future<List<AuditLogModel>> getAuditLogs() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return List.from(_webAuditLogs);
    }
    final db = await database;
    final res = await db.query('audit_logs', orderBy: 'id DESC', limit: 100);
    return res.map((m) => AuditLogModel.fromMap(m)).toList();
  }

  Future<int> insertActivity(ActivityModel act) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webActivities.length + 1;
      _webActivities.add(act.copyWith(id: newId));
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('activities', act.toMap());
  }

  Future<int> insertInstance(ActivityInstance instance) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webInstances.length + 1;
      _webInstances.add(instance.copyWith(id: newId));
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('instances', instance.toMap());
  }

  Future<List<ActivityModel>> getAllActivities() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return List.from(_webActivities);
    }
    final db = await database;
    final res = await db.query('activities', orderBy: 'id DESC');
    return res.map((m) => ActivityModel.fromMap(m)).toList();
  }

  // --- CRUD OPERACIONES: PROPLANES ---
  Future<List<ProPlanModel>> getProPlans({String? plantId}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      if (plantId != null && plantId != 'ALL') {
        return _webProPlans.where((p) => p.plantId == plantId).toList();
      }
      return List.from(_webProPlans);
    }
    final db = await database;
    List<Map<String, dynamic>> res;
    if (plantId != null && plantId != 'ALL') {
      res = await db.query('proplanes', where: 'plantId = ?', whereArgs: [plantId], orderBy: 'id DESC');
    } else {
      res = await db.query('proplanes', orderBy: 'id DESC');
    }
    return res.map((m) => ProPlanModel.fromMap(m)).toList();
  }

  Future<int> insertProPlan(ProPlanModel plan) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webProPlans.length + 1;
      _webProPlans.insert(0, plan.copyWith(id: newId));
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('proplanes', plan.toMap());
  }

  Future<void> updateProPlan(ProPlanModel plan) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webProPlans.indexWhere((p) => p.id == plan.id);
      if (idx != -1) {
        _webProPlans[idx] = plan;
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('proplanes', plan.toMap(), where: 'id = ?', whereArgs: [plan.id]);
  }

  Future<void> deleteProPlan(int id) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webProPlans.removeWhere((p) => p.id == id);
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.delete('proplanes', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD OPERACIONES: ESTÁNDARES VISUALES / FOTOS SUPERVISOR ---
  Future<List<PlantPhotoStandardModel>> getPlantPhotoStandards({String? plantId}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      if (plantId != null && plantId != 'ALL') {
        return _webPhotoStandards.where((s) => s.plantId == plantId).toList();
      }
      return List.from(_webPhotoStandards);
    }
    final db = await database;
    List<Map<String, dynamic>> res;
    if (plantId != null && plantId != 'ALL') {
      res = await db.query('plant_photo_standards', where: 'plantId = ?', whereArgs: [plantId], orderBy: 'id DESC');
    } else {
      res = await db.query('plant_photo_standards', orderBy: 'id DESC');
    }
    return res.map((m) => PlantPhotoStandardModel.fromMap(m)).toList();
  }

  Future<int> insertPlantPhotoStandard(PlantPhotoStandardModel std) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webPhotoStandards.length + 1;
      _webPhotoStandards.insert(0, std.copyWith(id: newId));
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('plant_photo_standards', std.toMap());
  }

  Future<void> updatePlantPhotoStandard(PlantPhotoStandardModel std) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webPhotoStandards.indexWhere((s) => s.id == std.id);
      if (idx != -1) {
        _webPhotoStandards[idx] = std;
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('plant_photo_standards', std.toMap(), where: 'id = ?', whereArgs: [std.id]);
  }

  Future<void> deletePlantPhotoStandard(int id) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webPhotoStandards.removeWhere((s) => s.id == id);
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.delete('plant_photo_standards', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD OPERACIONES: SOLICITUDES DE TAREAS EXCEPCIONALES (>10) ---
  Future<List<ExtraTaskRequestModel>> getExtraTaskRequests({String? plantId}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      if (plantId != null && plantId != 'ALL') {
        return _webExtraRequests.where((r) => r.plantId == plantId).toList();
      }
      return List.from(_webExtraRequests);
    }
    final db = await database;
    List<Map<String, dynamic>> res;
    if (plantId != null && plantId != 'ALL') {
      res = await db.query('extra_task_requests', where: 'plantId = ?', whereArgs: [plantId], orderBy: 'id DESC');
    } else {
      res = await db.query('extra_task_requests', orderBy: 'id DESC');
    }
    return res.map((m) => ExtraTaskRequestModel.fromMap(m)).toList();
  }

  Future<int> insertExtraTaskRequest(ExtraTaskRequestModel req) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webExtraRequests.length + 1;
      _webExtraRequests.insert(0, req.copyWith(id: newId));
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('extra_task_requests', req.toMap());
  }

  Future<void> updateExtraTaskRequest(ExtraTaskRequestModel req) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webExtraRequests.indexWhere((r) => r.id == req.id);
      if (idx != -1) {
        _webExtraRequests[idx] = req;
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('extra_task_requests', req.toMap(), where: 'id = ?', whereArgs: [req.id]);
  }

  // --- CRUD GENÉRICO TOTAL: PLANTAS, USUARIOS, ACTIVIDADES ---
  Future<void> updatePlant(PlantModel plant) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webPlants.indexWhere((p) => p.id == plant.id);
      if (idx != -1) {
        _webPlants[idx] = plant;
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('plants', plant.toMap(), where: 'id = ?', whereArgs: [plant.id]);
  }

  Future<void> deletePlant(String plantId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webPlants.removeWhere((p) => p.id == plantId);
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.delete('plants', where: 'id = ?', whereArgs: [plantId]);
  }

  Future<void> updateUser(UserProfile user) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webUsers.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _webUsers[idx] = user;
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteUser(String userId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webUsers.removeWhere((u) => u.id == userId);
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateActivity(ActivityModel act) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webActivities.indexWhere((a) => a.id == act.id);
      if (idx != -1) {
        _webActivities[idx] = act;
        await _persistWebState();
      }
      return;
    }
    final db = await database;
    await db.update('activities', act.toMap(), where: 'id = ?', whereArgs: [act.id]);
  }

  Future<void> deleteActivity(int activityId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webActivities.removeWhere((a) => a.id == activityId);
      _webSubtasks.removeWhere((s) => s.activityId == activityId);
      _webInstances.removeWhere((i) => i.activityId == activityId);
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.delete('activities', where: 'id = ?', whereArgs: [activityId]);
    await db.delete('subtasks', where: 'activityId = ?', whereArgs: [activityId]);
    await db.delete('instances', where: 'activityId = ?', whereArgs: [activityId]);
  }

  Future<void> deleteInstance(int instanceId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webInstances.removeWhere((i) => i.id == instanceId);
      _webExecutions.removeWhere((e) => e.instanceId == instanceId);
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.delete('instances', where: 'id = ?', whereArgs: [instanceId]);
    await db.delete('subtask_executions', where: 'instanceId = ?', whereArgs: [instanceId]);
  }

  // --- MÉTODOS DE REASIGNACIÓN Y SUPERVISIÓN PARA WEB/NATIVO ---
  Future<void> reassignUserInstances({
    required String fromUserId,
    required String toUserId,
    required int day,
    required String weekKey,
  }) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      for (int i = 0; i < _webInstances.length; i++) {
        final ins = _webInstances[i];
        if (ins.userId == fromUserId && ins.day == day && ins.weekKey == weekKey) {
          _webInstances[i] = ins.copyWith(userId: toUserId);
        }
      }
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.update(
      'instances',
      {'userId': toUserId},
      where: 'userId = ? AND day = ? AND weekKey = ?',
      whereArgs: [fromUserId, day, weekKey],
    );
  }

  Future<List<SubtaskExecutionModel>> getPendingReviewsForPlant(String plantId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final plantInstanceIds = _webInstances
          .where((i) => i.plantId == plantId || plantId == 'ALL')
          .map((i) => i.id)
          .toSet();
      return _webExecutions
          .where((e) => plantInstanceIds.contains(e.instanceId) && !e.aprobada)
          .toList();
    }
    final db = await database;
    final res = await db.rawQuery('''
      SELECT e.* FROM subtask_executions e
      INNER JOIN instances i ON e.instanceId = i.id
      WHERE (i.plantId = ? OR ? = 'ALL') AND e.aprobada = 0
      ORDER BY e.fechaReporte DESC
    ''', [plantId, plantId]);
    return res.map((m) => SubtaskExecutionModel.fromMap(m)).toList();
  }

  Future<void> reassignActivityInstances({
    required int activityId,
    required String plantId,
    required String newUserId,
  }) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      for (int i = 0; i < _webInstances.length; i++) {
        final ins = _webInstances[i];
        if (ins.activityId == activityId && ins.plantId == plantId) {
          _webInstances[i] = ins.copyWith(userId: newUserId);
        }
      }
      await _persistWebState();
      return;
    }
    final db = await database;
    await db.update(
      'instances',
      {'userId': newUserId},
      where: 'activityId = ? AND plantId = ?',
      whereArgs: [activityId, plantId],
    );
  }

  // --- CRUD: REGISTROS DE INFORMACIÓN / REUNIÓN / NOVEDAD ---
  Future<int> insertMeetingRecord(MeetingRecordModel record) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = _webMeetingRecords.length + 1;
      final saved = record.copyWith(id: newId);
      _webMeetingRecords.insert(0, saved);
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('meeting_records', record.toMap());
  }

  Future<List<MeetingRecordModel>> getMeetingRecords({String? plantId, int? instanceId}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webMeetingRecords.where((r) {
        final matchesPlant = plantId == null || plantId == 'ALL' || r.plantId == plantId;
        final matchesInst = instanceId == null || r.instanceId == instanceId;
        return matchesPlant && matchesInst;
      }).toList();
    }
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (plantId != null && plantId != 'ALL') {
      whereClause = 'plantId = ?';
      whereArgs.add(plantId);
    }
    if (instanceId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'instanceId = ?';
      whereArgs.add(instanceId);
    }
    final res = await db.query(
      'meeting_records',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );
    return res.map((m) => MeetingRecordModel.fromMap(m)).toList();
  }

  Future<MeetingRecordModel?> getMeetingRecordForInstance(int instanceId) async {
    final list = await getMeetingRecords(instanceId: instanceId);
    if (list.isNotEmpty) return list.first;
    return null;
  }

  // --- CRUD DE PLANTILLAS ESTÁNDAR (TEMPLATES) ---

  Future<List<ActivityTemplateModel>> getAllTemplates() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      if (_webTemplates.isEmpty) _seedDefaultTemplatesWeb();
      return List.unmodifiable(_webTemplates);
    }
    final db = await database;
    final res = await db.query('activity_templates', orderBy: 'id DESC');
    if (res.isEmpty) {
      // Seed inicial nativo
      final defs = [
        ActivityTemplateModel(
          nombre: 'Auditoría 5S de Estación & Despeje Operacional',
          descripcion: 'Verificación exhaustiva de orden, limpieza, rotulación y despeje de estación de trabajo.',
          area: 'Producción',
          category: 'Calidad & 5S',
          prioridad: 'Alta',
          fija: true,
          reqFoto: true,
          reqMedicion: false,
          reqComentario: true,
          tipoActividad: 'ejecucion',
          requierePlanAccion: false,
          planAccionObligatorio: false,
          instrucciones: 'Fotografiar estación antes y después del turno. Reportar cualquier desviación.',
          criteriosCumplimiento: 'Cero residuos en suelo, herramientas rotuladas en su sombra.',
          subtareasJson: jsonEncode([
            {'orden': 1, 'nombre': 'Despeje de piso y retiro de material no conforme', 'reqFoto': 1, 'reqMed': 0},
            {'orden': 2, 'nombre': 'Limpieza de cabezal y calandrias', 'reqFoto': 1, 'reqMed': 0},
            {'orden': 3, 'nombre': 'Verificación de panel de control y parada de emergencia', 'reqFoto': 0, 'reqMed': 0},
          ]),
          fechaCreacion: DateTime.now().toIso8601String(),
        ),
        ActivityTemplateModel(
          nombre: 'Inspección Pre-Operacional de Extrusora / Termoformadora',
          descripcion: 'Control de presiones hidráulicas, temperaturas de zonas y tolerancias mecánicas.',
          area: 'Mantenimiento & Producción',
          category: 'Operación',
          prioridad: 'Crítica',
          fija: true,
          reqFoto: true,
          reqMedicion: true,
          reqComentario: true,
          tipoActividad: 'ejecucion',
          requierePlanAccion: true,
          planAccionObligatorio: false,
          instrucciones: 'Medir presión de bomba y espesor de lámina de arranque.',
          criteriosCumplimiento: 'Presión entre 120-150 bar, temperatura nominal +/- 2°C.',
          subtareasJson: jsonEncode([
            {'orden': 1, 'nombre': 'Medición de presión hidráulica (bar)', 'reqFoto': 0, 'reqMed': 1, 'min': 120.0, 'max': 150.0, 'unidad': 'bar'},
            {'orden': 2, 'nombre': 'Inspección visual de lubricación y fugas', 'reqFoto': 1, 'reqMed': 0},
          ]),
          fechaCreacion: DateTime.now().toIso8601String(),
        ),
        ActivityTemplateModel(
          nombre: 'Reunión de Cambio de Turno & Acuerdos Operativos',
          descripcion: 'Registro informativo de entregas de turno, metas cumplidas y novedades críticas.',
          area: 'Dirección de Planta',
          category: 'Gestión',
          prioridad: 'Media',
          fija: true,
          reqFoto: false,
          reqMedicion: false,
          reqComentario: true,
          tipoActividad: 'registro',
          requierePlanAccion: true,
          planAccionObligatorio: false,
          instrucciones: 'Anotar participantes, compromisos de mantenimiento y metas para el siguiente turno.',
          criteriosCumplimiento: 'Registro firmado digitalmente con compromisos y responsables asignados.',
          subtareasJson: '[]',
          fechaCreacion: DateTime.now().toIso8601String(),
        ),
      ];
      for (final d in defs) {
        await db.insert('activity_templates', d.toMap());
      }
      final seeded = await db.query('activity_templates', orderBy: 'id DESC');
      return seeded.map((m) => ActivityTemplateModel.fromMap(m)).toList();
    }
    return res.map((m) => ActivityTemplateModel.fromMap(m)).toList();
  }

  Future<int> insertTemplate(ActivityTemplateModel template) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final newId = (_webTemplates.isEmpty ? 1 : (_webTemplates.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1));
      final saved = template.copyWith(id: newId);
      _webTemplates.insert(0, saved);
      await _persistWebState();
      return newId;
    }
    final db = await database;
    return await db.insert('activity_templates', template.toMap());
  }

  Future<int> updateTemplate(ActivityTemplateModel template) async {
    if (template.id == null) return 0;
    if (kIsWeb) {
      await _ensureWebInitialized();
      final idx = _webTemplates.indexWhere((t) => t.id == template.id);
      if (idx != -1) {
        _webTemplates[idx] = template;
        await _persistWebState();
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(
      'activity_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> deleteTemplate(int id) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webTemplates.removeWhere((t) => t.id == id);
      await _persistWebState();
      return 1;
    }
    final db = await database;
    return await db.delete('activity_templates', where: 'id = ?', whereArgs: [id]);
  }
}

