import React from 'react';
import { Composition } from 'remotion';
import { ExecutiveComposition } from './compositions/ExecutiveComposition';
import { VerticalComposition } from './compositions/VerticalComposition';
import {
  ShowcaseComposition,
  SHOWCASE_TOTAL_FRAMES,
} from './compositions/ShowcaseComposition';
import { TOTAL_FRAMES } from './styles/theme';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* 40-Second Pure Visual UI Showcase */}
      <Composition
        id="ShowcaseComposition"
        component={ShowcaseComposition}
        durationInFrames={SHOWCASE_TOTAL_FRAMES}
        fps={30}
        width={1920}
        height={1080}
      />

      {/* Long-form Executive Presentations */}
      <Composition
        id="ExecutiveComposition"
        component={ExecutiveComposition}
        durationInFrames={TOTAL_FRAMES}
        fps={30}
        width={1920}
        height={1080}
      />

      <Composition
        id="VerticalComposition"
        component={VerticalComposition}
        durationInFrames={TOTAL_FRAMES}
        fps={30}
        width={1080}
        height={1920}
      />
    </>
  );
};
