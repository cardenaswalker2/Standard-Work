/// Configuración centralizada de red para TRACK60 (Web, PWA y APK).
/// Se inyecta en compilación mediante:
/// --dart-define=API_BASE_URL=https://tu-backend.onrender.com/api/v1
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://track60.onrender.com/api/v1',
  );

  static const Duration timeout = Duration(seconds: 55);
}

