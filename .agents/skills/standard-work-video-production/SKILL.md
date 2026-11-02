---
name: standard-work-video-production
description: Directrices especializadas para la producción audiovisual y cinematográfica del proyecto corporativo Standard Work (Darnel Group) mediante Remotion, Playwright y React.
version: 1.0.0
---

# Standard Work Video Production Skill

Esta Skill guía la producción de presentaciones ejecutivas y videos corporativos de alta fidelidad para el ecosistema **Standard Work** de Darnel Group.

## 1. Análisis de Aplicaciones Empresariales
- Inspeccionar exhaustivamente la arquitectura existente (código Flutter/Dart, bases de datos SQLite, esquemas de datos, hojas de cálculo operativas y prototipos web).
- Distinguir estrictamente entre funcionalidades implementadas, parcialmente implementadas y propuestas conceptuales.
- Identificar procesos de negocio reales: Trabajo Estándar de Supervisores en plantas de producción (extrusión, termoformado, calidad, logística), ciclos de 4 semanas, distribución porcentual del tiempo y matrices maestras de actividades.
- Comprender la relación de términos clave como **RMNC** (*Reporte/Revisión de Material No Conforme y Concesiones* dentro del módulo de Calidad e Inocuidad).

## 2. Creación de Guiones Ejecutivos
- Redactar en español neutro / latinoamericano con tono corporativo de alto nivel, claro, seguro y persuasivo.
- Evitar jerga técnica innecesaria; enfocarse en el valor aportado a la organización: disciplina operativa, visibilidad, centralización de datos y reducción de errores en piso.
- Estructurar en 7 escenas cinematográficas con progresión narrativa:
  1. Apertura Cinematográfica (Identidad y Propósito).
  2. Contexto Operativo y Necesidad Empresarial.
  3. Solución Tecnológica (Ecosistema Standard Work).
  4. Flujo de Trabajo y Navegación en Piso.
  5. Módulos y Funcionalidades Reales.
  6. Impacto y Valor Organizacional.
  7. Cierre Institucional.

## 3. Dirección de Arte e Identidad Visual
- **Paleta Oficial Darnel Group**:
  - Darnel Deep Blue: `#002F6C`
  - Darnel Vibrant Blue: `#006DB2`
  - Darnel Cyan Accent: `#0095D9`
  - Success Green: `#16A34A` / `#4ADE80`
  - Alert Red: `#DC2626`
  - Slate Background: `#F3F5FA` / `#0F172A`
  - Card & Surfaces: Glassmorphism refinado, sombras suaves y bordes limpios.
- **Tipografía**: Plus Jakarta Sans / Inter.
- **Estética**: Minimalismo sofisticado tipo Apple / Linear / Stripe, movimiento de cámara simulado, tarjetas con profundidad y jerarquía clara.

## 4. Captura y Demostración Real
- Utilizar Playwright y automatización de navegador para registrar pantallas del simulador interactivo oficial (`prueba.html`) y portal (`index.html`).
- Mostrar estados reales: Login, Dashboard con avance circular, Planificación de 4 Semanas, Modal de Actividad, Reprogramación justificada, Calendario e Indicadores.
- Anonimizar cualquier dato confidencial sensible y utilizar datos operacionales autorizados.

## 5. Animación y Composición en Remotion
- Usar `interpolate`, `spring` y composición modular por escenas en Remotion.
- Envolver capturas en mockups elegantes de smartphones (iPhone/Android frame) y estaciones de trabajo.
- Aplicar paneos y zooms dinámicos sobre botones, tarjetas y selectores de semana.
- Incorporar subtítulos cinéticos sincronizados con la narración.

## 6. Locución y Audio
- Emplear voces neuronales de alta fidelidad en español latinoamericano (`edge-tts` con voz corporativa como `es-CO-GonzaloNeural` o `es-MX-JorgeNeural`).
- Integrar música de fondo ambiental corporativa libre de regalías, mezclada a -18dB bajo la locución.

## 7. Renderizado y Verificación de Calidad
- Exportar en dos resoluciones independientes:
  - **Horizontal 16:9** (1920×1080 @ 30fps) -> `STANDARD_WORK_PRESENTACION_EJECUTIVA.mp4`
  - **Vertical 9:16** (1080×1920 @ 30fps) -> `STANDARD_WORK_PRESENTACION_VERTICAL.mp4`
- Validar sincronía de audio, renderizado sin frames negros ni solapamientos tipográficos, y verificar la reproducción con FFprobe/FFmpeg.

