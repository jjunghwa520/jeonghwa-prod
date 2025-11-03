import { test, expect } from '@playwright/test';
import path from 'path';

/**
 * 토스 페이먼츠 심사 제출용 스크린샷 자동 캡처
 * 저장 위치: public/screenshots/toss_submission_2025-11-01/
 */

test.describe('토스 페이먼츠 심사용 스크린샷', () => {
  const BASE_URL = 'https://정화의서재.kr';
  const SCREENSHOT_DIR = path.join(__dirname, '../../public/screenshots/toss_submission_2025-11-01');
  
  const TEST_USER = {
    email: 'parent1@jeonghwa.com',
    password: 'password123'
  };

  test('1. 홈페이지 메인 (풀페이지)', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');
    
    // 풀페이지 스크린샷
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/01_homepage_main.png`,
      fullPage: true 
    });
    
    console.log('✅ 1. 홈페이지 스크린샷 저장');
  });

  test('2. 로그인 페이지', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);
    await page.waitForLoadState('networkidle');
    
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/02_login_page.png`,
      fullPage: true 
    });
    
    console.log('✅ 2. 로그인 페이지 스크린샷 저장');
  });

  test('3. 유료 상품 상세 페이지 (₩6,000)', async ({ page }) => {
    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);
    
    // 상품 페이지로 이동 (달나라 토끼의 꿈)
    await page.goto(`${BASE_URL}/courses/3`);
    await page.waitForLoadState('networkidle');
    
    // 가격이 보이는지 확인
    await page.waitForSelector('text=₩6,000', { timeout: 5000 });
    
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/03_product_detail.png`,
      fullPage: true 
    });
    
    console.log('✅ 3. 상품 상세 페이지 스크린샷 저장');
  });

  test('4. 결제 페이지 - 약관 동의 전', async ({ page }) => {
    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);
    
    // 결제 페이지로 직접 이동
    await page.goto(`${BASE_URL}/payments/3/checkout`);
    await page.waitForLoadState('networkidle');
    
    // 약관 동의 체크박스가 보일 때까지 대기
    await page.waitForSelector('#agree-all', { timeout: 5000 });
    
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/04_checkout_before_agree.png`,
      fullPage: true 
    });
    
    console.log('✅ 4. 결제 페이지 (약관 동의 전) 스크린샷 저장');
  });

  test('5. 결제 페이지 - 약관 동의 후', async ({ page }) => {
    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);
    
    // 결제 페이지로 이동
    await page.goto(`${BASE_URL}/payments/3/checkout`);
    await page.waitForLoadState('networkidle');
    
    // 약관 전체 동의
    await page.waitForSelector('#agree-all', { timeout: 5000 });
    await page.check('#agree-all');
    await page.waitForTimeout(500);
    
    // 결제 버튼 활성화 확인
    const paymentButton = page.locator('#payment-button');
    await expect(paymentButton).toBeEnabled();
    
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/05_checkout_after_agree.png`,
      fullPage: true 
    });
    
    console.log('✅ 5. 결제 페이지 (약관 동의 후) 스크린샷 저장');
  });

  test('6. 환불 정책 페이지', async ({ page }) => {
    await page.goto(`${BASE_URL}/pages/terms`);
    await page.waitForLoadState('networkidle');
    
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/06_refund_policy.png`,
      fullPage: true 
    });
    
    console.log('✅ 6. 환불 정책 페이지 스크린샷 저장');
  });

  test('7. 최고가 상품 페이지 (₩150,000)', async ({ page }) => {
    // 로그인
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', TEST_USER.email);
    await page.fill('input[type="password"]', TEST_USER.password);
    await page.click('button[type="submit"]');
    await page.waitForURL(BASE_URL);
    
    // 최고가 상품 (동화작가 마스터 과정)
    await page.goto(`${BASE_URL}/courses/24`);
    await page.waitForLoadState('networkidle');
    
    // 가격 확인
    await page.waitForSelector('text=₩150,000', { timeout: 5000 });
    
    await page.screenshot({ 
      path: `${SCREENSHOT_DIR}/07_highest_price_product.png`,
      fullPage: true 
    });
    
    console.log('✅ 7. 최고가 상품 페이지 스크린샷 저장');
  });

  test('8. 사업자 정보 (하단 푸터)', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');
    
    // 푸터까지 스크롤
    await page.evaluate(() => {
      window.scrollTo(0, document.body.scrollHeight);
    });
    await page.waitForTimeout(1000);
    
    // 푸터 영역만 스크린샷
    const footer = page.locator('footer, contentinfo');
    await footer.screenshot({ 
      path: `${SCREENSHOT_DIR}/08_business_info_footer.png`
    });
    
    console.log('✅ 8. 사업자 정보 푸터 스크린샷 저장');
  });

  test('9. README 파일 생성', async ({ page }) => {
    const fs = require('fs');
    const readmeContent = `# 토스 페이먼츠 심사 제출용 스크린샷

**캡처 일시**: 2025-11-01
**사이트**: https://정화의서재.kr
**목적**: 토스 페이먼츠 계약심사 제출용 결제경로 자료

## 📸 스크린샷 목록

### 1. 홈페이지 메인
- 파일: \`01_homepage_main.png\`
- 내용: 정화의서재 메인 페이지 풀페이지
- 용도: PPT 슬라이드 2 - 서비스 소개

### 2. 로그인 페이지
- 파일: \`02_login_page.png\`
- 내용: 이메일/비밀번호 로그인 화면
- 용도: PPT 슬라이드 5 - 로그인 프로세스

### 3. 유료 상품 상세 페이지
- 파일: \`03_product_detail.png\`
- 내용: 🐰 달나라 토끼의 꿈 (₩6,000)
- 용도: PPT 슬라이드 3 - 상품 상세 및 가격

### 4. 결제 페이지 (약관 동의 전)
- 파일: \`04_checkout_before_agree.png\`
- 내용: 약관 체크박스, 결제 버튼 비활성화
- 용도: PPT 슬라이드 6 - 약관 동의 프로세스

### 5. 결제 페이지 (약관 동의 후)
- 파일: \`05_checkout_after_agree.png\`
- 내용: 약관 체크 완료, 결제 버튼 활성화
- 용도: PPT 슬라이드 7 - 결제 버튼 활성화

### 6. 환불 정책 페이지
- 파일: \`06_refund_policy.png\`
- 내용: 이용약관 페이지 (제7조 환불 정책 포함)
- 용도: PPT 슬라이드 10 - 환불 정책

### 7. 최고가 상품 페이지
- 파일: \`07_highest_price_product.png\`
- 내용: 🏆 동화작가 마스터 과정 (₩150,000)
- 용도: PPT 슬라이드 4 - 최고가 상품

### 8. 사업자 정보 (푸터)
- 파일: \`08_business_info_footer.png\`
- 내용: 상호, 대표이사, 사업자등록번호, 통신판매업 신고번호 등
- 용도: PPT 슬라이드 11 - 사업자 정보

## 📋 토스 페이먼츠 제출 자료

### 필수 질문 답변

**[1]-① 결제 상품/서비스 URL**
\`\`\`
https://정화의서재.kr
https://정화의서재.kr/courses/3
https://정화의서재.kr/courses/24
\`\`\`

**[1]-② 환불정책 URL**
\`\`\`
https://정화의서재.kr/pages/terms
\`\`\`

**[1]-③ 상품/서비스 상세**
\`\`\`
어린이 대상 디지털 교육 콘텐츠 (전자동화책, 구연동화, 동화만들기)
가격: ₩4,500 ~ ₩150,000
즉시 디지털 제공 (배송 없음)
\`\`\`

**[1]-④ 최고가**
\`\`\`
₩150,000 (동화작가 마스터 과정)
\`\`\`

**테스트 계정**
\`\`\`
ID: parent1@jeonghwa.com
PW: password123
\`\`\`

### PPT 슬라이드 구성 (권장)

1. **표지** - 정화의서재 결제 프로세스
2. **홈페이지** - 01_homepage_main.png
3. **상품 상세** - 03_product_detail.png
4. **최고가 상품** - 07_highest_price_product.png
5. **로그인** - 02_login_page.png
6. **결제 (약관 동의 전)** - 04_checkout_before_agree.png
7. **결제 (약관 동의 후)** - 05_checkout_after_agree.png
8. **토스 결제창** - (실제 결제창 캡처 필요)
9. **환불 정책** - 06_refund_policy.png
10. **사업자 정보** - 08_business_info_footer.png

## 🚀 다음 단계

1. [ ] 이 스크린샷들로 PPT 제작
2. [ ] 실제 토스 결제창 스크린샷 추가 (수동 캡처)
3. [ ] 사업자등록증 첨부
4. [ ] 통신판매업 신고증 첨부
5. [ ] 토스 페이먼츠에 이메일 제출

---

**캡처 완료**: 2025-11-01
**총 파일 수**: 8개
`;

    fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
    fs.writeFileSync(`${SCREENSHOT_DIR}/README.md`, readmeContent);
    
    console.log('✅ 9. README.md 파일 생성 완료');
  });
});

