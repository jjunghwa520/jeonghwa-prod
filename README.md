# README

## 📋 MCP (Model Context Protocol) Daily Digest
> 2025-09-18 업데이트

### 🔧 현재 구성된 MCP 서버
1. **cursor-claude-bridge** - Cursor IDE와 Claude 간 통신 브리지
2. **rails-kicda** - Rails 프로젝트 전용 MCP 서버
3. **filesystem** - 파일시스템 접근 서버 (프로젝트 루트: `/Users/l2dogyu/KICDA/ruby/kicda-jh`)

### 🎯 오늘의 활동
- MCP 서버 구성 검증 완료
- Sentry, Playwright, Supabase, BrightData MCP 통합 확인
- 자동화된 워크플로우 파이프라인 구축 (autopilot mode)

### 🚀 활용 가능한 기능
- **Sentry**: 에러 추적, 이슈 분석, 로그 모니터링
- **Playwright**: 브라우저 자동화 테스팅
- **Supabase**: 데이터베이스 관리, Edge Functions
- **BrightData**: 웹 스크래핑, 검색 엔진 데이터

### 📝 다음 단계
- [ ] Rails 앱과 MCP 서버 통합 테스트
- [ ] Sentry 에러 모니터링 설정
- [ ] Playwright E2E 테스트 작성

---

# prompt
1) 점검 및 구현
    보안/법규: HTTPS/HSTS, CSP, rails credentials 분리, 이용약관·개인정보·환불정책·사업자정보 고지.

    인프라: SQLite→PostgreSQL, ActiveStorage :local→S3(+CloudFront), 에러/로그(Sentry 등), rack-attack 레이트리밋, reCAPTCHA.

    인증: 이메일 유니크 인덱스, 로그인/로그아웃 시 reset_session, 비번 재설정·이메일 인증·OAuth(구글/카카오/네이버).

    결제: PG(토스/카카오 등) + Order/Payment·웹훅·환불·영수증.

    동영상: S3 업로드, FFmpeg HLS 인코딩(백그라운드 잡), 서명 URL/수강생 전용, video.js/hls.js, 진도·재개.

    성능/SEO: N+1 제거, 캐시, CDN, OG/사이트맵.

2) 1번 완료 후 보안 내용

    보안: 관리자 2FA, 감사 로그.
    구매: 쿠폰/포인트/프로모션, 강사 정산.
    학습경험: 커리큘럼/레슨, 퀴즈·Q&A, 추천, 검색 고도화.
    운영: 관리자 대시보드, 공지/배너.
