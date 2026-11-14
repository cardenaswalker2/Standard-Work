# Configuración de MongoDB Atlas y Seguridad

## MongoDB Atlas
1. Crear un clúster en MongoDB Atlas y una base de datos llamada `track60`.
2. Crear un usuario de base de datos con rol `readWrite` únicamente sobre `track60`.
3. En **Network Access**, agregar las IPs salientes de Render (o `0.0.0.0/0` únicamente si se requiere acceso dinámico desde Render, protegido por usuario/contraseña fuerte y TLS).
4. Nunca subir `MONGODB_URI` a GitHub; configurarla solo en `.env` local o en el panel de Render.

## Seguridad Spring Security + JWT
- Autenticación stateless con Bearer JWT (`accessToken` + `refreshToken`).
- Contraseñas/PINs cifrados con `BCryptPasswordEncoder` (nunca en texto plano ni en respuestas REST).
- Validación de alcance organizacional (`ScopeValidator`): un `admin_planta` o `supervisor` solo puede consultar o modificar datos de su propia `plantId`.
- Validación de capacidad de creación en el servidor: base `2` actividades locales por planta + ampliaciones aprobadas por Super Admin (referencia corporativa `8`).

