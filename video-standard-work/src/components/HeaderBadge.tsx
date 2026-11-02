import React from 'react';
import { theme } from '../styles/theme';

interface HeaderBadgeProps {
  category?: string;
  version?: string;
  style?: React.CSSProperties;
}

export const HeaderBadge: React.FC<HeaderBadgeProps> = ({
  category = 'OPERACIONES & PLANTA',
  version = 'VERSIÓN OFICIAL 2.0.0',
  style,
}) => {
  return (
    <div
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 12,
        padding: '8px 18px',
        borderRadius: 999,
        background: 'rgba(0, 47, 108, 0.45)',
        border: '1px solid rgba(0, 149, 217, 0.4)',
        backdropFilter: 'blur(12px)',
        boxShadow: '0 4px 20px rgba(0, 0, 0, 0.25)',
        ...style,
      }}
    >
      <div
        style={{
          width: 8,
          height: 8,
          borderRadius: '50%',
          background: '#4ADE80',
          boxShadow: '0 0 10px #4ADE80',
        }}
      />
      <span
        style={{
          fontFamily: theme.fonts.main,
          fontSize: 13,
          fontWeight: 700,
          letterSpacing: '0.08em',
          color: '#E0F2FE',
          textTransform: 'uppercase',
        }}
      >
        DARNEL GROUP · {category}
      </span>
      <span
        style={{
          width: 1,
          height: 12,
          background: 'rgba(255, 255, 255, 0.2)',
        }}
      />
      <span
        style={{
          fontFamily: theme.fonts.main,
          fontSize: 12,
          fontWeight: 600,
          color: '#38BDF8',
          letterSpacing: '0.05em',
        }}
      >
        {version}
      </span>
    </div>
  );
};

