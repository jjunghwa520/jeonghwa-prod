# 🧪 E2E 테스트 시나리오 완전 가이드

**작성일**: 2025-10-24  
**목적**: 나노→메타 레벨 체계적 테스트  
**상용화 필수 검증 항목**

---

## 📊 테스트 레벨 구조

```
메타 레벨 (System Integration)
    ↑
매크로 레벨 (User Scenarios)
    ↑
마이크로 레벨 (Page Functions)
    ↑
나노 레벨 (Components)
```

---

## 🔬 Level 1: 나노 레벨 (Component Testing)

### 목적
개별 컴포넌트가 독립적으로 정상 작동하는지 검증

### 테스트 항목 (30개)

#### A. 네비게이션 컴포넌트 (5개)

**1. 로고 클릭 → 홈 이동**
```javascript
await page.click('.navbar-brand');
expect(page.url()).toContain('/');
```

**2. 드롭다운 메뉴 표시**
```javascript
await page.click('.dropdown-toggle');
await expect(page.locator('.dropdown-menu')).toBeVisible();
```

**3. 드롭다운 항목 클릭**
```javascript
await page.click('.dropdown-item:has-text("로그아웃")');
expect(page.url()).toContain('/');
```

**4. 모바일 햄버거 메뉴**
```javascript
await page.setViewportSize({ width: 390, height: 844 });
await page.click('.navbar-toggler');
await expect(page.locator('.navbar-collapse')).toBeVisible();
```

**5. 카테고리 링크 작동**
```javascript
await page.click('a:has-text("전자동화책")');
expect(page.url()).toContain('category=ebook');
```

#### B. 카드 컴포넌트 (5개)

**6. 코스 카드 호버 효과**
```javascript
await page.hover('.course-card:first-child');
const transform = await page.$eval('.course-card:first-child', 
  el => getComputedStyle(el).transform);
expect(transform).not.toBe('none');
```

**7. 썸네일 이미지 로드**
```javascript
const img = page.locator('.course-thumbnail img').first();
await expect(img).toBeVisible();
const src = await img.getAttribute('src');
expect(src).toBeTruthy();
```

**8. 가격 표시**
```javascript
const price = await page.locator('.course-price').first().textContent();
expect(price).toMatch(/₩[\d,]+/);
```

**9. 평점 표시**
```javascript
const rating = page.locator('.rating').first();
await expect(rating).toBeVisible();
```

**10. 카드 클릭 → 상세 페이지**
```javascript
const courseId = await page.locator('.course-card').first()
  .getAttribute('data-course-id');
await page.click('.course-card:first-child');
expect(page.url()).toContain(`/courses/${courseId}`);
```

#### C. 폼 컴포넌트 (5개)

**11. 검색 입력**
```javascript
await page.fill('input[type="search"]', '토끼');
await page.press('input[type="search"]', 'Enter');
expect(page.url()).toContain('q=토끼');
```

**12. 카테고리 선택**
```javascript
await page.selectOption('select[name="category"]', 'ebook');
const selected = await page.$eval('select[name="category"]', 
  el => el.value);
expect(selected).toBe('ebook');
```

**13. 폼 검증 (필수 필드)**
```javascript
await page.click('button[type="submit"]');
const error = await page.locator('.invalid-feedback').first();
await expect(error).toBeVisible();
```

**14. 파일 선택**
```javascript
await page.setInputFiles('input[type="file"]', 'test.jpg');
const filename = await page.locator('.file-name').textContent();
expect(filename).toContain('test.jpg');
```

**15. 체크박스/라디오 토글**
```javascript
await page.check('input[type="checkbox"]');
const checked = await page.isChecked('input[type="checkbox"]');
expect(checked).toBe(true);
```

#### D. 리더 컴포넌트 (5개)

**16. 페이지 넘김 (다음)**
```javascript
const initialPage = await page.locator('#currentPageNum').textContent();
await page.click('#nextPageBtn');
await page.waitForTimeout(500);
const newPage = await page.locator('#currentPageNum').textContent();
expect(Number(newPage)).toBe(Number(initialPage) + 1);
```

**17. 페이지 넘김 (이전)**
```javascript
await page.click('#nextPageBtn'); // 2페이지로
await page.click('#prevPageBtn'); // 1페이지로
const page1 = await page.locator('#currentPageNum').textContent();
expect(page1).toBe('1');
```

**18. TTS 버튼 토글**
```javascript
await page.click('#toggleTtsBtn');
const ttsActive = await page.$eval('#toggleTtsBtn', 
  el => el.classList.contains('active'));
expect(ttsActive).toBe(true);
```

**19. 진행률 저장**
```javascript
await page.click('#nextPageBtn');
const courseId = await page.getAttribute('[data-course-id]', 'data-course-id');
const saved = await page.evaluate((id) => {
  return localStorage.getItem(`reader:${id}:page`);
}, courseId);
expect(saved).toBe('2');
```

**20. 페이지 복원**
```javascript
await page.reload();
await page.waitForLoadState('networkidle');
const restored = await page.locator('#currentPageNum').textContent();
expect(restored).toBe('2'); // 이전 위치 복원
```

#### E. 플레이어 컴포넌트 (5개)

**21. 재생/일시정지**
```javascript
await page.click('#playPauseBtn');
await page.waitForTimeout(1000);
const playing = await page.$eval('video', v => !v.paused);
expect(playing).toBe(true);
```

**22. 볼륨 조절**
```javascript
await page.fill('#volumeSlider', '50');
const volume = await page.$eval('video', v => v.volume);
expect(volume).toBeCloseTo(0.5, 1);
```

**23. 재생 속도 변경**
```javascript
await page.selectOption('#speedSelect', '1.5');
const speed = await page.$eval('video', v => v.playbackRate);
expect(speed).toBe(1.5);
```

**24. 탐색 바 클릭**
```javascript
await page.click('.progress-bar', { position: { x: 100, y: 10 } });
const time = await page.$eval('video', v => v.currentTime);
expect(time).toBeGreaterThan(0);
```

**25. 전체화면 토글**
```javascript
await page.click('#fullscreenBtn');
const isFullscreen = await page.evaluate(() => !!document.fullscreenElement);
expect(isFullscreen).toBe(true);
```

#### F. 장바구니 컴포넌트 (5개)

**26. 장바구니 추가**
```javascript
await page.click('.add-to-cart-btn');
const count = await page.locator('.cart-count').textContent();
expect(Number(count)).toBeGreaterThan(0);
```

**27. 장바구니 항목 제거**
```javascript
await page.click('.remove-cart-item');
await page.waitForResponse(response => response.status() === 200);
```

**28. 장바구니 전체 삭제**
```javascript
await page.click('.clear-cart-btn');
await page.click('.confirm-btn'); // 확인 다이얼로그
const count = await page.locator('.cart-count').textContent();
expect(count).toBe('0');
```

**29. 가격 합계 계산**
```javascript
const total = await page.locator('.cart-total').textContent();
expect(total).toMatch(/₩[\d,]+/);
```

**30. 전체 수강신청**
```javascript
await page.click('.enroll-all-btn');
await expect(page.locator('.success-message')).toBeVisible();
```

---

## 📄 Level 2: 마이크로 레벨 (Page Testing)

### 목적
각 페이지의 핵심 기능이 정상 작동하는지 검증

### 테스트 항목 (20개 페이지 × 3-5개 = 60-100개)

#### A. 공개 페이지

**1. 홈페이지** (`/`)
```javascript
✅ 히어로 섹션 표시
✅ 카테고리 카드 표시
✅ 인기 코스 표시
✅ 푸터 링크 작동
✅ 반응형 레이아웃
```

**2. 코스 목록** (`/courses`)
```javascript
✅ 코스 카드 그리드 표시
✅ 카테고리 필터 작동
✅ 연령 필터 작동
✅ 검색 기능
✅ 페이지네이션
```

**3. 코스 상세** (`/courses/:id`)
```javascript
✅ 코스 정보 표시
✅ 강사 정보
✅ 리뷰 목록
✅ 장바구니 버튼
✅ 수강하기 버튼
✅ 미리보기 버튼 (로그인 불필요)
```

**4. 리더** (`/courses/:id/read`)
```javascript
✅ 페이지 이미지 로드
✅ 캡션 텍스트 표시
✅ 페이지 네비게이션
✅ TTS 기능
✅ 진행률 저장
✅ 북마크 복원
✅ 10% 게이트 (비회원)
```

**5. 플레이어** (`/courses/:id/watch`)
```javascript
✅ 비디오 로드 (MP4/HLS)
✅ 자막 표시
✅ 플레이어 컨트롤
✅ 이어보기
✅ 10% 게이트 (비회원)
```

**6. 로그인** (`/login`)
```javascript
✅ 폼 표시
✅ 이메일 검증
✅ 비밀번호 검증
✅ 로그인 성공 → 홈 리다이렉트
✅ 로그인 실패 → 에러 메시지
```

**7. 회원가입** (`/signup`)
```javascript
✅ 폼 표시
✅ 이메일 중복 체크
✅ 비밀번호 확인 검증
✅ 회원가입 성공 → 자동 로그인
✅ 검증 실패 → 에러 표시
```

#### B. 인증 필요 페이지

**8. 사용자 대시보드** (`/users/:id/dashboard`)
```javascript
✅ 수강 중인 강의 표시
✅ 최근 리뷰 표시
✅ 학습 통계
✅ 본인만 접근 가능
```

**9. 장바구니** (`/cart_items`)
```javascript
✅ 장바구니 항목 표시
✅ 항목 삭제
✅ 전체 삭제
✅ 가격 합계
✅ 전체 수강신청
```

**10. 결제** (`/payments/:course_id/checkout`)
```javascript
✅ 주문 정보 표시
✅ 토스페이먼츠 위젯 로드
⚠️ 실제 결제 (샌드박스)
⚠️ 결제 승인 콜백
⚠️ 자동 수강 등록
```

#### C. 관리자 페이지

**11. 관리자 대시보드** (`/admin`)
```javascript
✅ 통계 카드 (코스/회원/수강/리뷰)
✅ 카테고리별 현황
✅ 인기 코스 Top 5
✅ 최근 활동
```

**12. 코스 관리** (`/admin/courses`)
```javascript
✅ 코스 목록 표시
✅ 검색 기능
✅ 페이지네이션
✅ 신규 등록 버튼
```

**13. 코스 생성** (`/admin/courses/new`)
```javascript
✅ 폼 표시
✅ 카테고리 선택
✅ 파일 업로드 (드래그앤드롭)
✅ 썸네일 옵션
✅ 발행 상태 선택
✅ 저장 → 상세 페이지
```

**14. 코스 수정** (`/admin/courses/:id/edit`)
```javascript
✅ 기존 값 로드
✅ 필드 수정
✅ 파일 추가/삭제
✅ 저장 → 상세 페이지
```

**15. AI 콘텐츠 생성** (`/admin/content_generator`)
```javascript
✅ 프롬프트 입력
✅ 프리뷰
✅ 생성 시작
✅ 진행 상태 확인
⚠️ 완료 후 이미지 표시
```

**16. 작가 관리** (`/admin/authors`)
```javascript
✅ 작가 목록
✅ 신규 등록
✅ 수정
✅ 삭제 (연결된 코스 확인)
```

**17. 리뷰 관리** (`/admin/reviews`)
```javascript
✅ 리뷰 목록
✅ 활성화/비활성화 토글
✅ 삭제
```

**18. 사용자 관리** (`/admin/users`)
```javascript
✅ 사용자 목록
✅ 검색
✅ 권한 변경
```

**19. 파일 업로드** (`/admin/uploads/new`)
```javascript
✅ 코스 선택
✅ 파일 유형 선택
✅ 다중 파일 업로드
✅ 진행률 표시
```

**20. 리뷰 작성** (코스 상세 페이지)
```javascript
✅ 별점 선택
✅ 내용 입력
✅ 제출
✅ 즉시 표시
```

---

## 📱 Level 2: 마이크로 레벨 (Page Testing)

### 목적
페이지 전체의 비즈니스 로직이 정상 작동하는지 검증

### 주요 시나리오 (15개)

#### 1. 회원가입 플로우
```
단계:
1. /signup 접속
2. 이메일 입력 (unique 검증)
3. 비밀번호 입력 (8자 이상)
4. 비밀번호 확인
5. 이름 입력
6. 제출
7. 자동 로그인 확인
8. 홈 리다이렉트

검증:
✅ User.count 증가
✅ 세션 생성
✅ 플래시 메시지
```

#### 2. 로그인 플로우
```
단계:
1. /login 접속
2. 이메일 입력
3. 비밀번호 입력
4. 제출
5. 홈 리다이렉트

검증:
✅ 세션 생성
✅ 환영 메시지
✅ 네비게이션 변경 (로그아웃 버튼 표시)
```

#### 3. 코스 검색 플로우
```
단계:
1. /courses 접속
2. 검색어 입력 ("토끼")
3. Enter
4. 결과 확인

검증:
✅ URL 쿼리 파라미터
✅ 필터링된 결과
✅ 결과 수 표시
```

#### 4. 코스 수강 등록 플로우
```
단계:
1. 로그인
2. 코스 상세 페이지
3. "바로 수강하기" 클릭
4. 대시보드로 이동

검증:
✅ Enrollment 생성
✅ 수강 중인 강의에 표시
✅ 중복 등록 방지
```

#### 5. 리뷰 작성 플로우
```
단계:
1. 수강 등록된 코스 접속
2. 별점 선택
3. 내용 입력
4. 제출

검증:
✅ Review 생성
✅ 평균 평점 업데이트
✅ 코스 상세에 즉시 표시
```

#### 6. 장바구니 플로우
```
단계:
1. 코스 상세 → 장바구니 추가
2. /cart_items 확인
3. 항목 제거
4. 다시 추가
5. 전체 수강신청

검증:
✅ CartItem 생성/삭제
✅ 수량 표시
✅ 가격 합계
✅ 중복 방지
```

#### 7. 관리자 코스 생성 플로우
```
단계:
1. /admin 로그인
2. "신규 콘텐츠 등록"
3. 폼 작성
4. 파일 업로드
5. 발행

검증:
✅ Course 생성
✅ 파일 저장
✅ 썸네일 생성 (AI)
✅ 홈페이지 즉시 반영
```

#### 8. 관리자 코스 수정 플로우
```
단계:
1. 코스 목록 → 수정
2. 제목/가격 변경
3. 저장

검증:
✅ Course 업데이트
✅ 홈페이지 즉시 반영
✅ 수정 시간 업데이트
```

#### 9. 관리자 코스 삭제 플로우
```
단계:
1. 코스 상세 → 삭제
2. 확인
3. 홈페이지 확인

검증:
✅ Course 삭제 (또는 archived)
✅ 홈페이지에서 제거
✅ 연결된 Enrollment 처리
```

#### 10. 작가 할당 플로우
```
단계:
1. 작가 생성
2. 코스 수정
3. 작가 선택
4. 저장

검증:
✅ CourseAuthor 생성
✅ 코스 상세에 표시
```

#### 11. 리뷰 관리 플로우
```
단계:
1. /admin/reviews
2. 활성화 토글
3. 삭제

검증:
✅ 상태 변경
✅ 홈페이지 반영
```

#### 12. 사용자 권한 변경 플로우
```
단계:
1. /admin/users
2. 사용자 선택
3. 권한 변경 (student → instructor)
4. 저장

검증:
✅ User.role 업데이트
✅ 권한별 기능 접근 변경
```

#### 13. 결제 플로우 (중요!)
```
단계:
1. 로그인
2. 유료 코스 선택
3. "바로 수강하기"
4. 결제 페이지
5. 토스페이먼츠 위젯
6. 결제 승인
7. 자동 수강 등록
8. 코스 페이지 리다이렉트

검증:
⚠️ Order 생성 (pending)
⚠️ 토스 API 호출
⚠️ Order 상태 (completed)
⚠️ Enrollment 생성
⚠️ 이메일 발송 (미구현)
```

#### 14. 환불 플로우
```
단계:
1. 주문 내역
2. 환불 요청
3. 사유 입력
4. 확인

검증:
⚠️ 토스 환불 API
⚠️ Order 상태 (refunded)
⚠️ Enrollment 삭제
⚠️ 이메일 발송 (미구현)
```

#### 15. 비회원 제한 플로우
```
단계:
1. 로그아웃
2. 유료 코스 리더/플레이어
3. 10% 이상 접근 시도

검증:
✅ 10% 게이트 작동
✅ 로그인 유도
✅ 무료 코스는 전체 접근
```

---

## 👥 Level 3: 매크로 레벨 (User Scenario Testing)

### 목적
실제 사용자의 전체 여정이 매끄러운지 검증

### 시나리오 (10개)

#### 시나리오 1: 신규 학부모 - 전자책 구매
```
[배경] 5세 자녀를 둔 학부모가 처음 방문

1. 홈페이지 접속
2. "전자동화책" 카테고리 클릭
3. "유아 (3-5세)" 필터 적용
4. 마음에 드는 동화책 클릭
5. 미리보기 (10%) 시청
6. 회원가입
7. 로그인
8. 장바구니 담기
9. 다른 책도 2-3개 추가
10. 전체 수강신청 (무료 또는 결제)
11. 전자책 읽기
12. 리뷰 작성

예상 소요 시간: 10-15분
검증 포인트: 
✅ 전체 플로우 단절 없음
✅ 에러 메시지 사용자 친화적
✅ 학습 시작까지 3클릭 이내
```

#### 시나리오 2: 재방문 사용자 - 이어보기
```
[배경] 어제 절반까지 본 동화 이어보기

1. 로그인
2. 대시보드 → "수강 중인 강의"
3. 이어볼 코스 클릭
4. 자동으로 이전 위치에서 시작
5. 완료
6. 리뷰 작성

예상 소요 시간: 5분
검증 포인트:
✅ 북마크 정확히 복원
✅ 진행률 표시
✅ 완료 시 표시 변경
```

#### 시나리오 3: 관리자 - 신규 콘텐츠 등록
```
[배경] 새로운 동화책 출시

1. 관리자 로그인
2. "신규 콘텐츠 등록"
3. 제목/설명 입력
4. 카테고리 선택
5. 페이지 이미지 업로드 (10장)
6. 캡션 파일 업로드 (10개)
7. AI 썸네일 생성 선택
8. 발행
9. 홈페이지 확인 → 즉시 표시
10. 실제 사용자 계정으로 확인

예상 소요 시간: 10분
검증 포인트:
✅ 파일 업로드 안정성
✅ AI 썸네일 생성 성공
✅ 실시간 반영
```

#### 시나리오 4: 모바일 사용자
```
[배경] 스마트폰으로 동화책 읽기

1. 모바일 브라우저 접속
2. 로그인
3. 코스 선택
4. 리더 실행
5. 스와이프로 페이지 넘김
6. 세로/가로 회전
7. 북마크 저장

예상 소요 시간: 5분
검증 포인트:
✅ 반응형 레이아웃
✅ 터치 제스처
✅ 오버플로우 없음
✅ 회전 대응
```

#### 시나리오 5: 청소년 사용자
```
[배경] 14세 청소년이 청소년 콘텐츠 탐색

1. "청소년 콘텐츠" 클릭
2. 전용 페이지 확인
3. 콘텐츠 선택
4. 학습 시작

검증 포인트:
✅ 연령별 콘텐츠 분리
✅ 적절한 UI/UX
```

#### 시나리오 6: 강사 - 내 강의 관리
```
[배경] 강사가 자신의 강의 통계 확인

1. 강사 계정 로그인
2. "내 강의" 메뉴
3. 수강생 목록
4. 리뷰 확인
5. 강의 수정

검증 포인트:
⚠️ 강사 전용 페이지 구현 확인
⚠️ 권한 분리
```

#### 시나리오 7: 에러 복구
```
[배경] 결제 중 네트워크 끊김

1. 결제 진행 중
2. 네트워크 연결 해제
3. 결제 실패
4. 재시도

검증 포인트:
⚠️ 에러 처리
⚠️ 주문 상태 관리
⚠️ 중복 결제 방지
```

#### 시나리오 8: 동시 접속
```
[배경] 100명이 동시에 접속

1. 부하 테스트 도구 사용
2. 동시 100 요청
3. 응답 시간 측정

검증 포인트:
⚠️ 응답 시간 < 3초
⚠️ 에러율 < 1%
⚠️ 데이터베이스 락 없음
```

#### 시나리오 9: 브라우저 호환성
```
[배경] 다양한 브라우저 테스트

1. Chrome
2. Safari
3. Firefox
4. Edge
5. 모바일 Safari
6. 모바일 Chrome

검증 포인트:
✅ 모든 브라우저 정상 렌더링
⚠️ HLS 지원 (Safari native, 기타 hls.js)
✅ CSS 호환성
```

#### 시나리오 10: 데이터 일관성
```
[배경] 관리자/사용자 동시 작업

1. 관리자: 코스 수정 (가격 변경)
2. 사용자: 동시에 장바구니 담기
3. 사용자: 결제 시도

검증 포인트:
✅ 가격 일관성
✅ 트랜잭션 안전성
⚠️ 낙관적 잠금 또는 비관적 잠금
```

---

## 🌐 Level 4: 메타 레벨 (System Integration Testing)

### 목적
전체 시스템이 하나의 유기체처럼 작동하는지 검증

### 통합 테스트 (5개)

#### 1. 풀 스택 통합 테스트
```
시나리오:
신규 사용자 → 회원가입 → 
코스 탐색 → 결제 → 
학습 → 리뷰 작성 → 
관리자 확인 → 통계 반영

검증:
✅ DB 트랜잭션 일관성
✅ 세션 관리
✅ 파일 시스템 동기화
✅ 캐시 무효화
⚠️ 이메일 발송 (미구현)
```

#### 2. 멀티 사용자 동시성 테스트
```
시나리오:
100명 사용자가 동시에:
- 로그인
- 코스 검색
- 수강 등록
- 리뷰 작성

검증:
⚠️ 데드락 없음
⚠️ Race condition 없음
⚠️ 데이터 무결성
```

#### 3. 장기 실행 안정성 테스트
```
시나리오:
24시간 연속 운영:
- 주기적 요청
- 메모리 누수 모니터링
- 응답 시간 추적

검증:
⚠️ 메모리 안정성
⚠️ 성능 저하 없음
⚠️ 에러율 < 0.1%
```

#### 4. 재해 복구 테스트
```
시나리오:
1. 정상 운영 중
2. 서버 강제 종료
3. 재시작
4. 데이터 무결성 확인

검증:
⚠️ 데이터 손실 없음
⚠️ 진행 중 작업 복구
⚠️ 세션 복원 (선택)
```

#### 5. 외부 서비스 장애 대응
```
시나리오:
1. Vertex AI API 다운
2. 썸네일 생성 실패
3. 재시도 메커니즘
4. 폴백 이미지 사용

검증:
✅ 에러 처리
✅ 재시도 로직
⚠️ 알림 발송
```

---

## 📊 테스트 실행 가이드

### Playwright 전체 실행
```bash
cd e2e-playwright

# 모든 테스트
npm test

# 특정 프로젝트
npm test -- --project=desktop-1440

# 특정 파일
npm test reader.spec.ts

# UI 모드
npm test -- --ui

# 디버그 모드
npm test -- --debug
```

### 수동 테스트 체크리스트
```bash
# 1. 서버 시작
rails server

# 2. 브라우저 열기
open http://localhost:3000

# 3. 시나리오 1-10 순차 실행

# 4. 결과 기록
# - 스크린샷
# - 에러 메시지
# - 소요 시간
```

---

## 🎯 테스트 커버리지 목표

### 현재 상태
```
E2E Tests: 84개 작성, 5개 통과 (6%)
Unit Tests: ~0개
Integration Tests: 수동만
```

### 목표 (2주 후)
```
E2E Tests: 120개 작성, 100개 통과 (83%)
Unit Tests: 50개 (모델/서비스)
Integration Tests: 30개 (컨트롤러)
```

### 최종 목표 (상용화 시)
```
E2E Tests: 200개, 95%+ 통과
Unit Tests: 100개, 90%+ 커버리지
Integration Tests: 80개
성능 Tests: 10개
보안 Tests: 20개
```

---

## 📋 테스트 자동화

### CI/CD 파이프라인 (권장)

```yaml
# .github/workflows/test.yml

name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2.2
          bundler-cache: true
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 20
      
      - name: Install dependencies
        run: |
          bundle install
          cd e2e-playwright && npm install
      
      - name: Setup database
        run: |
          rails db:create
          rails db:migrate
          rails db:seed
      
      - name: Run unit tests
        run: rails test
      
      - name: Run E2E tests
        run: |
          rails server -d
          cd e2e-playwright && npm test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: e2e-playwright/playwright-report/
```

---

## 🔧 테스트 환경 설정

### 로컬 환경
```bash
# 1. PostgreSQL 실행
brew services start postgresql@16

# 2. 테스트 DB 준비
rails db:test:prepare

# 3. 서버 시작 (테스트용)
rails server -e test -p 3001

# 4. Playwright 실행
cd e2e-playwright
npm test
```

### Docker 환경
```bash
# docker-compose.test.yml
docker-compose -f docker-compose.test.yml up -d
docker-compose -f docker-compose.test.yml run web npm test
```

---

## 📈 테스트 결과 추적

### 대시보드 (권장)
- Playwright HTML Report
- Sentry Error Dashboard
- Custom Admin Dashboard

### 주간 리포트 템플릿
```markdown
## Week X Test Report

### 실행 요약
- 총 테스트: XXX개
- 통과: XXX개 (XX%)
- 실패: XX개
- 스킵: XX개

### 주요 발견
1. ...
2. ...

### 수정 사항
1. ...
2. ...

### 다음 주 목표
- ...
```

---

## 🎓 결론

### 테스트 전략 우선순위

**즉시 (이번 주)**:
1. ✅ Playwright fixture 수정
2. ✅ Critical 경로 E2E 완성
3. ✅ 수동 통합 테스트

**1주일 내**:
4. ⏳ 단위 테스트 50개 추가
5. ⏳ 컨트롤러 테스트 20개
6. ⏳ 결제 플로우 검증

**2주일 내**:
7. ⏳ 성능 테스트
8. ⏳ 보안 테스트
9. ⏳ 부하 테스트

**상용화 전**:
10. ⏳ 전체 시나리오 검증
11. ⏳ 브라우저 호환성
12. ⏳ 모바일 완전 테스트

---

**작성**: 2025-10-24  
**업데이트**: 테스트 진행 시 지속 업데이트  
**담당자**: 개발팀 전체



