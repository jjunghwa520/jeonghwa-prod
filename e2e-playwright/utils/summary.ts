import { writeFileSync, existsSync, mkdirSync } from 'fs';
import path from 'path';
import { getRunArtifactsDir } from './paths';

export type SuiteSummary = {
  durationMs: number;
  readerErrors: number;
  playerErrors: number;
  mobileReaderOverflow: boolean;
  mobilePlayerOverflow: boolean;
  positionRestoreAccuracy?: string;
};

export function writeSummary(data: SuiteSummary) {
  const dir = getRunArtifactsDir();
  const json = path.join(dir, 'summary.json');
  writeFileSync(json, JSON.stringify(data, null, 2), 'utf-8');
  const md = path.join(dir, 'summary.md');
  const lines = [
    `# Test Summary`,
    `- durationMs: ${data.durationMs}`,
    `- readerErrors: ${data.readerErrors}`,
    `- playerErrors: ${data.playerErrors}`,
    `- mobileReaderOverflow: ${data.mobileReaderOverflow}`,
    `- mobilePlayerOverflow: ${data.mobilePlayerOverflow}`,
    data.positionRestoreAccuracy ? `- positionRestoreAccuracy: ${data.positionRestoreAccuracy}` : ''
  ].filter(Boolean);
  writeFileSync(md, lines.join('\n'), 'utf-8');
  return { json, md };
}




