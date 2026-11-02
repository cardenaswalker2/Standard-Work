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
import { PhoneMockup } from '../components/PhoneMockup';
import { Subtitles } from '../components/Subtitles';
import { theme } from '../styles/theme';

interface SceneProps {
  vertical?: boolean;
}

export const Scene5Modules: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // 4 Modules cycled over 660 frames (~165 frames each)
  const modules = [
    {
      id: 'excel_weeks',
      tag: 'MÓDULO 1',
      title: 'Planificador de 4 Semanas',
      desc: 'Digitaliza la matriz mensual de Excel. Visualiza y audita las Semanas 1 a 4 de lunes a viernes.',
      image: 'screenshots/screen_excel_weeks.png',
      color: '#0095D9',
    },
    {
      id: 'calendar',
      tag: 'MÓDULO 2',
      title: 'Calendario Dinámico',
      desc: 'Navegación ágil por día y turno de trabajo con filtrado de franjas horarias y actividades programadas.',
      image: 'screenshots/screen_calendar.png',
      color: '#16A34A',
    },
    {
      id: 'rmnc_quality',
      tag: 'MÓDULO 3',
      title: 'Calidad & Control RMNC',
      desc: 'Revisión sistemática de Material No Conforme, concesiones y alertas para blindar los despachos.',
      image: 'screenshots/screen_activity_detail.png',
      color: '#7C3AED',
    },
    {
      id: 'indicators',
      tag: 'MÓDULO 4',
      title: 'Tablero de Indicadores',
      desc: 'Gráficas de distribución del tiempo real frente al planificado en las 7 categorías estratégicas.',
      image: 'screenshots/screen_indicators.png',
      color: '#F97316',
    },
  ];

  const currentModuleIndex = Math.min(Math.floor(frame / 165), 3);
  const currentMod = modules[currentModuleIndex];

  const modSpring = spring({
    frame: frame % 165,
    fps,
    config: { damping: 14, stiffness: 90 },
  });

  const cues = [
    {
      startFrame: 0,
      endFrame: 165,
      text: 'Standard Work articula todos los procesos en módulos: el Planificador de Cuatro Semanas sincroniza la matriz operativa del mes.',
    },
    {
      startFrame: 165,
      endFrame: 330,
      text: 'El Calendario Dinámico permite navegar entre turnos y días de la semana con total agilidad.',
    },
    {
      startFrame: 330,
      endFrame: 495,
      text: 'El módulo de Calidad asegura el control de alertas y la revisión oportuna de material no conforme.',
    },
    {
      startFrame: 495,
      endFrame: 660,
      text: 'Y el Tablero de Indicadores mide la distribución del tiempo en las siete categorías estratégicas del negocio.',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 40%, #001F47 0%, #080E1A 70%, #03060C 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      <Audio src={staticFile('audio/scene5.mp3')} volume={1} />

      {/* Top Header Badge */}
      <div
        style={{
          position: 'absolute',
          top: vertical ? 50 : 60,
          left: vertical ? 0 : 80,
          right: vertical ? 0 : 'auto',
          textAlign: vertical ? 'center' : 'left',
          zIndex: 10,
        }}
      >
        <HeaderBadge category="ARQUITECTURA DE MÓDULOS" version="4 COMPONENTES CLAVE" />
      </div>

      {vertical ? (
        // VERTICAL LAYOUT
        <div
          style={{
            position: 'absolute',
            top: '46%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
          }}
        >
          <div style={{ textAlign: 'center', marginBottom: 16, width: '90%' }}>
            <span
              style={{
                fontSize: 12,
                fontWeight: 700,
                color: currentMod.color,
                letterSpacing: '0.1em',
                padding: '4px 12px',
                borderRadius: 999,
                background: 'rgba(255, 255, 255, 0.08)',
                border: `1px solid ${currentMod.color}`,
              }}
            >
              {currentMod.tag}
            </span>
            <h2
              style={{
                fontSize: 34,
                fontWeight: 800,
                color: '#FFFFFF',
                margin: '10px 0 6px 0',
              }}
            >
              {currentMod.title}
            </h2>
            <p style={{ fontSize: 16, color: '#CBD5E1', margin: 0, lineHeight: 1.4 }}>
              {currentMod.desc}
            </p>
          </div>

          <div
            style={{
              transform: `scale(${modSpring * 0.95})`,
              transition: 'transform 0.1s ease',
            }}
          >
            <PhoneMockup imageSrc={currentMod.image} width={380} height={760} />
          </div>
        </div>
      ) : (
        // HORIZONTAL LAYOUT
        <div
          style={{
            position: 'absolute',
            top: '52%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '88%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          {/* Left Module Switcher Information */}
          <div style={{ width: '50%' }}>
            {/* Step Indicators */}
            <div style={{ display: 'flex', gap: 10, marginBottom: 24 }}>
              {modules.map((m, i) => (
                <div
                  key={i}
                  style={{
                    flex: 1,
                    height: 6,
                    borderRadius: 999,
                    background:
                      i === currentModuleIndex
                        ? currentMod.color
                        : i < currentModuleIndex
                        ? 'rgba(255, 255, 255, 0.4)'
                        : 'rgba(255, 255, 255, 0.1)',
                    transition: 'background 0.3s ease',
                  }}
                />
              ))}
            </div>

            <span
              style={{
                display: 'inline-block',
                fontSize: 13,
                fontWeight: 800,
                color: currentMod.color,
                letterSpacing: '0.12em',
                padding: '6px 14px',
                borderRadius: 999,
                background: 'rgba(255, 255, 255, 0.08)',
                border: `1px solid ${currentMod.color}`,
                marginBottom: 16,
              }}
            >
              {currentMod.tag}
            </span>

            <h2
              style={{
                fontSize: 54,
                fontWeight: 800,
                color: '#FFFFFF',
                margin: '0 0 16px 0',
                letterSpacing: '-0.02em',
                lineHeight: 1.15,
              }}
            >
              {currentMod.title}
            </h2>

            <p
              style={{
                fontSize: 22,
                color: '#CBD5E1',
                lineHeight: 1.55,
                margin: '0 0 32px 0',
                maxWidth: 580,
              }}
            >
              {currentMod.desc}
            </p>

            {/* Modules Quick List */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 500 }}>
              {modules.map((item, idx) => {
                const isActive = idx === currentModuleIndex;
                return (
                  <div
                    key={idx}
                    style={{
                      padding: '12px 18px',
                      borderRadius: 14,
                      background: isActive
                        ? 'rgba(255, 255, 255, 0.12)'
                        : 'rgba(255, 255, 255, 0.03)',
                      border: `1px solid ${
                        isActive ? item.color : 'rgba(255, 255, 255, 0.06)'
                      }`,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      transition: 'all 0.3s ease',
                    }}
                  >
                    <span
                      style={{
                        fontSize: 16,
                        fontWeight: isActive ? 700 : 500,
                        color: isActive ? '#FFFFFF' : '#94A3B8',
                      }}
                    >
                      {item.title}
                    </span>
                    <span
                      style={{
                        fontSize: 12,
                        fontWeight: 700,
                        color: item.color,
                      }}
                    >
                      {isActive ? 'ACTIVO' : `PASO ${idx + 1}`}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Right Phone Mockup with active module screenshot */}
          <div
            style={{
              width: '44%',
              display: 'flex',
              justifyContent: 'center',
              transform: `scale(${modSpring})`,
            }}
          >
            <PhoneMockup imageSrc={currentMod.image} width={390} height={780} glow />
          </div>
        </div>
      )}

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

