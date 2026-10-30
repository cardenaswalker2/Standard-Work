import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/app_models.dart';

class DatabaseHelper {
  static const String _dbName = 'darnel_standard_work.db';
  static const int _dbVersion = 4;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Permite inyectar base de datos para pruebas unitarias con sqflite_common_ffi
  void setDatabaseForTesting(Database testDb) {
    _db = testDb;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS audit_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          action TEXT NOT NULL,
          entity TEXT NOT NULL,
          entityId INTEGER NOT NULL,
          details TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await _createExcelScheduleTable(db);
      // Asegurar perfil de Yonny López en bases existentes
      await db.insert('profiles', const UserProfile(
        id: 'YL',
        nombre: 'Yonny López',
        cargo: 'Jefe de Planta / Operaciones Extrusa',
        area: 'Planta Extrusa',
        iniciales: 'YL',
      ).toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    if (oldVersion < 4) {
      // Migración V4: Añadir category, timeStart, timeEnd a activities e instances, y area a instances
      try {
        await db.execute("ALTER TABLE activities ADD COLUMN category TEXT DEFAULT 'Operación y Ejecución'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE activities ADD COLUMN timeStart TEXT DEFAULT '08:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE activities ADD COLUMN timeEnd TEXT DEFAULT '08:30'");
      } catch (_) {}

      try {
        await db.execute("ALTER TABLE instances ADD COLUMN area TEXT DEFAULT 'Planta Extrusa'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE instances ADD COLUMN category TEXT DEFAULT 'Operación y Ejecución'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE instances ADD COLUMN timeStart TEXT DEFAULT '08:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE instances ADD COLUMN timeEnd TEXT DEFAULT '08:30'");
      } catch (_) {}
    }
  }

  Future<void> _createExcelScheduleTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS excel_schedule (
        id INTEGER PRIMARY KEY,
        weekNumber INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        dayName TEXT NOT NULL,
        timeStart TEXT NOT NULL,
        timeEnd TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        activityName TEXT NOT NULL,
        originalName TEXT NOT NULL,
        category TEXT NOT NULL,
        isFixed INTEGER NOT NULL DEFAULT 0,
        excelSheet TEXT NOT NULL,
        excelRow INTEGER NOT NULL,
        excelCol INTEGER NOT NULL,
        excelCell TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla de Perfiles
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        cargo TEXT NOT NULL,
        area TEXT NOT NULL,
        iniciales TEXT NOT NULL
      )
    ''');

    // 2. Tabla de Definición de Actividades
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        dias TEXT NOT NULL,
        fija INTEGER NOT NULL DEFAULT 0,
        area TEXT NOT NULL,
        category TEXT DEFAULT 'Operación y Ejecución',
        timeStart TEXT DEFAULT '08:00',
        timeEnd TEXT DEFAULT '08:30',
        activa INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (userId) REFERENCES profiles (id)
      )
    ''');

    // 3. Tabla de Instancias Semanales
    await db.execute('''
      CREATE TABLE instances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activityId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        weekKey TEXT NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        day INTEGER NOT NULL,
        orig INTEGER NOT NULL,
        fija INTEGER NOT NULL DEFAULT 0,
        area TEXT DEFAULT 'Planta Extrusa',
        category TEXT DEFAULT 'Operación y Ejecución',
        timeStart TEXT DEFAULT '08:00',
        timeEnd TEXT DEFAULT '08:30',
        done INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        observaciones TEXT,
        motivoNoRealizada TEXT,
        FOREIGN KEY (activityId) REFERENCES activities (id),
        FOREIGN KEY (userId) REFERENCES profiles (id)
      )
    ''');

    // 4. Tabla de Historial Acumulado (Mes / Año)
    await db.execute('''
      CREATE TABLE history (
        userId TEXT NOT NULL,
        activityName TEXT NOT NULL,
        mD INTEGER NOT NULL DEFAULT 0,
        mT INTEGER NOT NULL DEFAULT 0,
        yD INTEGER NOT NULL DEFAULT 0,
        yT INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (userId, activityName),
        FOREIGN KEY (userId) REFERENCES profiles (id)
      )
    ''');

    // 5. Tabla de Preferencias Locales
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 6. Tabla de Auditoría Local
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        action TEXT NOT NULL,
        entity TEXT NOT NULL,
        entityId INTEGER NOT NULL,
        details TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 7. Tabla de Programación Completa de 4 Semanas del Excel
    await _createExcelScheduleTable(db);

    // Poblado inicial con la información exacta del HTML
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Perfiles
    final profiles = [
      const UserProfile(
        id: 'X',
        nombre: 'Usuario X · Carlos Méndez',
        cargo: 'Supervisor de Producción',
        area: 'Producción',
        iniciales: 'CM',
      ),
      const UserProfile(
        id: 'Y',
        nombre: 'Usuario Y · Laura Pérez',
        cargo: 'Coordinadora de Calidad',
        area: 'Calidad',
        iniciales: 'LP',
      ),
      const UserProfile(
        id: 'Z',
        nombre: 'Usuario Z · Andrés Ruiz',
        cargo: 'Líder de Logística',
        area: 'Logística',
        iniciales: 'AR',
      ),
      const UserProfile(
        id: 'YL',
        nombre: 'Yonny López',
        cargo: 'Jefe de Planta / Operaciones Extrusa',
        area: 'Planta Extrusa',
        iniciales: 'YL',
      ),
    ];

    for (final p in profiles) {
      await db.insert('profiles', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Actividades base e individuales idénticas a Mira.html
    final List<Map<String, dynamic>> rawActivities = [
      // Base para todos
      {'u': 'X', 'n': 'Reunión Diaria (Visual Room)', 'd': 'Revisión de KPIs, seguridad y prioridades del día', 'dias': '[1,2,3,4,5]', 'f': 1, 'a': 'Producción'},
      {'u': 'X', 'n': 'Gemba Walk', 'd': 'Recorrido en piso', 'dias': '[1,2,3,4,5]', 'f': 1, 'a': 'Producción'},
      {'u': 'X', 'n': 'Revisión OEE', 'd': 'Análisis de paradas y desempeño de línea', 'dias': '[1,3,5]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Seguimiento de Scrap', 'd': 'Pareto de desperdicio y acciones', 'dias': '[2,4]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Auditoría 5S', 'd': 'Orden y limpieza del área', 'dias': '[3]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Verificación de setup', 'd': 'Cambios de referencia y arranques', 'dias': '[1,4]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Seguimiento planes de acción', 'd': 'Estado de acciones abiertas', 'dias': '[2,5]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Charla de seguridad', 'd': 'Tema de seguridad con el turno', 'dias': '[1]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Revisión de mantenimiento', 'd': 'Órdenes de trabajo y paros programados', 'dias': '[3]', 'f': 0, 'a': 'Producción'},
      {'u': 'X', 'n': 'Cierre semanal de indicadores', 'd': 'Consolidado de producción', 'dias': '[5]', 'f': 0, 'a': 'Producción'},

      // Usuario Y (Calidad)
      {'u': 'Y', 'n': 'Reunión Diaria (Visual Room)', 'd': 'Revisión de KPIs, seguridad y prioridades del día', 'dias': '[1,2,3,4,5]', 'f': 1, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Gemba Walk', 'd': 'Recorrido en piso', 'dias': '[1,2,3,4,5]', 'f': 1, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Liberación de lotes', 'd': 'Verificación de producto terminado', 'dias': '[1,2,4]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Revisión de reclamos', 'd': 'Seguimiento RNC con clientes', 'dias': '[1,4]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Calibración de equipos', 'd': 'Laboratorio de calidad', 'dias': '[2]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Auditoría de proceso', 'd': 'Parámetros críticos de línea', 'dias': '[3,5]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Control de no conformes', 'd': 'Producto retenido y disposición', 'dias': '[2,4]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Revisión de PPM', 'd': 'Defectos por millón', 'dias': '[3]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Verificación de inocuidad', 'd': 'Buenas prácticas de manufactura', 'dias': '[1,5]', 'f': 0, 'a': 'Calidad'},
      {'u': 'Y', 'n': 'Reporte semanal de calidad', 'd': 'Consolidado para gerencia', 'dias': '[5]', 'f': 0, 'a': 'Calidad'},

      // Usuario Z (Logística)
      {'u': 'Z', 'n': 'Reunión Diaria (Visual Room)', 'd': 'Revisión de KPIs, seguridad y prioridades del día', 'dias': '[1,2,3,4,5]', 'f': 1, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Gemba Walk', 'd': 'Recorrido en piso', 'dias': '[1,2,3,4,5]', 'f': 1, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Plan de cargue', 'd': 'Programación de despachos', 'dias': '[1,3,5]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Checklist montacargas', 'd': 'Inspección preoperacional', 'dias': '[1,3]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Inventario cíclico', 'd': 'Conteo de bodega PT', 'dias': '[2,4]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Revisión de OTIF', 'd': 'Entregas a tiempo y completas', 'dias': '[1,4]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Control de exportaciones', 'd': 'Documentación y contenedores', 'dias': '[2,5]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Auditoría 5S bodega', 'd': 'Orden y señalización', 'dias': '[3]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Revisión con transportadores', 'd': 'Novedades y programación', 'dias': '[4]', 'f': 0, 'a': 'Logística'},
      {'u': 'Z', 'n': 'Cierre semanal logístico', 'd': 'Indicadores y pendientes', 'dias': '[5]', 'f': 0, 'a': 'Logística'},
    ];

    for (final a in rawActivities) {
      await db.insert('activities', {
        'userId': a['u'],
        'nombre': a['n'],
        'descripcion': a['d'],
        'dias': a['dias'],
        'fija': a['f'],
        'area': a['a'],
        'activa': 1,
      });

      // Historial base coherente (valores históricos calculados por semilla controlada)
      await db.insert('history', {
        'userId': a['u'],
        'activityName': a['n'],
        'mD': 12,
        'mT': 15,
        'yD': 98,
        'yT': 115,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
