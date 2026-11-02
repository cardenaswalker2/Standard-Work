import React from 'react';
import { interpolate, useCurrentFrame } from 'remotion';
import { theme } from '../styles/theme';

interface SubtitleCue {
  startFrame: number;
  endFrame: number;
  text: string;
}

interface SubtitlesProps {
  cues: SubtitleCue[];
  vertical?: boolean;
}

export const Subtitles: React.FC<SubtitlesProps> = ({ cues, vertical = false }) => {
  const frame = useCurrentFrame();

  const activeCue = cues.find((c) => frame >= c.startFrame && frame < c.endFrame);

  if (!activeCue) return null;

  const fadeIn = interpolate(
    frame,
    [activeCue.startFrame, activeCue.startFrame + 8],
    [0, 1],
    { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
  );

  return (
    <div
      style={{
        position: 'absolute',
        bottom: vertical ? 120 : 40,
        left: '50%',
        transform: 'translateX(-50%)',
        width: vertical ? '90%' : '75%',
        maxWidth: 1000,
        textAlign: 'center',
        zIndex: 50,
        opacity: fadeIn,
      }}
    >
      <div
        style={{
          display: 'inline-block',
          padding: '14px 28px',
          borderRadius: 18,
          background: 'rgba(11, 18, 32, 0.88)',
          border: '1px solid rgba(255, 255, 255, 0.12)',
          backdropFilter: 'blur(16px)',
          boxShadow: '0 12px 35px rgba(0, 0, 0, 0.5)',
        }}
      >
        <span
          style={{
            fontFamily: theme.fonts.main,
            fontSize: vertical ? 28 : 22,
            fontWeight: 600,
            lineHeight: 1.45,
            color: '#FFFFFF',
            letterSpacing: '-0.01em',
            textShadow: '0 2px 4px rgba(0, 0, 0, 0.5)',
          }}
        >
          {activeCue.text}
        </span>
      </div>
    </div>
  );
};

