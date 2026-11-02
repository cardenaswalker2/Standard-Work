import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
} from 'remotion';
import { PhoneMockup } from '../../components/PhoneMockup';
import { TouchPointer } from './TouchPointer';
import { theme } from '../../styles/theme';

export const ShowcaseScene4Calendar: React.FC = () => {
  const frame = useCurrentFrame();

  // Day selection happens at frame 70
  const isDaySelected = frame >= 75;

  const currentImage = isDaySelected
    ? 'showcase/10_calendar_day_select.png'
    : 'showcase/09_calendar.png';

  const cameraScale = interpolate(frame, [0, 60, 140, 240], [1.02, 1.22, 1.32, 1.18], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cameraY = interpolate(frame, [0, 60, 140, 240], [0, 60, -90, -30], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 60% 45%, #002D62 0%, #070E1C 65%, #030509 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      {/* Top Header Tag */}
      <div
        style={{
          position: 'absolute',
          top: 36,
          left: 80,
          display: 'flex',
          alignItems: 'center',
          gap: 12,
          padding: '8px 20px',
          borderRadius: 999,
          background: 'rgba(15, 23, 42, 0.75)',
          border: '1px solid rgba(0, 149, 217, 0.4)',
          backdropFilter: 'blur(12px)',
          zIndex: 10,
        }}
      >
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#16A34A', boxShadow: '0 0 10px #16A34A' }} />
        <span style={{ fontSize: 13, fontWeight: 800, color: '#FFFFFF', letterSpacing: '0.08em' }}>
          CALENDARIO & ACTIVIDADES
        </span>
        <span style={{ width: 1, height: 12, background: 'rgba(255, 255, 255, 0.2)' }} />
        <span style={{ fontSize: 12, fontWeight: 700, color: '#38BDF8' }}>
          SELECCIÓN DIARIA Y HORARIOS
        </span>
      </div>

      {/* Side Dynamic Highlights (Left) */}
      <div
        style={{
          position: 'absolute',
          left: 80,
          top: '50%',
          transform: 'translateY(-50%)',
          width: 440,
          display: 'flex',
          flexDirection: 'column',
          gap: 16,
          zIndex: 10,
        }}
      >
        <div
          style={{
            padding: '18px 22px',
            borderRadius: 18,
            background: isDaySelected ? 'rgba(22, 163, 74, 0.18)' : 'rgba(15, 23, 42, 0.7)',
            border: `1px solid ${isDaySelected ? '#16A34A' : 'rgba(255, 255, 255, 0.1)'}`,
            backdropFilter: 'blur(14px)',
            transition: 'all 0.3s ease',
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: isDaySelected ? '#4ADE80' : '#38BDF8', letterSpacing: '0.1em', marginBottom: 4 }}>
            {isDaySelected ? '✓ DÍA SELECCIONADO (MARTES)' : 'FILTRADO INTERACTIVO'}
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Selector de Días de Turno
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Conmutación instantánea entre jornadas laborales de lunes a viernes con carga inmediata.
          </div>
        </div>

        <div
          style={{
            padding: '18px 22px',
            borderRadius: 18,
            background: 'rgba(15, 23, 42, 0.7)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(14px)',
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: '#38BDF8', letterSpacing: '0.1em', marginBottom: 4 }}>
            FRANJAS HORARIAS
          </div>
          <div style={{ fontSize: 20, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Línea de Tiempo Operacional
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Eventos programados por bloques de 15, 30 y 60 minutos con estado visual directo.
          </div>
        </div>
      </div>

      {/* Main Interactive Phone (Right Center) */}
      <div
        style={{
          position: 'absolute',
          right: 180,
          top: '50%',
          transform: `translate(0, calc(-50% + ${cameraY}px)) scale(${cameraScale})`,
          transformOrigin: 'center center',
        }}
      >
        <PhoneMockup imageSrc={currentImage} width={390} height={780} glow />

        {/* Touch Ripple on the Day Pill (x: 235, y: 138) */}
        {!isDaySelected && <TouchPointer x={235} y={138} startFrame={70} duration={20} />}

        {/* Touch Ripple on timeline activity (x: 200, y: 380) */}
        {isDaySelected && <TouchPointer x={200} y={380} startFrame={150} duration={22} />}
      </div>
    </AbsoluteFill>
  );
};

