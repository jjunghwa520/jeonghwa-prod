import { expect, Page } from '@playwright/test';

export async function getLocalStorageItem(page: Page, key: string): Promise<string | null> {
  return page.evaluate((k) => window.localStorage.getItem(k), key);
}

export async function expectLocalStorageToPersist(page: Page, key: string) {
  await waitForLocalStorageKey(page, key, 10000);
  const before = await getLocalStorageItem(page, key);
  expect(before, `localStorage ${key} should exist before reload`).not.toBeNull();
  await page.reload();
  await page.waitForLoadState('networkidle');
  const after = await getLocalStorageItem(page, key);
  expect(after, `localStorage ${key} should exist after reload`).not.toBeNull();
  expect(after).toBe(before);
}

export async function expectPositionRestoreWithin(page: Page, key: string, maxDeltaSeconds: number) {
  await waitForLocalStorageKey(page, key, 10000);
  const before = await getLocalStorageItem(page, key);
  expect(before).not.toBeNull();
  await page.reload();
  await page.waitForLoadState('networkidle');
  await waitForLocalStorageKey(page, key, 10000);
  const after = await getLocalStorageItem(page, key);
  expect(after).not.toBeNull();
  const b = Number(before);
  const a = Number(after);
  expect(Number.isFinite(b) && Number.isFinite(a)).toBeTruthy();
  const delta = Math.abs(a - b);
  expect(delta).toBeLessThanOrEqual(maxDeltaSeconds);
}

export async function waitForLocalStorageKey(page: Page, key: string, timeoutMs = 5000) {
  await page.waitForFunction((k: string) => {
    // 정확히 해당 키 또는, 일치하는 패턴(정규식 문자열로 전달된 경우) 지원
    try {
      const maybeRegex = k.startsWith('/') && k.endsWith('/') ? new RegExp(k.slice(1, -1)) : null;
      if (!maybeRegex) return !!window.localStorage.getItem(k);
      for (let i = 0; i < window.localStorage.length; i++) {
        const kk = window.localStorage.key(i) as string;
        if (maybeRegex.test(kk) && window.localStorage.getItem(kk)) return true;
      }
      return false;
    } catch {
      return !!window.localStorage.getItem(k);
    }
  }, key, { timeout: timeoutMs });
}


