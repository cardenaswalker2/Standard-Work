# DIAGNÓSTICO Y ANÁLISIS INTEGRAL: PROYECTO STANDARD WORK
**Organización:** Darnel Group  
**Solución Tecnológica:** Standard Work Ecosystem (App Móvil Flutter v2.0.0 · Simulador Web · Portal Corporativo)  
**Fecha de Diagnóstico:** Noviembre 2026  
**Documento Interno de Ingeniería y Producción Audiovisual**

---

## 1. RESUMEN EJECUTIVO Y PROPÓSITO DEL SISTEMA

### 1.1 ¿Qué es Standard Work?
**Standard Work** es la plataforma digital de gestión, ejecución y seguimiento del trabajo estándar de supervisión y liderazgo operativo de **Darnel Group**. El sistema digitaliza la matriz de rutinas que anteriormente se administraba en hojas de cálculo complejas de Excel (`ST - WR YONNY LOPEZ.xlsb`), trasladándola a una aplicación móvil ágil, offline-first y trazable, diseñada específicamente para el entorno de planta (producción, extrusión, termoformado, calidad y logística).

### 1.2 ¿Qué problema busca resolver?
En plantas industriales de manufactura continua de empaques sostenibles, los supervisores y coordinadores enfrentaban barreras críticas:
1. **Dependencia de archivos estáticos:** El seguimiento de rutinas dependía de hojas de cálculo binarias de Excel poco prácticas para consultar en movimiento en piso de planta.
2. **"Flujo cargando el error hacia arriba" (Gobernanza Operativa):** Como documenta la matriz de gobernanza interna, los registros manuales de paradas e incidencias se corregían tarde en oficina por ingenieros, basando decisiones ejecutivas en datos dudosos o distorsionados en lugar de validar en tiempo real en el Gemba.
3. **Falta de trazabilidad y justificación:** Cuando una actividad programada no se ejecutaba a tiempo (por urgencias operativas), no quedaba registro del motivo ni de su reprogramación formal.
4. **Visibilidad fragmentada:** La gerencia carecía de un indicador consolidado y en tiempo real sobre el porcentaje de adherencia al plan de supervisión semanal y la distribución del tiempo de sus líderes.

### 1.3 Propósito del Proyecto
Centralizar, estandarizar y visibilizar en tiempo real las actividades críticas de los líderes de planta, asegurando que el dato operativo llegue "listo para decidir y no para corregir", elevando la disciplina operativa, el acompañamiento al personal (1:1s) y la prevención de fallas en calidad y seguridad.

---

## 2. PÚBLICO OBJETIVO Y ÁREAS DE APLICACIÓN

- **Supervisores de Turno y Jefes de Planta:** Ejecutan sus rutinas diarias en planta (Gemba Walk, reuniones de piso, revisión de adherencia al plan de producción).
- **Coordinadores de Calidad e Inocuidad:** Gestión de alertas de calidad, reclamos y **revisión RMNC** (*Reportes de Material No Conforme* y concesiones).
- **Líderes de Mantenimiento y Confiabilidad:** Seguimiento a equipos críticos, planes de mantenimiento y proyectos CAPEX.
- **Responsables de SST (Seguridad y Salud en el Trabajo):** Ejecución de JSAs (*Job Safety Analysis*), reuniones de seguridad de extrusión y planes de acción preventivos.
- **Gerencia Operativa y de Planta:** Monitoreo del One Pager, análisis de KPIs de productividad, OEE y cumplimiento de las 4 semanas del ciclo de trabajo estándar.

---

## 3. MATRIZ DE TIEMPO Y CATEGORÍAS ESTRATÉGICAS VERIFICADAS

A partir del análisis de la base de datos y la matriz maestra del proyecto, el tiempo de los líderes de Darnel Group se estructura en **7 categorías estratégicas con ponderación porcentual definida**:

| Categoría | Color Corporativo | % Tiempo Meta | Actividades Representativas Verificadas |
|---|---|---|---|
| **Operación y Ejecución** | Azul Oscuro (`#002F6C`) | **28%** | Gemba Walk diario, Reunión de Piso Operacional, Revisión de Adherencia al Plan de Producción. |
| **Resultados y Productividad** | Verde Éxito (`#16A34A`) | **18%** | Revisión de KPIs, Utilidades, Capacidad y Productividad de Máquinas, Semanal Poliolefina, Confiabilidad de Equipos Críticos. |
| **Liderazgo y Desarrollo de Personas** | Naranja (`#F97316`) | **15%** | Reuniones 1:1 con colaboradores (Geisson, Naren, Emily, Edwin, Alberto), Desarrollo de Competencias Operacionales (Capacitación Integral del Cargo). |
| **Administración Operativa** | Gris Pizarra (`#64748B`) | **14%** | Tareas pendientes, aprobaciones y solicitudes, Correos, Revisión de Cubos / BI, DEXs, Revisión de Agenda del día siguiente. |
| **Proyectos y Mejora Continua** | Azul Vibrante (`#006DB2`) | **11%** | Desarrollos de Productos POF, Proyectos Menores / CAPEX, Pre-revisión de Mejoras, Seguimiento al Dashboard One Pager, Avance Plan de Mantenimiento. |
| **Calidad e Inocuidad** | Morado / Púrpura (`#7C3AED`) | **9%** | **Revisión RMNC y concesiones** (Material No Conforme), Alertas y Reclamos de Calidad, Semanal de Inocuidad. |
| **Seguridad (SST)** | Rojo Alerta (`#DC2626`) | **5%** | Revisión JSA Operaciones, Semanal Seguridad Extrusión, Planes de Acción de Seguridad, Global Safety Meeting mensual. |

---

## 4. RELACIÓN VERIFICADA ENTRE STANDARD WORK Y RMNC

- **Definición:** **RMNC** corresponde a **Revisión de Material No Conforme y Concesiones** (Reportes de Rechazo / No Conformidad de Producto).
- **Vínculo Operativo:** En el catálogo maestro y la planificación semanal de Darnel Group, la revisión de RMNC es una actividad semanal crítica (bloque de 30 minutos programado los días viernes de 09:30 a 10:00 o jueves según turno).
- **Impacto:** Permite al supervisor y al área de calidad analizar producto observado o retenido antes de que cause retrasos logísticos o costos por scrap, registrando las concesiones autorizadas dentro del marco del Trabajo Estándar.

---

## 5. DIAGNÓSTICO DEL ECOSISTEMA TECNOLÓGICO Y CÓDIGO FUENTE

El ecosistema está compuesto por tres piezas sincronizadas:

### 5.1 Aplicación Móvil Nativa Flutter (`standard_work_app`)
- **Arquitectura:** Clean Architecture con separación de capas (`core`, `data`, `features`).
- **Base de Datos:** SQLite local mediante `sqflite` / `database_helper.dart` con soporte de persistencia 100% offline.
- **Modelos de Datos:** `ActivityModel`, `ActivityInstance`, `AuditLogModel`, `ExcelScheduleModels`.
- **Reglas de Negocio Verificadas en Tests Unitarios:**
  - Cálculo de semana ISO (`weekKey` ej. `2026-W44`).
  - Restricción estricta de días laborales (Lunes a Viernes, 1 a 5).
  - Preservación de inmutabilidad con `copyWith`, registro de `observaciones` y `motivoNoRealizada`.
  - Auditoría sistemática (`AuditLogModel`) para cada cambio, reprogramación o marcación de estado.
  - Prevención de división por cero en fórmulas de porcentaje de cumplimiento e indicadores.

### 5.2 Simulador Web Móvil Interactivo (`prueba.html` / `Mira.html`)
- Prototipo web de alta fidelidad montado sobre un chasis de smartphone corporativo.
- Pantallas funcionales:
  - `scrLogin`: Ingreso con perfiles de supervisores.
  - `scrDashboard`: Tacómetro circular de avance (Gauge), porcentaje diario y semanal, lista de tarjetas con tags de colores, check interactivo y botón de reprogramación.
  - `scrExcelWeeks`: Matriz de 4 semanas sincronizada con la estructura Excel original.
  - `scrCalendar`: Agenda con filtro diario de lunes a viernes.
  - `scrIndicators`: Gráficos de barras y distribución de tiempo real vs planificado por las 7 categorías.
  - `scrHistory`: Bitácora cronológica de actividades ejecutadas y auditoría.

### 5.3 Portal Web Corporativo de Distribución (`index.html`)
- Landing page oficial desarrollada con estética Glassmorphism corporativa de Darnel Group.
- Información sobre la versión 2.0.0, requisitos técnicos (Android 8.0+, 50 MB, 100% offline), enlaces de descarga directa de la APK y acceso al prototipo web interactivo.

---

## 6. CLASIFICACIÓN ESTRICTA DE FUNCIONALIDADES

| Funcionalidad | Estado de Implementación | Evidencia en Código / Archivos |
|---|---|---|
| Autenticación de Supervisor y Roles | **Implementada** | `login_screen.dart`, `scrLogin` en `prueba.html` |
| Dashboard Operativo con % de Cumplimiento | **Implementada** | `dashboard_screen.dart`, SVG Gauge en `prueba.html` |
| Rutina Diaria (Lunes a Viernes, franjas horarias) | **Implementada** | `date_utils_helper.dart`, matriz en `weekly_review_parsed.txt` |
| Marcado de Actividad Completada con Observaciones | **Implementada** | `activity_detail_modal.dart`, modal interactivo en `prueba.html` |
| Reprogramación Justificada con Motivo Trazable | **Implementada** | `move_activity_sheet.dart`, `AuditLogModel` |
| Matriz de 4 Semanas (S1, S2, S3, S4) | **Implementada** | `four_weeks_planning_screen.dart`, `scrExcelWeeks` |
| Indicadores de Distribución de Tiempo (7 Categorías) | **Implementada** | `indicators_screen.dart`, barras visuales en `scrIndicators` |
| Historial y Trazabilidad Operativa | **Implementada** | `history_screen.dart`, lista de logs en `scrHistory` |
| Persistencia Local SQLite 100% Offline | **Implementada** | `database_helper.dart` |
| Portal Web y Descarga de APK | **Implementada** | `index.html`, `styles.css`, `main.js` |
| Sincronización Automática con Servidor Central / Cloud | **Parcial / Arquitectura Lista** | El modelo offline almacena cambios localmente; la sincronización API remota está desacoplada para operar sin cobertura en planta. |
| Integración Telemétrica con Sensores de Planta (IoT OEE) | **Futura / Conceptual** | Aparece como necesidad en la hoja de "Gobernanza actividades" pero no está programada en la APK actual. |

---

## 7. SISTEMA DE DISEÑO E IDENTIDAD VISUAL

- **Tipografía:** `Plus Jakarta Sans`, moderna, geométrica y con alta legibilidad en pantallas industriales.
- **Paleta de Color Primaria:**
  - Azul Institucional Darnel: `#002F6C` (profundidad, confianza, liderazgo)
  - Azul Vibrante / Secundario: `#006DB2` (acciones, botones primarios)
  - Cyan Tecnológico: `#0095D9` (acentos, bordes activos)
  - Fondo de Superficie: `#F3F5FA` / `#0F172A`
  - Estados: Verde Cumplimiento (`#16A34A`), Rojo Alerta/JSA (`#DC2626`), Naranja Liderazgo (`#F97316`), Púrpura Calidad/RMNC (`#7C3AED`).
- **Lenguaje Visual:** Minimalismo sofisticado (Apple / Linear / Stripe), bordes redondeados (`12px` - `24px`), tarjetas elevadas con sombras suaves (`rgba(15, 23, 42, 0.08)`), microanimaciones de progreso y mockups de dispositivos limpios.

---

## 8. ESTRUCTURA NARRATIVA PROPUESTA PARA EL VIDEO CORPORATIVO

El video ejecutivo se desarrollará en 7 escenas cinematográficas fluidas:

1. **ESCENA 1: APERTURA CINEMATOGRÁFICA (00:00 - 00:18)**
   - Logo oficial de Darnel Group y título "Standard Work".
   - Tipografía cinética: *"De la hoja de cálculo a la disciplina operativa en planta"*.
   - Presentación de la versión móvil 2.0.0.

2. **ESCENA 2: EL DESAFÍO OPERATIVO (00:18 - 00:40)**
   - La realidad de las plantas de producción: supervisión exigente, múltiples frentes (OEE, Calidad, Seguridad, 1:1s).
   - El cuello de botella de los archivos Excel dispersos y la necesidad de que el dato operativo llegue listo para decidir.

3. **ESCENA 3: LA SOLUCIÓN TECNOLÓGICA (00:40 - 01:05)**
   - Presentación de la aplicación en un mockup de smartphone premium.
   - Respaldo 100% offline-first con SQLite: diseñada para el piso de planta sin depender de cobertura WiFi.

4. **ESCENA 4: EL FLUJO EN PISO DE PLANTA (01:05 - 01:35)**
   - Demostración de navegación: Dashboard diario con tacómetro de avance.
   - Marcación de actividades con un toque, registro de notas de inspección y reprogramación justificada con motivo auditable.

5. **ESCENA 5: ARQUITECTURA DE MÓDULOS (01:35 - 02:05)**
   - Recorrido por los módulos clave: Planificación 4 Semanas, Calendario Dinámico, Módulo de Calidad & RMNC, y Tablero de Indicadores por las 7 categorías estratégicas.

6. **ESCENA 6: VALOR ESTRATÉGICO ORGANIZACIONAL (02:05 - 02:30)**
   - Beneficios comprobados: visibilidad en tiempo real, reducción de errores de reporte, estandarización de turnos y fortalecimiento del liderazgo visible (Gemba & 1:1s).

7. **ESCENA 7: CIERRE INSTITUCIONAL (02:30 - 02:45)**
   - Recapitulación ejecutiva, portal de descarga oficial y cierre corporativo con el sello Darnel Group.

---

Este diagnóstico constituye la base técnica y narrativa para la elaboración del guion, storyboard, capturas reales y producción en Remotion.

