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

export const Scene4Workflow: React.FC<SceneProps> = ({ vertical = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Progress of the compliance gauge (from 0 to 86%)
  const gaugePercent = Math.round(
    interpolate(frame, [20, 100], [0, 86], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    })
  );

  // Transition from Dashboard to Activity Detail Modal around frame 350
  const isDetailView = frame > 360;

  const phoneScale = spring({
    frame,
    fps,
    config: { damping: 15, stiffness: 90 },
  });

  const zoomDetail = interpolate(frame, [350, 390], [1, 1.08], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cues = [
    {
      startFrame: 0,
      endFrame: 170,
      text: 'El flujo de trabajo es directo y natural. Al ingresar, el dashboard presenta un tacómetro visual con el avance en tiempo real.',
    },
    {
      startFrame: 170,
      endFrame: 370,
      text: 'Cada actividad está organizada por hora y código de color. El supervisor confirma la ejecución con un solo toque y notas.',
    },
    {
      startFrame: 370,
      endFrame: 705,
      text: 'Si una urgencia requiere mover una tarea, registra el motivo formalmente garantizando una auditoría transparente.',
    },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 40% 50%, #00224D 0%, #080E1A 60%, #04070D 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      <Audio src={staticFile('audio/scene4.mp3')} volume={1} />

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
        <HeaderBadge category="OPERACIÓN EN PISO" version="DASHBOARD & ACTIVIDADES" />
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
          <div style={{ textAlign: 'center', marginBottom: 16 }}>
            <h2
              style={{
                fontSize: 36,
                fontWeight: 800,
                color: '#FFFFFF',
                margin: '0 0 6px 0',
              }}
            >
              Control en <span style={{ color: '#0095D9' }}>Tiempo Real</span>
            </h2>
            <div
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 8,
                padding: '6px 14px',
                borderRadius: 999,
                background: 'rgba(22, 163, 74, 0.2)',
                border: '1px solid #16A34A',
                color: '#4ADE80',
                fontSize: 14,
                fontWeight: 700,
              }}
            >
              Cumplimiento Turno: {gaugePercent}%
            </div>
          </div>

          <div
            style={{
              transform: `scale(${phoneScale * zoomDetail * 0.95})`,
              transition: 'transform 0.1s ease',
            }}
          >
            <PhoneMockup
              imageSrc={
                isDetailView
                  ? 'screenshots/screen_activity_detail.png'
                  : 'screenshots/screen_dashboard.png'
              }
              width={380}
              height={760}
            />
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
          {/* Left Explanation & Live Metric */}
          <div style={{ width: '50%' }}>
            <h2
              style={{
                fontSize: 54,
                fontWeight: 800,
                color: '#FFFFFF',
                margin: '0 0 16px 0',
                letterSpacing: '-0.03em',
                lineHeight: 1.15,
              }}
            >
              Gestión Diaria con <br />
              <span style={{ color: '#0095D9' }}>Tacómetro y Auditoría</span>
            </h2>

            <p
              style={{
                fontSize: 20,
                color: '#CBD5E1',
                lineHeight: 1.5,
                margin: '0 0 28px 0',
                maxWidth: 580,
              }}
            >
              Desde el Gemba Walk de las 07:00 hasta la reunión de piso operacional, cada actividad
              se registra al instante con observaciones y justificación de reprogramaciones.
            </p>

            {/* Live Progress Card */}
            <div
              style={{
                padding: 24,
                borderRadius: 20,
                background: 'rgba(15, 23, 42, 0.75)',
                border: '1px solid rgba(255, 255, 255, 0.12)',
                boxShadow: '0 12px 30px rgba(0, 0, 0, 0.4)',
                backdropFilter: 'blur(12px)',
                maxWidth: 500,
              }}
            >
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: 12,
                }}
              >
                <span style={{ fontSize: 16, fontWeight: 700, color: '#FFFFFF' }}>
                  Adherencia del Supervisor al Plan
                </span>
                <span
                  style={{
                    fontSize: 22,
                    fontWeight: 900,
                    color: '#4ADE80',
                  }}
                >
                  {gaugePercent}%
                </span>
              </div>

              {/* Progress Bar */}
              <div
                style={{
                  width: '100%',
                  height: 12,
                  background: 'rgba(255, 255, 255, 0.1)',
                  borderRadius: 999,
                  overflow: 'hidden',
                  marginBottom: 14,
                }}
              >
                <div
                  style={{
                    width: `${gaugePercent}%`,
                    height: '100%',
                    background: 'linear-gradient(90deg, #0095D9 0%, #16A34A 100%)',
                    borderRadius: 999,
                    boxShadow: '0 0 12px rgba(74, 222, 128, 0.5)',
                  }}
                />
              </div>

              <div
                style={{
                  display: 'flex',
                  gap: 16,
                  fontSize: 13,
                  color: '#94A3B8',
                  fontWeight: 500,
                }}
              >
                <span>✓ Actividades Ejecutadas</span>
                <span>• Observaciones Registradas</span>
                <span>• Trazabilidad SQLite</span>
              </div>
            </div>
          </div>

          {/* Right Phone Mockup with Dynamic State */}
          <div
            style={{
              width: '44%',
              display: 'flex',
              justifyContent: 'center',
              transform: `scale(${phoneScale * zoomDetail})`,
            }}
          >
            <PhoneMockup
              imageSrc={
                isDetailView
                  ? 'screenshots/screen_activity_detail.png'
                  : 'screenshots/screen_dashboard.png'
              }
              width={390}
              height={780}
              glow
            />
          </div>
        </div>
      )}

      <Subtitles cues={cues} vertical={vertical} />
    </AbsoluteFill>
  );
};

