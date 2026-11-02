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
import { theme } from '../../styles/theme';

export const ShowcaseScene6MontageOutro: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Dynamic entry spring
  const entrySpring = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 90 },
  });

  // Outro fade to black at the end (last 15 frames: 135 to 150)
  const fadeOut = interpolate(frame, [135, 150], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Perspective positions for 3 floating showcase screens
  const leftX = interpolate(frame, [0, 60], [-180, -220]);
  const rightX = interpolate(frame, [0, 60], [180, 220]);

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 40%, #002D62 0%, #080F1E 65%, #030509 100%)`,
        overflow: 'hidden',
        fontFamily: theme.fonts.main,
        opacity: fadeOut,
      }}
    >
      {/* Background radial glow */}
      <div
        style={{
          position: 'absolute',
          top: '35%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: 800,
          height: 800,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(0, 149, 217, 0.35) 0%, transparent 70%)',
          filter: 'blur(60px)',
          pointerEvents: 'none',
        }}
      />

      {/* Floating 3-Phone Showcase in 3D Perspective */}
      <div
        style={{
          position: 'absolute',
          top: '46%',
          left: '50%',
          transform: `translate(-50%, -50%) scale(${entrySpring})`,
          width: 1200,
          height: 700,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          perspective: 1200,
        }}
      >
        {/* Left Screen: 4 Weeks Planning (Tilted) */}
        <div
          style={{
            position: 'absolute',
            left: `calc(50% + ${leftX}px - 280px)`,
            transform: 'rotateY(26deg) rotateX(4deg) scale(0.82)',
            transformOrigin: 'right center',
            opacity: 0.85,
            filter: 'brightness(0.9)',
          }}
        >
          <PhoneMockup imageSrc="showcase/07_four_weeks.png" width={340} height={680} glow={false} />
        </div>

        {/* Right Screen: Indicators (Tilted) */}
        <div
          style={{
            position: 'absolute',
            left: `calc(50% + ${rightX}px - 60px)`,
            transform: 'rotateY(-26deg) rotateX(4deg) scale(0.82)',
            transformOrigin: 'left center',
            opacity: 0.85,
            filter: 'brightness(0.9)',
          }}
        >
          <PhoneMockup imageSrc="showcase/11_indicators.png" width={340} height={680} glow={false} />
        </div>

        {/* Center Screen: Dashboard (Hero) */}
        <div
          style={{
            position: 'relative',
            zIndex: 20,
            transform: 'scale(0.96)',
          }}
        >
          <PhoneMockup imageSrc="showcase/05_dashboard_checked.png" width={370} height={740} glow />
        </div>
      </div>

      {/* Bottom Brand Bar */}
      <div
        style={{
          position: 'absolute',
          bottom: 45,
          left: '50%',
          transform: 'translateX(-50%)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 10,
          zIndex: 30,
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 16,
            padding: '12px 28px',
            borderRadius: 999,
            background: 'rgba(11, 18, 32, 0.9)',
            border: '1px solid rgba(0, 149, 217, 0.5)',
            boxShadow: '0 12px 35px rgba(0, 0, 0, 0.6)',
            backdropFilter: 'blur(16px)',
          }}
        >
          <div
            style={{
              width: 38,
              height: 38,
              borderRadius: 10,
              background: 'linear-gradient(135deg, #002F6C 0%, #006DB2 100%)',
              border: '1px solid rgba(0, 149, 217, 0.5)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              overflow: 'hidden',
            }}
          >
            <Img
              src={staticFile('logos/app_icon.png')}
              style={{ width: '85%', height: '85%', objectFit: 'contain' }}
            />
          </div>

          <div style={{ textAlign: 'left' }}>
            <div style={{ fontSize: 20, fontWeight: 900, color: '#FFFFFF', letterSpacing: '0.04em' }}>
              STANDARD <span style={{ color: '#0095D9' }}>WORK</span>
            </div>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#38BDF8', letterSpacing: '0.12em' }}>
              DARNEL GROUP · VERSION 2.0.0 FLUTTER
            </div>
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};

