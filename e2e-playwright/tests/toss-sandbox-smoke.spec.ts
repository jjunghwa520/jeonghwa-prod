import { test, expect } from '@playwright/test';

// 간단 스모크: 결제 페이지 접근 및 위젯 로드 확인 (샌드박스 키 필요)
test('Toss 결제 위젯 로드 스모크', async ({ page }) => {
  const base = process.env.BASE_URL || 'http://localhost:3000';

  // 테스트용 코스 ID (홈 → 첫 코스 링크 이용)
  await page.goto(base);
  await page.waitForLoadState('networkidle');

  // 첫 코스 상세 이동 (가장 먼저 보이는 카드)
  const firstCourse = page.locator('a:has-text("자세히 보기"), a:has-text("바로가기"), .course-card a').first();
  await firstCourse.click({ trial: true }).catch(() => {});
  if (await firstCourse.isVisible()) {
    await firstCourse.click();
  }

  await page.waitForLoadState('networkidle');

  // 결제/수강 버튼 찾기
  const checkoutBtn = page.locator('a:has-text("결제")').first();
  if (await checkoutBtn.isVisible()) {
    await checkoutBtn.click();
  } else {
    // 대체: URL 패턴로 접근 시도 (코스 ID 가정)
    const currentUrl = page.url();
    const match = currentUrl.match(/courses\/(\d+)/);
    if (match) {
      await page.goto(`${base}/payments/${match[1]}/checkout`);
    }
  }

  // Toss 스크립트 로드 확인
  await expect(page.locator('script[src*="js.tosspayments.com"]')).toBeVisible({ timeout: 10000 });

  // 위젯 초기화 스니펫 존재 여부 (페이지 스크립트 내부에서 TossPayments 호출 여부)
  const hasTossInit = await page.evaluate(() => {
    return typeof (window as any).TossPayments === 'function' || !!document.querySelector('#toss-checkout, #payment-widget');
  });

  expect(hasTossInit).toBeTruthy();
});



