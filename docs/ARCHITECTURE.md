# Arquitectura Empresarial Cloud — TRACK60 (Grupo Darnel)

## Visión General
TRACK60 evoluciona de almacenamiento local por dispositivo a una arquitectura centralizada en la nube:
- **Frontend único:** Flutter (`track60_fin`) para Android APK, Flutter Web y PWA (iOS/Desktop).
- **Backend REST:** Java 17 + Spring Boot 3.3.5 + Maven (`track60-backend`).
- **Base de Datos:** MongoDB Atlas (`track60`) con índices compuestos y fechas en UTC.
- **Almacenamiento de Evidencias:** Externo (Cloudinary / Cloudflare R2), sin Base64 en MongoDB ni disco temporal en Render.
- **Despliegue:** Render Web Service (Docker) para el backend y Render Static Site para Flutter Web/PWA.

## Colecciones MongoDB (`track60`)
- `usuarios` (índice único `cedula`, índice compuesto `plantId + rol + activo`)
- `plantas` (índice único `codigo`)
- `actividades` (índice compuesto `plantId + userId + esGlobal`)
- `ejecuciones_actividades` (índice compuesto `plantId + weekKey + day + userId`)
- `subtareas`, `evidencias`, `planes_accion`, `solicitudes_capacidad`, `notificaciones`, `auditoria`, `registros_informativos`, `plantillas`.

