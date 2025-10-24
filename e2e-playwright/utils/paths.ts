import { mkdirSync } from 'fs';
import path from 'path';

export function getArtifactsBaseDir(): string {
  // __dirname points to e2e-playwright/utils
  // We want: kicda-jh/public/screenshots
  const base = path.resolve(__dirname, '../../public/screenshots');
  mkdirSync(base, { recursive: true });
  return base;
}

export function getRunArtifactsDir(): string {
  // memoize per process so all tests share one run directory
  // @ts-ignore
  if (!(global as any).__RUN_ARTIFACTS_DIR) {
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const d = String(now.getDate()).padStart(2, '0');
    const hh = String(now.getHours()).padStart(2, '0');
    const mm = String(now.getMinutes()).padStart(2, '0');
    const ss = String(now.getSeconds()).padStart(2, '0');
    const stamp = `DATE-${y}${m}${d}-${hh}${mm}${ss}`;
    const dir = path.join(getArtifactsBaseDir(), stamp);
    mkdirSync(dir, { recursive: true });
    // @ts-ignore
    (global as any).__RUN_ARTIFACTS_DIR = dir;
  }
  // @ts-ignore
  return (global as any).__RUN_ARTIFACTS_DIR as string;
}

export function joinArtifacts(...segments: string[]): string {
  return path.join(getRunArtifactsDir(), ...segments);
}


