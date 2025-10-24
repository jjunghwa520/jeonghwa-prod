# 2025-10-14 E2E 자동화 인수인계 (Reader/Player/Admin + Mobile Overflow)

## 개요
- 대상 서비스: 정화의서재 (Rails)
- 서버: `http://localhost:3000` (서버 재시작 금지)
- 코스 ID: `1001`
- 스택: Playwright + TypeScript (headless)
- 관리자 인증: ENV `ADMIN_EMAIL` / `ADMIN_PASSWORD` (미설정 시 관리자 시나리오 자동 skip)
- 산출물: `kicda-jh/public/screenshots/DATE-YYYYMMDD-HHmmss/`

## 폴더 구조
- `kicda-jh/e2e-playwright/`
  - `package.json`, `tsconfig.json`, `playwright.config.ts`, `.env.example`
  - `tests/reader.spec.ts` (리더 1440)
  - `tests/player.spec.ts` (플레이어 1440)
  - `tests/mobile.spec.ts` (모바일 390×844 + overflowX 진단)
  - `tests/admin.spec.ts` (관리자 리그레션; ENV 없으면 skip)
  - `tests/summary.spec.ts` (요약 리포트 생성)
  - `utils/{paths,errorCollector,storage,overflowInspector,adminLogin,summary}.ts`

## 실행 방법
1) 설치
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright
npm install
npx playwright install --with-deps
```

2) 데스크톱+모바일 실행 (관리자 제외)
```bash
BASE_URL=http://localhost:3000 COURSE_ID=1001 npx playwright test \
  --project=desktop-1440 --project=mobile-390
```

3) 관리자 포함 실행 (ENV 필요)
```bash
export ADMIN_EMAIL="<admin@example.com>" ADMIN_PASSWORD="<password>"
BASE_URL=http://localhost:3000 COURSE_ID=1001 npx playwright test
```

4) 장시간 안정성 시나리오(옵션)
```bash
LONG_RUN=1 npx playwright test --project=long-run
```

5) 리포트/트레이스 확인
```bash
npx playwright show-report
# 실패 케이스 트레이스 예시
npx playwright show-trace test-results/<실패케이스>/trace.zip
```

## 산출물
- 디렉토리: `kicda-jh/public/screenshots/DATE-YYYYMMDD-HHmmss/`
- 포함 파일:
  - `reader-desktop.png`, `player-desktop.png`
  - `reader-errors.json`, `player-errors.json`
  - `reader-mobile-overflow.json|.csv|.png`, `player-mobile-overflow.json|.csv|.png`
  - `summary.json`, `summary.md`

## 현재 상태 요약 (마지막 실행)
- 통과: 6, 스킵: 6, 실패: 4
- 실패 상세:
  - Player: `window.Hls` 감지 타임아웃 (5s). 환경에 따라 HLS가 `window`에 노출되지 않을 수 있음. blob 소스는 이후 단계에서 대기로 확인 가능.
  - Reader: `localStorage reader:1001:page` 키가 10s 내 생성되지 않음. 앱이 특정 상호작용 이후에만 저장할 가능성.

## 개선 제안 (다음 액션)
- Player HLS 확인 로직 완화:
  - `window.Hls` 강제 검증을 선택적(try)로 낮추고, 핵심 판정은 `video.currentSrc.startsWith('blob:')` + 네트워크에 `.m3u8` 요청 존재 여부로 대체.
- Reader 복원 검증 안정화:
  - 페이지 이동(다음/이전) 또는 썸네일 클릭 후 `reader:<id>:page` 키 생성까지 `waitForFunction` 대기.
  - 앱 이벤트가 있으면(`reader:pageSaved` 등) 해당 이벤트 대기로 전환.

## 모바일 overflowX 진단/가이드
- 재현: 390×844 진입 → 최하단까지 스크롤 → `documentElement.scrollWidth > clientWidth` 검사.
- 수집: 상위 10개 overflow 기여 요소를 JSON/CSV로 저장 (`reader-mobile-overflow.*`, `player-mobile-overflow.*`).
- 원인 체크리스트:
  - main/toolbar/thumbnail strip 너비 합 > viewport 여부
  - wrap/overflow 설정 및 gap/margin 계산
  - `width: 100vw` 사용 부위 → `width: 100%` 전환 필요 여부
- 수정 가이드(초안):
  - 썸네일 컨테이너: `box-sizing: border-box; overflow-x: hidden;`
  - 내부 아이템: `max-width: 100%; flex: 0 0 auto;`
  - 고정 상/하단 레이아웃: `100vw` 대신 `100%` 고려
- 검증: 리더 새로고침 후 `overflowX=false`, 320/375/390/414 뷰포트 교차 체크

## 관리자 시나리오
- ENV 없으면 자동 skip. 설정 시:
  - 업로드 생성 → 성공 확인 → 되돌림
  - 리뷰 active 토글/삭제(테스트 데이터)
  - 사용자 역할 토글 후 원복

## 주의사항
- Rails 서버 재시작 금지 (별도 터미널에서 실행 중 전제)
- 자동화는 산출물을 `public/screenshots/DATE-...`에만 저장

## 연락/승계
- 본 문서를 기준으로 새 채팅에서 계속 진행. 실패 트레이스(`show-trace`)를 우선 확인 후 테스트 로직을 환경 친화적으로 보정하세요.


