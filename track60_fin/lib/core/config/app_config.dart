enum DataSourceType {
  excel,
  sharepoint,
}

class AppConfig {
  AppConfig._();

  /// Origen de datos activo
  /// - [DataSourceType.excel]: Etapa actual mientras TI entrega permisos
  /// - [DataSourceType.sharepoint]: Etapa futura (Microsoft Graph REST API)
  static const DataSourceType activeDataSource = DataSourceType.excel;

  /// Configuración de Microsoft Entra ID (Asignada por TI cuando autoricen)
  static const String tenantId = 'TI_PENDIENTE_TENANT_ID';
  static const String clientId = 'TI_PENDIENTE_CLIENT_ID';
  static const String redirectUriWeb = 'https://standardwork.darnelgroup.com/auth';
  static const String redirectUriNative = 'msauth://com.darnel.track60/callback';

  /// Listas Existentes de SharePoint (Estructura Darnel)
  static const String spSiteUrl = 'https://darnelgroup.sharepoint.com/sites/OperacionesStandardWork';
  static const String listProPlanes = 'ProPlanes';
  static const String listActivities = 'ActividadesEstandar';
  static const String listInstances = 'InstanciasRutinas';
  static const String listPlants = 'PlantasOperativas';
  static const String listUsers = 'UsuariosPersonal';
  static const String listEvidence = 'EvidenciasSubtareas';
}

