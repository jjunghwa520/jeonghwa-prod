# GitHub Secrets 설정 가이드 (2025-11-01)

## 개요
이 문서는 정화의서재 프로덕션 배포를 위한 GitHub Secrets 설정 방법을 안내합니다.

## 필수 Secrets 목록

### 1. GCP_PROJECT_ID
**설명**: Google Cloud Platform 프로젝트 ID

**값 확인 방법**:
```bash
gcloud config get-value project
```
또는 GCP 콘솔: https://console.cloud.google.com → 프로젝트 선택 → 프로젝트 ID 복사

**예시**: `jeonghwa-prod-12345`

**설정 위치**: GitHub → Settings → Secrets and variables → Actions → New repository secret
- Name: `GCP_PROJECT_ID`
- Secret: `프로젝트 ID`

---

### 2. GCP_WORKLOAD_IDENTITY_PROVIDER
**설명**: Workload Identity Federation 제공업체의 전체 리소스 이름

**중요**: 반드시 전체 리소스 이름 형식이어야 합니다.

**올바른 형식**:
```
projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_NAME/providers/PROVIDER_NAME
```

**현재 설정값**:
```
projects/296627717123/locations/global/workloadIdentityPools/github-pool/providers/github
```

**값 확인 방법**:
1. GCP 콘솔 → IAM & Admin → Workload Identity Federation
2. 풀 이름 클릭 (예: `github-pool`)
3. 제공업체 클릭 (예: `github`)
4. "리소스 이름" 전체 복사

또는 CLI:
```bash
gcloud iam workload-identity-pools providers describe github \
  --workload-identity-pool=github-pool \
  --location=global \
  --format="value(name)"
```

**잘못된 형식 예시** (사용 금지):
- `//iam.googleapis.com/projects/.../providers/github` ❌
- `github-pool/providers/github` ❌
- `296627717123` ❌

**설정 위치**:
- Name: `GCP_WORKLOAD_IDENTITY_PROVIDER`
- Secret: `projects/296627717123/locations/global/workloadIdentityPools/github-pool/providers/github`

---

### 3. GCP_SERVICE_ACCOUNT
**설명**: Cloud Run 배포용 서비스 계정 이메일

**형식**:
```
SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com
```

**예시**:
```
cloud-run-deployer@jeonghwa-prod-12345.iam.gserviceaccount.com
```

**값 확인 방법**:
1. GCP 콘솔 → IAM & Admin → Service Accounts
2. 배포용 서비스 계정 찾기
3. 이메일 주소 복사

또는 CLI:
```bash
gcloud iam service-accounts list --filter="displayName:cloud-run"
```

**필수 권한**:
- `roles/run.admin` - Cloud Run 서비스 관리
- `roles/storage.admin` - Container Registry 이미지 관리
- `roles/iam.serviceAccountUser` - 서비스 계정 사용

**권한 확인**:
```bash
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:SERVICE_ACCOUNT_EMAIL"
```

**설정 위치**:
- Name: `GCP_SERVICE_ACCOUNT`
- Secret: `cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com`

---

### 4. RAILS_MASTER_KEY
**설명**: Rails 애플리케이션의 마스터 키 (credentials 암호화/복호화)

**값 확인 방법**:
로컬 프로젝트의 `config/master.key` 파일 내용

```bash
cat config/master.key
```

**보안 주의사항**:
- ⚠️ 이 키는 절대 공개 저장소에 커밋하지 마세요
- ⚠️ `.gitignore`에 `config/master.key` 포함 확인
- ⚠️ 정기적으로 로테이션 권장 (년 1회 이상)
- ⚠️ 키 유출 시 즉시 재생성 필요

**키 재생성 방법** (필요 시):
```bash
# 백업
cp config/credentials.yml.enc config/credentials.yml.enc.backup

# 새 키 생성
rm config/master.key
EDITOR=vim rails credentials:edit

# 생성된 새 키 확인
cat config/master.key
```

**설정 위치**:
- Name: `RAILS_MASTER_KEY`
- Secret: `config/master.key 파일 내용` (예: `a1b2c3d4e5f6...`)

---

## Workload Identity Federation 초기 설정

### WIF가 없는 경우 (최초 설정)

#### 1단계: Workload Identity Pool 생성
```bash
gcloud iam workload-identity-pools create github-pool \
  --location=global \
  --display-name="GitHub Actions Pool" \
  --project=PROJECT_ID
```

#### 2단계: GitHub Provider 생성
```bash
gcloud iam workload-identity-pools providers create-oidc github \
  --location=global \
  --workload-identity-pool=github-pool \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --project=PROJECT_ID
```

#### 3단계: 서비스 계정 생성
```bash
gcloud iam service-accounts create cloud-run-deployer \
  --display-name="Cloud Run Deployer" \
  --project=PROJECT_ID
```

#### 4단계: 서비스 계정에 권한 부여
```bash
# Cloud Run Admin
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Storage Admin (Container Registry)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Service Account User
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"
```

#### 5단계: GitHub 리포지토리에 WIF 바인딩
```bash
gcloud iam service-accounts add-iam-policy-binding \
  cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/OWNER/REPO_NAME" \
  --project=PROJECT_ID
```

**변수 설명**:
- `PROJECT_ID`: GCP 프로젝트 ID (예: `jeonghwa-prod-12345`)
- `PROJECT_NUMBER`: GCP 프로젝트 번호 (예: `296627717123`)
- `OWNER`: GitHub 소유자 (예: `jjunghwa520`)
- `REPO_NAME`: GitHub 리포지토리 이름 (예: `jeonghwa-prod`)

**프로젝트 번호 확인**:
```bash
gcloud projects describe PROJECT_ID --format="value(projectNumber)"
```

---

## 검증 절차

### 1. Secrets 설정 확인
GitHub → Settings → Secrets and variables → Actions

각 시크릿이 존재하는지 확인 (값은 마스킹됨):
- ✅ GCP_PROJECT_ID
- ✅ GCP_WORKLOAD_IDENTITY_PROVIDER
- ✅ GCP_SERVICE_ACCOUNT
- ✅ RAILS_MASTER_KEY

### 2. WIF 인증 테스트
GitHub Actions에서 수동으로 배포 워크플로 실행:
```
Actions → Deploy to Cloud Run → Run workflow
```

**성공 시**: `Auth to GCP` 스텝 통과  
**실패 시**: 에러 메시지 확인 후 아래 트러블슈팅 참조

### 3. 로컬에서 시크릿 검증
```bash
# RAILS_MASTER_KEY 테스트
RAILS_MASTER_KEY=$(cat config/master.key) rails credentials:show

# 정상 출력: credentials.yml 내용 표시
# 오류: "ActiveSupport::MessageEncryptor::InvalidMessage"
```

---

## 트러블슈팅

### 에러: "Invalid value for audience"
**원인**: `GCP_WORKLOAD_IDENTITY_PROVIDER`가 잘못된 형식

**해결**:
1. WIF 제공업체의 전체 리소스 이름 확인
2. 형식: `projects/NUMBER/locations/global/workloadIdentityPools/POOL/providers/PROVIDER`
3. GitHub Secret 업데이트

### 에러: "Permission denied" (Cloud Run 배포)
**원인**: 서비스 계정 권한 부족

**해결**:
```bash
# 현재 권한 확인
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com"

# 필요 권한 추가 (위 4단계 참조)
```

### 에러: "ActiveSupport::MessageEncryptor::InvalidMessage"
**원인**: `RAILS_MASTER_KEY`가 올바르지 않음

**해결**:
1. 로컬 `config/master.key` 파일 확인
2. GitHub Secret의 `RAILS_MASTER_KEY` 값과 비교
3. 정확히 일치하는지 확인 (공백, 줄바꿈 없이)

### 에러: "gcr.io push denied"
**원인**: Container Registry 권한 부족

**해결**:
```bash
# Storage Admin 권한 부여
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-run-deployer@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Container Registry API 활성화 확인
gcloud services enable containerregistry.googleapis.com --project=PROJECT_ID
```

---

## 보안 모범 사례

### 1. 최소 권한 원칙
- 서비스 계정에 필요한 최소 권한만 부여
- 정기적으로 권한 검토 및 정리

### 2. 시크릿 로테이션
- RAILS_MASTER_KEY: 년 1회 이상
- 서비스 계정 키: WIF 사용으로 키 불필요
- 유출 의심 시 즉시 재생성

### 3. 접근 제한
- GitHub 리포지토리 접근 권한 최소화
- Secrets 수정 권한은 관리자만
- 2FA 활성화 필수

### 4. 감사 로그
- GCP 감사 로그 활성화
- GitHub Actions 로그 정기 검토
- 비정상 배포 활동 모니터링

---

## 관련 문서
- [인수인계서](./HANDOVER_프로덕션_자동배포_E2E_인수인계_2025-11-01.md)
- [검증 체크리스트](./VERIFICATION_CHECKLIST_2025-11-01.md)
- [GCP 배포 가이드](./GCP_상용_배포_최초_가이드.md)

---

**마지막 업데이트**: 2025-11-01  
**작성자**: Cursor AI Assistant

