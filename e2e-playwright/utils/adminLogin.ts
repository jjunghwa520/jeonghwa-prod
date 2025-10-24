import { expect, Page } from '@playwright/test';

export async function adminLogin(page: Page) {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  if (!email || !password) throw new Error('ADMIN_EMAIL/ADMIN_PASSWORD env required');

  // 로그인 페이지로 직접 이동 (리다이렉트/보안 헤더 등 변수 제거)
  await page.goto('/login', { waitUntil: 'domcontentloaded' });
  // 이미 로그인되어 있으면 관리자 페이지로 바로 이동
  if (!/\/login/.test(page.url())) {
    await page.goto('/admin', { waitUntil: 'domcontentloaded' });
    await expect(page).toHaveURL(/\/admin(\b|\/)/);
    return;
  }

  const emailField = page.getByLabel(/이메일|email/i).or(page.locator('input[type="email"], input[name*="email" i], #email, #admin_email').first());
  const passField = page.getByLabel(/비밀번호|password/i).or(page.locator('input[type="password"], input[name*="password" i], #password, #admin_password').first());
  await emailField.waitFor({ state: 'visible', timeout: 10000 });
  await emailField.fill(email);
  await passField.fill(password);
  const submit = page.getByRole('button', { name: /로그인|sign in|log in|login/i }).or(page.locator('button[type="submit"], input[type="submit"]').first());
  await submit.click();
  await page.waitForLoadState('networkidle');
  // 로그인 후 홈으로 리다이렉트될 수 있으므로 관리자 페이지로 진입
  if (!/\/admin(\b|\/)/.test(page.url())) {
    await page.goto('/admin', { waitUntil: 'domcontentloaded' });
  }
  // Basic assertion: admin dashboard visible
  await expect(page).toHaveURL(/\/admin(\b|\/)/);
}




