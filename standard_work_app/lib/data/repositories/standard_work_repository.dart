import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/app_models.dart';
import '../models/excel_schedule_models.dart';

class StandardWorkRepository {
  final DatabaseHelper _dbHelper;

  StandardWorkRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // --- PERFILES ---
  Future<List<UserProfile>> getAllProfiles() async {
    final db = await _dbHelper.database;
    final res = await db.query('profiles');
    return res.map((m) => UserProfile.fromMap(m)).toList();
  }

  Future<UserProfile?> getProfileById(String id) async {
    final db = await _dbHelper.database;
    final res = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return UserProfile.fromMap(res.first);
    return null;
  }

  // --- ACTIVIDADES MAESTRAS ---
  Future<List<ActivityModel>> getActivitiesForUser(String userId) async {
    final db = await _dbHelper.database;
    final res = await db.query('activities',
        where: 'userId = ? AND activa = 1', whereArgs: [userId]);
    return res.map((m) => ActivityModel.fromMap(m)).toList();
  }

  Future<int> insertActivity(ActivityModel activity) async {
    final db = await _dbHelper.database;
    return await db.insert('activities', activity.toMap());
  }

  Future<int> updateActivity(ActivityModel activity) async {
    final db = await _dbHelper.database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> archiveActivity(int activityId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'activities',
      {'activa': 0},
      where: 'id = ? AND fija = 0',
      whereArgs: [activityId],
    );
  }

  // --- INSTANCIAS SEMANALES ---
  Future<List<ActivityInstance>> getInstancesForWeek(
      String userId, String weekKey, int simulatedHoy) async {
    final db = await _dbHelper.database;
    final existing = await db.query('instances',
        where: 'userId = ? AND weekKey = ?', whereArgs: [userId, weekKey]);

    if (existing.isNotEmpty) {
      return existing.map((m) => ActivityInstance.fromMap(m)).toList();
    }

    // Si no existen instancias para esta semana, las sembramos desde las actividades maestras
    return await _seedInstancesForWeek(userId, weekKey, simulatedHoy);
  }

  Future<List<ActivityInstance>> _seedInstancesForWeek(
      String userId, String weekKey, int simulatedHoy) async {
    final db = await _dbHelper.database;
    final activities = await getActivitiesForUser(userId);
    final List<ActivityInstance> created = [];

    await db.transaction((txn) async {
      for (final a in activities) {
        for (final d in a.diasList) {
          // Si el día de la actividad ya pasó antes del día simulado "HOY",
          // asignamos un estado completado realista para pruebas
          final isPast = d < simulatedHoy;
          final isDone = isPast; // Completadas las de días anteriores
          final inst = ActivityInstance(
            activityId: a.id ?? 0,
            userId: userId,
            weekKey: weekKey,
            nombre: a.nombre,
            descripcion: a.descripcion,
            day: d,
            orig: d,
            fija: a.fija,
            done: isDone,
            completedAt: isDone ? DateTime.now().subtract(Duration(days: simulatedHoy - d)) : null,
          );

          final id = await txn.insert('instances', inst.toMap());
          created.add(inst.copyWith(id: id));
        }

        // Asegurar que exista en historial
        final histCheck = await txn.query('history',
            where: 'userId = ? AND activityName = ?',
            whereArgs: [userId, a.nombre]);
        if (histCheck.isEmpty) {
          await txn.insert('history', {
            'userId': userId,
            'activityName': a.nombre,
            'mD': 10,
            'mT': 12,
            'yD': 85,
            'yT': 98,
          });
        }
      }
    });

    return created;
  }

  Future<void> updateInstanceStatus(int id, bool done, {String? obs, String? motivo}) async {
    final db = await _dbHelper.database;
    await db.update(
      'instances',
      {
        'done': done ? 1 : 0,
        'completedAt': done ? DateTime.now().toIso8601String() : null,
        'observaciones': obs,
        'motivoNoRealizada': motivo,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> moveInstance(int id, int newDay) async {
    final db = await _dbHelper.database;
    await db.update(
      'instances',
      {
        'day': newDay,
        'done': 0, // Al moverla queda pendiente en el nuevo día
      },
      where: 'id = ? AND fija = 0',
      whereArgs: [id],
    );
  }

  Future<void> addInstancesForNewActivity(
      ActivityModel activity, String weekKey) async {
    final db = await _dbHelper.database;
    final actId = await db.insert('activities', activity.toMap());
    final List<int> days = activity.diasList;

    for (final d in days) {
      final inst = ActivityInstance(
        activityId: actId,
        userId: activity.userId,
        weekKey: weekKey,
        nombre: activity.nombre,
        descripcion: activity.descripcion,
        day: d,
        orig: d,
        fija: activity.fija,
        done: false,
        area: activity.area,
        category: activity.category,
        timeStart: activity.timeStart,
        timeEnd: activity.timeEnd,
      );
      await db.insert('instances', inst.toMap());
    }

    // Inicializar historial
    final histCheck = await db.query('history',
        where: 'userId = ? AND activityName = ?',
        whereArgs: [activity.userId, activity.nombre]);
    if (histCheck.isEmpty) {
      await db.insert('history', {
        'userId': activity.userId,
        'activityName': activity.nombre,
        'mD': 0,
        'mT': 0,
        'yD': 0,
        'yT': 0,
      });
    }
  }

  // --- HISTORIAL & INDICADORES ---
  Future<Map<String, ActivityHistory>> getHistoryForUser(String userId) async {
    final db = await _dbHelper.database;
    final res = await db.query('history', where: 'userId = ?', whereArgs: [userId]);
    final Map<String, ActivityHistory> map = {};
    for (final r in res) {
      final h = ActivityHistory.fromMap(r);
      map[h.activityName] = h;
    }
    return map;
  }

  Future<void> resetUserData(String userId, String weekKey, int simulatedHoy) async {
    final db = await _dbHelper.database;
    await db.delete('instances',
        where: 'userId = ? AND weekKey = ?', whereArgs: [userId, weekKey]);
    await _seedInstancesForWeek(userId, weekKey, simulatedHoy);
  }

  Future<void> updateActivityDetails(
      int activityId, String newNombre, String newDescripcion) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'activities',
        {'nombre': newNombre, 'descripcion': newDescripcion},
        where: 'id = ?',
        whereArgs: [activityId],
      );
      // Actualizar instancias pendientes futuras
      await txn.update(
        'instances',
        {'nombre': newNombre, 'descripcion': newDescripcion},
        where: 'activityId = ? AND done = 0',
        whereArgs: [activityId],
      );
    });
  }

  // --- AUDITORÍA ---
  Future<void> logAudit(AuditLogModel log) async {
    final db = await _dbHelper.database;
    await db.insert('audit_logs', log.toMap());
  }

  Future<List<AuditLogModel>> getAuditLogs(String userId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'audit_logs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 100,
    );
    return res.map((m) => AuditLogModel.fromMap(m)).toList();
  }

  // --- HISTORIAL COMPLETO DE EJECUCIONES ---
  Future<List<ActivityInstance>> getAllInstancesForUser(String userId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'instances',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return res.map((m) => ActivityInstance.fromMap(m)).toList();
  }

  // --- BACKUP & RESTORE LOCAL EN JSON ---
  Future<Map<String, dynamic>> exportBackupData(String userId) async {
    final db = await _dbHelper.database;
    final profiles = await db.query('profiles', where: 'id = ?', whereArgs: [userId]);
    final activities = await db.query('activities', where: 'userId = ?', whereArgs: [userId]);
    final instances = await db.query('instances', where: 'userId = ?', whereArgs: [userId]);
    final history = await db.query('history', where: 'userId = ?', whereArgs: [userId]);
    final audits = await db.query('audit_logs', where: 'userId = ?', whereArgs: [userId]);

    return {
      'version': 1,
      'app': 'Standard Work · Darnel Group',
      'exportedAt': DateTime.now().toIso8601String(),
      'userId': userId,
      'profiles': profiles,
      'activities': activities,
      'instances': instances,
      'history': history,
      'audit_logs': audits,
    };
  }

  Future<void> restoreBackupData(Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    final userId = data['userId'] as String;

    await db.transaction((txn) async {
      // 1. Limpiar registros actuales del usuario para reemplazo limpio sin afectar otros usuarios
      await txn.delete('instances', where: 'userId = ?', whereArgs: [userId]);
      await txn.delete('activities', where: 'userId = ?', whereArgs: [userId]);
      await txn.delete('history', where: 'userId = ?', whereArgs: [userId]);
      await txn.delete('audit_logs', where: 'userId = ?', whereArgs: [userId]);

      // 2. Restaurar actividades
      if (data['activities'] is List) {
        for (final item in data['activities']) {
          await txn.insert('activities', Map<String, dynamic>.from(item));
        }
      }

      // 3. Restaurar instancias
      if (data['instances'] is List) {
        for (final item in data['instances']) {
          await txn.insert('instances', Map<String, dynamic>.from(item));
        }
      }

      // 4. Restaurar historial
      if (data['history'] is List) {
        for (final item in data['history']) {
          await txn.insert('history', Map<String, dynamic>.from(item));
        }
      }

      // 5. Restaurar auditoría
      if (data['audit_logs'] is List) {
        for (final item in data['audit_logs']) {
          await txn.insert('audit_logs', Map<String, dynamic>.from(item));
        }
      }
    });
  }

  // --- PREFERENCIAS / SIMULACIÓN ---
  Future<void> setSimulatedHoy(int day) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {'key': 'simulated_hoy', 'value': day.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getSimulatedHoy() async {
    final db = await _dbHelper.database;
    final res = await db.query('settings',
        where: 'key = ?', whereArgs: ['simulated_hoy']);
    if (res.isNotEmpty) {
      return int.tryParse(res.first['value'] as String);
    }
    return null;
  }

  // --- INTEGRACIÓN Y GESTIÓN DE LAS 4 SEMANAS DEL EXCEL ---
  Future<void> importExcelScheduleFromJson(Map<String, dynamic> jsonData) async {
    final db = await _dbHelper.database;
    final List scheduleList = jsonData['schedule'] as List? ?? [];
    
    await db.transaction((txn) async {
      // Importación idempotente: insert or replace para conservar integridad
      for (final raw in scheduleList) {
        final act = ExcelScheduleActivity.fromMap(raw as Map<String, dynamic>);
        await txn.insert(
          'excel_schedule',
          act.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<ExcelScheduleActivity>> getExcelSchedule({
    int? weekNumber,
    int? dayOfWeek,
    String? category,
    String? searchQuery,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (weekNumber != null && weekNumber > 0) {
      whereClauses.add('weekNumber = ?');
      whereArgs.add(weekNumber);
    }
    if (dayOfWeek != null && dayOfWeek > 0) {
      whereClauses.add('dayOfWeek = ?');
      whereArgs.add(dayOfWeek);
    }
    if (category != null && category.isNotEmpty && category != 'Todas') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(activityName LIKE ? OR originalName LIKE ? OR category LIKE ?)');
      final term = '%${searchQuery.trim()}%';
      whereArgs.addAll([term, term, term]);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final res = await db.query(
      'excel_schedule',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'weekNumber ASC, dayOfWeek ASC, timeStart ASC',
    );

    return res.map((m) => ExcelScheduleActivity.fromMap(m)).toList();
  }

  Future<int> getExcelScheduleCount() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM excel_schedule');
    return Sqflite.firstIntValue(res) ?? 0;
  }
}
