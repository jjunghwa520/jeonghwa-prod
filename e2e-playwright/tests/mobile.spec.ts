import { test, expect } from '@playwright/test';
import { attachErrorCollector } from '../utils/errorCollector';
import { inspectOverflow, saveOverflowReport } from '../utils/overflowInspector';

const COURSE_ID = process.env.COURSE_ID || '1001';

test.describe('모바일 390×844 - 리더/플레이어 overflowX 진단', () => {
  test.use({ viewport: { width: 390, height: 844 } });

  test('리더 overflowX 여부 및 상위 요소 캡처', async ({ page }) => {
    const collector = attachErrorCollector(page);
    await page.goto(`/courses/${COURSE_ID}/read`);
    await page.waitForLoadState('networkidle');
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    const overflow = await inspectOverflow(page);
    const json = saveOverflowReport('reader-mobile', overflow);
    await page.screenshot({ path: json.replace('.json', '.png'), fullPage: true });
    test.info().annotations.push({ type: 'overflow', description: json });
    collector.save('mobile-reader');
  });

  test('플레이어 overflowX 여부 및 스냅샷', async ({ page }) => {
    const collector = attachErrorCollector(page);
    await page.goto(`/courses/${COURSE_ID}/watch`);
    await page.waitForLoadState('networkidle');
    const overflow = await inspectOverflow(page);
    const json = saveOverflowReport('player-mobile', overflow);
    await page.screenshot({ path: json.replace('.json', '.png'), fullPage: true });
    test.info().annotations.push({ type: 'overflow', description: json });
    collector.save('mobile-player');
  });
});




