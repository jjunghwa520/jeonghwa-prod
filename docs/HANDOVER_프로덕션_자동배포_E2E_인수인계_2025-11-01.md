# 정화의서재 프로덕션 자동배포·상용 E2E 인수인계서 (2025-11-01)

## 1) 문서 목적
- 본 문서는 정화의서재(정화의서재.kr)의 프로덕션 자동배포(Cloud Run)와 상용 E2E(Playwright) 체계를 과거/현재/미래 관점에서 일관성 있게 유지·운영하기 위한 인수인계 문서입니다.

## 2) 시스템 개요
- 애플리케이션: Ruby on Rails
- 인프라: GCP Cloud Run (컨테이너 이미지: gcr.io)
- CI/CD: GitHub Actions
- 브라우저 테스트: Playwright (상용 환경 대상 워크플로 별도)
- 도메인: 정화의서재.kr (punycode: `https://xn--2i4b17iihloh20d.kr`)

## 3) 현재 상태 요약 (Present)
- Cloud Run 배포 워크플로(`.github/workflows/deploy-cloudrun.yml`)가 push(main)와 수동 실행 모두 지원하며 기본 입력값(서비스/리전/베이스URL)을 내장했습니다.
- Workload Identity Federation(WIF) `GCP_WORKLOAD_IDENTITY_PROVIDER`가 “전체 리소스 이름”으로 교정됨.
  - 값: `projects/296627717123/locations/global/workloadIdentityPools/github-pool/providers/github`
- `RAILS_MASTER_KEY`가 Cloud Run 환경변수로 주입되도록 배포 스텝에 반영됨.
- 과거 ‘Run workflow’ 버튼 오버레이로 인한 무반응 문제를 제거하기 위해 push 트리거를 활성화하여 수동 클릭 의존도 축소.
- 배포 성공 후 BASE_URL로 도메인 헬스 체크 → 상용 E2E 실행 → 리포트 갱신 프로세스로 운영.

## 4) 변경 타임라인 (Past → Now)
1. 초기 상태
   - WIF audience 형식 오류로 GCP STS 인증 실패.
   - GitHub UI 토스트/오버레이로 ‘Run workflow’ 클릭 무반응 현상.
   - Docker 빌드 컨텍스트 오지정(`kicda-jh` 경로) → 루트(`.`)로 교정 필요.
   - Rails routes에서 `match "/404"`, `match "/500"`로 인해 assets:precompile 실패.
2. 적용 조치
   - WIF 제공업체 리소스 이름을 전체 경로로 교정.
   - 배포 워크플로 입력 기본값 추가; push 트리거 활성화(자동 실행 구조).
   - Docker 빌드 컨텍스트를 `.`로 수정.
   - `match`를 `get`으로 변경하여 precompile 오류 제거.
   - Cloud Run 배포 시 `RAILS_MASTER_KEY`/`BASE_URL` 환경변수 세팅.
3. 현재
   - push → Build/Push → Cloud Run Deploy → 도메인 헬스 → 상용 E2E → 리포트 업데이트가 연속 동작.

## 5) 아키텍처·파이프라인 구성 (Now)
- 컨테이너 빌드: 루트 `Dockerfile`
  - 빌드 스테이지에서 `libsqlite3-dev` 등 설치, assets precompile(`SECRET_KEY_BASE_DUMMY=1`) 수행.
- 배포:
  - 워크플로: `.github/workflows/deploy-cloudrun.yml`
  - 트리거: `push: main` + `workflow_dispatch`
  - 레지스트리: `gcr.io/${GCP_PROJECT_ID}/${SERVICE}:<git-sha>`
  - Cloud Run `--set-env-vars`: `BASE_URL`, `RAILS_MASTER_KEY`
- 인증:
  - WIF Provider: `projects/296627717123/locations/global/workloadIdentityPools/github-pool/providers/github`
  - Service Account: `${{ secrets.GCP_SERVICE_ACCOUNT }}` (예: `cloud-run-deployer@<PROJECT_ID>.iam.gserviceaccount.com`)

## 6) 시크릿/변수 명세 (Secrets & Vars)
- GitHub Secrets
  - `GCP_PROJECT_ID`: GCP 프로젝트 ID
  - `GCP_WORKLOAD_IDENTITY_PROVIDER`: 전체 리소스 이름(위 표기값)
  - `GCP_SERVICE_ACCOUNT`: 배포용 서비스 계정 이메일
  - `RAILS_MASTER_KEY`: Rails 마스터 키 값
- Cloud Run 런타임 Env
  - `BASE_URL`: `https://xn--2i4b17iihloh20d.kr`
  - `RAILS_MASTER_KEY`: GitHub Secret에서 주입

## 7) 표준 운영 절차(SOP)
### A. 배포(자동)
1) main 브랜치에 커밋/머지 → GitHub Actions가 자동 실행.
2) 워크플로 경로: Actions → Deploy to Cloud Run → 최신 Run 확인.
3) 성공 시 다음 단계 자동/수동:
   - 도메인 헬스 체크 → 상용 E2E 트리거(필요 시 재실행).

### B. 배포(수동)
1) Actions → Deploy to Cloud Run → Run workflow.
2) 기본값(서비스/리전/URL) 확인 후 실행.

### C. 롤백(Cloud Run)
1) Cloud Run 콘솔 → 서비스 → 리비전 탭 → 이전 리비전에 트래픽 100% 전환.
2) CLI 예시:
```bash
gcloud run services update-traffic <SERVICE> \
  --to-revisions=<REVISION>=100 \
  --region=asia-northeast3 --platform=managed --project=<PROJECT_ID>
```

### D. 상용 E2E 실행/리포트
1) Actions → E2E on Production (Playwright) → Run workflow.
2) 완료 후 `playwright-report` 아티팩트 다운로드/확인.

### E. 도메인 헬스 체크
```bash
curl -I https://xn--2i4b17iihloh20d.kr
```
`HTTP/2 200` 또는 적절한 리다이렉션/정상 응답 확인.

## 8) 장애 대응 런북(Runbooks)
### 8.1 WIF audience 오류
- 증상: `Invalid value for audience… Identity Provider full resource name 필요`.
- 조치: `GCP_WORKLOAD_IDENTITY_PROVIDER`를 전체 리소스 이름으로 교정.
- 경로: GCP 콘솔 → IAM & Admin → Workload Identity Federation → 풀/제공업체 → 세부정보의 “리소스 이름”.

### 8.2 GitHub UI 클릭 무반응(오버레이)
- 증상: Run workflow 클릭해도 반응 없음.
- 조치: push 트리거 중심 운영(수동 클릭 회피) 또는 오버레이 닫은 뒤 재시도.

### 8.3 Docker 빌드 컨텍스트 오류
- 증상: `docker build` 경로 불일치.
- 조치: 워크플로에서 `docker build -t ${IMAGE} .` 유지.

### 8.4 assets:precompile 실패(routes DSL)
- 증상: `match "/404"`/`match "/500"`로 precompile 실패.
- 조치: `get "/404"`, `get "/500"`로 교체(이미 반영됨).

### 8.5 gcr.io 인증 문제
- 증상: `denied` 또는 `not found`/`invalid tag`류 오류.
- 조치: `gcloud auth configure-docker gcr.io -q` 스텝 정상 실행 여부 확인, `PROJECT_ID/SERVICE` 값 점검.

## 9) 검증 체크리스트(Checklist)
- 배포 직후
  - [ ] Cloud Run 리비전 생성/트래픽 전환 확인
  - [ ] 환경변수 `BASE_URL`/`RAILS_MASTER_KEY` 적용 확인
  - [ ] `curl -I` 헬스 체크 200 계열 응답
- 상용 UX 흐름
  - [ ] 비회원: 미리보기 접근(전자동화책/구연동화 10%) 가능
  - [ ] 회원가입: 체크박스 동의 시 버튼 활성화/로딩 상태 정상
  - [ ] 로그인/일반회원: 카테고리/콘텐츠 접근 정상
  - [ ] 유료결제/결제 이후: 접근 권한/리디렉션/썸네일 노출 확인
- 테스트
  - [ ] Playwright E2E on Production 성공, 리포트 검토
  - [ ] CI 워크플로(브레이크맨/린트/스모크) 통과

## 10) 향후 과제(Future)
- Cloud SQL 도입 및 DB 외부화(현재 sqlite 빌드 의존 제거)
- 모니터링/알림: Uptime checks, Error Reporting, Slack/이메일 알림
- CDN/캐시 정책 정교화, 정적 자산 최적화
- 시크릿 로테이션/권한 최소화 재점검(WIF/SA 권한)
- Kamal 워크플로와 Cloud Run 파이프라인 동시성 정책 정리(둘 중 하나만 활성 운용 권장)

## 11) 운영자 빠른 참조(Links)
- 리포지토리: `https://github.com/jjunghwa520/jeonghwa-prod`
- 배포 워크플로: Actions → `Deploy to Cloud Run`
- 상용 E2E: Actions → `E2E on Production (Playwright)`
- 시크릿: Settings → Secrets and variables → Actions
- Cloud Run 콘솔: `https://console.cloud.google.com/run?project=<PROJECT_ID>`
- WIF 콘솔: `https://console.cloud.google.com/iam-admin/workload-identity-pools?project=<PROJECT_ID>`

## 12) 명령어 모음(Appendix)
```bash
# 수동 배포(로컬에서 참조용): 이미지 태그, 프로젝트/서비스 일치 필요
IMAGE=gcr.io/$GCP_PROJECT_ID/$SERVICE:$(git rev-parse --short HEAD)
docker build -t $IMAGE .
docker push $IMAGE
gcloud run deploy $SERVICE \
  --image=$IMAGE --project=$GCP_PROJECT_ID \
  --region=asia-northeast3 --platform=managed \
  --allow-unauthenticated \
  --set-env-vars=BASE_URL=https://xn--2i4b17iihloh20d.kr,RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# 롤백(이전 리비전에 100%)
gcloud run services update-traffic $SERVICE \
  --to-revisions=$REV=100 --region=asia-northeast3 \
  --platform=managed --project=$GCP_PROJECT_ID
```

---
담당 교대 시: 본 문서의 링크/시크릿 값/워크플로 경로가 최신인지 확인 후 인수인계하시기 바랍니다.

