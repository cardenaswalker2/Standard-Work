# PROPUESTA TÉCNICA Y DE ARQUITECTURA EMPRESARIAL
## PROYECTO: TRACK60 – INTEGRACIÓN FLUTTER & MICROSOFT SHAREPOINT
### GRUPO DARNEL – DIRECCIÓN DE OPERACIONES & DIRECCIÓN DE TECNOLOGÍA E INFORMACIÓN (TI)

---

## 1. RESUMEN EJECUTIVO

El proyecto **TRACK60** es una solución corporativa de software diseñada para estandarizar, gobernar y auditar en tiempo real las rutinas operativas (Standard Work), la supervisión 5S y el cumplimiento de metas en las plantas de manufactura de Grupo Darnel (**Extrusión, Termoformado, Inyección y Litografía**).

La aplicación ya ha sido desarrollada y validada operativamente con tecnología **Flutter Enterprise Multiplataforma**, lo que permite desplegarla de manera unificada en:
1. **Celulares Android:** Mediante APK nativo para operadores y supervisores en piso de planta.
2. **Celulares iPhone (iOS):** Mediante Aplicación Web Progresiva (PWA) instalable directamente desde Safari con icono oficial corporativo, sin requerir publicación en tiendas públicas.
3. **Computadores y Portátiles (PC):** Mediante navegador web (Microsoft Edge y Google Chrome) para jefes de planta y directores, sin requerir permisos de administrador de Windows para instalación.

El objetivo de este documento es solicitar al departamento de **Tecnología e Información (TI) de Grupo Darnel** la habilitación de los permisos requeridos en **Microsoft Entra ID** y **Microsoft Graph API** para conectar la aplicación con las **listas de SharePoint que ya existen**, consolidando una fuente centralizada de información segura y gobernada.

---

## 2. ETAPA ACTUAL (TRANSITORIA) VS. ETAPA FUTURA CON SHAREPOINT

| Dimensión Técnica | Etapa Actual (Excel / SQLite Local) | Etapa Futura (Microsoft SharePoint Online) |
| :--- | :--- | :--- |
| **Repositorio de Datos** | Archivos Excel estructurados y base de datos local SQLite / LocalStorage. | Listas oficiales centralizadas en el tenant de SharePoint de Grupo Darnel. |
| **Autenticación** | Credenciales locales (PIN / Cédula) validadas contra catálogo interno. | **Single Sign-On (SSO)** con cuentas `@darnel.com` respaldado por **Microsoft Entra ID**. |
| **Concurrencia** | Los archivos Excel compartidos presentan bloqueos y riesgos de edición simultánea. | **Concurrencia transaccional nativa:** Cientos de operadores y supervisores actualizan en paralelo. |
| **Trazabilidad y Auditoría** | Registro local con exportación manual periódica. | Versionado de registros, auditoría completa de modificaciones y retención corporativa Microsoft 365. |
| **Costo de Infraestructura** | Cero costo adicional de licencias. | **Costo CERO adicional:** Aprovecha las licencias de Microsoft 365 y SharePoint que Darnel ya tiene contratadas. |

---

## 3. ARQUITECTURA DE SEGURIDAD Y CUMPLIMIENTO (ESTÁNDAR MICROSOFT)

La integración con el ecosistema Microsoft 365 se ha diseñado bajo los principios de **mínimo privilegio** y **cero almacenamiento de credenciales**:

1. **Protocolo de Autenticación:** OAuth 2.0 con *Authorization Code Flow with PKCE* (RFC 7636), recomendado por Microsoft para clientes públicos y SPAs.
2. **Confidencialidad de Contraseñas:** La aplicación **nunca** almacena contraseñas de los colaboradores. La validación la realiza Microsoft Entra ID directamente.
3. **Manejo de Tokens:** La aplicación recibe un JSON Web Token (JWT) de corta duración firmado por Microsoft, utilizado exclusivamente para consultar y escribir en las listas autorizadas vía Microsoft Graph API.
4. **Aislamiento de Recursos:** La aplicación solo tendrá acceso a las listas de SharePoint asociadas a TRACK60, sin visibilidad ni acceso a otros sitios o buzones de correo.

---

## 4. SOLICITUD PUNTUAL AL EQUIPO DE TI DE GRUPO DARNEL

Para habilitar la sincronización nativa en tiempo real, se requiere que el equipo de TI configure en el portal de Azure / Microsoft Entra ID:

### A. Registro de Aplicación (App Registration)
* **Nombre de la Aplicación:** `TRACK60 - Grupo Darnel`
* **Tipos de cuenta admitidos:** Solo las cuentas de este directorio organizativo (*Single Tenant* - Tenant Darnel).

### B. Permisos de Microsoft Graph API (Delegados)
* `User.Read` (Lectura básica del perfil del colaborador: nombre, correo, cargo).
* `Sites.Selected` (Recomendado por seguridad: restringe el acceso únicamente al sitio de SharePoint de TRACK60) **O** `Sites.ReadWrite.All` limitado a las listas operativas.

### C. Redirect URIs (URIs de Redirección)
* **Web (PWA y Navegador PC):**
  * `http://localhost:8080` (Entorno de pruebas/desarrollo)
  * `https://[dominio-corporativo-darnel]/` (Producción)
* **Aplicación Móvil (Android/iOS):**
  * `msauth://com.darnel.track60/[FirmaHash]`

### D. Información a entregar al equipo de desarrollo
* `Application (client) ID`
* `Directory (tenant) ID`
* URLs / GUIDs de las listas de SharePoint ya existentes destinadas a TRACK60.

---

## 5. IMPACTO OPERATIVO Y BENEFICIOS PARA DARNEL

1. **Gobernanza Total en Planta:** Javier Julio y los directores de planta disponen de un semáforo en vivo que refleja el porcentaje real de cumplimiento de cada planta en cualquier instante.
2. **Calidad y 5S con Sustento:** Eliminación del reporte "en papel" sin evidencia. Toda actividad crítica requiere fotografía previa y posterior aprobada por supervisión.
3. **Gestión de Planes de Acción (ProPlanes):** Seguimiento estructurado a compromisos con fecha, responsable y estado, evitando olvidos de mantenimiento preventivo.
4. **Cero Mantenimiento para TI:** Al correr sobre SharePoint y PWA/APK, no requiere servidores locales, mantenimiento de bases de datos SQL dedicadas ni parches de infraestructura externa.

---

**Preparado para:**  
Dirección General de Operaciones & Dirección de Tecnología e Información (TI)  
**Grupo Darnel – 2026**

