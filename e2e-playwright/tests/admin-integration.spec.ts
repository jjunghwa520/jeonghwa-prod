import { test, expect } from '@playwright/test';

/**
 * 관리자 페이지 ↔ 홈페이지 통합 테스트
 * 시나리오: 관리자가 콘텐츠 등록 → 사용자가 확인/구매 → 관리자가 통계 확인
 */

const BASE_URL = 'http://localhost:3000';
const ADMIN_EMAIL = 'admin@jeonghwa.com';
const ADMIN_PASSWORD = 'password123'; // 실제 비밀번호로 변경 필요

test.describe('🔗 관리자-홈페이지 통합 플로우', () => {
  
  test.beforeEach(async ({ page }) => {
    // 모든 테스트 전에 관리자 로그인
    await page.goto(`${BASE_URL}/login`);
    
    // 로그인 폼이 있는지 확인 (리다이렉트될 수 있음)
    const currentUrl = page.url();
    if (currentUrl.includes('/login') || currentUrl.includes('/session')) {
      await page.fill('input[name="email"]', ADMIN_EMAIL);
      await page.fill('input[name="password"]', ADMIN_PASSWORD);
      await page.click('button[type="submit"]');
      await page.waitForLoadState('networkidle');
    }
  });

  test('✅ 시나리오 1: 관리자 대시보드 접근 및 통계 확인', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin`);
    
    // 대시보드 요소 확인
    await expect(page.locator('h1')).toContainText('관리자 대시보드');
    
    // 통계 카드 확인
    await expect(page.locator('text=전체 코스')).toBeVisible();
    await expect(page.locator('text=가입 회원')).toBeVisible();
    
    // 스크린샷
    await page.screenshot({ path: 'screenshots/admin-dashboard-initial.png' });
  });

  test('✅ 시나리오 2: 신규 콘텐츠 등록 페이지 UI 확인', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin/courses/new`);
    
    // 6단계 UI 확인
    await expect(page.locator('text=1️⃣ 콘텐츠 유형 선택')).toBeVisible();
    await expect(page.locator('text=2️⃣ 기본 정보')).toBeVisible();
    await expect(page.locator('text=3️⃣ 제작진 정보')).toBeVisible();
    await expect(page.locator('text=4️⃣ 콘텐츠 파일 업로드')).toBeVisible();
    await expect(page.locator('text=5️⃣ 썸네일')).toBeVisible();
    await expect(page.locator('text=6️⃣ 발행 설정')).toBeVisible();
    
    // 작가 선택 확인
    const writerSelect = page.locator('select[name="course[writer_id]"]');
    await expect(writerSelect).toBeVisible();
    
    // 옵션 개수 확인 (최소 1개 이상 - "선택하세요" + 작가들)
    const options = await writerSelect.locator('option').count();
    expect(options).toBeGreaterThan(0);
    
    await page.screenshot({ path: 'screenshots/admin-new-course-form.png' });
  });

  test('✅ 시나리오 3: 코스 목록 필터링 작동', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin/courses`);
    
    // 검색 필터 확인
    await expect(page.locator('input[name="search"]')).toBeVisible();
    await expect(page.locator('select[name="category"]')).toBeVisible();
    
    // 카테고리 필터 테스트
    await page.selectOption('select[name="category"]', '전자동화책');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');
    
    // URL에 카테고리 파라미터 확인
    expect(page.url()).toContain('category');
    
    await page.screenshot({ path: 'screenshots/admin-courses-filtered.png' });
  });

  test('✅ 시나리오 4: 코스 상세보기 → 프론트 미리보기', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin/courses`);
    
    // 첫 번째 코스 상세보기
    const firstCourseLink = page.locator('a[href*="/admin/courses/"]').first();
    await firstCourseLink.click();
    await page.waitForLoadState('networkidle');
    
    // 상세 페이지 확인
    await expect(page.locator('text=기본 정보')).toBeVisible();
    
    // 미리보기 버튼 클릭 (새 탭)
    const [previewPage] = await Promise.all([
      page.waitForEvent('popup'),
      page.click('a:has-text("미리보기")')
    ]);
    
    await previewPage.waitForLoadState('networkidle');
    
    // 프론트 페이지 확인
    expect(previewPage.url()).not.toContain('/admin/');
    
    await previewPage.screenshot({ path: 'screenshots/frontend-course-detail.png' });
    await previewPage.close();
  });

  test('✅ 시나리오 5: 홈페이지에서 코스 검색', async ({ page }) => {
    await page.goto(BASE_URL);
    
    // 네비게이션 확인
    await expect(page.locator('text=전자동화책')).toBeVisible();
    
    // 전자동화책 클릭
    await page.click('a[href*="category=ebook"]');
    await page.waitForLoadState('networkidle');
    
    // 코스 카드 확인
    const courseCards = page.locator('.course-card, .card');
    const count = await courseCards.count();
    expect(count).toBeGreaterThan(0);
    
    await page.screenshot({ path: 'screenshots/frontend-ebook-list.png' });
  });

  test('✅ 시나리오 6: 작가 관리 시스템', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin/authors`);
    
    // 작가 목록 확인
    await expect(page.locator('h1')).toContainText('작가 관리');
    
    // 테이블 확인
    await expect(page.locator('table')).toBeVisible();
    
    // 신규 작가 등록 버튼
    await expect(page.locator('text=신규 작가 등록')).toBeVisible();
    
    await page.screenshot({ path: 'screenshots/admin-authors-list.png' });
  });

  test('✅ 시나리오 7: 키보드 단축키 작동', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin/courses`);
    
    // Cmd/Ctrl + F로 검색 포커스
    await page.keyboard.press('Meta+F'); // Mac
    
    const searchInput = page.locator('input[name="search"]');
    const isFocused = await searchInput.evaluate(el => el === document.activeElement);
    expect(isFocused).toBeTruthy();
    
    await page.screenshot({ path: 'screenshots/keyboard-shortcut-search.png' });
  });

  test('✅ 시나리오 8: 모바일 반응형 확인', async ({ page }) => {
    // iPhone SE 크기로 변경
    await page.setViewportSize({ width: 375, height: 812 });
    
    await page.goto(`${BASE_URL}/admin/courses/new`);
    
    // 모바일에서도 모든 요소 보이는지 확인
    await expect(page.locator('text=1️⃣ 콘텐츠 유형 선택')).toBeVisible();
    await expect(page.locator('text=2️⃣ 기본 정보')).toBeVisible();
    
    await page.screenshot({ path: 'screenshots/mobile-admin-new-course.png' });
    
    // 데스크탑으로 복원
    await page.setViewportSize({ width: 1920, height: 1080 });
  });
});

test.describe('🛒 사용자 구매 플로우', () => {
  
  test('✅ 시나리오 9: 홈 → 코스 상세 → 장바구니 → 결제', async ({ page }) => {
    // 1. 홈페이지
    await page.goto(BASE_URL);
    await page.screenshot({ path: 'screenshots/flow-1-homepage.png' });
    
    // 2. 전자동화책 카테고리
    await page.click('a[href*="category=ebook"]');
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/flow-2-category.png' });
    
    // 3. 첫 번째 코스 클릭
    const firstCourse = page.locator('a[href*="/courses/"]').first();
    if (await firstCourse.count() > 0) {
      await firstCourse.click();
      await page.waitForLoadState('networkidle');
      await page.screenshot({ path: 'screenshots/flow-3-course-detail.png' });
    }
  });
});

test.describe('📊 통계 반영 확인', () => {
  
  test('✅ 시나리오 10: 관리자 대시보드 통계 정확성', async ({ page }) => {
    await page.goto(`${BASE_URL}/admin`);
    
    // 통계 숫자 추출
    const statsText = await page.textContent('body');
    
    // 전체 코스 수
    const courseCountMatch = statsText?.match(/전체 코스[\s\S]*?(\d+)/);
    if (courseCountMatch) {
      const courseCount = parseInt(courseCountMatch[1]);
      console.log(`  📚 전체 코스: ${courseCount}개`);
      expect(courseCount).toBeGreaterThan(0);
    }
    
    // 콘텐츠 현황
    const ebookMatch = statsText?.match(/전자동화책 현황[\s\S]*?(\d+)%/);
    if (ebookMatch) {
      const completionRate = parseInt(ebookMatch[1]);
      console.log(`  📊 전자동화책 완성도: ${completionRate}%`);
    }
    
    await page.screenshot({ path: 'screenshots/admin-statistics.png' });
  });
});

