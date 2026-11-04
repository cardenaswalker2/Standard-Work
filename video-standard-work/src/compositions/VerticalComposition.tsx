import React from 'react';
import { AbsoluteFill, Audio, Series, staticFile } from 'remotion';
import { Scene1Intro } from '../scenes/Scene1Intro';
import { Scene2Context } from '../scenes/Scene2Context';
import { Scene3Solution } from '../scenes/Scene3Solution';
import { Scene4Workflow } from '../scenes/Scene4Workflow';
import { Scene5Modules } from '../scenes/Scene5Modules';
import { Scene6Value } from '../scenes/Scene6Value';
import { Scene7Outro } from '../scenes/Scene7Outro';
import { sceneDurations } from '../styles/theme';

export const VerticalComposition: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: '#080E1A' }}>
      {/* Background Corporate Music Track */}
      <Audio src={staticFile('music/background_corporate.mp3')} volume={0.09} />

      {/* Main 7 Scenes Series (Vertical Adaptation) */}
      <Series>
        <Series.Sequence durationInFrames={sceneDurations.scene1}>
          <Scene1Intro vertical={true} />
        </Series.Sequence>

        <Series.Sequence durationInFrames={sceneDurations.scene2}>
          <Scene2Context vertical={true} />
        </Series.Sequence>

        <Series.Sequence durationInFrames={sceneDurations.scene3}>
          <Scene3Solution vertical={true} />
        </Series.Sequence>

        <Series.Sequence durationInFrames={sceneDurations.scene4}>
          <Scene4Workflow vertical={true} />
        </Series.Sequence>

        <Series.Sequence durationInFrames={sceneDurations.scene5}>
          <Scene5Modules vertical={true} />
        </Series.Sequence>

        <Series.Sequence durationInFrames={sceneDurations.scene6}>
          <Scene6Value vertical={true} />
        </Series.Sequence>

        <Series.Sequence durationInFrames={sceneDurations.scene7}>
          <Scene7Outro vertical={true} />
        </Series.Sequence>
      </Series>
    </AbsoluteFill>
  );
};

