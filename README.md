# Standard Work · Darnel Group (Ecosistema Integral de Gestión de Trabajo Estándar)

Plataforma corporativa y móvil para la digitalización, estandarización y seguimiento en tiempo real de las rutinas de supervisión y liderazgo operativo en plantas industriales de **Darnel Group** (Extrusión, Termoformado, Calidad, Logística y SST).

---

## 📌 Componentes del Ecosistema

1. **Aplicación Móvil Nativa Flutter (`standard_work_app/`)**:
   - Persistencia local **SQLite 100% offline-first** (`sqflite`).
   - Gestión de turnos y actividades de lunes a viernes en bloques horarios.
   - Tacómetro visual de adherencia al plan y porcentaje de cumplimiento.
   - Registro de observaciones de inspección y hoja de reprogramación formal con motivo trazable.
   - Matriz de 4 semanas del ciclo mensual sincronizada con la estructura operativa original.
   - Control de calidad y revisión de **RMNC** (*Material No Conforme y Concesiones*).
   - Tablero de distribución de tiempo en las 7 categorías estratégicas del negocio.

2. **Simulador y Prototipo Web Interactivo (`prueba.html` / `Mira.html`)**:
   - Entorno interactivo montado sobre un chasis realista de smartphone corporativo.
   - Permite recorrer todas las pantallas del sistema: Login, Dashboard, Calendario, 4 Semanas, Calidad y Tablero de Indicadores sin necesidad de compilar la app en un emulador Android.

3. **Portal Web de Distribución y Descarga (`index.html`)**:
   - Landing page corporativa con diseño Glassmorphism basada en los colores oficiales de Darnel Group (`#002F6C`, `#006DB2`, `#0095D9`).
   - Enlace directo de descarga de la APK versión 2.0.0 alojada en Google Drive.
   - Guía paso a paso de instalación en dispositivos Android y preguntas frecuentes (FAQ).

4. **Suite de Producción Audiovisual Ejecutiva (`video-standard-work/`)**:
   - Proyecto independiente desarrollado con **Remotion**, **React**, **TypeScript**, **Playwright**, **FFmpeg** y **Edge-TTS**.
   - Composiciones de video corporativo con animación cinética, mockups 3D de smartphone, subtítulos sincronizados y locución neuronal profesional en español latinoamericano.

---

## 🎬 Videos Corporativos de Presentación

Los videos oficiales listos para presentar ante gerencia y directivos se encuentran en:

1. **`STANDARD_WORK_PRESENTACION_EJECUTIVA.mp4`**:
   - Formato: **16:9 Horizontal** (1920 × 1080 @ 30 FPS).
   - Códec: H.264 / AAC.
   - Duración: ~2 minutos y 23 segundos (143.5 s / 4,305 frames).
   - Diseñado para pantallas de juntas, conferencias y presentaciones a jefatura.

2. **`STANDARD_WORK_PRESENTACION_VERTICAL.mp4`**:
   - Formato: **9:16 Vertical** (1080 × 1920 @ 30 FPS).
   - Códec: H.264 / AAC.
   - Duración: ~2 minutos y 23 segundos.
   - Adaptación nativa con encuadre reestructurado para smartphones corporativos, estados y plataformas móviles.

---

## 📑 Documentación Técnica y Estratégica

- **`ANALISIS_STANDARD_WORK.md`**: Diagnóstico exhaustivo del proyecto, gobernanza de actividades ("el dato listo para decidir"), matriz de 7 categorías de tiempo y relación con RMNC.
- **`GUION_PRESENTACION.md`**: Guion ejecutivo completo en 7 escenas con locución en español latinoamericano y visuales sincronizados.
- **`STORYBOARD.md`**: Guía visual cuadro por cuadro, encuadres, transiciones, paleta cromática y especificaciones de animación.
- **`video-standard-work/README.md`**: Manual técnico para desarrolladores sobre cómo iniciar Remotion Studio, modificar textos, cambiar música, regenerar audios y renderizar nuevas versiones.

---

## 🛠️ Herramientas y Skills Utilizadas

- **Node.js v22.14.0 (LTS)** y **npm 10.9.2** (configurado en PATH de usuario).
- **Remotion v4.0.260**: Framework de video programático.
- **FFmpeg v8.0**: Síntesis de pistas de audio corporativas y empaquetado de video.
- **Playwright (Python 1.64.1)**: Captura automatizada de pantallas en alta resolución de la app real.
- **Edge-TTS (Python 7.3.1)**: Voz neuronal profesional (`es-CO-GonzaloNeural`).
- **Skills de Agente**:
  - `remotion-dev/skills` (`remotion-best-practices`, `remotion-render`, `remotion-studio`, etc.).
  - `standard-work-video-production` (`.agents/skills/standard-work-video-production/SKILL.md`).

---

## 🚀 Cómo Iniciar la Previsualización Interactiva (Remotion Studio)

```bash
cd video-standard-work
npm start
```
Abre automáticamente `http://localhost:3000` con la línea de tiempo interactiva.

---

## 📦 Cómo Renderizar los Videos Manualmente

```bash
cd video-standard-work

# Renderizar versión horizontal (16:9)
npm run render:horizontal

# Renderizar versión vertical (9:16)
npm run render:vertical

# Renderizar ambas versiones
npm run build
```

Los videos generados se guardan automáticamente en `video-standard-work/out/` y se copian en la raíz del proyecto para acceso inmediato.
