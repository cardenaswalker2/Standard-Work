import React from 'react';
import { Img, staticFile } from 'remotion';
import { theme } from '../styles/theme';

interface PhoneMockupProps {
  imageSrc: string;
  width?: number;
  height?: number;
  scale?: number;
  glow?: boolean;
  style?: React.CSSProperties;
}

export const PhoneMockup: React.FC<PhoneMockupProps> = ({
  imageSrc,
  width = 390,
  height = 800,
  scale = 1,
  glow = true,
  style,
}) => {
  return (
    <div
      style={{
        width,
        height,
        transform: `scale(${scale})`,
        transformOrigin: 'center center',
        position: 'relative',
        borderRadius: 44,
        background: '#0F172A',
        padding: 10,
        boxShadow: glow
          ? `0 25px 60px -10px rgba(0, 0, 0, 0.7), 0 0 50px rgba(0, 149, 217, 0.25)`
          : theme.shadows.phone,
        border: '3px solid rgba(255, 255, 255, 0.15)',
        boxSizing: 'border-box',
        overflow: 'hidden',
        ...style,
      }}
    >
      {/* Dynamic Island / Speaker Pill */}
      <div
        style={{
          position: 'absolute',
          top: 18,
          left: '50%',
          transform: 'translateX(-50%)',
          width: 100,
          height: 22,
          background: '#000000',
          borderRadius: 20,
          zIndex: 30,
          boxShadow: '0 2px 6px rgba(0, 0, 0, 0.4)',
        }}
      />

      {/* Screen Frame Container */}
      <div
        style={{
          width: '100%',
          height: '100%',
          borderRadius: 36,
          overflow: 'hidden',
          background: '#F3F5FA',
          position: 'relative',
        }}
      >
        <Img
          src={staticFile(imageSrc)}
          style={{
            width: '100%',
            height: '100%',
            objectFit: 'cover',
            display: 'block',
          }}
        />
      </div>

      {/* Subtle Inner Bezel Glass Reflection */}
      <div
        style={{
          position: 'absolute',
          top: 10,
          left: 10,
          right: 10,
          height: '40%',
          borderRadius: '36px 36px 0 0',
          background:
            'linear-gradient(180deg, rgba(255, 255, 255, 0.08) 0%, rgba(255, 255, 255, 0) 100%)',
          pointerEvents: 'none',
          zIndex: 20,
        }}
      />
    </div>
  );
};

