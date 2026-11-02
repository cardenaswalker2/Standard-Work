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
import { PhoneMockup } from '../components/PhoneMockup';
import { Subtitles } from '../components/Subtitles';
import { theme } from '../styles/theme';

interface SceneProps {
  vertical?: boolean;
}

export const Scene7Outro: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoSpring = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 85 },
  });

  const fadeOut = interpolate(frame, [430, 465], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cues = [
    {
      startFrame: 0,
      endFrame: 230,
      text: 'Standard Work es más que una aplicación: es el estándar de excelencia operativa que impulsa el futuro de Darnel Group.',
    },
    {
      startFrame: 230,
      endFrame: 465,
      text: 'Una herramienta lista, comprobada y en marcha para llevar nuestra gestión al siguiente nivel. Muchas gracias.',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 40%, #002F6C 0%, #001738 50%, #050811 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
        opacity: fadeOut,
      }}
    >
      <Audio src={staticFile('audio/scene7.mp3')} volume={1} />

      {/* Ambient glow */}
      <div
        style={{
          position: 'absolute',
          top: '35%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: vertical ? 500 : 750,
          height: vertical ? 500 : 750,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(0, 149, 217, 0.35) 0%, transparent 70%)',
          filter: 'blur(50px)',
          pointerEvents: 'none',
        }}
      />

      {vertical ? (
        // VERTICAL OUTRO
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
            width: '90%',
          }}
        >
          <div style={{ marginBottom: 20 }}>
            <HeaderBadge category="TRANSFORMACIÓN DIGITAL" version="DARNEL GROUP" />
          </div>

          <div
            style={{
              width: 80,
              height: 80,
              borderRadius: 24,
              background: 'linear-gradient(135deg, #002F6C 0%, #006DB2 100%)',
              border: '2px solid rgba(0, 149, 217, 0.5)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 12px 30px rgba(0, 47, 108, 0.5)',
              marginBottom: 16,
              transform: `scale(${logoSpring})`,
            }}
          >
            <Img
              src={staticFile('logos/app_icon.png')}
              style={{ width: '85%', height: '85%', objectFit: 'contain' }}
            />
          </div>

          <h1
            style={{
              fontSize: 54,
              fontWeight: 900,
              color: '#FFFFFF',
              letterSpacing: '-0.02em',
              margin: '0 0 10px 0',
            }}
          >
            STANDARD <span style={{ color: '#0095D9' }}>WORK</span>
          </h1>

          <p
            style={{
              fontSize: 20,
              color: '#CBD5E1',
              maxWidth: 500,
              margin: '0 0 28px 0',
              lineHeight: 1.4,
            }}
          >
            El nuevo estándar de gestión operativa en planta.
          </p>

          <div
            style={{
              transform: `scale(${logoSpring * 0.9})`,
              transition: 'transform 0.1s ease',
            }}
          >
            <PhoneMockup imageSrc="screenshots/screen_dashboard.png" width={340} height={680} glow />
          </div>
        </div>
      ) : (
        // HORIZONTAL OUTRO
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
          {/* Left Close Information */}
          <div style={{ width: '50%' }}>
            <HeaderBadge category="TRANSFORMACIÓN DIGITAL OPERATIVA" version="DESPLIEGUE OFICIAL" />

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 18,
                marginTop: 24,
                marginBottom: 20,
              }}
            >
              <div
                style={{
                  width: 72,
                  height: 72,
                  borderRadius: 20,
                  background: 'linear-gradient(135deg, #002F6C 0%, #006DB2 100%)',
                  border: '2px solid rgba(0, 149, 217, 0.5)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: '0 10px 25px rgba(0, 47, 108, 0.5)',
                }}
              >
                <Img
                  src={staticFile('logos/app_icon.png')}
                  style={{ width: '85%', height: '85%', objectFit: 'contain' }}
                />
              </div>

              <div>
                <div style={{ fontSize: 32, fontWeight: 900, color: '#FFFFFF', letterSpacing: '0.1em' }}>
                  DARNEL
                </div>
                <div style={{ fontSize: 16, fontWeight: 700, color: '#38BDF8', letterSpacing: '0.2em' }}>
                  GROUP
                </div>
              </div>
            </div>

            <h1
              style={{
                fontSize: 64,
                fontWeight: 900,
                color: '#FFFFFF',
                letterSpacing: '-0.03em',
                margin: '0 0 16px 0',
                lineHeight: 1.1,
              }}
            >
              STANDARD <span style={{ color: '#0095D9' }}>WORK</span>
            </h1>

            <p
              style={{
                fontSize: 22,
                color: '#CBD5E1',
                lineHeight: 1.5,
                margin: '0 0 32px 0',
                maxWidth: 580,
              }}
            >
              Una plataforma integral creada por y para la operación de Darnel Group.
              Disciplina en planta, visibilidad en tiempo real y excelencia continua.
            </p>

            <div
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 14,
                padding: '14px 26px',
                borderRadius: 16,
                background: 'linear-gradient(90deg, #002F6C 0%, #006DB2 100%)',
                border: '1px solid rgba(0, 149, 217, 0.4)',
                boxShadow: '0 10px 25px rgba(0, 47, 108, 0.4)',
              }}
            >
              <div
                style={{
                  width: 10,
                  height: 10,
                  borderRadius: '50%',
                  background: '#4ADE80',
                  boxShadow: '0 0 8px #4ADE80',
                }}
              />
              <span style={{ fontSize: 18, fontWeight: 700, color: '#FFFFFF' }}>
                Versión 2.0.0 · Lista para Presentar
              </span>
            </div>
          </div>

          {/* Right Phone & Mockup Showcase */}
          <div
            style={{
              width: '44%',
              display: 'flex',
              justifyContent: 'center',
              transform: `scale(${logoSpring})`,
            }}
          >
            <PhoneMockup imageSrc="screenshots/screen_dashboard.png" width={390} height={780} glow />
          </div>
        </div>
      )}

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

