import { test, expect } from '@playwright/test';

const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'admin@jeonghwa.com';
// seeds.rb 기준 기본값
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'password123';
const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

async function loginIfNeeded(page) {
  // 로그인 페이지로 직접 이동 (네비 의존 제거)
  await page.goto(`${BASE_URL}/login`, { waitUntil: 'domcontentloaded' });
  // 이미 로그인되어 있으면 홈으로 리다이렉트될 수 있으므로 확인
  if (!/\/login/.test(page.url())) {
    return; // 이미 로그인 상태라고 판단
  }

  // 라벨 기반 셀렉터로 견고하게 선택
  const emailField = page.getByLabel(/이메일|email/i).first();
  const passwordField = page.getByLabel(/비밀번호|password/i).first();
  await emailField.waitFor({ state: 'visible', timeout: 10000 });
  await emailField.fill(ADMIN_EMAIL);
  await passwordField.fill(ADMIN_PASSWORD);
  await page.getByRole('button', { name: /로그인/ }).first().click();
  await page.waitForLoadState('networkidle');
}

test.describe('🎨 Quick UI & Security Test', () => {
  test('UI 개선 확인 - 프로필 드롭다운', async ({ page }) => {
    await loginIfNeeded(page);

    const profileBtn = page.locator('a.user-menu, .dropdown-toggle').first();
    await profileBtn.waitFor({ state: 'visible', timeout: 10000 });
    await profileBtn.click();
    await page.waitForTimeout(300);

    const dropdown = page.locator('.dropdown-menu').first();
    await expect(dropdown).toBeVisible();

    const bgColor = await dropdown.evaluate(el => window.getComputedStyle(el).backgroundColor);
    console.log(`✅ 드롭다운 배경색: ${bgColor}`);

    await page.screenshot({ path: 'test-results/ui-dropdown-test.png', fullPage: false });
    console.log('✅ UI 테스트 완료 - 스크린샷 저장됨');
  });

  test('Rate Limiting 확인', async ({ page }) => {
    await page.goto(`${BASE_URL}/logout`);
    await page.waitForTimeout(300);
    await page.goto(`${BASE_URL}/login`, { waitUntil: 'domcontentloaded' });

    for (let i = 1; i <= 6; i++) {
      await page.getByLabel(/이메일|email/i).first().fill('wrong@test.com');
      await page.getByLabel(/비밀번호|password/i).first().fill('wrongpass');
      await page.getByRole('button', { name: /로그인/ }).first().click();
      await page.waitForTimeout(400);

      console.log(`시도 ${i}/6`);

      if (i === 6) {
        const content = await page.content();
        const has429 = content.includes('너무 많은 요청') ||
                       content.includes('Too Many Requests') ||
                       page.url().includes('429');
        if (has429) {
          console.log('✅ Rate Limiting 작동 확인!');
          await page.screenshot({ path: 'test-results/rate-limit-429.png', fullPage: true });
        } else {
          console.log('⚠️ Rate Limiting이 작동하지 않았습니다');
          await page.screenshot({ path: 'test-results/rate-limit-failed.png', fullPage: true });
        }
        expect(has429).toBe(true);
      }
    }
  });

  test('보안 헤더 확인', async ({ page }) => {
    const response = await page.goto(BASE_URL);
    const headers = response?.headers();

    console.log('\n🛡️ 보안 헤더 확인:');
    console.log(`X-Frame-Options: ${headers?.['x-frame-options'] || '없음'}`);
    console.log(`X-Content-Type-Options: ${headers?.['x-content-type-options'] || '없음'}`);
    console.log(`X-XSS-Protection: ${headers?.['x-xss-protection'] || '없음'}`);
    console.log(`Content-Security-Policy: ${headers?.['content-security-policy'] ? '설정됨' : '없음'}`);

    const securityHeaders = [
      headers?.['x-frame-options'],
      headers?.['x-content-type-options'],
      headers?.['x-xss-protection']
    ].filter(h => h);
    expect(securityHeaders.length).toBeGreaterThanOrEqual(3);
    console.log(`\n✅ ${securityHeaders.length}개 보안 헤더 확인됨`);
  });
});

