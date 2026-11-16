import '../database/database_helper.dart';
import '../models/app_models.dart';
import 'i_standard_work_repository.dart';

class ExcelStandardWorkRepository implements IStandardWorkRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<List<PlantModel>> getPlants() => _db.getAllPlants();

  @override
  Future<List<UserProfile>> getUsers() => _db.getAllUsers();

  @override
  Future<UserProfile?> authenticateUser(String identifier, {String? pin}) async {
    final users = await _db.getAllUsers();
    final cleanId = identifier.trim();

    // 1. Super Admin (Javier Julio)
    if (cleanId == '1428' || cleanId == 'JJ' || (cleanId == '10203040' && pin == '1428')) {
      return users.firstWhere((u) => u.isSuperAdmin, orElse: () => users.first);
    }

    // 2. Por Cédula
    try {
      final user = users.firstWhere((u) => u.cedula == cleanId);
      if (pin != null && pin.isNotEmpty) {
        if (user.pin == pin) return user;
        return null;
      }
      return user;
    } catch (_) {}

    // 3. Por PIN de Supervisor o Admin de Planta
    if (pin != null && pin.isNotEmpty) {
      try {
        return users.firstWhere((u) => u.pin == pin && (u.isSupervisor || u.isPlantAdmin));
      } catch (_) {}
    }

    return null;
  }

  @override
  Future<List<ActivityModel>> getActivities({String? plantId}) => _db.getAllActivities();

  @override
  Future<List<ActivityInstance>> getInstances({required String weekKey, String? plantId, String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      return _db.getInstancesForUserAndWeek(userId, weekKey);
    }
    if (plantId != null && plantId.isNotEmpty) {
      return _db.getInstancesForPlant(plantId, weekKey);
    }
    return [];
  }

  @override
  Future<void> updateInstanceStatus(int instanceId, bool done, {String state = 'Completada'}) =>
      _db.updateInstanceStatus(instanceId, done, state: state);

  @override
  Future<List<ActivitySubtaskModel>> getSubtasks(int activityId) => _db.getSubtasksForActivity(activityId);

  @override
  Future<void> saveSubtaskExecution(SubtaskExecutionModel execution) => _db.saveSubtaskExecution(execution);

  @override
  Future<List<SubtaskExecutionModel>> getSubtaskExecutions(int instanceId) => _db.getSubtaskExecutionsForInstance(instanceId);

  @override
  Future<List<ProPlanModel>> getProPlans({String? plantId}) => _db.getProPlans(plantId: plantId);

  @override
  Future<int> insertProPlan(ProPlanModel plan) => _db.insertProPlan(plan);

  @override
  Future<void> updateProPlan(ProPlanModel plan) => _db.updateProPlan(plan);

  @override
  Future<void> deleteProPlan(int id) => _db.deleteProPlan(id);

  @override
  Future<void> logAudit(AuditLogModel log) => _db.logAudit(log);

  @override
  Future<List<NotificationModel>> getNotifications(String userId) => _db.getNotificationsForUser(userId);
}
