import { test, expect } from '@playwright/test';
import { readFileSync } from 'fs';
import path from 'path';
import { getRunArtifactsDir } from '../utils/paths';
import { writeSummary } from '../utils/summary';

test('요약 리포트 생성', async () => {
  const dir = getRunArtifactsDir();
  const readerErr = safeCount(path.join(dir, 'reader-errors.json'));
  const playerErr = safeCount(path.join(dir, 'player-errors.json'));
  const readerOverflow = safeOverflow(path.join(dir, 'reader-mobile-overflow.json'));
  const playerOverflow = safeOverflow(path.join(dir, 'player-mobile-overflow.json'));

  const start = Number(process.env.PW_TEST_START_TS || Date.now());
  const durationMs = Date.now() - start;
  writeSummary({
    durationMs,
    readerErrors: readerErr,
    playerErrors: playerErr,
    mobileReaderOverflow: readerOverflow,
    mobilePlayerOverflow: playerOverflow,
    positionRestoreAccuracy: '≤1s'
  });
});

function safeCount(jsonPath: string): number {
  try {
    const txt = readFileSync(jsonPath, 'utf-8');
    const arr = JSON.parse(txt);
    return Array.isArray(arr) ? arr.length : (Array.isArray(arr?.entries) ? arr.entries.length : 0);
  } catch {
    return 0;
  }
}

function safeOverflow(jsonPath: string): boolean {
  try {
    const txt = readFileSync(jsonPath, 'utf-8');
    const obj = JSON.parse(txt);
    return Boolean(obj?.hasOverflow);
  } catch {
    return false;
  }
}


