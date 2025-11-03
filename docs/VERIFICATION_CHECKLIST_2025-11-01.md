# 정화의서재 프로덕션 검증 체크리스트 (2025-11-01)

## 배포 전 검증

### 코드 품질
- [x] Brakeman 보안 스캔 통과
- [x] Rubocop 린트 검사 통과
- [x] JavaScript dependencies audit 통과
- [x] 단위/시스템 테스트 통과
- [x] E2E 스모크 테스트 통과 (로컬)

### 라우팅 설정
- [x] `routes.rb`에서 404/500 에러 라우트가 `get` 메소드 사용 확인
- [x] 모든 라우트가 올바르게 정의됨
- [x] assets:precompile 정상 동작 확인

### Docker/컨테이너
- [x] Dockerfile 빌드 컨텍스트가 루트(`.`)로 설정됨
- [x] `libsqlite3-dev` 등 필수 패키지 포함
- [x] `SECRET_KEY_BASE_DUMMY=1`로 assets precompile 수행
- [x] 멀티스테이지 빌드로 최종 이미지 크기 최적화
- [x] 비루트 사용자(rails:1000)로 실행

## GitHub Actions 워크플로 검증

### Deploy to Cloud Run
- [x] WIF Provider가 전체 리소스 이름으로 설정
  - `projects/296627717123/locations/global/workloadIdentityPools/github-pool/providers/github`
- [x] push(main) 트리거 활성화
- [x] workflow_dispatch 기본값 설정
- [x] Docker 빌드 명령어: `docker build -t ${IMAGE} .`
- [x] Cloud Run 환경변수 주입: `BASE_URL`, `RAILS_MASTER_KEY`
- [x] 배포 후 헬스 체크 스텝 추가 (10회 재시도, 10초 간격)

### E2E on Production
- [x] 트리거가 "Deploy to Cloud Run" 완료 시로 설정
- [x] working-directory가 `e2e-playwright`로 올바르게 설정
- [x] artifact 경로가 `e2e-playwright/playwright-report`로 설정
- [x] BASE_URL 기본값: `https://정화의서재.kr`

### CI
- [x] 중복 정의 제거 완료
- [x] scan_ruby, scan_js, lint, test, e2e_smoke 작업 정의
- [x] PR 및 main push 시 자동 실행

## GitHub Secrets 검증

### 필수 시크릿
- [ ] `GCP_PROJECT_ID`: GCP 프로젝트 ID
- [ ] `GCP_WORKLOAD_IDENTITY_PROVIDER`: 전체 리소스 이름 (위 형식 확인)
- [ ] `GCP_SERVICE_ACCOUNT`: 서비스 계정 이메일
- [ ] `RAILS_MASTER_KEY`: Rails 마스터 키

### 시크릿 확인 방법
```bash
# GitHub Settings → Secrets and variables → Actions
# 각 시크릿이 존재하는지 확인 (값은 마스킹됨)
```

## 배포 후 검증

### 도메인 헬스 체크
- [x] `https://xn--2i4b17iihloh20d.kr` 접속 가능
- [x] HTTP 200 또는 302 응답 확인
- [x] `/up` 엔드포인트 정상 응답

### Cloud Run 서비스
- [ ] 리비전 생성 확인
- [ ] 트래픽 100% 할당 확인
- [ ] 환경변수 설정 확인 (BASE_URL, RAILS_MASTER_KEY)
- [ ] 컨테이너 로그 정상 확인
- [ ] Cold start 시간 확인 (첫 요청)

### 상용 UX 흐름 테스트

#### 비회원 접근
- [ ] 홈페이지 접속 성공
- [ ] 전자동화책 미리보기 10% 접근 가능
- [ ] 구연동화 미리보기 10% 접근 가능
- [ ] 로그인/회원가입 버튼 표시

#### 회원가입
- [ ] 필수 체크박스 동의 시 버튼 활성화
- [ ] 회원가입 처리 정상
- [ ] 로딩 상태 표시 정상
- [ ] 가입 완료 후 리디렉션

#### 로그인
- [ ] 로그인 폼 표시
- [ ] 인증 처리 정상
- [ ] 세션 유지 확인

#### 일반회원 콘텐츠 접근
- [ ] 카테고리별 콘텐츠 목록 표시
- [ ] 썸네일 이미지 로딩 (Vertex AI 생성 이미지)
- [ ] 미리보기 제한 적용 (10%)
- [ ] 결제 안내 표시

#### 유료결제
- [ ] Toss Payments 위젯 로딩
- [ ] 결제 처리 정상
- [ ] 결제 완료 후 접근 권한 부여
- [ ] 웹훅 처리 정상

#### 유료회원 콘텐츠 접근
- [ ] 전체 콘텐츠 접근 가능
- [ ] 전자동화책 리더 정상 동작
- [ ] 구연동화 비디오 재생 정상
- [ ] 동화만들기 교육 접근 가능
- [ ] 청소년 콘텐츠(14-16세) 접근 가능

## E2E 테스트 실행

### 로컬 환경
```bash
cd e2e-playwright
npm ci
npx playwright install --with-deps
npx playwright test --project=desktop-1440
```

### 상용 환경
- [ ] GitHub Actions → "E2E on Production (Playwright)" 실행
- [ ] 테스트 성공 확인
- [ ] HTML 리포트 다운로드
- [ ] 실패 시 스크린샷 확인

## 모니터링

### 실시간 확인
- [ ] Cloud Run 메트릭 (CPU, Memory, Latency)
- [ ] 에러 로그 확인
- [ ] 요청 수/응답 시간 확인

### 정기 점검
- [ ] 일일 접속자 수
- [ ] 에러율
- [ ] 응답 시간 P50, P95, P99
- [ ] 컨테이너 재시작 빈도

## 롤백 절차

### 즉시 롤백이 필요한 경우
1. Cloud Run 콘솔 접속
2. 서비스 선택 → 리비전 탭
3. 이전 안정 리비전에 트래픽 100% 할당
4. 문제 분석 후 수정

```bash
gcloud run services update-traffic jeonghwa-app \
  --to-revisions=<PREVIOUS_REVISION>=100 \
  --region=asia-northeast3 \
  --platform=managed \
  --project=<PROJECT_ID>
```

## 향후 개선 사항

### 인프라
- [ ] Cloud SQL 마이그레이션 (SQLite → PostgreSQL)
- [ ] Redis 캐시 도입
- [ ] CDN 설정 (Cloud CDN 또는 Cloudflare)
- [ ] 정적 자산 최적화 (이미지 압축, lazy loading)

### 모니터링/알림
- [ ] Uptime checks 설정
- [ ] Error Reporting 통합
- [ ] Slack/이메일 알림 설정
- [ ] APM 도구 도입 (Sentry, New Relic 등)

### 보안
- [ ] 시크릿 로테이션 정책
- [ ] WIF/SA 권한 최소화 재점검
- [ ] HTTPS 강제 설정
- [ ] 보안 헤더 강화

### 배포 프로세스
- [ ] Blue/Green 배포 전략
- [ ] Canary 배포 (트래픽 점진적 전환)
- [ ] 자동 롤백 조건 설정
- [ ] 배포 승인 프로세스 (프로덕션)

## 문서 링크

- [인수인계서](./HANDOVER_프로덕션_자동배포_E2E_인수인계_2025-11-01.md)
- [GCP 배포 가이드](./GCP_상용_배포_최초_가이드.md)
- [E2E 테스트 보고서](./UX_E2E_상용_테스트_보고서_2025-11-01.md)
- [CI 설정](./DEPLOYMENT_CI_SETUP.md)

---

**마지막 업데이트**: 2025-11-01  
**검증자**: Cursor AI Assistant  
**다음 검증 예정**: 배포 시마다

