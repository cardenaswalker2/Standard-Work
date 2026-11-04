import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Img,
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

export const Scene1Intro: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Animations
  const logoScale = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 90 },
  });

  const titleOpacity = interpolate(frame, [15, 35], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const titleY = interpolate(frame, [15, 35], [30, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const subtitleOpacity = interpolate(frame, [35, 55], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const glowPulse = interpolate(Math.sin(frame * 0.05), [-1, 1], [0.3, 0.6]);

  const cues = [
    {
      startFrame: 0,
      endFrame: 140,
      text: 'En la industria moderna de empaques, la excelencia operativa se construye día a día en el piso de planta.',
    },
    {
      startFrame: 140,
      endFrame: 300,
      text: 'Bienvenidos a TRACK60, la plataforma corporativa de Darnel Group...',
    },
    {
      startFrame: 300,
      endFrame: 478,
      text: '...diseñada para estandarizar, asignar y supervisar la disciplina operativa de nuestros supervisores y líderes de producción.',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 40%, #002F6C 0%, #001738 50%, #080E1A 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      <Audio src={staticFile('audio/scene1.mp3')} volume={1} />

      {/* Ambient background glow ring */}
      <div
        style={{
          position: 'absolute',
          top: '30%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: vertical ? 500 : 800,
          height: vertical ? 500 : 800,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(0, 149, 217, 0.3) 0%, transparent 70%)',
          filter: 'blur(60px)',
          opacity: glowPulse,
          pointerEvents: 'none',
        }}
      />

      {/* Main Content Box */}
      <div
        style={{
          position: 'absolute',
          top: '46%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          textAlign: 'center',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          width: vertical ? '90%' : '80%',
        }}
      >
        <div style={{ marginBottom: 24, transform: `scale(${logoScale})` }}>
          <HeaderBadge category="TRANSFORMACIÓN DIGITAL OPERATIVA" version="OFICIAL v2.0" />
        </div>

        {/* Icon & Brand Logo */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 18,
            marginBottom: 20,
            transform: `scale(${logoScale})`,
          }}
        >
          <div
            style={{
              width: vertical ? 72 : 84,
              height: vertical ? 72 : 84,
              borderRadius: 22,
              background: 'linear-gradient(135deg, #002F6C 0%, #006DB2 100%)',
              border: '2px solid rgba(0, 149, 217, 0.5)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 12px 30px rgba(0, 47, 108, 0.5)',
              overflow: 'hidden',
            }}
          >
            <Img
              src={staticFile('logos/app_icon.png')}
              style={{ width: '85%', height: '85%', objectFit: 'contain' }}
            />
          </div>

          <div style={{ textAlign: 'left' }}>
            <div
              style={{
                fontSize: vertical ? 28 : 34,
                fontWeight: 900,
                letterSpacing: '0.12em',
                color: '#FFFFFF',
              }}
            >
              DARNEL
            </div>
            <div
              style={{
                fontSize: vertical ? 14 : 16,
                fontWeight: 700,
                letterSpacing: '0.22em',
                color: '#38BDF8',
              }}
            >
              GROUP
            </div>
          </div>
        </div>

        {/* Cinematic Main Title */}
        <h1
          style={{
            fontSize: vertical ? 62 : 84,
            fontWeight: 900,
            color: '#FFFFFF',
            letterSpacing: '-0.03em',
            margin: '0 0 16px 0',
            opacity: titleOpacity,
            transform: `translateY(${titleY}px)`,
            textShadow: '0 10px 30px rgba(0, 0, 0, 0.6)',
            lineHeight: 1.05,
          }}
        >
          TRACK<span style={{ color: '#0095D9' }}>60</span>
        </h1>

        {/* Subtitle */}
        <p
          style={{
            fontSize: vertical ? 22 : 26,
            fontWeight: 500,
            color: '#CBD5E1',
            maxWidth: vertical ? 650 : 800,
            margin: 0,
            lineHeight: 1.4,
            opacity: subtitleOpacity,
          }}
        >
          Plataforma de asignación, seguimiento y disciplina operativa para supervisores de planta.
        </p>

        {/* Feature Pills */}
        <div
          style={{
            display: 'flex',
            gap: 14,
            marginTop: 36,
            flexWrap: 'wrap',
            justifyContent: 'center',
            opacity: subtitleOpacity,
          }}
        >
          {['100% Offline (SQLite)', '10 Actividades Base', 'Notificaciones 🔔', 'Matriz 4 Semanas Real'].map((tag, i) => (
            <div
              key={i}
              style={{
                padding: '8px 18px',
                borderRadius: 12,
                background: 'rgba(255, 255, 255, 0.06)',
                border: '1px solid rgba(255, 255, 255, 0.14)',
                color: '#93C5FD',
                fontSize: vertical ? 14 : 16,
                fontWeight: 600,
              }}
            >
              ✓ {tag}
            </div>
          ))}
        </div>
      </div>

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

