# Despliegue en Render — TRACK60

El repositorio incluye `render.yaml` en la raíz para desplegar ambos servicios:

## 1. Backend (`track60-backend` — Web Service Docker)
Variables de entorno obligatorias a configurar en el panel de Render:
- `SPRING_PROFILES_ACTIVE=prod`
- `MONGODB_URI=mongodb+srv://<usuario>:<password>@<cluster>.mongodb.net/track60?retryWrites=true&w=majority`
- `JWT_SECRET=<clave_segura_minimo_32_caracteres>`
- `CORS_ALLOWED_ORIGINS=https://track60-web.onrender.com,http://localhost:8080`
- `STORAGE_PROVIDER=cloudinary` (y `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`)

Health Check configurado en `/actuator/health`.

## 2. Frontend (`track60-web` — Static Site)
- **Build Command:** `flutter build web --release --dart-define=API_BASE_URL=https://<tu-backend>.onrender.com/api/v1`
- **Publish Directory:** `./build/web`
- **Rewrite SPA:** `/* -> /index.html`

## 3. APK Android de Producción
Compilar apuntando a la URL de producción:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://<tu-backend>.onrender.com/api/v1
```

