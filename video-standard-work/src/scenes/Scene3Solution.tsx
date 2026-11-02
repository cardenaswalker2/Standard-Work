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

export const Scene3Solution: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance phone spring
  const phoneSpring = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 85 },
  });

  const contentOpacity = interpolate(frame, [15, 35], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cues = [
    {
      startFrame: 0,
      endFrame: 160,
      text: 'Para responder a esta necesidad nace Standard Work, una aplicación móvil con arquitectura offline first.',
    },
    {
      startFrame: 160,
      endFrame: 380,
      text: 'Funciona de manera ininterrumpida en cualquier punto de la planta, incluso sin cobertura de red.',
    },
    {
      startFrame: 380,
      endFrame: 645,
      text: 'Con una interfaz limpia y moderna, cada supervisor inicia su turno con claridad absoluta de sus prioridades.',
    },
  ];

  const features = [
    {
      title: 'Arquitectura Offline-First',
      detail: 'Persistencia SQLite local ultra veloz: cero dependencia de WiFi o datos móviles en planta.',
      icon: '⚡',
    },
    {
      title: 'Desarrollada en Flutter Nativo',
      detail: 'Rendimiento fluido a 60 FPS, diseño ergonómico y compatibilidad total con dispositivos Android.',
      icon: '📱',
    },
    {
      title: 'Ingreso Rápido por Perfil',
      detail: 'Autenticación instantánea por supervisor con asignación de turnos y áreas especializadas.',
      icon: '👤',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 65% 50%, #002F6C 0%, #07101E 60%, #03060C 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      <Audio src={staticFile('audio/scene3.mp3')} volume={1} />

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
        <HeaderBadge category="LA SOLUCIÓN TECNOLÓGICA" version="FLUTTER & SQLITE" />
      </div>

      {vertical ? (
        // VERTICAL LAYOUT (Phone centered, feature pills bottom)
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
          <div style={{ textAlign: 'center', marginBottom: 20, opacity: contentOpacity }}>
            <h2
              style={{
                fontSize: 38,
                fontWeight: 800,
                color: '#FFFFFF',
                margin: '0 0 8px 0',
                letterSpacing: '-0.02em',
              }}
            >
              Movilidad y <span style={{ color: '#0095D9' }}>Control Total</span>
            </h2>
            <p style={{ fontSize: 18, color: '#94A3B8', margin: 0 }}>
              Diseñada específicamente para las rutinas del piso industrial.
            </p>
          </div>

          <div
            style={{
              transform: `scale(${phoneSpring * 0.95})`,
              transition: 'transform 0.1s ease',
            }}
          >
            <PhoneMockup imageSrc="screenshots/screen_login.png" width={380} height={760} />
          </div>
        </div>
      ) : (
        // HORIZONTAL LAYOUT (Split View: Left Text & Pillars, Right Phone Mockup)
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
          {/* Left Text & Features */}
          <div style={{ width: '52%', opacity: contentOpacity }}>
            <h2
              style={{
                fontSize: 56,
                fontWeight: 800,
                color: '#FFFFFF',
                margin: '0 0 16px 0',
                lineHeight: 1.1,
                letterSpacing: '-0.03em',
              }}
            >
              Movilidad real y <br />
              <span style={{ color: '#0095D9' }}>Persistencia 100% Offline</span>
            </h2>

            <p
              style={{
                fontSize: 22,
                color: '#CBD5E1',
                lineHeight: 1.5,
                margin: '0 0 32px 0',
                maxWidth: 620,
              }}
            >
              Los supervisores recorren extrusión, termoformado y bodegas con acceso inmediato a sus
              rutinas, sin depender de la señal WiFi de planta.
            </p>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
              {features.map((item, idx) => (
                <div
                  key={idx}
                  style={{
                    display: 'flex',
                    alignItems: 'flex-start',
                    gap: 16,
                    padding: '16px 20px',
                    borderRadius: 18,
                    background: 'rgba(15, 23, 42, 0.65)',
                    border: '1px solid rgba(255, 255, 255, 0.08)',
                    backdropFilter: 'blur(10px)',
                  }}
                >
                  <div
                    style={{
                      fontSize: 24,
                      width: 44,
                      height: 44,
                      borderRadius: 12,
                      background: 'rgba(0, 47, 108, 0.5)',
                      border: '1px solid rgba(0, 149, 217, 0.3)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    {item.icon}
                  </div>
                  <div>
                    <div style={{ fontSize: 18, fontWeight: 700, color: '#FFFFFF', marginBottom: 4 }}>
                      {item.title}
                    </div>
                    <div style={{ fontSize: 14, color: '#94A3B8', lineHeight: 1.4 }}>
                      {item.detail}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right Phone Mockup */}
          <div
            style={{
              width: '42%',
              display: 'flex',
              justifyContent: 'center',
              transform: `scale(${phoneSpring}) translateY(${(1 - phoneSpring) * 50}px)`,
            }}
          >
            <PhoneMockup imageSrc="screenshots/screen_login.png" width={390} height={780} glow />
          </div>
        </div>
      )}

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

