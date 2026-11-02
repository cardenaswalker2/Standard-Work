import React from 'react';
import {
  AbsoluteFill,
  Audio,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { HeaderBadge } from '../components/HeaderBadge';
import { Subtitles } from '../components/Subtitles';
import { theme } from '../styles/theme';

interface SceneProps {
  vertical?: boolean;
}

export const Scene6Value: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleSpring = spring({
    frame,
    fps,
    config: { damping: 15, stiffness: 95 },
  });

  const pillars = [
    {
      pct: '28%',
      title: 'Operación & Gemba',
      detail: 'Tiempo directo en piso de planta, recorridos operativos y adherencia estricta al plan.',
      color: '#0095D9',
      delay: 15,
    },
    {
      pct: '18%',
      title: 'Productividad & KPIs',
      detail: 'Monitoreo de OEE, capacidad de máquinas, confiabilidad de equipos y utilidades.',
      color: '#16A34A',
      delay: 35,
    },
    {
      pct: '15%',
      title: 'Liderazgo & Personas',
      detail: 'Cumplimiento de reuniones 1:1, retroalimentación y desarrollo de competencias del equipo.',
      color: '#F97316',
      delay: 55,
    },
    {
      pct: '14%',
      title: 'Calidad, RMNC & SST',
      detail: 'Control riguroso de producto no conforme, concesiones, JSAs y seguridad en extrusión.',
      color: '#7C3AED',
      delay: 75,
    },
  ];

  const cues = [
    {
      startFrame: 0,
      endFrame: 160,
      text: 'El impacto en nuestra organización es directo: estandarizamos la gestión en todos los turnos y eliminamos la pérdida de información.',
    },
    {
      startFrame: 160,
      endFrame: 340,
      text: 'Garantizamos que el tiempo de los líderes se concentre en lo que genera verdadero valor en piso.',
    },
    {
      startFrame: 340,
      endFrame: 555,
      text: 'La seguridad de los colaboradores, la calidad del producto y la mejora continua de nuestras líneas.',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 50%, #00224D 0%, #070E1A 65%, #03050A 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      <Audio src={staticFile('audio/scene6.mp3')} volume={1} />

      {/* Top Header */}
      <div
        style={{
          position: 'absolute',
          top: vertical ? 60 : 70,
          left: 0,
          right: 0,
          textAlign: 'center',
          zIndex: 10,
        }}
      >
        <HeaderBadge category="VALOR ORGANIZACIONAL" version="DISTRIBUCIÓN DEL TIEMPO" />
        <h2
          style={{
            fontSize: vertical ? 40 : 54,
            fontWeight: 800,
            color: '#FFFFFF',
            margin: '20px 0 8px 0',
            letterSpacing: '-0.02em',
            transform: `scale(${titleSpring})`,
          }}
        >
          Impacto Real en la <span style={{ color: '#0095D9' }}>Operación</span>
        </h2>
        <p
          style={{
            fontSize: vertical ? 18 : 22,
            color: '#94A3B8',
            margin: 0,
            fontWeight: 500,
          }}
        >
          Alineación estratégica entre el Trabajo Estándar y los objetivos de Darnel Group.
        </p>
      </div>

      {/* 4 Pillars Grid Container */}
      <div
        style={{
          position: 'absolute',
          top: vertical ? '48%' : '53%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: vertical ? '88%' : '86%',
          display: 'grid',
          gridTemplateColumns: vertical ? '1fr' : 'repeat(4, 1fr)',
          gap: vertical ? 16 : 24,
        }}
      >
        {pillars.map((item, idx) => {
          const itemSpring = spring({
            frame: frame - item.delay,
            fps,
            config: { damping: 14, stiffness: 85 },
          });

          const opacity = interpolate(frame, [item.delay, item.delay + 15], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          });

          return (
            <div
              key={idx}
              style={{
                padding: vertical ? '18px 22px' : '32px 24px',
                borderRadius: 22,
                background: 'rgba(15, 23, 42, 0.72)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                backdropFilter: 'blur(16px)',
                boxShadow: '0 16px 36px rgba(0, 0, 0, 0.4)',
                opacity,
                transform: `scale(${itemSpring}) translateY(${(1 - itemSpring) * 30}px)`,
                display: 'flex',
                flexDirection: 'column',
              }}
            >
              <div
                style={{
                  fontSize: vertical ? 34 : 46,
                  fontWeight: 900,
                  color: item.color,
                  marginBottom: 8,
                  lineHeight: 1,
                  fontFamily: theme.fonts.main,
                }}
              >
                {item.pct}
              </div>

              <div
                style={{
                  fontSize: 12,
                  fontWeight: 700,
                  color: '#94A3B8',
                  letterSpacing: '0.08em',
                  textTransform: 'uppercase',
                  marginBottom: 8,
                }}
              >
                TIEMPO META
              </div>

              <h3
                style={{
                  fontSize: vertical ? 20 : 22,
                  fontWeight: 700,
                  color: '#FFFFFF',
                  margin: '0 0 10px 0',
                }}
              >
                {item.title}
              </h3>

              <p
                style={{
                  fontSize: vertical ? 14 : 15,
                  color: '#CBD5E1',
                  margin: 0,
                  lineHeight: 1.45,
                  fontWeight: 400,
                }}
              >
                {item.detail}
              </p>
            </div>
          );
        })}
      </div>

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

