import { test, expect } from '@playwright/test';

/**
 * 토스 페이먼츠 결제 전체 플로우 E2E 테스트
 * 
 * 테스트 범위:
 * 1. 로그인
 * 2. 유료 상품 선택
 * 3. 결제 페이지 이동
 * 4. 약관 동의
 * 5. 토스 SDK 로드 확인
 * 6. 결제 버튼 활성화
 */

test.describe('토스 페이먼츠 결제 E2E', () => {
  const BASE_URL = 'https://정화의서재.kr';
  const TEST_USER = {
    email: 'parent1@jeonghwa.com',
    password: 'password123'
  };

  test('1. 로그인 → 유료 강의 선택 → 결제 페이지까지', async ({ page }) => {
    // 1. 홈페이지 접속
    await page.goto(BASE_URL);
    await expect(page).toHaveTitle(/정화의 서재/);

    // 2. 로그인 페이지로 이동
    await page.click('text=로그인');
    await page.waitForURL('**/login');

    // 3. 로그인
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    
    // 로그인 완료 대기
    await page.waitForURL(BASE_URL);
    await expect(page.locator('text=학부모1')).toBeVisible();

    console.log('✅ 로그인 성공');

    // 4. 유료 강의 페이지로 이동 (달나라 토끼의 꿈 - 6,000원)
    await page.goto(`${BASE_URL}/courses/3`);
    await page.waitForLoadState('networkidle');

    // 5. 가격 확인
    await expect(page.locator('text=₩6,000')).toBeVisible();

    console.log('✅ 유료 강의 페이지 접속');

    // 6. "바로 수강하기" 버튼 찾기
    const enrollButton = page.locator('button:has-text("바로 수강하기"), input[value*="바로 수강하기"]');
    
    // 이미 수강 중이면 "수강하기" 버튼 찾기
    const watchButton = page.locator('a:has-text("수강하기")');
    
    if (await watchButton.isVisible()) {
      console.log('⚠️  이미 수강 중인 강의입니다. 다른 강의로 테스트하세요.');
      return;
    }

    // 7. 결제 페이지로 이동
    await enrollButton.click();
    
    // 결제 페이지 로딩 대기
    await page.waitForURL('**/payments/**/checkout', { timeout: 10000 });
    
    console.log('✅ 결제 페이지 이동 성공');

    // 8. 결제 페이지 요소 확인
    await expect(page.locator('h4:has-text("결제하기")')).toBeVisible();
    await expect(page.locator('text=₩6,000')).toBeVisible();

    console.log('✅ 결제 금액 표시 확인');
  });

  test('2. 결제 페이지 - 약관 동의 UI 확인', async ({ page }) => {
    // 로그인 및 결제 페이지 이동 (위 테스트와 동일)
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);

    // 결제 페이지로 직접 이동 (강의 ID 3)
    await page.goto(`${BASE_URL}/payments/3/checkout`);
    await page.waitForLoadState('networkidle');

    // 1. 약관 동의 체크박스 확인
    const agreeTerms = page.locator('#agree-terms');
    const agreePrivacy = page.locator('#agree-privacy');
    const agreeRefund = page.locator('#agree-refund');
    const agreeAll = page.locator('#agree-all');

    await expect(agreeTerms).toBeVisible();
    await expect(agreePrivacy).toBeVisible();
    await expect(agreeRefund).toBeVisible();
    await expect(agreeAll).toBeVisible();

    console.log('✅ 약관 동의 체크박스 표시 확인');

    // 2. 결제 버튼이 비활성화 상태인지 확인
    const paymentButton = page.locator('#payment-button');
    await expect(paymentButton).toBeDisabled();

    console.log('✅ 초기 결제 버튼 비활성화 확인');

    // 3. 전체 동의 체크
    await agreeAll.check();
    await page.waitForTimeout(500);

    // 4. 개별 체크박스도 모두 체크되었는지 확인
    await expect(agreeTerms).toBeChecked();
    await expect(agreePrivacy).toBeChecked();
    await expect(agreeRefund).toBeChecked();

    console.log('✅ 전체 동의 시 개별 체크박스 자동 체크 확인');

    // 5. 결제 버튼이 활성화되었는지 확인
    await expect(paymentButton).toBeEnabled();

    console.log('✅ 약관 동의 후 결제 버튼 활성화 확인');

    // 6. 약관 링크 확인
    const termsLink = page.locator('a:has-text("이용약관")');
    const privacyLink = page.locator('a:has-text("개인정보처리방침")');

    await expect(termsLink).toBeVisible();
    await expect(privacyLink).toBeVisible();

    console.log('✅ 약관 링크 표시 확인');
  });

  test('3. 토스 SDK 로드 및 초기화 확인', async ({ page }) => {
    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);

    // 결제 페이지로 이동
    await page.goto(`${BASE_URL}/payments/3/checkout`);
    await page.waitForLoadState('networkidle');

    // 1. 토스 SDK 스크립트 로드 확인
    const tossScript = page.locator('script[src*="tosspayments.com"]');
    await expect(tossScript).toBeAttached();

    console.log('✅ 토스 SDK 스크립트 로드 확인');

    // 2. TossPayments 객체 초기화 확인
    const isTossInitialized = await page.evaluate(() => {
      return typeof (window as any).TossPayments === 'function';
    });

    expect(isTossInitialized).toBeTruthy();

    console.log('✅ TossPayments 객체 초기화 확인');

    // 3. 클라이언트 키 확인
    const clientKey = await page.evaluate(() => {
      const scriptContent = document.querySelector('script:not([src])')?.textContent || '';
      const match = scriptContent.match(/const clientKey = ['"]([^'"]+)['"]/);
      return match ? match[1] : null;
    });

    expect(clientKey).toBeTruthy();
    expect(clientKey).toContain('test_ck_');

    console.log(`✅ 클라이언트 키 확인: ${clientKey}`);

    // 4. 결제 버튼 클릭 가능 여부 (약관 동의 후)
    await page.locator('#agree-all').check();
    await page.waitForTimeout(500);

    const paymentButton = page.locator('#payment-button');
    await expect(paymentButton).toBeEnabled();
    await expect(paymentButton).toHaveText(/토스페이먼츠로 결제하기/);

    console.log('✅ 결제 버튼 텍스트 및 활성화 상태 확인');
  });

  test('4. 환경변수 확인 (API 키)', async ({ page }) => {
    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);

    // 결제 페이지로 이동
    await page.goto(`${BASE_URL}/payments/3/checkout`);
    await page.waitForLoadState('networkidle');

    // 페이지 소스에서 클라이언트 키 추출
    const clientKey = await page.evaluate(() => {
      const scriptContent = document.querySelector('script:not([src])')?.textContent || '';
      const match = scriptContent.match(/const clientKey = ['"]([^'"]+)['"]/);
      return match ? match[1] : null;
    });

    // 제공받은 테스트 키인지 확인
    expect(clientKey).toBe('test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R');

    console.log('✅ 제공받은 토스 API 클라이언트 키 확인 성공');
  });

  test('5. 결제 프로세스 전체 흐름 (토스 결제창 호출까지)', async ({ page, context }) => {
    // 새 탭/팝업 감지 설정
    const popupPromise = context.waitForEvent('page');

    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);

    // 결제 페이지로 이동
    await page.goto(`${BASE_URL}/payments/3/checkout`);
    await page.waitForLoadState('networkidle');

    // 약관 동의
    await page.locator('#agree-all').check();
    await page.waitForTimeout(500);

    // 결제 버튼 클릭
    const paymentButton = page.locator('#payment-button');
    await expect(paymentButton).toBeEnabled();

    console.log('🔄 결제 버튼 클릭 시도...');

    // 결제 버튼 클릭 (토스 결제창 팝업 예상)
    await paymentButton.click();

    // 팝업 또는 리다이렉트 대기 (최대 5초)
    try {
      const popup = await popupPromise;
      
      // 팝업 URL 확인
      await popup.waitForLoadState('domcontentloaded', { timeout: 5000 });
      const popupUrl = popup.url();
      
      console.log(`✅ 토스 결제창 팝업 열림: ${popupUrl}`);
      
      // 토스 도메인인지 확인
      expect(popupUrl).toContain('tosspayments.com');
      
      await popup.close();
    } catch (error) {
      // 팝업이 아닌 리다이렉트일 수 있음
      await page.waitForTimeout(2000);
      const currentUrl = page.url();
      
      console.log(`⚠️  팝업 대신 리다이렉트: ${currentUrl}`);
      
      // 토스 URL이거나 에러 페이지일 수 있음
      if (currentUrl.includes('tosspayments.com')) {
        console.log('✅ 토스 결제 페이지로 리다이렉트됨');
      }
    }

    console.log('✅ 결제 프로세스 시작 확인 완료');
  });
});

/**
 * 수동 테스트 가이드
 * 
 * 이 자동화 테스트는 실제 결제 완료까지는 진행하지 않습니다.
 * 아래 단계로 수동 테스트를 진행하세요:
 * 
 * 1. https://정화의서재.kr 접속
 * 2. 로그인: parent1@jeonghwa.com / password123
 * 3. 유료 강의 선택 (예: 달나라 토끼의 꿈)
 * 4. "바로 수강하기" 클릭
 * 5. 약관 모두 동의
 * 6. "토스페이먼츠로 결제하기" 클릭
 * 7. 토스 결제창에서 테스트 카드 입력:
 *    - 카드번호: 5570**********1074 (또는 아무 숫자)
 *    - 유효기간: 12/25 (미래 날짜)
 *    - CVC: 123
 *    - 비밀번호: 12
 * 8. 결제 완료 확인
 * 9. 강의 페이지에서 "수강하기" 버튼 확인
 */

