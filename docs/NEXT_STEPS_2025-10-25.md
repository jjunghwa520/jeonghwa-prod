# 내일 작업 계획 · 역할 분담 (2025-10-25)

## 결론 요약
- 현재 상태: 제한적 상용화(Soft launch) 가능. 전면 공개(GA) 전 필수 과제 필요.
- 목표: 내일 필수/우선 과제를 병행 처리하여 상용 안정성·보안·운영 신뢰도 확보.

## Assistant가 내일 수행할 작업(자동 처리 가능)
- 보안/CSP 고도화
  - nonce/hash 기반으로 inline 스크립트/스타일 제거 단계 적용, 화이트리스트 최소화(jsdelivr/gtag/toss만).
  - 환경별 분기 재정비(dev 완화, prod 최소 허용). 불필요한 connect_src 제거.
- 에러 페이지/구조화 로깅
  - 404/500 사용자 친화 페이지 추가, exceptions_app 라우팅 구성.
  - 구조화 로깅(JSON/태그드 로깅) 및 request_id 상관관계 강화, 기본 대시보드 필드 정의.
- CI/E2E 안정화
  - Playwright 스모크 분리, headless 안정화, flaky locator 개선, HTML 리포트 아티팩트 고정화.
- 성능/프론트
  - 주요 이미지 sizes/명시적 width/height 보강, 폰트 font-display: swap + preload, FOIT 최소화.
- 접근성(a11y)
  - 포커스 링/랜드마크/대비 점검 및 수정, 토스트/플래시에 라이브 리전 일관성 확인.
- 관리자 UX 정비
  - select/prompt/required 일관성, 가격/상태/레벨 프리셋 정비.
- 레이트리밋 정책 반영
  - Rack::Attack ENV 임계치 키 일원화, 관리자 화이트리스트/세이프리스트 정리, 429 UX 미세 조정.
- DB/쿼리 점검
  - 추가된 인덱스 사용 여부 EXPLAIN 확인, 필요한 경우 courses(category,status,created_at) 보강 검토.
- 문서화
  - 백업/마이그레이션 가이드 초안(PostgreSQL/S3), 운영 런북(장애대응/롤백) 작성.

## Owner(사용자)가 반드시 해야 할 일(권한/비밀키/의사결정)
- 인프라 비밀키/리소스 제공
  - PostgreSQL 접속 정보(DB 호스트/유저/패스워드/DB명) 또는 DATABASE_URL.
  - AWS S3 버킷/리전 및 IAM Access/Secret Key, CloudFront 배포(선택).
  - 도메인/DNS/TLS 최종 정보(앱 호스트, 메일러 도메인).
- 결제
  - Toss Payments 샌드박스/운영 키, webhook 엔드포인트 등록/검증(성공/실패/환불).
  - 실거래 테스트 카드/시나리오 승인.
- 보안 정책 승인
  - 최종 CSP 허용 도메인·전략(unsafe-inline 제거 시 영향 수용 여부), 로그인 임계치(분/횟수)·락 정책.
  - 관리자/사내 IP 화이트리스트 범위.
- 모니터링/로깅
  - Sentry DSN(APM 포함 시), 로그 보존 정책/전송 경로 결정.
- 법정 고지·정책
  - 이용약관/개인정보/환불정책/사업자정보 문안 확정 및 페이지 최종 검토.
- 백업/DR
  - 백업 주기·보존/복구 리허설 일정 승인.

## 일정(제안)
- D0: CSP 고도화 초안, 404/500, CI 안정화, a11y/성능 1차.
- D1: 결제 샌드박스 전수, 구조화 로깅/대시보드, DB 쿼리계획 검증.
- D2: 운영 리허설(롤백/백업/장애훈련), 카나리 5–10% 공개.

## 수용 기준(샘플)
- 보안: CSP nonce/hash 적용, 레이트리밋 운영 임계치 문서화·ENV 반영.
- 결제: 성공/실패/환불 + webhook 로그 증빙.
- 품질: Lighthouse 80+ 주요 페이지, Playwright 스모크 CI 녹색.
- 운영: 404/500 커스텀, 구조화 로그에 request_id/유저컨텍스트 포함.

## 필요 ENV 체크리스트(소유자 입력 필요)
- 데이터/캐시: DATABASE_URL 또는 DB 설정, REDIS_URL.
- 레이트리밋: RACK_ATTACK_LOGIN_LIMIT, RACK_ATTACK_LOGIN_PERIOD_SECONDS, RACK_ATTACK_API_LIMIT, RACK_ATTACK_API_PERIOD_SECONDS, RACK_ATTACK_PAYMENT_*.
- 스토리지: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET.
- 결제: TOSS_CLIENT_KEY, TOSS_SECRET_KEY.
- 관측: SENTRY_DSN, GOOGLE_ANALYTICS_ID.
- 앱: BASE_URL(배포 URL), 메일러 호스트.

## 최종 점검 체크리스트(객관/비판적 리뷰)
- 주요 사용자 플로우(목록→상세→장바구니→결제 시뮬레이션) 0-에러 확인.
- 관리자 CRUD→홈 반영 시나리오 200/404 교차 검증.
- CSP 위반/콘솔 에러 0, 네트워크 4xx/5xx 비율 허용치 이내.
- E2E 스모크 CI 녹색 + 리포트/트레이스 확인 가능.
- 로깅/모니터링에 request_id 상관관계, 경보 기준 정상 동작.

