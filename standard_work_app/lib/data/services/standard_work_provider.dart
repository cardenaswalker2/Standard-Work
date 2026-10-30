import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/app_models.dart';
import '../models/excel_schedule_models.dart';
import '../repositories/standard_work_repository.dart';
import '../../core/utils/date_utils_helper.dart';

class StandardWorkProvider extends ChangeNotifier {
  final StandardWorkRepository _repository;

  StandardWorkProvider({StandardWorkRepository? repository})
      : _repository = repository ?? StandardWorkRepository();

  // Estados reactivos
  List<UserProfile> _profiles = [];
  UserProfile? _currentProfile;
  List<ActivityInstance> _instances = [];
  Map<String, ActivityHistory> _historyMap = {};

  // Estado para la Programación del Excel (4 Semanas)
  List<ExcelScheduleActivity> _excelActivities = [];
  List<FollowupTask> _followupTasks = [];
  List<CategoryDistribution> _categoryDistributions = [];
  int _excelSelectedWeek = 1; // 1, 2, 3 o 4
  int _excelSelectedDay = 0; // 0: Todos, 1..5 días de la semana
  String _excelSelectedCategory = 'Todas';
  String _excelSearchQuery = '';
  bool _isExcelScheduleLoaded = false;

  int _hoy = 1; // 1: Lun, 5: Vie
  int _selectedDay = 1;
  String _currentWeekKey = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserProfile> get profiles => _profiles;
  UserProfile? get currentProfile => _currentProfile;
  List<ActivityInstance> get instances => _instances;
  int get hoy => _hoy;
  int get selectedDay => _selectedDay;
  String get currentWeekKey => _currentWeekKey;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Getters para Programación del Excel
  List<ExcelScheduleActivity> get excelActivities => _excelActivities;
  List<FollowupTask> get followupTasks => _followupTasks;
  List<CategoryDistribution> get categoryDistributions => _categoryDistributions;
  int get excelSelectedWeek => _excelSelectedWeek;
  int get excelSelectedDay => _excelSelectedDay;
  String get excelSelectedCategory => _excelSelectedCategory;
  String get excelSearchQuery => _excelSearchQuery;
  bool get isExcelScheduleLoaded => _isExcelScheduleLoaded;

  // Actividades filtradas del Excel en tiempo real
  List<ExcelScheduleActivity> get filteredExcelActivities {
    return _excelActivities.where((a) {
      final matchesWeek = _excelSelectedWeek == 0 || a.weekNumber == _excelSelectedWeek;
      final matchesDay = _excelSelectedDay == 0 || a.dayOfWeek == _excelSelectedDay;
      final matchesCategory = _excelSelectedCategory == 'Todas' || a.category == _excelSelectedCategory;
      final matchesSearch = _excelSearchQuery.isEmpty ||
          a.activityName.toLowerCase().contains(_excelSearchQuery.toLowerCase()) ||
          a.category.toLowerCase().contains(_excelSearchQuery.toLowerCase());
      return matchesWeek && matchesDay && matchesCategory && matchesSearch;
    }).toList();
  }

  // Resumen de cantidad por semana
  int countActivitiesForWeek(int week) {
    return _excelActivities.where((a) => a.weekNumber == week).length;
  }

  // Actividades del día seleccionado
  List<ActivityInstance> get selectedDayInstances {
    final list = _instances.where((i) => i.day == _selectedDay).toList();
    // Ordenar: primero las fijas, luego las demás
    list.sort((a, b) {
      if (a.fija == b.fija) return a.nombre.compareTo(b.nombre);
      return a.fija ? -1 : 1;
    });
    return list;
  }

  // Actividades del día actual "Hoy"
  List<ActivityInstance> get todayInstances {
    return _instances.where((i) => i.day == _hoy).toList();
  }

  int get todayCompletedCount => todayInstances.where((i) => i.done).length;
  int get todayTotalCount => todayInstances.length;
  double get todayProgressPercent {
    if (todayTotalCount == 0) return 0.0;
    return todayCompletedCount / todayTotalCount;
  }

  /// Inicialización de perfiles y fecha actual
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profiles = await _repository.getAllProfiles();
      _currentWeekKey = DateUtilsHelper.getWeekKey();
      
      final savedHoy = await _repository.getSimulatedHoy();
      _hoy = savedHoy ?? DateUtilsHelper.getWorkDayNumber();
      _selectedDay = _hoy;

      // Cargar programación oficial de 4 semanas de ST - WR YONNY LOPEZ.xlsb
      await loadExcelSchedule();
    } catch (e) {
      _errorMessage = 'Error al inicializar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga la programación completa de las 4 semanas desde assets hacia SQLite y memoria
  Future<void> loadExcelSchedule() async {
    try {
      // 1. Cargar asset empaquetado
      final jsonString = await rootBundle.loadString('assets/data/yonny_lopez_schedule.json');
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;

      // 2. Extraer tareas de seguimiento y categorías
      if (data['followupTasks'] is List) {
        _followupTasks = (data['followupTasks'] as List)
            .map((t) => FollowupTask.fromMap(t as Map<String, dynamic>))
            .toList();
      }
      if (data['categoryDistribution'] is List) {
        _categoryDistributions = (data['categoryDistribution'] as List)
            .map((c) => CategoryDistribution.fromMap(c as Map<String, dynamic>))
            .toList();
      }

      // 3. Sincronizar de forma idempotente con SQLite
      final countInDb = await _repository.getExcelScheduleCount();
      if (countInDb < 270) {
        await _repository.importExcelScheduleFromJson(data);
      }

      // 4. Leer desde SQLite para garantizar persistencia local íntegra
      _excelActivities = await _repository.getExcelSchedule();
      _isExcelScheduleLoaded = true;
    } catch (e) {
      debugPrint('Error cargando programación de Excel: $e');
    }
  }

  /// Cambiar la semana seleccionada (1..4 o 0 para todas)
  void setExcelSelectedWeek(int week) {
    _excelSelectedWeek = week;
    notifyListeners();
  }

  /// Cambiar el día seleccionado (0: todos, 1: Lun, 2: Mar, 3: Mié, 4: Jue, 5: Vie)
  void setExcelSelectedDay(int day) {
    _excelSelectedDay = day;
    notifyListeners();
  }

  /// Filtrar por categoría
  void setExcelSelectedCategory(String category) {
    _excelSelectedCategory = category;
    notifyListeners();
  }

  /// Buscar actividades por texto
  void setExcelSearchQuery(String query) {
    _excelSearchQuery = query;
    notifyListeners();
  }

  /// Iniciar sesión con un perfil (X, Y o Z)
  Future<void> login(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentProfile = await _repository.getProfileById(userId);
      await _loadUserData();
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cerrar sesión y volver al login
  void logout() {
    _currentProfile = null;
    _instances = [];
    _historyMap = {};
    notifyListeners();
  }

  /// Cargar las instancias de la semana y el historial del usuario actual
  Future<void> _loadUserData() async {
    if (_currentProfile == null) return;
    _instances = await _repository.getInstancesForWeek(
      _currentProfile!.id,
      _currentWeekKey,
      _hoy,
    );
    _historyMap = await _repository.getHistoryForUser(_currentProfile!.id);
  }

  /// Cambiar de día en la navegación horizontal (1..5)
  void selectDay(int day) {
    if (day >= 1 && day <= 5) {
      _selectedDay = day;
      notifyListeners();
    }
  }

  /// Cambiar el día simulado "HOY"
  Future<void> setSimulatedHoy(int day) async {
    if (day < 1 || day > 5) return;
    _hoy = day;
    _selectedDay = day;
    await _repository.setSimulatedHoy(day);
    notifyListeners();
  }



  /// Mover actividad a un día posterior dentro de la semana laboral
  /// Reglas de negocio: No se pueden mover actividades fijas ni a días anteriores o iguales.
  Future<String?> moveInstance(int id, int newDay) async {
    final index = _instances.indexWhere((i) => i.id == id);
    if (index == -1) return 'Actividad no encontrada';

    final instance = _instances[index];
    if (instance.fija) {
      return 'Esta actividad es obligatoria diaria y no se puede mover';
    }
    if (newDay <= instance.day || newDay > 5) {
      return 'Solo puedes moverla a un día posterior de la misma semana';
    }

    await _repository.moveInstance(id, newDay);
    _instances[index] = instance.copyWith(
      day: newDay,
      done: false,
    );

    notifyListeners();
    return 'Actividad movida a ${DateUtilsHelper.diasCompletos[newDay - 1]}';
  }

  /// Agregar nueva actividad personalizada con área, categoría y horario reales
  Future<String?> addNewActivity({
    required String nombre,
    required String descripcion,
    required List<int> days,
    String? area,
    String? category,
    String? timeStart,
    String? timeEnd,
    bool? isFixed,
  }) async {
    if (_currentProfile == null) return 'No hay usuario activo';
    if (nombre.trim().isEmpty) return 'Escribe el nombre de la actividad';
    if (days.isEmpty) return 'Selecciona al menos un día';

    final selectedArea = (area != null && area.trim().isNotEmpty)
        ? area.trim()
        : _currentProfile!.area;

    final selectedCategory = (category != null && category.trim().isNotEmpty)
        ? category.trim()
        : 'Operación y Ejecución';

    final selectedTimeStart = (timeStart != null && timeStart.trim().isNotEmpty)
        ? timeStart.trim()
        : '08:00';

    final selectedTimeEnd = (timeEnd != null && timeEnd.trim().isNotEmpty)
        ? timeEnd.trim()
        : '08:30';

    final bool fija = isFixed ?? (days.length == 5);

    final act = ActivityModel(
      userId: _currentProfile!.id,
      nombre: nombre.trim(),
      descripcion: descripcion.trim().isEmpty
          ? 'Actividad registrada por el usuario'
          : descripcion.trim(),
      dias: '[${days.join(",")}]',
      fija: fija,
      area: selectedArea,
      category: selectedCategory,
      timeStart: selectedTimeStart,
      timeEnd: selectedTimeEnd,
    );

    await _repository.addInstancesForNewActivity(act, _currentWeekKey);

    // Registro de auditoría
    await _repository.logAudit(AuditLogModel(
      userId: _currentProfile!.id,
      action: 'CREATE_ACTIVITY',
      entity: 'activity',
      entityId: 0,
      details: 'Nueva actividad creada: "${act.nombre}" en área "$selectedArea", categoría "$selectedCategory"',
      timestamp: DateTime.now(),
    ));

    await _loadUserData();
    _selectedDay = days.first;
    notifyListeners();

    return 'Actividad registrada correctamente';
  }

  /// Cálculo exacto de indicadores para una actividad (mes y año)
  /// Coincide con la fórmula ind(name) de Mira.html
  Map<String, int> getIndicatorsForActivity(String activityName) {
    final hist = _historyMap[activityName] ??
        const ActivityHistory(
          userId: '',
          activityName: '',
          mD: 0,
          mT: 0,
          yD: 0,
          yT: 0,
        );

    // Instancias de la semana actual correspondientes a días ya transcurridos o hoy
    final wk = _instances.where((x) => x.nombre == activityName && x.day <= _hoy).toList();
    final wd = wk.where((x) => x.done).length;

    final tMes = hist.mT + wk.length;
    final tAno = hist.yT + wk.length;

    final int pMes = tMes > 0 ? (((hist.mD + wd) / tMes) * 100).round() : 0;
    final int pAno = tAno > 0 ? (((hist.yD + wd) / tAno) * 100).round() : 0;

    return {'m': pMes, 'y': pAno};
  }

  String _searchQuery = '';
  String _filterStatus = 'ALL'; // 'ALL', 'DONE', 'PENDING', 'FIXED'

  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;

  void setSearchQuery(String q) {
    _searchQuery = q.toLowerCase().trim();
    notifyListeners();
  }

  void setFilterStatus(String s) {
    _filterStatus = s;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = 'ALL';
    notifyListeners();
  }

  // Actividades del día seleccionado con filtros aplicados
  List<ActivityInstance> get filteredSelectedDayInstances {
    return selectedDayInstances.where((i) {
      if (_searchQuery.isNotEmpty) {
        final matchesName = i.nombre.toLowerCase().contains(_searchQuery);
        final matchesDesc = i.descripcion.toLowerCase().contains(_searchQuery);
        if (!matchesName && !matchesDesc) return false;
      }

      if (_filterStatus == 'DONE' && !i.done) return false;
      if (_filterStatus == 'PENDING' && i.done) return false;
      if (_filterStatus == 'FIXED' && !i.fija) return false;

      return true;
    }).toList();
  }

  /// Conmutar estado Realizada / Pendiente con observación opcional y auditoría
  Future<String?> toggleInstance(int id, {String? observaciones, String? motivo}) async {
    final index = _instances.indexWhere((i) => i.id == id);
    if (index == -1) return 'Actividad no encontrada';

    final instance = _instances[index];
    if (instance.day > _hoy) {
      return 'Aún no es el día de esta actividad';
    }

    final newStatus = !instance.done;
    await _repository.updateInstanceStatus(
      id,
      newStatus,
      obs: observaciones ?? instance.observaciones,
      motivo: motivo ?? instance.motivoNoRealizada,
    );

    _instances[index] = instance.copyWith(
      done: newStatus,
      completedAt: newStatus ? DateTime.now() : null,
      observaciones: observaciones ?? instance.observaciones,
      motivoNoRealizada: motivo ?? instance.motivoNoRealizada,
    );

    // Registro de auditoría
    if (_currentProfile != null) {
      await _repository.logAudit(AuditLogModel(
        userId: _currentProfile!.id,
        action: newStatus ? 'TOGGLE_DONE' : 'TOGGLE_PENDING',
        entity: 'instance',
        entityId: id,
        details: 'Actividad "${instance.nombre}" marcada como ${newStatus ? "Realizada" : "Pendiente"}',
        timestamp: DateTime.now(),
      ));
    }

    notifyListeners();
    return newStatus ? '✔ Actividad registrada como realizada' : 'Actividad marcada como pendiente';
  }

  /// Guardar observación o motivo sin cambiar el estado
  Future<void> saveInstanceNotes(int id, {String? observaciones, String? motivo}) async {
    final index = _instances.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final instance = _instances[index];
    await _repository.updateInstanceStatus(
      id,
      instance.done,
      obs: observaciones,
      motivo: motivo,
    );

    _instances[index] = instance.copyWith(
      observaciones: observaciones,
      motivoNoRealizada: motivo,
    );

    if (_currentProfile != null) {
      await _repository.logAudit(AuditLogModel(
        userId: _currentProfile!.id,
        action: 'UPDATE_NOTES',
        entity: 'instance',
        entityId: id,
        details: 'Observación registrada en "${instance.nombre}"',
        timestamp: DateTime.now(),
      ));
    }

    notifyListeners();
  }

  /// Editar el nombre y descripción de una actividad
  Future<String?> editActivity(int activityId, String newNombre, String newDescripcion) async {
    if (newNombre.trim().isEmpty) return 'El nombre no puede estar vacío';

    await _repository.updateActivityDetails(
      activityId,
      newNombre.trim(),
      newDescripcion.trim(),
    );

    if (_currentProfile != null) {
      await _repository.logAudit(AuditLogModel(
        userId: _currentProfile!.id,
        action: 'UPDATE_ACTIVITY',
        entity: 'activity',
        entityId: activityId,
        details: 'Actividad editada: $newNombre',
        timestamp: DateTime.now(),
      ));
    }

    await _loadUserData();
    notifyListeners();
    return 'Actividad actualizada correctamente';
  }

  /// Archivar actividad no fija
  Future<String?> archiveActivity(int activityId) async {
    final act = _instances.firstWhere((i) => i.activityId == activityId, orElse: () => _instances.first);
    if (act.fija) {
      return 'No se puede archivar una actividad fija obligatoria';
    }

    await _repository.archiveActivity(activityId);

    if (_currentProfile != null) {
      await _repository.logAudit(AuditLogModel(
        userId: _currentProfile!.id,
        action: 'ARCHIVE_ACTIVITY',
        entity: 'activity',
        entityId: activityId,
        details: 'Actividad archivada id $activityId',
        timestamp: DateTime.now(),
      ));
    }

    await _loadUserData();
    notifyListeners();
    return 'Actividad archivada';
  }

  /// Consultar historial completo de ejecuciones
  Future<List<ActivityInstance>> getExecutionHistory() async {
    if (_currentProfile == null) return [];
    return await _repository.getAllInstancesForUser(_currentProfile!.id);
  }

  /// Consultar logs de auditoría
  Future<List<AuditLogModel>> getAuditLogs() async {
    if (_currentProfile == null) return [];
    return await _repository.getAuditLogs(_currentProfile!.id);
  }

  /// Exportar datos de backup en JSON
  Future<Map<String, dynamic>?> exportBackupJson() async {
    if (_currentProfile == null) return null;
    return await _repository.exportBackupData(_currentProfile!.id);
  }

  /// Restaurar datos desde JSON
  Future<String?> restoreBackupJson(Map<String, dynamic> data) async {
    if (_currentProfile == null) return 'No hay usuario activo';
    if (data['app'] != 'Standard Work · Darnel Group' || data['userId'] != _currentProfile!.id) {
      return 'El archivo de respaldo no corresponde a este perfil o aplicación.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.restoreBackupData(data);
      await _loadUserData();
      return 'Datos restaurados con éxito';
    } catch (e) {
      return 'Error al restaurar respaldo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reiniciar datos de la semana actual
  Future<void> resetData() async {
    if (_currentProfile == null) return;
    _isLoading = true;
    notifyListeners();

    await _repository.resetUserData(_currentProfile!.id, _currentWeekKey, _hoy);
    await _loadUserData();

    _isLoading = false;
    notifyListeners();
  }
}
