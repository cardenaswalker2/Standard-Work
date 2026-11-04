export const theme = {
  colors: {
    darnelNavy: '#001A3D',
    darnelBlue: '#002F6C',
    darnelVibrant: '#006DB2',
    darnelCyan: '#0095D9',
    darnelLightBg: '#F3F5FA',
    darkBg: '#080E1A',
    darkCard: 'rgba(15, 23, 42, 0.78)',
    darkCardBorder: 'rgba(255, 255, 255, 0.12)',
    accentGreen: '#16A34A',
    accentGreenBg: '#ECFDF3',
    accentRed: '#DC2626',
    accentOrange: '#F97316',
    accentPurple: '#7C3AED',
    textLight: '#F8FAFC',
    textMuted: '#94A3B8',
    textDark: '#1E293B',
  },
  shadows: {
    soft: '0 10px 25px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.3)',
    glow: '0 0 50px -10px rgba(0, 149, 217, 0.35)',
    card: '0 20px 40px -15px rgba(0, 47, 108, 0.4)',
    phone: '0 25px 60px -12px rgba(0, 0, 0, 0.6)',
  },
  fonts: {
    main: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
  },
};

export const sceneDurations = {
  scene1: 478, // 14.76s - Apertura e Identidad TRACK60
  scene2: 568, // 17.74s - El Desafío Operativo en Gemba
  scene3: 594, // 18.60s - Arquitectura y Acceso Seguro
  scene4: 735, // 23.30s - Flujo Operativo y 10 Actividades
  scene5: 503, // 15.58s - Suite Administrativa 360° y Planificación
  scene6: 419, // 12.77s - Impacto y Valor Organizacional
  scene7: 364, // 10.94s - Cierre Institucional
};

export const TOTAL_FRAMES =
  sceneDurations.scene1 +
  sceneDurations.scene2 +
  sceneDurations.scene3 +
  sceneDurations.scene4 +
  sceneDurations.scene5 +
  sceneDurations.scene6 +
  sceneDurations.scene7; // 3661 frames (~2 min 02s @ 30fps)

