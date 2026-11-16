import '../models/app_models.dart';

abstract class IStandardWorkRepository {
  // --- USUARIOS Y PLANTAS ---
  Future<List<PlantModel>> getPlants();
  Future<List<UserProfile>> getUsers();
  Future<UserProfile?> authenticateUser(String identifier, {String? pin});

  // --- ACTIVIDADES E INSTANCIAS ---
  Future<List<ActivityModel>> getActivities({String? plantId});
  Future<List<ActivityInstance>> getInstances({required String weekKey, String? plantId, String? userId});
  Future<void> updateInstanceStatus(int instanceId, bool done, {String state = 'Completada'});

  // --- SUBTAREAS Y EVIDENCIAS ---
  Future<List<ActivitySubtaskModel>> getSubtasks(int activityId);
  Future<void> saveSubtaskExecution(SubtaskExecutionModel execution);
  Future<List<SubtaskExecutionModel>> getSubtaskExecutions(int instanceId);

  // --- PROPLANES ---
  Future<List<ProPlanModel>> getProPlans({String? plantId});
  Future<int> insertProPlan(ProPlanModel plan);
  Future<void> updateProPlan(ProPlanModel plan);
  Future<void> deleteProPlan(int id);

  // --- AUDITORÍA Y NOTIFICACIONES ---
  Future<void> logAudit(AuditLogModel log);
  Future<List<NotificationModel>> getNotifications(String userId);
}
