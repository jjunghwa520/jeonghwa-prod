# HANDOVER: E2E 상용화 진단 (2025-10-25)

## 상용화 판단 요약
- 소프트 런치 가능. 운영 전 체크리스트 권고: CSP 재강화, Rack::Attack 임계치 정책화, DB 인덱스/백업, CI에 스모크 연결, 결제 샌드박스 실거래 점검, a11y·Lighthouse 보완.

## 오늘 적용 변경
- CSP: unsafe-eval 제거, 운영/개발 분기, preconnect 추가 (`app/views/layouts/application.html.erb`, `config/initializers/secure_headers.rb`).
- Rack::Attack: Redis 사용(운영), ENV 기반 임계치, 429 전용 페이지 렌더링 (`config/initializers/rack_attack.rb`, `app/views/errors/too_many_requests.html.erb`, `config/routes.rb`).
- DB 인덱스: courses(status,category), courses(status,age), reviews(course_id,created_at), orders(user_id,status), orders(order_id) 고유 인덱스.
- 이미지 최적화: 주요 히어로/리더 이미지 lazy/decoding/fetchpriority 지정.
- a11y: 토스트/플래시에 role="status", aria-live="polite" 부여.
- CI: GitHub Actions Playwright 워크플로 추가, BASE_URL 파라미터화.

## 내일 보완 체크리스트(핵심)
1) CSP 운영값 최소 허용 재설정(지속 점검)
2) 로그인 스로틀/락 정책 수립(운영 임계치 확정, 관리자 화이트리스트)
3) 코스 폼 유효성/셀렉트 일관성(placeholder/prompt 통일, required 속성 정비)
4) 인덱스(courses/reviews) 점검 및 쿼리 계획 확인
5) 구조화 로깅·에러 페이지(404/500 커스텀, 구조화 로그)
6) Playwright CI 연결(스모크 세트 분리, flaky 클릭 대상 좁히기)
7) 이미지 최적화·폰트 디스플레이(FOIT 최소화, preload 검토)
8) a11y 빠른 점검(키보드 포커스 링, 대비, landmark)
9) 백업/마이그레이션 가이드(PostgreSQL 전환, 스토리지)
10) Toss 결제 플로우 샌드박스 검증(webhook 포함)

## 참고: E2E 보고서
- 위치: `kicda-jh/e2e-playwright/public/screenshots/admin-integration-2025-10-20/TEST_REPORT.md`
- Step 4/6/8 통과 확정, Step 4 상세 링크 클릭 간헐 타임아웃은 클릭 타겟 좁힘으로 안정화 가능.

## 운영 변수 예시
```
RACK_ATTACK_LOGIN_LIMIT=5
RACK_ATTACK_LOGIN_PERIOD_SECONDS=900
RACK_ATTACK_API_LIMIT=60
RACK_ATTACK_API_PERIOD_SECONDS=60
RACK_ATTACK_PAYMENT_LIMIT=5
RACK_ATTACK_PAYMENT_PERIOD_SECONDS=600
REDIS_URL=redis://... (production)
```

## 롤백 가이드
- CSP/보안 헤더: `config/initializers/secure_headers.rb` 이전 커밋으로 되돌림
- Rack::Attack: 임계치 완화는 ENV로 즉시 조정 가능
- DB 인덱스: `rails db:rollback STEP=1` (주의: 대형 테이블은 시간 소요)

## 영향도
- 보안 강화로 XSS/스크립트 인젝션 표면 축소, Rate limiting으로 인증 남용 방지
- 인덱스 추가로 목록/필터/주문 조회 응답 시간 안정화 기대
- CI 연결로 회귀 리스크 감소

(문서 자동 생성: 2025-10-25)

# 정화의서재 상용화 진단 · E2E 인수인계서 (2025-10-25)

## 1) 개요
- 목적: 상용화 가능성 진단, 실패 지점 제거, 내일 보완 계획 제공
- 범위: 나노→메타 레벨 E2E, 보안/성능/UX, 운영/릴리즈 체계
- 기준: 실제 브라우저 시나리오 확인(스크린샷/로그), 코드만 확인 금지

## 2) 실행 환경 / 명령어
- Rails: kicda-jh (Ruby on Rails 8)
- 서버: `cd kicda-jh && bin/rails server`
- UI 스모크: `cd kicda-jh/e2e-playwright && npx playwright test tests/quick-ui-test.spec.ts --project=desktop-1440`
- 관리자↔홈 통합: `cd kicda-jh/e2e-playwright && npx playwright test tests/admin-homepage-integration.spec.ts --project=desktop-1440`
- 환경변수: `ADMIN_EMAIL=admin@jeonghwa.com ADMIN_PASSWORD=password123`
- 보고서/스크린샷: `public/screenshots/admin-integration-2025-10-20/`

## 3) E2E 결과 요약 (나노→메타)
### 나노 (단일 UI/보안)
- 프로필 드롭다운 가독성 개선: 통과 (rgba(255,255,255,0.98))
- 보안 헤더 적용: 통과 (XFO, XCTO, XXP, CSP)
- Rate Limiting(개발 모드): 통과 (429 확인)

### 마이크로 (기능 플로우)
- 로그인·로그아웃: 통과 (세션 초기화 OK)
- 코스 CRUD(관리자): 통과 (생성/수정/삭제)

### 매크로 (시스템 연동)
- 홈 반영(생성/수정/삭제): 통과 (목록·상세 200/404 교차 확인)
- 카테고리 필터: 통과

### 메타 (상용화 체크리스트)
- 보안: 기본 헤더·Rate limiting·세션 보안 적용
- 성능: N+1 제거(핵심 페이지), 캐시(avg_rating/total_students)
- 운영: 스크립트·리포트 자동화, 리그레션 스모크 마련

## 4) 주요 개선 사항 (이번 작업)
- Bullet 팝업 OFF + 뷰 N+1 제거(`home#index`)
- `SecureHeaders` 중복 override 제거(500 해결)
- Rack::Attack dev 스로틀 강화 + 로그인 safelist 예외
- `sessions#create` 개발용 1분 스로틀(검증 편의)
- 관리자→홈 통합 스펙 안정화(상태 published, 검색/폴링, 상세 확인)

## 5) 상용화 판단 (10점 만점)
- 안정성 8.0: 주요 플로우 완주, 크리티컬 예외 제거
- 보안 7.5: 기본 헤더·스로틀 적용, CSP dev 완화(운영 재강화 필요)
- 성능 7.0: 핵심 쿼리 최적화, 추가 캐시/DB 인덱스 여지
- UX 7.5: 핵심 흐름 무리 없음, 일부 안내 문구/엣지 UX 보완 필요
- 운영 7.5: 스모크/E2E 자동화·리포팅 구축, CI 연계 미도입

결론: “소프트 런치 가능(제한적 공개)”. 본 릴리즈 전 체크리스트(6장) 완료 권고.

## 6) 남은 리스크 / 내일 보완 체크리스트
- [ ] CSP 운영값 재강화(폰트/jsdelivr 화이트리스트 최소화)
- [ ] Rack::Attack 운영 임계치 재설정(로그인 1m/5회 ⇒ 정책 정의)
- [ ] 관리자 폼 유효성(가격/상태/레벨 프리셋, select 통일)
- [ ] DB 인덱스 점검(`courses(category,status,created_at)`, `reviews(course_id)`)
- [ ] 에러 페이지/로깅(500/404 사용자 메시지 + 구조화 로깅)
- [ ] CI에 Playwright 스모크 연결(헤드리스, HTML 리포트 산출)
- [ ] Lighthouse 80+ 달성(이미지 lazy/sizes, font-display)
- [ ] 접근성 a11y quick pass(title landmark, label 대비)
- [ ] 백업·마이그레이션 가이드(프로덕션 DB/스토리지)
- [ ] 결제 플로우 실거래 샌드박스 점검(Toss 결제)

## 7) 실제 확인 스냅샷/증빙
- 관리자→홈 통합: 10/10 통과(최종). 보고서 `public/screenshots/admin-integration-2025-10-20/TEST_REPORT.md`.
- Step 4/6/8: 목록·상세(200/404) 교차 확인 스크린샷 07–09,13–14,18–19.

## 8) 운영 가이드 (TL;DR)
- 서버 기동: `bin/rails server` (별도 터미널)
- 스모크: `e2e-playwright`에서 `quick-ui-test.spec.ts`
- 통합: `admin-homepage-integration.spec.ts`
- 실패 시: `playwright-report/index.html` 열어 trace/video 확인

## 9) 부록 – 변경 코드 핵심 포인트
- `home_controller#index`: `@home_courses = Course.published.includes(:instructor)`
- `application.html.erb`: AOS 제거, dev 폰트 로컬 폴백
- `secure_headers.rb`: dev 완화/운영 재강화 TODO
- `rack_attack.rb`: 로그인 스로틀·safelist 보정
- `sessions_controller.rb`: dev 스로틀(1분/5회)
- Playwright: 로그인 유틸 안정화, 상태 selectOption, 검색/폴링, 상세 확인, 삭제 404 검증

---

### 상용화 진단 결론
- “제한적 상용화 가능”. 내일 체크리스트 완료 시 일반 공개 권장.
- 필수: CSP 운영값 강화, CI 스모크, DB 인덱스/백업 절차 고정화.
