# GCP 상용 배포 · 초간단 처음 가이드 (정화의서재)

아래 순서만 그대로 따라 하세요. 각 단계 끝에 “내가 복사할 값”을 체크합니다.

---

## 0) 준비물
- Google 계정(로그인 가능)
- GitHub 저장소(본 프로젝트)
- 가비아 도메인(예: `jeonghwa.com`)

---

## 1) GCP 프로젝트 만들기 → GCP_PROJECT_ID
1. 접속: https://console.cloud.google.com → 상단 프로젝트 선택 → “새 프로젝트 만들기”.
2. 이름 예: `jeonghwa-prod` → 만들기.
3. 상단 바에서 방금 만든 프로젝트 선택 → “프로젝트 ID” 복사.
- 내가 복사할 값: GCP_PROJECT_ID (예: `jeonghwa-prod-123456`)

필수 API 사용 설정(검색창에서 ‘API’):
- Cloud Run Admin API, Artifact Registry API, Cloud Storage, Cloud SQL Admin, IAM Service Account Credentials

### GCP_PROJECT_ID: jeonghwa-prod
---

## 2) GitHub Actions용 WIF(OIDC) → GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_SERVICE_ACCOUNT
1. GCP 콘솔 → IAM & Admin → Workload Identity Federation → “풀 만들기” (이름: `github-pool`).
2. 풀 안에서 “제공업체 만들기”:
   - 유형: OpenID Connect (OIDC)
   - 발급자 URL: `https://token.actions.githubusercontent.com`
   - 주체 조건(예시): `repository:<GitHub_계정>/<저장소>`
   - 생성 후 “제공업체 리소스 이름” 복사.
3. 서비스 계정 만들기: IAM & Admin → 서비스 계정 → 만들기
   - 이름: `cloud-run-deployer`
   - 역할: Cloud Run Admin, Service Account User, Artifact Registry Writer, (옵션) Storage Admin, Cloud SQL Client
   - 서비스 계정 이메일 복사 (예: `cloud-run-deployer@<PROJECT_ID>.iam.gserviceaccount.com`).
4. 풀 제공업체에 이 서비스 계정을 연결(주체 권한 부여).
5. GitHub 저장소 → Settings → Secrets and variables → Actions → New repository secret:
   - GCP_PROJECT_ID: 1단계 값
   - GCP_WORKLOAD_IDENTITY_PROVIDER: 2단계 “제공업체 리소스 이름” (예: `projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github`)
   - GCP_SERVICE_ACCOUNT: 3단계 서비스 계정 이메일

---

## 3) GCS 버킷 만들기 → GCS_BUCKET
1. GCP 콘솔 → Cloud Storage → “버킷 만들기”.
   - 이름: `jeonghwa-prod-assets`
   - 위치: Region (예: `asia-northeast3`)
   - 액세스 제어: “균일”
2. (선택) 로컬 개발용 키: 해당 서비스 계정 → “키” → JSON 키 만들기 → 저장 경로 `config/google_service_account.json`.
3. 권한: Cloud Run에 연결할 서비스 계정에 “Storage Object Admin”(혹은 읽기/쓰기 권한) 부여.
- 내가 복사할 값: GCS_BUCKET (예: `jeonghwa-prod-assets`)

앱 ENV 설정 예:
- GCS_BUCKET=`jeonghwa-prod-assets`
- (로컬) GCP_CREDENTIALS_JSON=`config/google_service_account.json`

## - 이름: jeonghwa-prod-assets
- 위치: Region: asia-northeast3 (서울)

---

## 4) Cloud Run 배포(자동) – GitHub Actions
저장소에 `deploy-cloudrun.yml` 워크플로가 있습니다.
1. GitHub → Actions → “Deploy to Cloud Run” → “Run workflow”.
2. 입력값:
   - service: `jeonghwa-app`
   - region: `asia-northeast3`
   - base_url: `https://www.jeonghwa.com`
3. Secrets 준비: `GCP_PROJECT_ID`, `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`.
4. 첫 배포 후 Cloud Run 콘솔에서 환경 변수 설정(7장 참고).

(참고) 수동 배포 예시:
```bash
# 인증
gcloud auth login
PROJECT_ID=jeonghwa-prod
REGION=asia-northeast3
SERVICE=jeonghwa-app
IMAGE=gcr.io/$PROJECT_ID/$SERVICE:$(git rev-parse --short HEAD)

docker build -t $IMAGE kicda-jh
docker push $IMAGE

gcloud run deploy $SERVICE \
  --image=$IMAGE \
  --project=$PROJECT_ID \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated
```

---

## 5) 도메인(가비아) 연결 → Cloud Run 커스텀 도메인
1. Cloud Run 콘솔 → 서비스 → Custom domains → “맵핑 추가”.
2. 안내되는 DNS 레코드를 가비아 DNS에 추가:
   - `www` 서브도메인: CNAME → `ghs.googlehosted.com`
   - 루트 도메인 A 레코드 4개:
     - 216.239.32.21 / 216.239.34.21 / 216.239.36.21 / 216.239.38.21
3. 저장 후 수 분~1시간 대기 → HTTPS 인증서 자동 발급.

---

## 6) 데이터베이스(DB)
### A안(쉬움): Supabase/Neon
1. 가입 → Project 생성 → Postgres 연결 정보 확인.
2. `DATABASE_URL` 복사 (예: `postgres://USER:PASSWORD@HOST:5432/DBNAME`).
3. Cloud Run 환경 변수에 저장.

### B안(GCP 공식): Cloud SQL for Postgres
1. 인스턴스 만들기(PostgreSQL) → 리전 선택.
2. 사용자/비번/DB명 생성.
3. 연결 방식:
   - 공용 IP(간편): 공용 IP 활성 → 방화벽 허용 → `DATABASE_URL` 구성.
   - Serverless VPC(권장): 커넥터 연결 → Cloud SQL 커넥터 사용.
4. 최종 예: `postgres://appuser:strongpass@203.0.113.10:5432/jeonghwa_prod`.

---

## 7) 앱 환경 변수(Cloud Run → Edit & Deploy New Revision → Variables)
- BASE_URL=`https://www.jeonghwa.com`
- DATABASE_URL=(6장 결과)
- GCS_BUCKET=(3장 결과)
- GCP_PROJECT_ID=(1장 결과)
- TOSS_CLIENT_KEY / TOSS_SECRET_KEY=(8장 결과)
- REDIS_URL / SENTRY_DSN / GOOGLE_ANALYTICS_ID: 선택

---

## 8) 결제(Toss)
1. Toss Payments 대시보드 → 설정 → API 키
   - 테스트/운영 키 확인
   - `TOSS_CLIENT_KEY`, `TOSS_SECRET_KEY` 복사
2. 웹훅 설정
   - URL: `https://www.jeonghwa.com/payments/webhook`
   - 이벤트: 승인/실패/취소 등 선택

---

## 9) 빠른 점검 체크리스트
- [ ] `https://www.jeonghwa.com` 접속 OK
- [ ] HTTPS 자물쇠 보임
- [ ] 이미지 업로드/표시 OK(GCS)
- [ ] 관리자→홈 연동 OK
- [ ] 결제 승인/실패/환불 웹훅 로그 OK
- [ ] 404/500 페이지 OK

---

## 10) 문제 해결 팁
- DNS 전파 대기(최대 1시간), 레코드 값 재확인
- Cloud Run 리비전 로그/IAM 권한 확인
- GCS: 서비스 계정 권한(Object Admin 또는 RW)
- DB: URL 오타/방화벽/포트(5432)
- 결제: 웹훅 200 OK 응답 여부

---

## 부록: 꼭 필요한 값 요약
- GCP_PROJECT_ID: GCP 콘솔 상단 바
- GCP_WORKLOAD_IDENTITY_PROVIDER: WIF 제공업체 리소스 이름
- GCP_SERVICE_ACCOUNT: `cloud-run-deployer@<PROJECT_ID>.iam.gserviceaccount.com`
- GCS_BUCKET: Cloud Storage 버킷명
- DATABASE_URL: Postgres 접속 URL
- TOSS_CLIENT_KEY / TOSS_SECRET_KEY: Toss 대시보드 → API 키
