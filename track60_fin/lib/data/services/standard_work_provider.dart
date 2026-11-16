import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../database/database_helper.dart';
import 'api_client.dart';

class StandardWorkProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final ApiClient _api = ApiClient.instance;

  bool _cloudAuthenticated = false;
  bool get isCloudAuthenticated => _cloudAuthenticated;

  Future<bool> _loginViaCloudApi(String identifier, {String? pin}) async {
    try {
      final data = await _api.post('/auth/login', {
        'identifier': identifier.trim(),
        if (pin != null && pin.isNotEmpty) 'pin': pin.trim(),
      }, auth: false);

      if (data is Map<String, dynamic> && data['accessToken'] != null) {
        await _api.saveTokens(
          data['accessToken'].toString(),
          data['refreshToken']?.toString() ?? '',
        );
        final uMap = data['user'] as Map<String, dynamic>;
        _currentUser = UserProfile(
          id: uMap['id']?.toString() ?? '',
          cedula: uMap['cedula']?.toString() ?? '',
          nombre: uMap['nombre']?.toString() ?? '',
          cargo: uMap['cargo']?.toString() ?? '',
          area: uMap['area']?.toString() ?? '',
          iniciales: uMap['iniciales']?.toString() ?? 'U',
          email: uMap['email']?.toString() ?? '',
          activo: uMap['activo'] == true,
          rol: uMap['rol']?.toString() ?? 'operador',
          plantId: uMap['plantId']?.toString() ?? 'PL-EXTRUSA',
        );
        _cloudAuthenticated = true;
        return true;
      }
    } catch (e) {
      debugPrint('Cloud login fallback a local: $e');
    }
    return false;
  }

  // Sesión y Usuario Actual
  UserProfile? _currentUser;
  void setCurrentUserForTesting(UserProfile? user) => _currentUser = user;
  PlantModel? _currentPlant;
  int _selectedDay = 1; // 1 = Lunes, 5 = Viernes
  String _currentWeekKey = 'W1';

  // Colecciones de datos
  List<UserProfile> _allUsers = [];
  List<PlantModel> _allPlants = [];
  List<ActivityInstance> _instances = [];
  List<ActivityModel> _activities = [];
  List<NotificationModel> _notifications = [];
  final List<SubtaskExecutionModel> _subtaskExecutions = [];
  List<AuditLogModel> _auditLogs = [];
  List<ProPlanModel> _proPlans = [];
  List<PlantPhotoStandardModel> _photoStandards = [];
  List<ExtraTaskRequestModel> _extraTaskRequests = [];
  List<MeetingRecordModel> _meetingRecords = [];
  List<ActivityTemplateModel> _templates = [];

  bool _isLoading = false;

  // Getters
  UserProfile? get currentUser => _currentUser;
  PlantModel? get currentPlant => _currentPlant;
  int get selectedDay => _selectedDay;
  String get currentWeekKey => _currentWeekKey;
  bool get isLoading => _isLoading;

  List<UserProfile> get allUsers => _allUsers;
  List<PlantModel> get allPlants => _allPlants;
  List<ActivityInstance> get instances => _instances;
  List<ActivityModel> get activities => _activities;
  List<NotificationModel> get notifications => _notifications;
  List<SubtaskExecutionModel> get subtaskExecutions => _subtaskExecutions;
  List<AuditLogModel> get auditLogs => _auditLogs;
  List<ProPlanModel> get proPlans => _proPlans;
  List<PlantPhotoStandardModel> get photoStandards => _photoStandards;
  List<ExtraTaskRequestModel> get extraTaskRequests => _extraTaskRequests;
  List<MeetingRecordModel> get meetingRecords => _meetingRecords;
  List<ActivityTemplateModel> get templates => _templates;

  // Alertas y Comunicados Corporativos
  bool _emergencyAlertActive = false;
  String _emergencyAlertMessage = '';
  String? _observingPlantId;

  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 1,
      'title': 'Meta Corporativa Q4: Cero Desperdicio de Resina',
      'body': 'Dirección General establece meta del 96% de estándar para todas las líneas de extrusión y formado.',
      'author': 'Javier Julio · Superadmin',
      'date': '2026-11-04',
      'type': 'DIRECTIVA',
    },
  ];

  final List<Map<String, dynamic>> _gembaLogs = [];
  final List<Map<String, dynamic>> _machineDowntimes = [];

  bool get emergencyAlertActive => _emergencyAlertActive;
  String get emergencyAlertMessage => _emergencyAlertMessage;
  String? get observingPlantId => _observingPlantId;
  List<Map<String, dynamic>> get announcements => _announcements;
  List<Map<String, dynamic>> get gembaLogs => _gembaLogs;
  List<Map<String, dynamic>> get machineDowntimes => _machineDowntimes;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  void toggleEmergencyAlert(bool active, String message) {
    _emergencyAlertActive = active;
    _emergencyAlertMessage = message;
    notifyListeners();
  }

  void setObservingPlant(String? plantId) {
    _observingPlantId = plantId;
    notifyListeners();
  }

  void postAnnouncement({required String title, required String body, required String author}) {
    _announcements.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'author': author,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'type': 'DIRECTIVA',
    });
    notifyListeners();
  }

  /// Relevo Operativo por Incapacidad o Ausencia (Transfiere jornada diaria)
  Future<void> transferOperatorDayTasks({
    required String fromUserId,
    required String toUserId,
    required int day,
  }) async {
    await _db.reassignUserInstances(
      fromUserId: fromUserId,
      toUserId: toUserId,
      day: day,
      weekKey: _currentWeekKey,
    );

    await _db.insertNotification(NotificationModel(
      userId: toUserId,
      title: 'Relevo Operativo Asignado',
      body: 'Se te ha transferido la jornada del día por ausencia del colaborador $fromUserId.',
      type: 'plant_assignment',
      timestamp: DateTime.now(),
      isRead: false,
    ));

    await _db.logAudit(AuditLogModel(
      userId: _currentUser?.id ?? 'ADMIN',
      action: 'RELEVO_OPERATIVO',
      entity: 'INSTANCE',
      details: 'Jornada día $day transferida de $fromUserId a $toUserId',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Parada de Máquina / Mantenimiento no programado
  Future<void> reportMachineDowntime({
    required String lineName,
    required String reason,
    required String plantId,
  }) async {
    _machineDowntimes.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'lineName': lineName,
      'reason': reason,
      'plantId': plantId,
      'timestamp': DateTime.now(),
      'status': 'Activa',
    });

    await _db.logAudit(AuditLogModel(
      userId: _currentUser?.id ?? 'ADMIN',
      action: 'PARADA_MAQUINA',
      entity: 'LINE',
      details: 'Parada en $lineName ($plantId): $reason',
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }

  /// Ronda 5S / Gemba Walk
  Future<void> submitGemba5SWalk({
    required String plantId,
    required int score,
    required String notes,
  }) async {
    _gembaLogs.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'supervisor': _currentUser?.nombre ?? 'Supervisor',
      'plantId': plantId,
      'score': score,
      'notes': notes,
      'timestamp': DateTime.now(),
    });

    await _db.logAudit(AuditLogModel(
      userId: _currentUser?.id ?? 'SUPERVISOR',
      action: 'RONDA_5S_GEMBA',
      entity: 'AUDIT',
      details: 'Ronda 5S en $plantId con calificación $score/100: $notes',
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }

  /// Retorna las instancias del día seleccionado para el usuario logueado
  List<ActivityInstance> get tasksForSelectedDay {
    if (_currentUser == null) return [];
    return _instances.where((i) => i.day == _selectedDay).toList();
  }

  /// Retorna las actividades filtradas por la planta del administrador
  List<UserProfile> get usersForCurrentPlant {
    if (_currentUser == null) return [];
    if (_currentUser!.isSuperAdmin) return _allUsers;
    return _allUsers.where((u) => u.plantId == _currentUser!.plantId).toList();
  }

  void setSelectedDay(int day) {
    if (_selectedDay != day) {
      _selectedDay = day;
      notifyListeners();
    }
  }

  void setWeekKey(String weekKey) {
    if (_currentWeekKey != weekKey) {
      _currentWeekKey = weekKey;
      refreshData();
    }
  }

  // --- AUTENTICACIÓN ---

  /// Login de Colaborador o Directivo (Cédula o PIN inteligente)
  Future<bool> loginWithCedula(String cedula) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cleanInput = cedula.trim();
      if (await _loginViaCloudApi(cleanInput)) {
        try {
          await _loadUserData();
        } catch (e) {
          debugPrint('Aviso en _loadUserData durante loginWithCedula (cloud): $e');
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      final user = await _db.getUserByCedula(cleanInput);
      if (user != null && user.activo) {
        _currentUser = user;
        try {
          await _loadUserData();
        } catch (e) {
          debugPrint('Aviso en _loadUserData durante loginWithCedula: $e');
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Fallback inteligente: si ingresó un PIN (1428, 1234, 5678, 3344, etc.) o ID en el campo principal
      final pinSuccess = await loginWithPin(cleanInput);
      if (pinSuccess) {
        return true;
      }
    } catch (e) {
      debugPrint('Error en loginWithCedula: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Login Directivo mediante PIN
  Future<bool> loginWithPin(String pin, {String? targetUserId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cleanPin = pin.trim();

      if (targetUserId == null) {
        final cloudOk = await _loginViaCloudApi(cleanPin);
        if (cloudOk) return true;
      }

      final users = await _db.getAllUsers();
      UserProfile? matched;

      // 1. Coincidencia con targetUserId (chips directos o biométrico)
      if (targetUserId != null) {
        final tid = targetUserId.toUpperCase();
        for (final u in users) {
          final isTid = u.id.toUpperCase() == tid ||
              (tid == 'JJ' && (u.id.toUpperCase() == 'JAVIER' || u.isSuperAdmin));
          if (isTid) {
            matched = u;
            break;
          }
        }
      }

      // 2. Coincidencia por PIN directo
      if (matched == null) {
        for (final u in users) {
          if (!u.isOperator &&
              (u.pin == cleanPin ||
                  (cleanPin == '1428' && u.isSuperAdmin) ||
                  (cleanPin == '1234' && u.id == 'YL') ||
                  (cleanPin == '5678' && u.id == 'RG') ||
                  (cleanPin == '3344' && u.id == 'CM') ||
                  (cleanPin == '7788' && u.id == 'MC'))) {
            matched = u;
            break;
          }
        }
      }

      // 3. Fallback de contingencia con credenciales maestras corporativas
      matched ??= _getMasterUserForPinOrId(cleanPin, targetUserId);

      if (matched != null && matched.activo) {
        _currentUser = matched;
        try {
          await _loadUserData();
        } catch (e) {
          debugPrint('Aviso en _loadUserData durante loginWithPin: $e');
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error en loginWithPin: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  UserProfile? _getMasterUserForPinOrId(String pin, String? targetUserId) {
    final tid = targetUserId?.toUpperCase();
    if (tid == 'ULTRA' || pin == '147728') {
      return const UserProfile(
        id: 'ULTRA',
        cedula: '0000000000',
        nombre: 'Owner · Ultra Admin',
        cargo: 'Arquitecto y Propietario del Sistema',
        area: 'Control Maestro',
        iniciales: 'UA',
        email: 'owner@track60.darnel.com',
        activo: true,
        rol: 'ultra_admin',
        plantId: 'ALL',
        pin: '147728',
      );
    }
    if (tid == 'JJ' || tid == 'JAVIER' || pin == '1428') {
      return const UserProfile(
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
      );
    }
    if (tid == 'YL' || pin == '1234') {
      return const UserProfile(
        id: 'YL',
        cedula: '1098765432',
        nombre: 'Yonny López',
        cargo: 'Jefe de Planta / Operaciones',
        area: 'Dirección de Planta',
        iniciales: 'YL',
        email: 'yonny.lopez@darnel.com',
        activo: true,
        rol: 'admin_planta',
        plantId: 'PL-EXTRUSA',
        pin: '1234',
      );
    }
    if (tid == 'RG' || pin == '5678') {
      return const UserProfile(
        id: 'RG',
        cedula: '1087654321',
        nombre: 'Roberto Gómez',
        cargo: 'Jefe de Planta Termoformado',
        area: 'Dirección de Planta',
        iniciales: 'RG',
        email: 'roberto.gomez@darnel.com',
        activo: true,
        rol: 'admin_planta',
        plantId: 'PL-TERMO',
        pin: '5678',
      );
    }
    if (tid == 'CM' || pin == '3344') {
      return const UserProfile(
        id: 'CM',
        cedula: '1012345678',
        nombre: 'Carlos Méndez',
        cargo: 'Supervisor de Producción Extrusa',
        area: 'Producción Extrusa',
        iniciales: 'CM',
        email: 'carlos.mendez@darnel.com',
        activo: true,
        rol: 'supervisor',
        plantId: 'PL-EXTRUSA',
        pin: '3344',
      );
    }
    if (tid == 'MC' || pin == '7788') {
      return const UserProfile(
        id: 'MC',
        cedula: '1034567890',
        nombre: 'Marcela Castro',
        cargo: 'Supervisora de Calidad',
        area: 'Calidad',
        iniciales: 'MC',
        email: 'marcela.castro@darnel.com',
        activo: true,
        rol: 'supervisor',
        plantId: 'PL-TERMO',
        pin: '7788',
      );
    }
    return null;
  }

  void logout() {
    _currentUser = null;
    _currentPlant = null;
    _instances.clear();
    _notifications.clear();
    _subtaskExecutions.clear();
    notifyListeners();
  }

  // --- CARGA DE DATOS ---

  Future<void> refreshData() async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    await _loadUserData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      _allUsers = await _db.getAllUsers();
    } catch (e) {
      debugPrint('Error cargando users: $e');
      _allUsers = [_currentUser!];
    }

    try {
      _allPlants = await _db.getAllPlants();
    } catch (e) {
      debugPrint('Error cargando plants: $e');
      _allPlants = [];
    }

    try {
      _activities = await _db.getAllActivities();
    } catch (e) {
      debugPrint('Error cargando activities: $e');
      _activities = [];
    }

    try {
      _auditLogs = await _db.getAuditLogs();
    } catch (e) {
      debugPrint('Error cargando auditLogs: $e');
      _auditLogs = [];
    }

    final plantIdFilter = _currentUser!.isSuperAdmin ? null : _currentUser!.plantId;

    try {
      _proPlans = await _db.getProPlans(plantId: plantIdFilter);
    } catch (e) {
      debugPrint('Error cargando proPlans: $e');
      _proPlans = [];
    }

    try {
      _photoStandards = await _db.getPlantPhotoStandards(plantId: plantIdFilter);
    } catch (e) {
      debugPrint('Error cargando photoStandards: $e');
      _photoStandards = [];
    }

    try {
      _extraTaskRequests = await _db.getExtraTaskRequests(plantId: plantIdFilter);
    } catch (e) {
      debugPrint('Error cargando extraTaskRequests: $e');
      _extraTaskRequests = [];
    }

    try {
      _meetingRecords = await _db.getMeetingRecords(plantId: plantIdFilter);
    } catch (e) {
      debugPrint('Error cargando meetingRecords: $e');
      _meetingRecords = [];
    }

    try {
      _templates = await _db.getAllTemplates();
    } catch (e) {
      debugPrint('Error cargando templates: $e');
      _templates = [];
    }

    // Planta actual
    try {
      if (_currentUser!.isSuperAdmin) {
        _currentPlant = _allPlants.isNotEmpty ? _allPlants.first : null;
        _instances = await _db.getInstancesForPlant('ALL', _currentWeekKey);
      } else {
        try {
          _currentPlant = _allPlants.firstWhere((p) => p.id == _currentUser!.plantId);
        } catch (_) {
          _currentPlant = null;
        }

        if (_currentUser!.isOperator) {
          _instances = await _db.getInstancesForUserAndWeek(_currentUser!.id, _currentWeekKey);
        } else {
          _instances = await _db.getInstancesForPlant(_currentUser!.plantId, _currentWeekKey);
        }
      }
    } catch (e) {
      debugPrint('Error cargando instances: $e');
      _instances = [];
    }

    try {
      _notifications = await _db.getNotificationsForUser(_currentUser!.id);
    } catch (e) {
      debugPrint('Error cargando notifications: $e');
      _notifications = [];
    }
  }

  // --- SUPER ADMINISTRADOR (JAVIER JULIO) ---

  /// Crea un nuevo proceso industrial y a su Administrador en una única operación atómica
  Future<String?> createProcessWithAdmin({
    required String processId,
    required String codigo,
    required String nombreProceso,
    required String ubicacion,
    required String adminCedula,
    required String adminNombre,
    required String adminEmail,
    required String adminPin,
    String adminCargo = 'Gerente / Admin de Proceso',
  }) async {
    try {
      if (processId.trim().isEmpty) return 'El ID del proceso es obligatorio';
      if (nombreProceso.trim().isEmpty) return 'El nombre del proceso es obligatorio';
      if (adminCedula.trim().isEmpty) return 'La cédula del administrador es obligatoria';
      if (adminNombre.trim().isEmpty) return 'El nombre del administrador es obligatorio';
      if (adminPin.trim().length < 4) return 'El PIN de acceso debe tener mínimo 4 dígitos';

      final cleanProcessId = processId.trim().toUpperCase();
      final cleanCedula = adminCedula.trim();

      // Validación de duplicidad
      if (_allPlants.any((p) => p.id.toUpperCase() == cleanProcessId)) {
        return 'Ya existe un proceso con el identificador "$cleanProcessId"';
      }
      if (_allUsers.any((u) => u.cedula == cleanCedula)) {
        return 'Ya existe un usuario registrado con la cédula "$cleanCedula"';
      }

      final adminId = 'ADM_${cleanProcessId.replaceAll('PL-', '').replaceAll('-', '_')}';
      final initials = adminNombre.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

      // 1. Crear modelo de Proceso/Planta
      final plant = PlantModel(
        id: cleanProcessId,
        codigo: codigo.trim().isNotEmpty ? codigo.trim().toUpperCase() : 'PRC-${cleanProcessId.replaceAll('PL-', '')}',
        nombre: nombreProceso.trim(),
        ubicacion: ubicacion.trim().isNotEmpty ? ubicacion.trim() : 'Planta Industrial',
        adminId: adminId,
        activa: true,
      );

      // 2. Crear modelo de Administrador de Planta
      final admin = UserProfile(
        id: adminId,
        cedula: cleanCedula,
        nombre: adminNombre.trim(),
        cargo: adminCargo.trim(),
        area: 'Dirección de Proceso',
        iniciales: initials.isNotEmpty ? initials : 'AP',
        email: adminEmail.trim(),
        activo: true,
        rol: 'admin_planta',
        plantId: cleanProcessId,
        pin: adminPin.trim(),
      );

      // Operación atómica con compensación
      await _db.savePlant(plant);
      try {
        await _db.saveUser(admin);
    try {
      await ApiClient.instance.post('/users', {
          'id': admin.id,
          'cedula': admin.cedula,
          'nombre': admin.nombre,
          'cargo': admin.cargo,
          'area': admin.area,
          'email': admin.email,
          'rol': admin.rol,
          'plantId': admin.plantId,
          'pin': admin.pin,
        });
      } catch (e) {
        debugPrint('Error sincronizando admin con nube: $e');
      }
      } catch (e) {
        // Compensación de fallo
        await _db.deletePlant(cleanProcessId);
        return 'Error al registrar administrador ($e). Creación de proceso cancelada.';
      }

      await _db.logAudit(AuditLogModel(
        userId: _currentUser?.id ?? 'JJ',
        action: 'CREAR_PROCESO_Y_ADMIN',
        entity: 'PROCESO',
        details: 'Creado proceso "$nombreProceso" ($cleanProcessId) y administrador "${admin.nombre}" asignado con éxito',
        timestamp: DateTime.now(),
      ));

      await refreshData();
      return null; // Éxito
    } catch (e) {
      return 'Error general al crear proceso y administrador: $e';
    }
  }

  /// Filtra la bitácora y auditoría por proceso específico
  List<AuditLogModel> getAuditLogsForPlant(String plantId) {
    if (plantId == 'ALL') return _auditLogs;
    final plantUsers = _allUsers.where((u) => u.plantId == plantId).map((u) => u.id).toSet();
    return _auditLogs.where((log) {
      final userMatches = plantUsers.contains(log.userId);
      final detailsMatch = log.details.toUpperCase().contains(plantId.toUpperCase());
      return userMatches || detailsMatch;
    }).toList();
  }

  /// Crea una nueva plantilla de actividad
  Future<void> createTemplate(ActivityTemplateModel template) async {
    await _db.insertTemplate(template);
    _templates = await _db.getAllTemplates();
    await _db.logAudit(AuditLogModel(
      userId: _currentUser?.id ?? 'JJ',
      action: 'CREAR_PLANTILLA',
      entity: 'PLANTILLA',
      details: 'Nueva plantilla creada: "${template.nombre}" (${template.area})',
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Edita una plantilla sin modificar retroactivamente actividades pasadas
  Future<void> updateTemplate(ActivityTemplateModel template) async {
    await _db.updateTemplate(template);
    _templates = await _db.getAllTemplates();
    await _db.logAudit(AuditLogModel(
      userId: _currentUser?.id ?? 'JJ',
      action: 'EDITAR_PLANTILLA',
      entity: 'PLANTILLA',
      details: 'Plantilla #${template.id} actualizada: "${template.nombre}"',
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Elimina una plantilla
  Future<void> deleteTemplate(int id) async {
    await _db.deleteTemplate(id);
    _templates = await _db.getAllTemplates();
    notifyListeners();
  }

  /// Crea una nueva planta industrial
  Future<void> createPlant({
    required String id,
    required String codigo,
    required String nombre,
    required String ubicacion,
    required String adminId,
  }) async {
    if (_currentUser == null || !_currentUser!.isSuperAdmin) return;

    final plant = PlantModel(
      id: id,
      codigo: codigo,
      nombre: nombre,
      ubicacion: ubicacion,
      adminId: adminId,
      activa: true,
    );

    await _db.savePlant(plant);
    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'CREAR_PLANTA',
      entity: 'PLANT',
      details: 'Planta ${plant.nombre} ($codigo) creada por Javier Julio',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Crea un Administrador de Planta con sus credenciales y PIN
  Future<void> createPlantAdmin({
    required String id,
    required String cedula,
    required String nombre,
    required String cargo,
    required String email,
    required String plantId,
    required String pin,
  }) async {
    if (_currentUser == null || !_currentUser!.isSuperAdmin) return;

    final initials = nombre.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

    final admin = UserProfile(
      id: id,
      cedula: cedula,
      nombre: nombre,
      cargo: cargo,
      area: 'Dirección Operativa',
      iniciales: initials.isNotEmpty ? initials : 'AD',
      email: email,
      activo: true,
      fechaRegistro: '2026-10-01',
      rol: 'admin_planta',
      plantId: plantId,
      pin: pin,
    );

    await _db.saveUser(admin);
    try {
      await ApiClient.instance.post('/users', {
          'id': admin.id,
          'cedula': admin.cedula,
          'nombre': admin.nombre,
          'cargo': admin.cargo,
          'area': admin.area,
          'email': admin.email,
          'rol': admin.rol,
          'plantId': admin.plantId,
          'pin': admin.pin,
        });
      } catch (e) {
        debugPrint('Error sincronizando admin con nube: $e');
      }
    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'CREAR_ADMIN_PLANTA',
      entity: 'USER',
      details: 'Administrador ${admin.nombre} asignado a la planta $plantId por Javier Julio',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  int get localActivitiesCountForPlant => _activities.where((a) => a.plantId == _currentUser?.plantId && !a.esGlobal).length;
  int get allowedCreationCapacityForPlant {
    final approvedExtra = _extraTaskRequests.where((r) => r.plantId == _currentUser?.plantId && r.estado == 'Aprobada').length;
    return 2 + approvedExtra;
  }
  bool get canCreateMorePlantActivities => localActivitiesCountForPlant < allowedCreationCapacityForPlant;

  /// Despacha una actividad corporativa global para TODAS las plantas o plantas específicas
  Future<void> dispatchCorporateActivity({
    required String nombre,
    required String descripcion,
    required String area,
    required String category,
    required String timeStart,
    required String timeEnd,
    required bool fija,
    required String dias,
    String prioridad = 'Alta',
    required List<ActivitySubtaskModel> subtasks,
    String tipoActividad = 'ejecucion',
    bool requierePlanAccion = false,
    bool planAccionObligatorio = false,
    String instrucciones = '',
    String criteriosCumplimiento = '',
    List<String>? targetPlantIds,
  }) async {
    if (_currentUser == null || !_currentUser!.isSuperAdmin) return;

    // 1. Insertar actividad maestra corporativa
    final act = ActivityModel(
      plantId: 'ALL',
      userId: 'ALL',
      nombre: nombre,
      descripcion: descripcion,
      area: area,
      category: category,
      timeStart: timeStart,
      timeEnd: timeEnd,
      fija: fija,
      dias: dias,
      prioridad: prioridad,
      reqFoto: subtasks.any((s) => s.requiereFoto),
      reqMedicion: subtasks.any((s) => s.requiereMedicion),
      reqComentario: subtasks.any((s) => s.requiereComentario),
      esGlobal: true,
      tipoActividad: tipoActividad,
      requierePlanAccion: requierePlanAccion,
      planAccionObligatorio: planAccionObligatorio,
      instrucciones: instrucciones,
      criteriosCumplimiento: criteriosCumplimiento,
    );

    final actId = await _db.insertActivity(act);

    // 2. Insertar subtareas si es modalidad ejecución
    for (int i = 0; i < subtasks.length; i++) {
      final s = subtasks[i];
      await _db.insertSubtask(s.copyWith(activityId: actId, orden: i + 1));
    }

    // 3. Crear instancias para los operadores de las plantas objetivo
    final allUsers = await _db.getAllUsers();
    final operators = allUsers.where((u) {
      if (!u.isOperator) return false;
      if (targetPlantIds != null && targetPlantIds.isNotEmpty && !targetPlantIds.contains('ALL')) {
        return targetPlantIds.contains(u.plantId);
      }
      return true;
    }).toList();
    final diasList = dias.split(',').map((s) => int.parse(s.trim())).toList();

    for (final op in operators) {
      for (final d in diasList) {
        await _db.insertInstance(ActivityInstance(
          activityId: actId,
          userId: op.id,
          plantId: op.plantId,
          weekKey: _currentWeekKey,
          nombre: nombre,
          descripcion: descripcion,
          area: area,
          category: category,
          timeStart: timeStart,
          timeEnd: timeEnd,
          prioridad: prioridad,
          day: d,
          orig: d,
          fija: fija,
          done: false,
          state: 'Pendiente',
          subtasksTotal: subtasks.length,
          subtasksReported: 0,
          subtasksApproved: 0,
          tipoActividad: tipoActividad,
          requierePlanAccion: requierePlanAccion,
          planAccionObligatorio: planAccionObligatorio,
          instrucciones: instrucciones,
          criteriosCumplimiento: criteriosCumplimiento,
        ));
      }

      // Notificación universal con la firma de Javier Julio
      await _db.insertNotification(NotificationModel(
        userId: op.id,
        title: 'Nueva Actividad Corporativa Global',
        body: 'Javier Julio asignó esta actividad: $nombre',
        type: 'corporate_assignment',
        timestamp: DateTime.now(),
        isRead: false,
      ));
    }

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'DESPACHO_CORPORATIVO_GLOBAL',
      entity: 'ACTIVITY',
      entityId: actId,
      details: 'Actividad global "$nombre" ($tipoActividad) asignada a ${operators.length} colaboradores',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  // --- ADMINISTRADOR DE PLANTA ---

  /// Crea un supervisor local para su planta
  Future<void> createSupervisor({
    required String id,
    required String cedula,
    required String nombre,
    required String cargo,
    required String area,
    required String email,
    required String pin,
  }) async {
    if (_currentUser == null || !_currentUser!.isPlantAdmin) return;

    final initials = nombre.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

    final sup = UserProfile(
      id: id,
      cedula: cedula,
      nombre: nombre,
      cargo: cargo,
      area: area,
      iniciales: initials.isNotEmpty ? initials : 'SP',
      email: email,
      activo: true,
      fechaRegistro: '2026-10-01',
      rol: 'supervisor',
      plantId: _currentUser!.plantId,
      pin: pin,
    );

    await _db.saveUser(sup);
    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'CREAR_SUPERVISOR',
      entity: 'USER',
      details: 'Supervisor ${sup.nombre} creado para planta ${_currentUser!.plantId}',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Crea un operador para su planta
  Future<void> createOperator({
    required String id,
    required String cedula,
    required String nombre,
    required String cargo,
    required String area,
    required String email,
  }) async {
    if (_currentUser == null || !_currentUser!.isPlantAdmin) return;

    final initials = nombre.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

    final op = UserProfile(
      id: id,
      cedula: cedula,
      nombre: nombre,
      cargo: cargo,
      area: area,
      iniciales: initials.isNotEmpty ? initials : 'OP',
      email: email,
      activo: true,
      fechaRegistro: '2026-10-01',
      rol: 'operador',
      plantId: _currentUser!.plantId,
      pin: '',
    );

    await _db.saveUser(op);
    try {
      await ApiClient.instance.post('/users', {
          'id': op.id,
          'cedula': op.cedula,
          'nombre': op.nombre,
          'cargo': op.cargo,
          'area': op.area,
          'email': op.email,
          'rol': op.rol,
          'plantId': op.plantId,
          'pin': op.pin,
        });
      } catch (e) {
        debugPrint('Error sincronizando operador con nube: $e');
      }
    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'CREAR_OPERADOR',
      entity: 'USER',
      details: 'Operador ${op.nombre} registrado en planta ${_currentUser!.plantId}',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Diseña y crea una actividad para un operador de su planta respetando el límite de capacidad
  Future<void> createPlantActivity({
    required String userId,
    required String nombre,
    required String descripcion,
    required String area,
    required String category,
    required String timeStart,
    required String timeEnd,
    required bool fija,
    required String dias,
    required List<ActivitySubtaskModel> subtasks,
    String tipoActividad = 'ejecucion',
    bool requierePlanAccion = false,
    bool planAccionObligatorio = false,
    String instrucciones = '',
    String criteriosCumplimiento = '',
  }) async {
    if (_currentUser == null || !_currentUser!.isPlantAdmin) return;

    // Validación de límite de capacidad (Base 2 para Admin de Planta + adicionales aprobadas)
    final localCount = _activities.where((a) => a.plantId == _currentUser!.plantId && !a.esGlobal).length;
    final approvedExtra = _extraTaskRequests.where((r) => r.plantId == _currentUser!.plantId && r.estado == 'Aprobada').length;
    final maxAllowed = 2 + approvedExtra;
    if (localCount >= maxAllowed) {
      throw StateError('Has alcanzado el límite de capacidad de creación ($maxAllowed actividades locales). Debes solicitar una ampliación de capacidad al Super Admin.');
    }

    final act = ActivityModel(
      plantId: _currentUser!.plantId,
      userId: userId,
      nombre: nombre,
      descripcion: descripcion,
      area: area,
      category: category,
      timeStart: timeStart,
      timeEnd: timeEnd,
      fija: fija,
      dias: dias,
      prioridad: 'Alta',
      reqFoto: subtasks.any((s) => s.requiereFoto),
      reqMedicion: subtasks.any((s) => s.requiereMedicion),
      reqComentario: subtasks.any((s) => s.requiereComentario),
      esGlobal: false,
      tipoActividad: tipoActividad,
      requierePlanAccion: requierePlanAccion,
      planAccionObligatorio: planAccionObligatorio,
      instrucciones: instrucciones,
      criteriosCumplimiento: criteriosCumplimiento,
    );

    final actId = await _db.insertActivity(act);

    // Guardar subtareas
    for (int i = 0; i < subtasks.length; i++) {
      final s = subtasks[i];
      await _db.insertSubtask(s.copyWith(activityId: actId, orden: i + 1));
    }

    // Generar instancias
    final diasList = dias.split(',').map((s) => int.parse(s.trim())).toList();
    for (final d in diasList) {
      await _db.insertInstance(ActivityInstance(
        activityId: actId,
        userId: userId,
        plantId: _currentUser!.plantId,
        weekKey: _currentWeekKey,
        nombre: nombre,
        descripcion: descripcion,
        area: area,
        category: category,
        timeStart: timeStart,
        timeEnd: timeEnd,
        prioridad: 'Alta',
        day: d,
        orig: d,
        fija: fija,
        done: false,
        state: 'Pendiente',
        subtasksTotal: subtasks.length,
        subtasksReported: 0,
        subtasksApproved: 0,
        tipoActividad: tipoActividad,
        requierePlanAccion: requierePlanAccion,
        planAccionObligatorio: planAccionObligatorio,
        instrucciones: instrucciones,
        criteriosCumplimiento: criteriosCumplimiento,
      ));
    }

    // Notificar al operador asignado
    await _db.insertNotification(NotificationModel(
      userId: userId,
      title: 'Nueva Actividad Asignada',
      body: 'Se ha programado la actividad "$nombre" en tu estándar operativo.',
      type: 'assignment',
      timestamp: DateTime.now(),
      isRead: false,
    ));

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'CREAR_ACTIVIDAD_PLANTA',
      entity: 'ACTIVITY',
      entityId: actId,
      details: 'Actividad "$nombre" ($tipoActividad) asignada a $userId por el Admin de Planta',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  // --- OPERADOR / COLABORADOR ---

  /// Reporta la ejecución de una subtarea con evidencia fotográfica y comentario
  Future<void> reportSubtaskExecution({
    required int instanceId,
    required int subtaskId,
    String? photoPath,
    String? comment,
    double? measuredValue,
  }) async {
    if (_currentUser == null) return;

    final exec = SubtaskExecutionModel(
      subtaskId: subtaskId,
      instanceId: instanceId,
      userId: _currentUser!.id,
      reportada: true,
      aprobada: false,
      fotoPath: photoPath,
      comentario: comment,
      valorMedido: measuredValue,
      fechaReporte: DateTime.now(),
    );

    await _db.saveSubtaskExecution(exec);

    // Verificar si todas las subtareas fueron reportadas para marcar la instancia como reportada
    final executions = await _db.getSubtaskExecutionsForInstance(instanceId);
    final instance = _instances.firstWhere((i) => i.id == instanceId);

    if (executions.length >= instance.subtasksTotal && instance.subtasksTotal > 0) {
      await _db.updateInstanceStatus(instanceId, true, state: 'Reportada');
    }

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'REPORTE_SUBTAREA',
      entity: 'SUBTASK',
      entityId: subtaskId,
      details: 'Evidencia reportada para instancia $instanceId: ${comment ?? ""}',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Solicita reprogramación justificada para una actividad flexible
  Future<bool> requestReprogramming({
    required int instanceId,
    required int toDay,
    required String motivo,
  }) async {
    if (_currentUser == null) return false;
    final instance = _instances.firstWhere((i) => i.id == instanceId);

    if (instance.fija) {
      // Actividades fijas no pueden ser reprogramadas
      return false;
    }

    await _db.updateInstanceDay(instanceId, toDay, motivo);

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'SOLICITUD_REPROGRAMACION',
      entity: 'INSTANCE',
      entityId: instanceId,
      details: 'Reprogramada de día ${instance.day} a día $toDay. Motivo: $motivo',
      timestamp: DateTime.now(),
    ));

    await refreshData();
    return true;
  }

  /// Completa una actividad validando evidencias y plan de acción obligatorio previo al cierre
  Future<String?> completeActivityInstance({
    required int instanceId,
    String? observaciones,
    String? fotoPath,
  }) async {
    final instance = _instances.firstWhere((i) => i.id == instanceId);

    // 1. Validación de fotografía obligatoria
    if (instance.reqFoto && (fotoPath == null || fotoPath.trim().isEmpty)) {
      return 'Esta actividad exige adjuntar una fotografía como evidencia obligatoria antes de finalizar.';
    }

    // 2. Validación fundamental: Plan de acción obligatorio
    if (instance.planAccionObligatorio) {
      final relatedPlan = _proPlans.firstWhere(
        (p) => p.activityInstanceId == instanceId || (p.activityId != null && p.activityId == instance.activityId),
        orElse: () => ProPlanModel(
          id: -1,
          plantId: '',
          plan: '',
          responsable: '',
          area: '',
          fechaCompromiso: '',
          creadoPor: '',
          fechaCreacion: DateTime.now(),
        ),
      );

      final isFulfilled = relatedPlan.id != -1 && (relatedPlan.estado == 'Cumplido' || relatedPlan.porcentajeAvance >= 1.0);
      if (!isFulfilled) {
        return 'Para completar esta actividad debes diligenciar y cumplir el plan de acción obligatorio asociado.';
      }
    }

    final obsFinal = [
      if (observaciones != null && observaciones.trim().isNotEmpty) observaciones.trim(),
      if (fotoPath != null && fotoPath.trim().isNotEmpty) '[Foto Evidencia: $fotoPath]',
    ].join(' · ');

    await _db.updateInstanceStatus(instanceId, true, state: 'Reportada', obs: obsFinal.isNotEmpty ? obsFinal : null);

    await _db.logAudit(AuditLogModel(
      userId: _currentUser?.id ?? 'OPERADOR',
      action: 'COMPLETAR_ACTIVIDAD',
      entity: 'INSTANCE',
      entityId: instanceId,
      details: 'Actividad "${instance.nombre}" finalizada por ${_currentUser?.nombre ?? "Usuario"}${fotoPath != null ? " con evidencia fotográfica" : ""}',
      timestamp: DateTime.now(),
    ));

    await refreshData();
    return null; // Éxito
  }

  /// Diligencia y envía un registro de información o reunión
  Future<void> submitMeetingRecord({
    required int instanceId,
    required String titulo,
    required String fecha,
    required String descripcion,
    required String participantes,
    required String observaciones,
    required String compromisos,
    required String responsablesCompromisos,
    required String fechaCumplimientoCompromisos,
    String? fotoOAdjuntoPath,
  }) async {
    if (_currentUser == null) return;
    final instance = _instances.firstWhere((i) => i.id == instanceId);

    final record = MeetingRecordModel(
      instanceId: instanceId,
      activityId: instance.activityId,
      plantId: instance.plantId,
      usuarioId: _currentUser!.id,
      usuarioNombre: _currentUser!.nombre,
      titulo: titulo,
      fecha: fecha,
      descripcion: descripcion,
      participantes: participantes,
      observaciones: observaciones,
      compromisos: compromisos,
      responsablesCompromisos: responsablesCompromisos,
      fechaCumplimientoCompromisos: fechaCumplimientoCompromisos,
      fotoOAdjuntoPath: fotoOAdjuntoPath,
      fechaRegistro: DateTime.now(),
    );

    await _db.insertMeetingRecord(record);
    await _db.updateInstanceStatus(instanceId, true, state: 'Reportada', obs: 'Registro informativo diligenciado: $titulo');

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'REGISTRO_INFORMACION_REUNION',
      entity: 'MEETING_RECORD',
      entityId: instanceId,
      details: 'Registro "$titulo" diligenciado por ${_currentUser!.nombre}',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Consulta el registro informativo de una instancia
  Future<MeetingRecordModel?> getMeetingRecordForInstance(int instanceId) async {
    return await _db.getMeetingRecordForInstance(instanceId);
  }

  /// Crea un plan de acción formal
  Future<int> createProPlan({
    required String plantId,
    required String plan,
    required String responsable,
    required String area,
    required String fechaCompromiso,
    int? activityInstanceId,
    int? activityId,
    String? activityNombre,
    String? descripcionSituacion,
    bool requiereRevision = false,
  }) async {
    final newPlan = ProPlanModel(
      plantId: plantId,
      plan: plan,
      responsable: responsable,
      area: area,
      fechaCompromiso: fechaCompromiso,
      estado: 'Pendiente',
      creadoPor: _currentUser?.id ?? 'Admin',
      fechaCreacion: DateTime.now(),
      activityInstanceId: activityInstanceId,
      activityId: activityId,
      activityNombre: activityNombre,
      descripcionSituacion: descripcionSituacion,
      requiereRevision: requiereRevision,
    );

    final id = await _db.insertProPlan(newPlan);
    await refreshData();
    return id;
  }

  /// Actualiza avance y estado de un plan de acción
  Future<void> updateProPlanStatus({
    required int planId,
    required String nuevoEstado,
    double? porcentajeAvance,
    String? evidencia,
    String? comentarios,
  }) async {
    final idx = _proPlans.indexWhere((p) => p.id == planId);
    if (idx != -1) {
      final current = _proPlans[idx];
      final updated = current.copyWith(
        estado: nuevoEstado,
        porcentajeAvance: porcentajeAvance ?? current.porcentajeAvance,
        evidencia: evidencia ?? current.evidencia,
        comentarios: comentarios ?? current.comentarios,
      );
      await _db.updateProPlan(updated);
      await refreshData();
    }
  }

  // --- SUPERVISOR ---

  /// Obtiene las evidencias de piso para revisión del supervisor
  Future<List<SubtaskExecutionModel>> getPendingReviewsForPlant() async {
    if (_currentUser == null || (!_currentUser!.isSupervisor && !_currentUser!.isPlantAdmin && !_currentUser!.isSuperAdmin)) {
      return [];
    }
    return await _db.getPendingReviewsForPlant(_currentUser!.plantId);
  }

  /// Aprueba la ejecución de una subtarea tras inspección de evidencia
  Future<void> approveSubtaskExecution({
    required int executionId,
    required int instanceId,
  }) async {
    if (_currentUser == null) return;

    await _db.reviewSubtaskExecution(
      executionId: executionId,
      aprobada: true,
      revisorId: _currentUser!.id,
    );

    // Actualizar conteo en la instancia
    final executions = await _db.getSubtaskExecutionsForInstance(instanceId);
    final approvedCount = executions.where((e) => e.aprobada).length;
    final instance = _instances.firstWhere((i) => i.id == instanceId);

    if (approvedCount >= instance.subtasksTotal && instance.subtasksTotal > 0) {
      await _db.updateInstanceStatus(instanceId, true, state: 'Validada');
    }

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'APROBACION_EVIDENCIA',
      entity: 'SUBTASK_EXECUTION',
      entityId: executionId,
      details: 'Evidencia aprobada por supervisor ${_currentUser!.nombre}',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Rechaza la evidencia solicitando corrección
  Future<void> rejectSubtaskExecution({
    required int executionId,
    required String motivoRechazo,
  }) async {
    if (_currentUser == null) return;

    await _db.reviewSubtaskExecution(
      executionId: executionId,
      aprobada: false,
      revisorId: _currentUser!.id,
      motivoRechazo: motivoRechazo,
    );

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'RECHAZO_EVIDENCIA',
      entity: 'SUBTASK_EXECUTION',
      entityId: executionId,
      details: 'Evidencia rechazada: $motivoRechazo',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  // --- NOTIFICACIONES ---

  Future<void> markNotificationAsRead(int id) async {
    await _db.markNotificationAsRead(id);
    _notifications = await _db.getNotificationsForUser(_currentUser!.id);
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    if (_currentUser == null) return;
    await _db.markAllNotificationsAsRead(_currentUser!.id);
    _notifications = await _db.getNotificationsForUser(_currentUser!.id);
    notifyListeners();
  }

  // --- REGLA 10 TAREAS: CONTEO DIARIO ---
  /// Retorna cuántas tareas tiene asignadas el operador o planta en un día específico
  int getTaskCountForDay({required String userId, required int day}) {
    return _instances.where((i) => i.userId == userId && i.day == day).length;
  }

  // --- SOLICITUD DE TAREA ADICIONAL (>10 TAREAS) ---
  Future<void> requestExtraTask({
    required String nombre,
    required String descripcion,
    required String area,
    required String prioridad,
    required String justificacion,
    required String dias,
    required String timeStart,
    required String timeEnd,
  }) async {
    if (_currentUser == null) return;

    final req = ExtraTaskRequestModel(
      plantId: _currentUser!.plantId,
      adminId: _currentUser!.id,
      nombre: nombre,
      descripcion: descripcion,
      area: area,
      prioridad: prioridad,
      justificacion: justificacion,
      dias: dias,
      timeStart: timeStart,
      timeEnd: timeEnd,
      estado: 'Pendiente',
      fechaSolicitud: DateTime.now(),
    );

    await _db.insertExtraTaskRequest(req);

    // Notificar a Javier Julio (Super Admin)
    final superAdmins = _allUsers.where((u) => u.isSuperAdmin);
    for (final sa in superAdmins) {
      await _db.insertNotification(NotificationModel(
        userId: sa.id,
        title: 'Solicitud Tarea Extra (>10) · ${_currentUser!.plantId}',
        body: '${_currentUser!.nombre} solicita habilitar la tarea "$nombre" ($prioridad). Motivo: $justificacion',
        type: 'extra_task_request',
        timestamp: DateTime.now(),
        isRead: false,
      ));
    }

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'SOLICITUD_TAREA_EXTRA',
      entity: 'EXTRA_TASK',
      details: 'Solicitud de tarea #11+ "$nombre" ($prioridad) enviada a Superadmin',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  /// Super Admin aprueba o rechaza solicitud de ampliación de capacidad
  Future<void> reviewExtraTaskRequest({
    required int requestId,
    required bool approve,
    String? motivoRechazo,
    String? assignedUserId,
  }) async {
    if (_currentUser == null || !_currentUser!.isSuperAdmin) return;

    final reqList = await _db.getExtraTaskRequests();
    final req = reqList.firstWhere((r) => r.id == requestId);

    if (approve) {
      // 1. Marcar como aprobada y registrar decisión
      final updatedReq = ExtraTaskRequestModel(
        id: req.id,
        plantId: req.plantId,
        adminId: req.adminId,
        nombre: req.nombre,
        descripcion: req.descripcion,
        area: req.area,
        prioridad: req.prioridad,
        justificacion: req.justificacion,
        dias: req.dias,
        timeStart: req.timeStart,
        timeEnd: req.timeEnd,
        estado: 'Aprobada',
        motivoRechazo: motivoRechazo ?? 'Capacidad ampliada por Dirección General',
        fechaSolicitud: req.fechaSolicitud,
      );
      await _db.updateExtraTaskRequest(updatedReq);

      // Notificar al Admin de Planta que su capacidad fue ampliada
      await _db.insertNotification(NotificationModel(
        userId: req.adminId,
        title: '¡Ampliación de Capacidad Aprobada!',
        body: 'Javier Julio aprobó la ampliación para "${req.nombre}". Tu cupo de creación en planta ha aumentado y ya puedes registrar tu actividad.',
        type: 'request_approved',
        timestamp: DateTime.now(),
        isRead: false,
      ));

      await _db.logAudit(AuditLogModel(
        userId: _currentUser!.id,
        action: 'AMPLIACION_CAPACIDAD_APROBADA',
        entity: 'CAPACIDAD_PLANTA',
        details: 'Ampliación de cupo aprobada para ${req.plantId} por solicitud "${req.nombre}". Comentario: ${motivoRechazo ?? "Autorizado"}',
        timestamp: DateTime.now(),
      ));
    } else {
      final updatedReq = ExtraTaskRequestModel(
        id: req.id,
        plantId: req.plantId,
        adminId: req.adminId,
        nombre: req.nombre,
        descripcion: req.descripcion,
        area: req.area,
        prioridad: req.prioridad,
        justificacion: req.justificacion,
        dias: req.dias,
        timeStart: req.timeStart,
        timeEnd: req.timeEnd,
        estado: 'Rechazada',
        motivoRechazo: motivoRechazo ?? 'No autorizada por capacidad operativa',
        fechaSolicitud: req.fechaSolicitud,
      );
      await _db.updateExtraTaskRequest(updatedReq);

      await _db.insertNotification(NotificationModel(
        userId: req.adminId,
        title: 'Solicitud de Capacidad Rechazada',
        body: 'Javier Julio no autorizó la ampliación para "${req.nombre}". Motivo: ${motivoRechazo ?? "Capacidad excedida"}',
        type: 'request_rejected',
        timestamp: DateTime.now(),
        isRead: false,
      ));

      await _db.logAudit(AuditLogModel(
        userId: _currentUser!.id,
        action: 'AMPLIACION_CAPACIDAD_RECHAZADA',
        entity: 'CAPACIDAD_PLANTA',
        details: 'Ampliación rechazada para ${req.plantId} ("${req.nombre}"). Motivo: ${motivoRechazo ?? "Sin justificación suficiente"}',
        timestamp: DateTime.now(),
      ));
    }

    await refreshData();
  }

  // --- ASIGNACIÓN DE ACTIVIDADES CORPORATIVAS POR ADMIN DE PLANTA ---
  /// El admin de planta toma una actividad corporativa global y la asigna a un operador o tableta de turno
  Future<void> assignCorporateActivityToOperator({
    required int activityId,
    required String targetUserId,
    required String plantId,
  }) async {
    if (_currentUser == null) return;

    // Reasignar instancias de esa actividad en esa planta
    await _db.reassignActivityInstances(
      activityId: activityId,
      plantId: plantId,
      newUserId: targetUserId,
    );

    final actList = await _db.getAllActivities();
    final act = actList.firstWhere((a) => a.id == activityId);

    // Notificar al operador asignado
    await _db.insertNotification(NotificationModel(
      userId: targetUserId,
      title: 'Actividad Corporativa Asignada',
      body: '${_currentUser!.nombre} te asignó la responsabilidad de "${act.nombre}".',
      type: 'assignment',
      timestamp: DateTime.now(),
      isRead: false,
    ));

    await _db.logAudit(AuditLogModel(
      userId: _currentUser!.id,
      action: 'ASIGNAR_ACTIVIDAD_CORPORATIVA',
      entity: 'ACTIVITY',
      entityId: activityId,
      details: 'Actividad "${act.nombre}" asignada a $targetUserId en planta $plantId',
      timestamp: DateTime.now(),
    ));

    await refreshData();
  }

  // --- CRUD GESTIÓN PROPLANES ---
  Future<void> addProPlan({
    required String plan,
    required String responsable,
    required String area,
    required String fechaCompromiso,
    String? comentarios,
    String? evidencia,
  }) async {
    if (_currentUser == null) return;

    final p = ProPlanModel(
      plantId: _currentUser!.plantId,
      plan: plan,
      responsable: responsable,
      area: area,
      fechaCompromiso: fechaCompromiso,
      comentarios: comentarios,
      evidencia: evidencia,
      creadoPor: _currentUser!.nombre,
      fechaCreacion: DateTime.now(),
    );

    await _db.insertProPlan(p);
    await refreshData();
  }


  Future<void> deleteProPlan(int planId) async {
    await _db.deleteProPlan(planId);
    await refreshData();
  }

  // --- CRUD GESTIÓN ESTÁNDARES VISUALES SUPERVISOR ---
  Future<void> addPlantPhotoStandard({
    required String titulo,
    required String descripcion,
    required String fotoPath,
    required String area,
  }) async {
    if (_currentUser == null) return;

    final std = PlantPhotoStandardModel(
      plantId: _currentUser!.plantId,
      supervisorId: _currentUser!.id,
      titulo: titulo,
      descripcion: descripcion,
      fotoPath: fotoPath,
      area: area,
      fechaRegistro: DateTime.now(),
    );

    await _db.insertPlantPhotoStandard(std);
    await refreshData();
  }

  Future<void> deletePlantPhotoStandard(int id) async {
    await _db.deletePlantPhotoStandard(id);
    await refreshData();
  }

  // --- CRUD COMPLETO GENÉRICO TOTAL ---
  Future<void> deletePlant(String plantId) async {
    await _db.deletePlant(plantId);
    await refreshData();
  }

  Future<void> updatePlant(PlantModel plant) async {
    await _db.updatePlant(plant);
    await refreshData();
  }

  Future<void> deleteUser(String userId) async {
    await _db.deleteUser(userId);
    await refreshData();
  }

  Future<void> resetUserPin(String userId, String newPin) async {
    try {
      await ApiClient.instance.patch('/users/$userId/reset-pin', body: {'pin': newPin});
    } catch (e) {
      debugPrint('Error reseteando PIN en nube: $e');
    }
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _allUsers[idx].copyWith(pin: newPin);
      await _db.updateUser(updated);
    }
    await refreshData();
  }

  Future<void> toggleUserActive(String userId, bool active) async {
    try {
      await ApiClient.instance.patch('/users/$userId/status?activo=$active');
    } catch (e) {
      debugPrint('Error actualizando estado en nube: $e');
    }
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _allUsers[idx].copyWith(activo: active);
      await _db.updateUser(updated);
    }
    await refreshData();
  }

  Future<void> updateUserRoleAndPlant(String userId, String rol, String plantId) async {
    try {
      await ApiClient.instance.patch('/users/$userId/role', body: {'rol': rol, 'plantId': plantId});
    } catch (e) {
      debugPrint('Error actualizando rol/planta en nube: $e');
    }
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _allUsers[idx].copyWith(rol: rol, plantId: plantId);
      await _db.updateUser(updated);
    }
    await refreshData();
  }

  Future<void> updateUser(UserProfile user) async {
    await _db.updateUser(user);
    await refreshData();
  }

  Future<List<AccessLogEntry>> fetchAccessLogs() async {
    final res = await ApiClient.instance.get('/access-logs');
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => AccessLogEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> clearAccessLogs({bool onlyFailed = false}) async {
    await ApiClient.instance.delete('/access-logs?onlyFailed=$onlyFailed');
  }

  Future<void> updateFullUser({
    required String userId,
    required String cedula,
    required String nombre,
    required String cargo,
    required String area,
    required String email,
    required String rol,
    required String plantId,
    required bool activo,
    String? newPin,
  }) async {
    final body = <String, dynamic>{
      'cedula': cedula.trim(),
      'nombre': nombre.trim(),
      'cargo': cargo.trim(),
      'area': area.trim(),
      'email': email.trim(),
      'rol': rol.trim(),
      'plantId': plantId.trim(),
      'activo': activo,
      if (newPin != null && newPin.trim().isNotEmpty) 'pin': newPin.trim(),
    };
    try {
      await ApiClient.instance.put('/users/$userId', body);
    } on ApiExceptionClient catch (e) {
      if (e.statusCode != 404) rethrow;
      // Si el usuario solo existía en caché local, lo creamos en la nube.
      await ApiClient.instance.post('/users', body);
    }
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _allUsers[idx].copyWith(
        cedula: cedula.trim(),
        nombre: nombre.trim(),
        cargo: cargo.trim(),
        area: area.trim(),
        email: email.trim(),
        rol: rol.trim(),
        plantId: plantId.trim(),
        activo: activo,
        pin: (newPin != null && newPin.trim().isNotEmpty) ? newPin.trim() : _allUsers[idx].pin,
      );
      await _db.updateUser(updated);
    }
    await refreshData();
  }

  Future<void> createFullUser({
    required String cedula,
    required String nombre,
    required String cargo,
    required String area,
    required String email,
    required String rol,
    required String plantId,
    String? pin,
  }) async {
    final cleanName = nombre.trim();
    final parts = cleanName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts[1][0]}'.toUpperCase()
        : (cleanName.isNotEmpty ? cleanName.substring(0, cleanName.length >= 2 ? 2 : 1).toUpperCase() : 'US');

    final created = await ApiClient.instance.post('/users', {
      'cedula': cedula.trim(),
      'nombre': cleanName,
      'cargo': cargo.trim(),
      'area': area.trim(),
      'iniciales': initials,
      'email': email.trim(),
      'rol': rol.trim(),
      'plantId': plantId.trim(),
      if (pin != null && pin.trim().isNotEmpty) 'pin': pin.trim(),
    });
    if (created is Map) {
      final map = Map<String, dynamic>.from(created);
      final newUser = UserProfile(
        id: map['id']?.toString() ?? 'USR-${DateTime.now().millisecondsSinceEpoch}',
        cedula: map['cedula']?.toString() ?? cedula.trim(),
        nombre: map['nombre']?.toString() ?? cleanName,
        cargo: map['cargo']?.toString() ?? cargo.trim(),
        area: map['area']?.toString() ?? area.trim(),
        iniciales: map['iniciales']?.toString() ?? initials,
        email: map['email']?.toString() ?? email.trim(),
        activo: map['activo'] != false,
        rol: map['rol']?.toString() ?? rol.trim(),
        plantId: map['plantId']?.toString() ?? plantId.trim(),
        pin: pin?.trim() ?? '',
      );
      await _db.insertUser(newUser);
    }
    await refreshData();
  }

  Future<void> deleteUserFromCloud(String userId) async {
    try {
      await ApiClient.instance.delete('/users/$userId');
    } on ApiExceptionClient catch (e) {
      // Si no existe en MongoDB (404, usuario fantasma de caché local), igual se elimina localmente.
      if (e.statusCode != 404) rethrow;
    }
    await _db.deleteUser(userId);
    _allUsers.removeWhere((u) => u.id == userId);
    await refreshData();
  }

  Future<void> sendGlobalBroadcast({required String title, required String message, String type = 'INFO'}) async {
    await ApiClient.instance.post('/notifications', {
      'title': title,
      'message': message,
      'type': type,
    });
    await refreshData();
  }

  Future<void> deleteActivity(int activityId) async {
    await _db.deleteActivity(activityId);
    await refreshData();
  }
}
