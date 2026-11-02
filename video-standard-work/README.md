# Standard Work · Producción Audiovisual Ejecutiva (Darnel Group)

Proyecto audiovisual independiente desarrollado con **Remotion**, **React**, **TypeScript**, **Playwright** y **FFmpeg**, diseñado para producir videos corporativos de alta fidelidad técnica y narrativa para el ecosistema **Standard Work** de Darnel Group.

---

## 🎬 Videos Generados y Entregables

Los videos finales renderizados se encuentran disponibles en:
- Versión Ejecutiva Principal (16:9, 1920×1080 @ 30 FPS, H.264, AAC):
  - `video-standard-work/out/STANDARD_WORK_PRESENTACION_EJECUTIVA.mp4`
  - Copia directa en raíz: `STANDARD_WORK_PRESENTACION_EJECUTIVA.mp4`
- Versión Vertical para Móviles/Pantallas (9:16, 1080×1920 @ 30 FPS, H.264, AAC):
  - `video-standard-work/out/STANDARD_WORK_PRESENTACION_VERTICAL.mp4`
  - Copia directa en raíz: `STANDARD_WORK_PRESENTACION_VERTICAL.mp4`

---

## 🛠️ Herramientas Instaladas y Entorno

1. **Node.js v22.14.0 (LTS)** y **npm 10.9.2**: Motor de ejecución para Remotion y scripts de render.
2. **Remotion v4.0.260**: Framework de video programático en React.
3. **FFmpeg v8.0**: Motor de codificación, síntesis de audio ambiental y empaquetado de video H.264.
4. **Playwright (Python 1.64.1)** con Chrome: Automatización de navegador para captura de pantallas reales de alta resolución.
5. **Edge-TTS (Python 7.3.1)**: Motor de síntesis de voz neuronal de alta fidelidad en español latinoamericano (`es-CO-GonzaloNeural`).
6. **Lucide Icons & React 18**: Iconografía y componentes UI para composiciones.

---

## 🧠 Skills Utilizadas

1. **`remotion-dev/skills`**:
   - `remotion-best-practices`: Reglas de arquitectura y rendimiento.
   - `remotion-render`: Directrices para renderizado H.264 / ProRes por CLI.
   - `remotion-studio`: Configuración y previsualización interactiva en tiempo real.
   - `remotion-captions`: Sincronización de subtítulos y textos cinéticos.
2. **`standard-work-video-production`** (`.agents/skills/standard-work-video-production/SKILL.md`):
   - Skill especializada desarrollada para este proyecto que define los estándares visuales de Darnel Group, la relación entre Standard Work y RMNC, y la estructura narrativa en 7 escenas.

---

## 💻 Cómo Iniciar Remotion Studio (Vista Previa Interactiva)

Para abrir el entorno interactivo de edición y previsualización en el navegador:

```bash
cd video-standard-work
npm start
# O directamente:
npx remotion studio
```
Remotion Studio abrirá automáticamente la interfaz web en `http://localhost:3000`, permitiendo:
- Navegar cuadro por cuadro con la barra de tiempo.
- Conmutar entre `ExecutiveComposition` (16:9) y `VerticalComposition` (9:16).
- Probar cambios en el código React en caliente (Hot Reload).

---

## 🎨 Cómo Modificar el Video

### 1. Modificar los Textos y Títulos de las Escenas
Los textos de cada escena se encuentran en componentes modulares dentro de `src/scenes/`:
- `Scene1Intro.tsx`: Título de apertura, badge de versión y subtítulo.
- `Scene2Context.tsx`: Tarjetas de diagnóstico y desafíos en planta.
- `Scene3Solution.tsx`: Pilares de arquitectura (Offline-First, Flutter, SQLite).
- `Scene4Workflow.tsx`: Tacómetro de cumplimiento diario y tarjetas horarias.
- `Scene5Modules.tsx`: Los 4 módulos clave (Planificador 4 Semanas, Calendario, RMNC y Tablero).
- `Scene6Value.tsx`: Las 4 categorías estratégicas y porcentajes meta (Operación 28%, Productividad 18%, Liderazgo 15%, Calidad/SST 14%).
- `Scene7Outro.tsx`: Mensaje de cierre institucional y llamado a la acción.

### 2. Modificar la Narración (Locución)
El guion de voz está centralizado en `scripts/generate_audio.py`. Para actualizar cualquier frase:
1. Edita el texto deseado en `SCENES_NARRATION` dentro de `scripts/generate_audio.py`.
2. Puedes cambiar la voz modificando la constante `VOICE` (por ejemplo, `es-CO-GonzaloNeural`, `es-MX-JorgeNeural` o `es-CO-SalomeNeural`).
3. Ejecuta:
   ```bash
   python scripts/generate_audio.py
   ```
4. Los archivos de audio se actualizarán automáticamente en `public/audio/scene1.mp3` hasta `scene7.mp3`.

### 3. Reemplazar las Capturas de Pantalla
Las capturas reales de la aplicación están almacenadas en `public/screenshots/`:
- `screen_login.png`: Pantalla de inicio de sesión de supervisores.
- `screen_dashboard.png`: Dashboard operativo con tacómetro y tarjetas.
- `screen_activity_detail.png`: Modal de confirmación, notas y reprogramación justificada.
- `screen_excel_weeks.png`: Matriz de 4 semanas de Excel digitalizada.
- `screen_calendar.png`: Vista diaria de calendario.
- `screen_indicators.png`: Gráficos de distribución de tiempo por categoría.
- `landing_hero.png`: Portal oficial de descarga corporativa.

Para regenerar todas las capturas automáticamente desde la aplicación real:
```bash
python scripts/capture_screens.py
```

### 4. Cambiar la Música de Fondo
La pista ambiental libre de regalías se ubica en `public/music/background_corporate.mp3`. Puedes colocar cualquier archivo `.mp3` con el mismo nombre, o regenerar la pista sintetizada ejecutando:
```bash
python scripts/generate_music.py
```

---

## 🚀 Cómo Renderizar Nuevas Versiones de los Videos

Desde la carpeta `video-standard-work`:

```bash
# Renderizar versión horizontal 16:9 (1920x1080)
npm run render:horizontal

# Renderizar versión vertical 9:16 (1080x1920)
npm run render:vertical

# Renderizar ambas versiones consecutivamente
npm run build
```

---

## 📁 Estructura del Proyecto Audiovisual

```text
video-standard-work/
├── src/
│   ├── animations/          # Helpers de interpolación y transiciones
│   ├── components/          # PhoneMockup, Subtitles, HeaderBadge
│   ├── compositions/        # ExecutiveComposition.tsx, VerticalComposition.tsx
│   ├── scenes/              # Scene1Intro a Scene7Outro
│   ├── styles/              # theme.ts (colores oficiales Darnel, duraciones, fuentes)
│   ├── Root.tsx             # Registro de composiciones Remotion
│   └── index.ts             # Entry point del bundle
├── public/
│   ├── audio/               # scene1.mp3 a scene7.mp3 (locución neuronal)
│   ├── music/               # background_corporate.mp3
│   ├── screenshots/         # Capturas en alta resolución de la app real
│   └── logos/               # app_icon.png oficial Darnel Group
├── scripts/
│   ├── capture_screens.py   # Script de Playwright para capturas
│   ├── generate_audio.py    # Generador de locución neuronal con edge-tts
│   └── generate_music.py    # Sintetizador FFmpeg de pista musical corporativa
├── out/                     # Videos MP4 exportados
├── package.json
├── tsconfig.json
└── README.md
```

