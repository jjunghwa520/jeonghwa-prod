# Google Cloud 완전 통합 가이드 - AI 자동화 최적화

**목표:** 모든 인프라를 Google Cloud로 통일  
**장점:** AI 자동화, Vertex AI 연동, 관리 통합  
**예상 비용:** 월 ₩30,000-50,000 (초기)

---

## 🎯 전체 아키텍처 (Google Cloud 통합)

```
┌─────────────────────────────────────────────┐
│         Google Cloud Platform              │
│                                             │
│  ┌──────────────┐      ┌─────────────────┐│
│  │  Cloud Run   │◄────►│ Cloud Storage   ││
│  │ (Rails App)  │      │ (이미지/비디오)  ││
│  └──────┬───────┘      └─────────────────┘│
│         │                                   │
│         │              ┌─────────────────┐ │
│         └─────────────►│  Vertex AI      │ │
│                        │ (이미지 생성)    │ │
│                        └─────────────────┘ │
│                                             │
│  ┌──────────────┐      ┌─────────────────┐│
│  │  Cloud CDN   │      │  Cloud DNS      ││
│  │  (빠른 전송)  │      │  (도메인 관리)   ││
│  └──────────────┘      └─────────────────┘│
└─────────────────────────────────────────────┘
         ↑
    Cloudflare
  (도메인 + API 자동화)
```

---

## 📋 Step-by-Step 가이드

### Phase 1: 도메인 구매 (Cloudflare 추천)

**왜 Cloudflare인가?** 🏆

```yaml
Google Cloud 자동화에 최적:
  ✅ API 완벽 지원 (AI 자동화 가능)
  ✅ Terraform/Infrastructure as Code 지원
  ✅ 무료 CDN (GCP와 조합)
  ✅ 무료 DNS (Cloud DNS 대체 가능)
  ✅ 무료 SSL
  ✅ DDoS 보호
  ✅ Workers (엣지 컴퓨팅)
  
비용:
  .com: $9.77/년 (₩13,000)
  DNS: 무료
  CDN: 무료
  API: 무료
  
GCP 연동:
  ✅ Cloud Run 자동 도메인 매핑
  ✅ Cloud Storage 커스텀 도메인
  ✅ Cloud CDN과 조합 가능
```

#### 도메인 구매 절차

```bash
1. https://dash.cloudflare.com 접속
2. Sign Up (또는 Login)
3. Registrar → Register Domains
4. 도메인 검색: jeonghwa-library.com
5. Purchase (1년, Auto-renew 체크)
6. 결제 (신용카드)
```

**저장할 정보:**
```
📌 도메인: jeonghwa-library.com
📌 Cloudflare Email: your-email@gmail.com
📌 Cloudflare API Token: (나중에 생성)
```

---

### Phase 2: GCP 프로젝트 생성 (새 계정)

#### Step 2-1: 새 구글 계정 생성

```
1. 새 Gmail 계정 생성 (사업용)
   예: jeonghwa.library@gmail.com
   
2. Google Cloud Console 접속
   https://console.cloud.google.com
   
3. 무료 크레딧 활성화
   - $300 무료 크레딧 (90일)
   - 신용카드 등록 필요
   - 자동 청구 안 됨 (확인 필요)
```

#### Step 2-2: 프로젝트 생성

```
1. 프로젝트 만들기
   - 프로젝트 이름: jeonghwa-library-prod
   - 프로젝트 ID: jeonghwa-library-prod-XXXXX
   - 위치: 조직 없음

2. 결제 계정 연결
   - 결제 → 결제 계정 추가
   - 신용카드 등록
   - 국가: 대한민국

3. API 활성화
   다음 API를 모두 활성화:
   
   ✅ Cloud Run API
   ✅ Cloud Storage API
   ✅ Cloud Build API
   ✅ Container Registry API
   ✅ Cloud DNS API (선택)
   ✅ Vertex AI API (이미지 생성)
   ✅ Cloud CDN API
   ✅ Cloud Logging API
```

**저장할 정보:**
```
📌 GCP Email: jeonghwa.library@gmail.com
📌 프로젝트 ID: jeonghwa-library-prod-xxxxx
📌 프로젝트 번호: 123456789012
```

---

### Phase 3: Cloud Storage 설정 (이미지/비디오)

#### Step 3-1: 버킷 생성

```
1. Cloud Console → Cloud Storage → Buckets

2. Create Bucket
   - Name: jeonghwa-assets
   - Location type: Region
   - Location: asia-northeast3 (Seoul) ⭐
   - Storage class: Standard
   - Access control: Uniform
   - Public access: Allow public access ✅

3. 생성 완료
```

#### Step 3-2: 버킷 권한 설정 (공개)

```
1. 버킷 선택 → Permissions

2. Grant Access
   - New principals: allUsers
   - Role: Storage Object Viewer

3. Save

※ 이미지가 공개적으로 접근 가능해짐
```

#### Step 3-3: 커스텀 도메인 연결

```
1. 버킷 → Settings → Custom domain

2. Domain: assets.jeonghwa-library.com

3. Cloudflare에서 CNAME 설정:
   - Type: CNAME
   - Name: assets
   - Target: c.storage.googleapis.com
   - Proxy: OFF (회색 구름)

4. 확인 (10-30분 소요)
```

**접근 URL:**
```
공개 URL: https://storage.googleapis.com/jeonghwa-assets/image.jpg
커스텀 URL: https://assets.jeonghwa-library.com/image.jpg
```

---

### Phase 4: Cloud Run 설정 (Rails 앱)

#### Step 4-1: gcloud CLI 설치 (로컬)

```bash
# Mac
brew install google-cloud-sdk

# 인증
gcloud auth login

# 프로젝트 설정
gcloud config set project jeonghwa-library-prod-xxxxx

# 리전 설정
gcloud config set run/region asia-northeast3
```

#### Step 4-2: Dockerfile 최적화 (GCP용)

현재 Dockerfile은 이미 준비되어 있으므로 그대로 사용 가능!

**확인:**
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
cat Dockerfile
# ✅ 이미 멀티스테이지 빌드로 최적화됨
```

#### Step 4-3: Cloud Build 설정

**cloudbuild.yaml 생성:**

```yaml
# cloudbuild.yaml
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'asia-northeast3-docker.pkg.dev/$PROJECT_ID/jeonghwa/rails-app:$COMMIT_SHA'
      - '-t'
      - 'asia-northeast3-docker.pkg.dev/$PROJECT_ID/jeonghwa/rails-app:latest'
      - '.'
    
  # Push to Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'asia-northeast3-docker.pkg.dev/$PROJECT_ID/jeonghwa/rails-app:$COMMIT_SHA'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'asia-northeast3-docker.pkg.dev/$PROJECT_ID/jeonghwa/rails-app:latest'
  
  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'jeonghwa-library'
      - '--image'
      - 'asia-northeast3-docker.pkg.dev/$PROJECT_ID/jeonghwa/rails-app:$COMMIT_SHA'
      - '--region'
      - 'asia-northeast3'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'
      - '--set-env-vars'
      - 'RAILS_ENV=production'

options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'E2_HIGHCPU_8'

timeout: '1200s'
```

#### Step 4-4: 첫 배포

```bash
# 1. Artifact Registry 생성
gcloud artifacts repositories create jeonghwa \
  --repository-format=docker \
  --location=asia-northeast3 \
  --description="Jeonghwa Library Docker images"

# 2. 환경변수 파일 생성
cat > .env.production <<EOF
RAILS_MASTER_KEY=$(cat config/master.key)
GOOGLE_CLOUD_PROJECT=jeonghwa-library-prod-xxxxx
GCS_BUCKET=jeonghwa-assets
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
EOF

# 3. Cloud Build로 배포
gcloud builds submit --config cloudbuild.yaml

# 4. 배포 확인
gcloud run services list

# 5. URL 확인
gcloud run services describe jeonghwa-library \
  --region=asia-northeast3 \
  --format='value(status.url)'
```

**결과:**
```
Service URL: https://jeonghwa-library-XXXXX-an.a.run.app
```

---

### Phase 5: 커스텀 도메인 매핑

#### Step 5-1: Cloud Run 도메인 매핑

```bash
# 1. 도메인 매핑
gcloud run domain-mappings create \
  --service=jeonghwa-library \
  --domain=jeonghwa-library.com \
  --region=asia-northeast3

# 2. DNS 레코드 확인
gcloud run domain-mappings describe \
  --domain=jeonghwa-library.com \
  --region=asia-northeast3
```

#### Step 5-2: Cloudflare DNS 설정

```
1. Cloudflare Dashboard → DNS

2. Add record:
   - Type: A
   - Name: @
   - IPv4 address: (Cloud Run에서 제공한 IP)
   - Proxy: OFF (회색 구름) ⚠️ 중요!
   - TTL: Auto

3. Add record (www):
   - Type: CNAME
   - Name: www
   - Target: jeonghwa-library.com
   - Proxy: OFF

4. Save
```

#### Step 5-3: SSL 인증서 자동 발급

```
Cloud Run이 자동으로 처리:
- Let's Encrypt SSL 자동 발급
- 자동 갱신
- HTTPS 강제

확인:
https://jeonghwa-library.com
→ 자물쇠 아이콘 확인
```

---

### Phase 6: 기존 파일 마이그레이션

#### Step 6-1: gsutil로 파일 업로드

```bash
# 1. gsutil 인증 확인
gcloud auth application-default login

# 2. 이미지 파일 업로드
cd /Users/l2dogyu/KICDA/ruby/kicda-jh

# 생성된 이미지만 업로드 (930MB)
gsutil -m cp -r public/assets/generated/* \
  gs://jeonghwa-assets/assets/generated/

# 진행 상황 확인
gsutil du -sh gs://jeonghwa-assets

# 3. 권한 설정 (공개)
gsutil iam ch allUsers:objectViewer gs://jeonghwa-assets

# 완료!
```

#### Step 6-2: Rails Active Storage 설정

**config/storage.yml:**

```yaml
# Google Cloud Storage (Production)
google:
  service: GCS
  project: jeonghwa-library-prod-xxxxx
  bucket: jeonghwa-assets
  credentials: <%= ENV['GOOGLE_APPLICATION_CREDENTIALS'] %>

# Local (Development)
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

**config/environments/production.rb:**

```ruby
# Active Storage 설정
config.active_storage.service = :google

# Asset Host 설정 (CDN)
config.asset_host = "https://assets.jeonghwa-library.com"
```

**app/helpers/application_helper.rb:**

```ruby
def asset_url(path)
  if Rails.env.production?
    "https://assets.jeonghwa-library.com/#{path}"
  else
    asset_path(path)
  end
end
```

---

## 💰 비용 분석 (Google Cloud 전체)

### 월간 예상 비용

```yaml
Cloud Run (앱 서버):
  무료 할당:
    - 200만 요청/월
    - CPU 시간: 360,000 vCPU-초
    - 메모리: 360,000 GiB-초
  
  초과 시 (사용자 1,000명 기준):
    - 요청: $0.40/백만 요청
    - CPU: $0.00002400/vCPU-초
    - 메모리: $0.00000250/GiB-초
    예상: $5-15/월

Cloud Storage (이미지):
  Standard Storage (Seoul):
    - $0.020/GB/월
    - 현재 1.5GB: $0.03/월
    - 10GB 성장: $0.20/월
    - 100GB: $2/월
  
  데이터 전송 (egress):
    - 한국 내: $0.12/GB
    - 100GB/월: $12/월
    - Cloud CDN 사용 시 감소

Cloud Build (배포):
  무료 할당:
    - 120분/일
  초과 시:
    - $0.003/빌드-분
  예상: $0-3/월

Vertex AI (이미지 생성):
  이미 사용 중 (별도 비용)

총 예상 비용:
  초기 (100명 사용자): $8-12/월 (₩11,000-16,000)
  성장 (1,000명): $20-35/월 (₩27,000-47,000)
  대규모 (10,000명): $80-150/월
```

### 비용 최적화 팁

```yaml
1. Cloud CDN 활성화:
   - 트래픽 비용 70-90% 감소
   - $0.08/GB (CDN) vs $0.12/GB (직접)
   - Cloudflare와 조합 시 더 절감

2. 이미지 최적화:
   - 930MB → 300MB (70% 감소)
   - WebP 변환
   - 썸네일 자동 생성

3. Cloud Storage 클래스:
   - 자주 안 쓰는 파일: Nearline ($0.010/GB)
   - 1년 이상: Coldline ($0.004/GB)

4. 리전 최적화:
   - Seoul (asia-northeast3) 사용
   - 한국 사용자에게 빠르고 저렴
```

---

## 🤖 AI 자동화 설정

### Cloudflare API + GCP 자동화

**장점:**
- AI가 직접 배포 가능
- 도메인 자동 설정
- DNS 자동 업데이트
- SSL 자동 관리

#### Step 1: Cloudflare API Token

```
1. Cloudflare Dashboard → Profile → API Tokens

2. Create Token

3. Template: Edit zone DNS

4. Permissions:
   - Zone - DNS - Edit
   - Zone - Zone - Read

5. Zone Resources:
   - Include - Specific zone - jeonghwa-library.com

6. Create Token

7. 토큰 복사 및 저장
```

#### Step 2: GCP Service Account (AI 자동화용)

```bash
# 1. Service Account 생성
gcloud iam service-accounts create ai-automation \
  --display-name="AI Automation Account"

# 2. 권한 부여
gcloud projects add-iam-policy-binding jeonghwa-library-prod-xxxxx \
  --member="serviceAccount:ai-automation@jeonghwa-library-prod-xxxxx.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding jeonghwa-library-prod-xxxxx \
  --member="serviceAccount:ai-automation@jeonghwa-library-prod-xxxxx.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding jeonghwa-library-prod-xxxxx \
  --member="serviceAccount:ai-automation@jeonghwa-library-prod-xxxxx.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.editor"

# 3. 키 생성
gcloud iam service-accounts keys create ~/ai-automation-key.json \
  --iam-account=ai-automation@jeonghwa-library-prod-xxxxx.iam.gserviceaccount.com

# 4. 키 확인
cat ~/ai-automation-key.json
```

#### Step 3: GitHub Actions 자동 배포

**.github/workflows/deploy.yml:**

```yaml
name: Deploy to GCP

on:
  push:
    branches: [main]

env:
  PROJECT_ID: jeonghwa-library-prod-xxxxx
  SERVICE: jeonghwa-library
  REGION: asia-northeast3

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Google Auth
        uses: google-github-actions/auth@v1
        with:
          credentials_json: '${{ secrets.GCP_SA_KEY }}'

      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v1

      - name: Build and Deploy
        run: |
          gcloud builds submit --config cloudbuild.yaml

      - name: Update Cloudflare Cache
        run: |
          curl -X POST "https://api.cloudflare.com/client/v4/zones/${{ secrets.CF_ZONE_ID }}/purge_cache" \
            -H "Authorization: Bearer ${{ secrets.CF_API_TOKEN }}" \
            -H "Content-Type: application/json" \
            --data '{"purge_everything":true}'
```

---

## 📋 AI에게 전달할 정보 (자동화용)

배포 준비가 완료되면 AI에게 전달:

```yaml
gcp_info:
  project_id: "jeonghwa-library-prod-xxxxx"
  project_number: "123456789012"
  region: "asia-northeast3"
  service_account_key: "(ai-automation-key.json 내용)"

cloudflare_info:
  domain: "jeonghwa-library.com"
  zone_id: "xxxxx"
  api_token: "xxxxx"

github_info:
  repo: "username/jeonghwa-library"
  branch: "main"

secrets:
  rails_master_key: "(config/master.key 내용)"
```

**AI가 자동으로 할 수 있는 작업:**
- ✅ Cloud Run 배포
- ✅ DNS 레코드 업데이트
- ✅ SSL 인증서 갱신
- ✅ 이미지 업로드
- ✅ 캐시 퍼지
- ✅ 로그 모니터링
- ✅ 비용 알림

---

## 🎓 다음 단계

### 우선순위 1: 기본 배포
```
1. Cloudflare 도메인 구매
2. GCP 프로젝트 생성
3. Cloud Storage 설정
4. Cloud Run 첫 배포
5. 커스텀 도메인 연결
```

### 우선순위 2: 최적화
```
1. 이미지 최적화 (930MB → 300MB)
2. Cloud CDN 활성화
3. GitHub Actions 자동 배포
4. 모니터링 설정
```

### 우선순위 3: 고급 기능
```
1. Cloud SQL (필요 시)
2. Cloud Armor (보안)
3. Cloud Monitoring
4. 비용 알림
```

---

**작성일:** 2025년 10월 23일  
**업데이트:** 배포 후 실제 비용/성능 반영 예정

**핵심 요약:**
- 전체 Google Cloud 통합
- Cloudflare로 도메인 + AI 자동화
- 월 ₩27,000-47,000 (1,000명 사용자)
- 완전 자동화 가능
- 무제한 확장

**다음 작업:**
도메인 구매하시면 바로 GCP 배포 시작 가능합니다! 🚀

