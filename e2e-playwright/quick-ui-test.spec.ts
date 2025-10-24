import { test, expect } from '@playwright/test';

test.describe('🎨 Quick UI & Security Test', () => {
  
  test('UI 개선 확인 - 프로필 드롭다운', async ({ page }) => {
    // 홈페이지 접속
    await page.goto('http://localhost:3000');
    await page.waitForLoadState('networkidle');
    
    // 로그인 (이미 되어있을 수도)
    const loginLink = page.locator('a:has-text("로그인")');
    if (await loginLink.isVisible()) {
      await loginLink.click();
      await page.fill('input[type="email"]', 'admin@jeonghwa.com');
      await page.fill('input[type="password"]', 'password');
      await page.click('button[type="submit"]:has-text("로그인")');
      await page.waitForLoadState('networkidle');
    }
    
    // 프로필 드롭다운 확인
    const profileBtn = page.locator('.dropdown-toggle, a:has-text("정화")').first();
    await profileBtn.click();
    await page.waitForTimeout(500);
    
    // 드롭다운 메뉴 스타일 확인
    const dropdown = page.locator('.dropdown-menu').first();
    await expect(dropdown).toBeVisible();
    
    const bgColor = await dropdown.evaluate(el => {
      const style = window.getComputedStyle(el);
      return style.backgroundColor;
    });
    
    console.log(`✅ 드롭다운 배경색: ${bgColor}`);
    
    // 스크린샷
    await page.screenshot({ 
      path: 'test-results/ui-dropdown-test.png',
      fullPage: false 
    });
    
    console.log('✅ UI 테스트 완료 - 스크린샷 저장됨');
  });
  
  test('Rate Limiting 확인', async ({ page }) => {
    // 로그아웃
    await page.goto('http://localhost:3000/logout');
    await page.waitForTimeout(1000);
    
    // 로그인 페이지
    await page.goto('http://localhost:3000/login');
    
    // 6번 연속 로그인 시도
    for (let i = 1; i <= 6; i++) {
      await page.fill('input[type="email"]', 'wrong@test.com');
      await page.fill('input[type="password"]', 'wrongpass');
      await page.click('button[type="submit"]:has-text("로그인")');
      await page.waitForTimeout(500);
      
      console.log(`시도 ${i}/6`);
      
      // 6번째에 429 에러 또는 Rate Limit 페이지 확인
      if (i === 6) {
        const content = await page.content();
        const has429 = content.includes('너무 많은 요청') || 
                       content.includes('Too Many Requests') ||
                       page.url().includes('429');
        
        if (has429) {
          console.log('✅ Rate Limiting 작동 확인!');
          await page.screenshot({ 
            path: 'test-results/rate-limit-429.png',
            fullPage: true 
          });
        } else {
          console.log('⚠️ Rate Limiting이 작동하지 않았습니다');
          await page.screenshot({ 
            path: 'test-results/rate-limit-failed.png',
            fullPage: true 
          });
        }
        
        expect(has429).toBe(true);
      }
    }
  });
  
  test('보안 헤더 확인', async ({ page }) => {
    const response = await page.goto('http://localhost:3000');
    const headers = response?.headers();
    
    console.log('\n🛡️ 보안 헤더 확인:');
    console.log(`X-Frame-Options: ${headers?.['x-frame-options'] || '없음'}`);
    console.log(`X-Content-Type-Options: ${headers?.['x-content-type-options'] || '없음'}`);
    console.log(`X-XSS-Protection: ${headers?.['x-xss-protection'] || '없음'}`);
    console.log(`Content-Security-Policy: ${headers?.['content-security-policy'] ? '설정됨' : '없음'}`);
    
    // 최소 3개 이상의 보안 헤더가 있어야 함
    const securityHeaders = [
      headers?.['x-frame-options'],
      headers?.['x-content-type-options'],
      headers?.['x-xss-protection']
    ].filter(h => h);
    
    expect(securityHeaders.length).toBeGreaterThanOrEqual(3);
    console.log(`\n✅ ${securityHeaders.length}개 보안 헤더 확인됨`);
  });
});



