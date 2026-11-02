import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { PhoneMockup } from '../../components/PhoneMockup';
import { TouchPointer } from './TouchPointer';
import { theme } from '../../styles/theme';

export const ShowcaseScene2Dashboard: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Camera choreography: starts at overview, zooms into gauge, then pans down to the activity card
  const cameraScale = interpolate(frame, [0, 40, 90, 180], [1.02, 1.28, 1.35, 1.15], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cameraY = interpolate(frame, [0, 40, 80, 180], [0, 120, -140, -40], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Checkbox tap happens at frame 80
  const isChecked = frame >= 85;

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 60% 45%, #002B5E 0%, #080F1E 65%, #03050A 100%)`,
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
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#4ADE80', boxShadow: '0 0 10px #4ADE80' }} />
        <span style={{ fontSize: 13, fontWeight: 800, color: '#FFFFFF', letterSpacing: '0.08em' }}>
          DASHBOARD OPERATIVO
        </span>
        <span style={{ width: 1, height: 12, background: 'rgba(255, 255, 255, 0.2)' }} />
        <span style={{ fontSize: 12, fontWeight: 700, color: '#38BDF8' }}>
          PROGRESO DIARIO & TARJETAS MATERIAL
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
            background: 'rgba(15, 23, 42, 0.7)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(14px)',
            boxShadow: '0 10px 25px rgba(0, 0, 0, 0.3)',
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: '#00D2FF', letterSpacing: '0.1em', marginBottom: 4 }}>
            SEGUIMIENTO EN VIVO
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Barra de Progreso Operativo
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Control inmediato de actividades completadas por turno, selector de días L-V y métricas de mes y año.
          </div>
        </div>

        <div
          style={{
            padding: '18px 22px',
            borderRadius: 18,
            background: isChecked ? 'rgba(22, 163, 74, 0.2)' : 'rgba(15, 23, 42, 0.7)',
            border: `1px solid ${isChecked ? '#16A34A' : 'rgba(255, 255, 255, 0.1)'}`,
            backdropFilter: 'blur(14px)',
            transition: 'all 0.3s ease',
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: isChecked ? '#4ADE80' : '#CBD5E1', letterSpacing: '0.1em', marginBottom: 4 }}>
            {isChecked ? '✓ ACTIVIDAD COMPLETADA' : 'INTERACCIÓN DIRECTA'}
          </div>
          <div style={{ fontSize: 20, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Confirmación con Un Toque
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Cambio dinámico entre Pendiente y Realizada con registro automático y actualización instantánea.
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
        <PhoneMockup
          imageSrc={isChecked ? 'showcase/05_dashboard_checked.png' : 'showcase/03_dashboard.png'}
          width={390}
          height={780}
          glow
        />

        {/* Touch Ripple on the State Badge (x: 320, y: 440) */}
        <TouchPointer x={320} y={440} startFrame={80} duration={24} />
      </div>
    </AbsoluteFill>
  );
};

