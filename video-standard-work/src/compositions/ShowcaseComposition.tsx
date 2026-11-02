import React from 'react';
import { AbsoluteFill, Audio, Series, staticFile } from 'remotion';
import { ShowcaseScene1Intro } from '../scenes/showcase/ShowcaseScene1Intro';
import { ShowcaseScene2Dashboard } from '../scenes/showcase/ShowcaseScene2Dashboard';
import { ShowcaseScene3Planning } from '../scenes/showcase/ShowcaseScene3Planning';
import { ShowcaseScene4Calendar } from '../scenes/showcase/ShowcaseScene4Calendar';
import { ShowcaseScene5Indicators } from '../scenes/showcase/ShowcaseScene5Indicators';
import { ShowcaseScene6MontageOutro } from '../scenes/showcase/ShowcaseScene6MontageOutro';

export const SHOWCASE_TOTAL_FRAMES = 1200; // Exact 40.00s @ 30fps

export const ShowcaseComposition: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: '#030509' }}>
      {/* 40-Second Upbeat Instrumental Tech Track (No voices, no lyrics) */}
      <Audio src={staticFile('music/showcase_tech_40s.mp3')} volume={0.5} />

      {/* 6 Exact Visual Scenes */}
      <Series>
        {/* ESCENA 1: Apertura y Pantalla Inicial (00:00 - 00:04) */}
        <Series.Sequence durationInFrames={120}>
          <ShowcaseScene1Intro />
        </Series.Sequence>

        {/* ESCENA 2: Dashboard y Navegación (00:04 - 00:10) */}
        <Series.Sequence durationInFrames={180}>
          <ShowcaseScene2Dashboard />
        </Series.Sequence>

        {/* ESCENA 3: Planificación de 4 Semanas (00:10 - 00:18) */}
        <Series.Sequence durationInFrames={240}>
          <ShowcaseScene3Planning />
        </Series.Sequence>

        {/* ESCENA 4: Calendario y Actividades (00:18 - 00:26) */}
        <Series.Sequence durationInFrames={240}>
          <ShowcaseScene4Calendar />
        </Series.Sequence>

        {/* ESCENA 5: Indicadores y Reportes (00:26 - 00:35) */}
        <Series.Sequence durationInFrames={270}>
          <ShowcaseScene5Indicators />
        </Series.Sequence>

        {/* ESCENA 6: Cierre Visual y Montaje (00:35 - 00:40) */}
        <Series.Sequence durationInFrames={150}>
          <ShowcaseScene6MontageOutro />
        </Series.Sequence>
      </Series>
    </AbsoluteFill>
  );
};

