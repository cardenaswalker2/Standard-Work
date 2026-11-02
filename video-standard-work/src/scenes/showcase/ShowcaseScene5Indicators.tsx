import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
} from 'remotion';
import { PhoneMockup } from '../../components/PhoneMockup';
import { theme } from '../../styles/theme';

export const ShowcaseScene5Indicators: React.FC = () => {
  const frame = useCurrentFrame();

  // Scroll down in indicators from frame 90, switch to history audit at frame 190
  const isHistory = frame >= 190;
  const isScrolled = frame >= 90 && frame < 190;

  const currentImage = isHistory
    ? 'showcase/13_history.png'
    : isScrolled
    ? 'showcase/12_indicators_scroll.png'
    : 'showcase/11_indicators.png';

  const cameraScale = interpolate(frame, [0, 45, 120, 190, 270], [1.02, 1.25, 1.3, 1.15, 1.05], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cameraY = interpolate(frame, [0, 50, 110, 190, 270], [0, 70, -80, -20, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 65% 50%, #00224D 0%, #060B17 65%, #020408 100%)`,
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
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#F97316', boxShadow: '0 0 10px #F97316' }} />
        <span style={{ fontSize: 13, fontWeight: 800, color: '#FFFFFF', letterSpacing: '0.08em' }}>
          INDICADORES & BITÁCORA
        </span>
        <span style={{ width: 1, height: 12, background: 'rgba(255, 255, 255, 0.2)' }} />
        <span style={{ fontSize: 12, fontWeight: 700, color: '#38BDF8' }}>
          MÉTRICAS POR CATEGORÍA
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
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: '#F97316', letterSpacing: '0.1em', marginBottom: 4 }}>
            7 CATEGORÍAS ESTRATÉGICAS
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Distribución Real vs Meta
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Barras visuales para Operación (28%), Productividad (18%), Liderazgo (15%) y Calidad/RMNC.
          </div>
        </div>

        <div
          style={{
            padding: '18px 22px',
            borderRadius: 18,
            background: isHistory ? 'rgba(0, 149, 217, 0.2)' : 'rgba(15, 23, 42, 0.7)',
            border: `1px solid ${isHistory ? '#0095D9' : 'rgba(255, 255, 255, 0.1)'}`,
            backdropFilter: 'blur(14px)',
            transition: 'all 0.3s ease',
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: isHistory ? '#38BDF8' : '#CBD5E1', letterSpacing: '0.1em', marginBottom: 4 }}>
            {isHistory ? '✓ TRAZABILIDAD AUDITABLE' : 'HISTORIAL OPERATIVO'}
          </div>
          <div style={{ fontSize: 20, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Registro Cronológico
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Bitácora inmutable de turnos anteriores con marcas de tiempo y usuario en base de datos local.
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
      </div>
    </AbsoluteFill>
  );
};

