import React from 'react';
import { interpolate, useCurrentFrame } from 'remotion';

interface TouchPointerProps {
  x: number;
  y: number;
  startFrame: number;
  duration?: number;
}

export const TouchPointer: React.FC<TouchPointerProps> = ({
  x,
  y,
  startFrame,
  duration = 20,
}) => {
  const frame = useCurrentFrame();
  const relFrame = frame - startFrame;

  if (relFrame < 0 || relFrame > duration) return null;

  const scale = interpolate(relFrame, [0, duration * 0.4, duration], [0.6, 1.25, 1.5], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const opacity = interpolate(relFrame, [0, duration * 0.3, duration], [0, 0.9, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const dotScale = interpolate(relFrame, [0, duration * 0.25, duration], [0.8, 1, 0.7], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <div
      style={{
        position: 'absolute',
        left: x,
        top: y,
        transform: 'translate(-50%, -50%)',
        pointerEvents: 'none',
        zIndex: 100,
      }}
    >
      {/* Expanding Ripple Ring */}
      <div
        style={{
          width: 56,
          height: 56,
          borderRadius: '50%',
          border: '3px solid #00D2FF',
          boxShadow: '0 0 20px #00D2FF, inset 0 0 10px #00D2FF',
          transform: `scale(${scale})`,
          opacity,
        }}
      />
      {/* Central Solid Touch Dot */}
      <div
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: `translate(-50%, -50%) scale(${dotScale})`,
          width: 22,
          height: 22,
          borderRadius: '50%',
          background: 'rgba(255, 255, 255, 0.95)',
          boxShadow: '0 0 14px rgba(0, 210, 255, 0.8), 0 2px 6px rgba(0,0,0,0.4)',
          opacity: opacity > 0 ? 1 : 0,
        }}
      />
    </div>
  );
};

