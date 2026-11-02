import React from 'react';
import {
  AbsoluteFill,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { PhoneMockup } from '../../components/PhoneMockup';
import { TouchPointer } from './TouchPointer';
import { theme } from '../../styles/theme';

export const ShowcaseScene1Intro: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Fast entry scale
  const enterScale = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 120 },
  });

  // Touch on the login button happens at frame 45
  const isTapped = frame >= 48;

  // Zoom into phone slightly when tapping
  const cameraZoom = interpolate(frame, [0, 45, 90, 120], [0.95, 1.05, 1.15, 1.25], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const panY = interpolate(frame, [45, 90], [0, -30], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 50%, #00224D 0%, #070E1A 70%, #03060C 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
      }}
    >
      {/* Background Brand Accent */}
      <div
        style={{
          position: 'absolute',
          top: 40,
          left: '50%',
          transform: 'translateX(-50%)',
          display: 'flex',
          alignItems: 'center',
          gap: 12,
          padding: '6px 18px',
          borderRadius: 999,
          background: 'rgba(0, 47, 108, 0.4)',
          border: '1px solid rgba(0, 149, 217, 0.3)',
          backdropFilter: 'blur(10px)',
          zIndex: 10,
        }}
      >
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#0095D9', boxShadow: '0 0 8px #0095D9' }} />
        <span style={{ fontSize: 13, fontWeight: 800, color: '#E0F2FE', letterSpacing: '0.1em' }}>
          DARNEL GROUP · STANDARD WORK
        </span>
        <span style={{ fontSize: 11, fontWeight: 700, color: '#38BDF8', padding: '2px 8px', borderRadius: 6, background: 'rgba(0, 149, 217, 0.2)' }}>
          APLICACIÓN FLUTTER
        </span>
      </div>

      {/* Main Center Phone */}
      <div
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: `translate(-50%, calc(-50% + ${panY}px)) scale(${enterScale * cameraZoom})`,
          transformOrigin: 'center center',
        }}
      >
        <PhoneMockup
          imageSrc={isTapped ? 'showcase/02_login_tap.png' : 'showcase/01_login.png'}
          width={390}
          height={780}
          glow
        />

        {/* Touch Ripple on the Profile Card (x: 195, y: 390 inside phone) */}
        <TouchPointer x={195} y={390} startFrame={45} duration={24} />
      </div>

      {/* Subtle Bottom Badge */}
      <div
        style={{
          position: 'absolute',
          bottom: 30,
          left: '50%',
          transform: 'translateX(-50%)',
          fontSize: 14,
          fontWeight: 600,
          color: '#94A3B8',
          letterSpacing: '0.05em',
        }}
      >
        AUTENTICACIÓN POR PERFIL Y TURNO
      </div>
    </AbsoluteFill>
  );
};

