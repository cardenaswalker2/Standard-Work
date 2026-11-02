import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
} from 'remotion';
import { PhoneMockup } from '../../components/PhoneMockup';
import { TouchPointer } from './TouchPointer';
import { theme } from '../../styles/theme';

export const ShowcaseScene3Planning: React.FC = () => {
  const frame = useCurrentFrame();

  // Scroll simulation from 07_four_weeks to 08_four_weeks_scroll
  const isScrolled = frame >= 65 && frame < 140;
  // Modal opens at frame 140
  const isModalOpen = frame >= 140;

  const currentImage = isModalOpen
    ? 'showcase/06_activity_modal.png'
    : isScrolled
    ? 'showcase/08_four_weeks_scroll.png'
    : 'showcase/07_four_weeks.png';

  const cameraScale = interpolate(frame, [0, 40, 130, 180, 240], [1.02, 1.15, 1.15, 1.28, 1.2], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cameraY = interpolate(frame, [0, 60, 130, 170, 240], [0, -60, -60, -20, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 65% 50%, #002554 0%, #070D1A 65%, #030408 100%)`,
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
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#00D2FF', boxShadow: '0 0 10px #00D2FF' }} />
        <span style={{ fontSize: 13, fontWeight: 800, color: '#FFFFFF', letterSpacing: '0.08em' }}>
          PLANIFICACIÓN DE 4 SEMANAS
        </span>
        <span style={{ width: 1, height: 12, background: 'rgba(255, 255, 255, 0.2)' }} />
        <span style={{ fontSize: 12, fontWeight: 700, color: '#38BDF8' }}>
          MATRIZ DIGITALIZADA (S1 A S4)
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
          <div style={{ fontSize: 12, fontWeight: 800, color: '#38BDF8', letterSpacing: '0.1em', marginBottom: 4 }}>
            CICLO MENSUAL COMPLETO
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            4 Semanas Estructuradas
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Distribución de lunes a viernes con códigos de color para Operación, Calidad y Mantenimiento.
          </div>
        </div>

        <div
          style={{
            padding: '18px 22px',
            borderRadius: 18,
            background: isModalOpen ? 'rgba(0, 149, 217, 0.2)' : 'rgba(15, 23, 42, 0.7)',
            border: `1px solid ${isModalOpen ? '#0095D9' : 'rgba(255, 255, 255, 0.1)'}`,
            backdropFilter: 'blur(14px)',
            transition: 'all 0.3s ease',
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: isModalOpen ? '#38BDF8' : '#CBD5E1', letterSpacing: '0.1em', marginBottom: 4 }}>
            {isModalOpen ? '✓ VENTANA MODAL ACTIVA' : 'CONSULTA DE DETALLE'}
          </div>
          <div style={{ fontSize: 20, fontWeight: 800, color: '#FFFFFF', marginBottom: 4 }}>
            Inspección y Observaciones
          </div>
          <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
            Apertura fluida para auditar horarios, justificar reprogramaciones y agregar notas de turno.
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

        {/* Touch Ripple selecting the activity card at frame 130 */}
        {!isModalOpen && <TouchPointer x={195} y={420} startFrame={130} duration={18} />}
      </div>
    </AbsoluteFill>
  );
};

