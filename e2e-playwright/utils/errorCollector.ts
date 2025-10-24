import { Page } from '@playwright/test';
import { writeFileSync, mkdirSync } from 'fs';
import path from 'path';
import { getRunArtifactsDir } from './paths';

export type ErrorEntry = {
  type: 'console' | 'pageerror' | 'requestfailed' | 'http4xx5xx' | 'warning';
  message: string;
  url?: string;
  status?: number;
  ts: string;
};

export function attachErrorCollector(page: Page) {
  const entries: ErrorEntry[] = [];

  function push(entry: ErrorEntry) {
    entries.push(entry);
  }

  page.on('console', (msg) => {
    try {
      const type = msg.type();
      const text = msg.text();
      const isWarning = type === 'warning';
      const isError = type === 'error';
      if (isWarning || isError) {
        push({
          type: isWarning ? 'warning' : 'console',
          message: text,
          ts: new Date().toISOString()
        });
      }
    } catch {}
  });

  page.on('pageerror', (err) => {
    push({ type: 'pageerror', message: err?.message || String(err), ts: new Date().toISOString() });
  });

  page.on('requestfailed', (req) => {
    push({ type: 'requestfailed', message: req.failure()?.errorText || 'request failed', url: req.url(), ts: new Date().toISOString() });
  });

  page.on('response', async (res) => {
    try {
      const status = res.status();
      if (status >= 400) {
        push({ type: 'http4xx5xx', message: res.statusText(), status, url: res.url(), ts: new Date().toISOString() });
      }
    } catch {}
  });

  return {
    getEntries: () => entries,
    save: (fileStem: string) => {
      const dir = getRunArtifactsDir();
      mkdirSync(dir, { recursive: true });
      const file = path.join(dir, `${fileStem}-errors.json`);
      writeFileSync(file, JSON.stringify(entries, null, 2), 'utf-8');
      return file;
    }
  };
}




