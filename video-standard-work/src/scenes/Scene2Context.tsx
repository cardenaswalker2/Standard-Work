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

export const Scene2Context: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 15, stiffness: 100 },
  });

  const cards = [
    {
      icon: '📊',
      tag: 'GESTIÓN ANTERIOR',
      title: 'Hojas de Cálculo Dispersas',
      desc: 'Rutinas complejas administradas en archivos Excel binarios (.xlsb), poco accesibles y rígidos en planta.',
      delay: 20,
    },
    {
      icon: '⚠️',
      tag: 'GOBERNANZA OPERATIVA',
      title: 'El Error Cargado hacia Arriba',
      desc: 'Datos corregidos tarde en oficina por ingenieros, restando tiempo de liderazgo presencial en el Gemba.',
      delay: 45,
    },
    {
      icon: '🔄',
      tag: 'DISCIPLINA & AUDITORÍA',
      title: 'Falta de Justificación Trazable',
      desc: 'Tareas reprogramadas sin registrar el motivo formal ni la bitácora histórica de contingencias de turno.',
      delay: 70,
    },
  ];

  const cues = [
    {
      startFrame: 0,
      endFrame: 180,
      text: 'Tradicionalmente, coordinar las rutinas en extrusión, termoformado y calidad implicaba hojas de cálculo y registros en papel.',
    },
    {
      startFrame: 180,
      endFrame: 410,
      text: 'Los líderes dedicaban tiempo valioso a conciliar datos en oficina, en lugar de acompañar los procesos en el Gemba.',
    },
    {
      startFrame: 410,
      endFrame: 735,
      text: 'Hacía falta una herramienta ágil, confiable y con movilidad total para decidir con datos verificados en tiempo real.',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 30%, #00224D 0%, #080E1A 75%, #050811 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      <Audio src={staticFile('audio/scene2.mp3')} volume={1} />

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
        <HeaderBadge category="EL DESAFÍO EN PLANTA" version="DIAGNÓSTICO OPERATIVO" />
        <h2
          style={{
            fontSize: vertical ? 40 : 52,
            fontWeight: 800,
            color: '#FFFFFF',
            margin: '20px 0 8px 0',
            letterSpacing: '-0.02em',
            transform: `scale(${titleProgress})`,
          }}
        >
          ¿Por qué nació <span style={{ color: '#0095D9' }}>Standard Work</span>?
        </h2>
        <p
          style={{
            fontSize: vertical ? 18 : 22,
            color: '#94A3B8',
            margin: 0,
            fontWeight: 500,
          }}
        >
          El dato debe llegar listo para decidir en planta, no para corregir en oficina.
        </p>
      </div>

      {/* Cards Container */}
      <div
        style={{
          position: 'absolute',
          top: vertical ? '48%' : '52%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: vertical ? '88%' : '86%',
          display: 'flex',
          flexDirection: vertical ? 'column' : 'row',
          gap: vertical ? 20 : 28,
          justifyContent: 'center',
          alignItems: 'stretch',
        }}
      >
        {cards.map((card, idx) => {
          const cardSpring = spring({
            frame: frame - card.delay,
            fps,
            config: { damping: 14, stiffness: 80 },
          });

          const opacity = interpolate(frame, [card.delay, card.delay + 15], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          });

          return (
            <div
              key={idx}
              style={{
                flex: 1,
                padding: vertical ? '22px 24px' : '36px 30px',
                borderRadius: 24,
                background: 'rgba(15, 23, 42, 0.72)',
                border: '1px solid rgba(255, 255, 255, 0.12)',
                boxShadow: '0 20px 40px rgba(0, 0, 0, 0.45)',
                backdropFilter: 'blur(16px)',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'flex-start',
                opacity,
                transform: `scale(${cardSpring}) translateY(${(1 - cardSpring) * 30}px)`,
                boxSizing: 'border-box',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  marginBottom: 16,
                }}
              >
                <div
                  style={{
                    fontSize: vertical ? 32 : 40,
                    width: vertical ? 54 : 64,
                    height: vertical ? 54 : 64,
                    borderRadius: 16,
                    background: 'rgba(0, 47, 108, 0.6)',
                    border: '1px solid rgba(0, 149, 217, 0.3)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  {card.icon}
                </div>
                <span
                  style={{
                    fontSize: 11,
                    fontWeight: 700,
                    color: '#38BDF8',
                    letterSpacing: '0.08em',
                    padding: '4px 10px',
                    borderRadius: 999,
                    background: 'rgba(0, 149, 217, 0.15)',
                    border: '1px solid rgba(0, 149, 217, 0.25)',
                  }}
                >
                  {card.tag}
                </span>
              </div>

              <h3
                style={{
                  fontSize: vertical ? 22 : 24,
                  fontWeight: 700,
                  color: '#FFFFFF',
                  margin: '0 0 12px 0',
                  lineHeight: 1.25,
                }}
              >
                {card.title}
              </h3>

              <p
                style={{
                  fontSize: vertical ? 15 : 16,
                  color: '#CBD5E1',
                  margin: 0,
                  lineHeight: 1.5,
                  fontWeight: 400,
                }}
              >
                {card.desc}
              </p>
            </div>
          );
        })}
      </div>

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

