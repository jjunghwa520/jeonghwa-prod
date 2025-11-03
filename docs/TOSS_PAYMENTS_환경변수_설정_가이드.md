# 토스 페이먼츠 환경변수 설정 가이드

## 📌 개요

정화의서재 결제 시스템에서 토스 페이먼츠 API 키를 안전하게 관리하기 위한 환경변수 설정 가이드입니다.

---

## 🔑 필요한 API 키

### 1. 클라이언트 키 (Client Key)
- **용도**: 프론트엔드에서 토스 SDK 초기화
- **노출**: 브라우저에 노출됨 (공개 가능)
- **환경변수명**: `TOSS_CLIENT_KEY`

### 2. 시크릿 키 (Secret Key)
- **용도**: 백엔드에서 토스 API 호출 (결제 승인/환불)
- **노출**: 절대 노출 금지 (서버에서만 사용)
- **환경변수명**: `TOSS_SECRET_KEY`

### 3. 현재 설정된 키
```bash
# 테스트 환경
TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R
TOSS_SECRET_KEY=test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR
```

---

## ☁️ Cloud Run 환경변수 설정

### 방법 1: gcloud CLI (권장)

#### 현재 환경변수 확인
```bash
gcloud run services describe jeonghwa-app \
  --region=asia-northeast3 \
  --format="get(spec.template.spec.containers[0].env)"
```

#### 환경변수 추가/수정
```bash
gcloud run services update jeonghwa-app \
  --region=asia-northeast3 \
  --update-env-vars="TOSS_CLIENT_KEY=test_ck_YOUR_KEY,TOSS_SECRET_KEY=test_sk_YOUR_KEY"
```

#### 환경변수 삭제
```bash
gcloud run services update jeonghwa-app \
  --region=asia-northeast3 \
  --remove-env-vars="TOSS_CLIENT_KEY,TOSS_SECRET_KEY"
```

### 방법 2: Google Cloud Console

1. [Cloud Run 콘솔](https://console.cloud.google.com/run) 접속
2. `jeonghwa-app` 서비스 클릭
3. 상단 "새 리비전 수정 및 배포" 클릭
4. "컨테이너" 탭 → "변수 및 보안 비밀" 섹션
5. "환경 변수 추가" 클릭
   - 이름: `TOSS_CLIENT_KEY`
   - 값: `test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R`
6. "환경 변수 추가" 클릭
   - 이름: `TOSS_SECRET_KEY`
   - 값: `test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR`
7. "배포" 클릭

### 방법 3: GitHub Actions (자동 배포)

`.github/workflows/deploy-cloudrun.yml`에 환경변수 추가:

```yaml
- name: Deploy to Cloud Run
  run: |
    gcloud run deploy jeonghwa-app \
      --region asia-northeast3 \
      --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/jeonghwa-app:${{ github.sha }} \
      --update-env-vars="TOSS_CLIENT_KEY=${{ secrets.TOSS_CLIENT_KEY }},TOSS_SECRET_KEY=${{ secrets.TOSS_SECRET_KEY }}"
```

**GitHub Secrets 설정**:
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. 추가:
   - `TOSS_CLIENT_KEY`: test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R
   - `TOSS_SECRET_KEY`: test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR

---

## 💻 로컬 개발 환경 설정

### 방법 1: .env 파일 (권장)

1. `.env` 파일 생성 (프로젝트 루트)
```bash
# .env
TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R
TOSS_SECRET_KEY=test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR
```

2. `.gitignore`에 추가 (이미 추가됨)
```
.env
```

3. `dotenv-rails` gem 사용 (이미 설치됨)
```ruby
# Gemfile
gem 'dotenv-rails', groups: [:development, :test]
```

4. Rails 서버 실행
```bash
rails server
# 또는
./bin/dev
```

### 방법 2: 환경변수 직접 설정

#### macOS/Linux
```bash
export TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R
export TOSS_SECRET_KEY=test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR
rails server
```

#### Windows (PowerShell)
```powershell
$env:TOSS_CLIENT_KEY="test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R"
$env:TOSS_SECRET_KEY="test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR"
rails server
```

### 방법 3: 한 줄 명령어

```bash
TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R \
TOSS_SECRET_KEY=test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR \
rails server
```

---

## 🔍 환경변수 사용 확인

### 1. Rails Console에서 확인

```ruby
# Rails console 실행
rails console

# 환경변수 확인
ENV['TOSS_CLIENT_KEY']
# => "test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R"

ENV['TOSS_SECRET_KEY']
# => "test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR"
```

### 2. 코드에서 사용 예시

#### PaymentsController

```ruby
# app/controllers/payments_controller.rb

# 클라이언트 키 (checkout 액션)
@toss_client_key = ENV.fetch('TOSS_CLIENT_KEY') do
  Rails.logger.warn "TOSS_CLIENT_KEY not set, using test key"
  'test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoq'  # fallback
end

# 시크릿 키 (confirm 액션)
secret_key = ENV.fetch('TOSS_SECRET_KEY') do
  Rails.logger.warn "TOSS_SECRET_KEY not set, using test key"
  'test_sk_zXLkKEypNArWmo50nX3lmeaxYG5R'  # fallback
end
```

#### 뷰에서 사용

```erb
<!-- app/views/payments/checkout.html.erb -->

<script src="https://js.tosspayments.com/v1"></script>
<script>
  const clientKey = '<%= @toss_client_key %>';
  const tossPayments = TossPayments(clientKey);
  // ...
</script>
```

---

## 🔒 보안 주의사항

### ✅ 해야 할 것

1. **환경변수로 관리**
   - API 키는 절대 코드에 하드코딩 금지
   - `.env` 파일은 `.gitignore`에 추가

2. **Secret Manager 사용 (프로덕션)**
   ```bash
   # Secret 생성
   echo -n "test_sk_YOUR_KEY" | \
     gcloud secrets create toss-secret-key --data-file=-

   # Cloud Run에서 사용
   gcloud run services update jeonghwa-app \
     --region=asia-northeast3 \
     --update-secrets=TOSS_SECRET_KEY=toss-secret-key:latest
   ```

3. **GitHub Secrets 사용**
   - 저장소 Settings → Secrets에 저장
   - GitHub Actions에서 `${{ secrets.XXX }}` 형태로 사용

4. **로그에서 제외**
   ```ruby
   # config/initializers/filter_parameter_logging.rb
   Rails.application.config.filter_parameters += [
     :password, :secret, :token, :secret_key, :client_key
   ]
   ```

### ❌ 하지 말아야 할 것

1. ❌ API 키를 코드에 직접 작성
2. ❌ `.env` 파일을 Git에 커밋
3. ❌ 클라이언트 키와 시크릿 키 혼동
4. ❌ 프로덕션 키를 로컬 개발에 사용
5. ❌ API 키를 로그에 출력

---

## 🧪 테스트 환경 vs 프로덕션 환경

### 테스트 환경 (현재)
```bash
# 테스트용 키
TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R
TOSS_SECRET_KEY=test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR
```

**특징**:
- 실제 결제 발생 안 함
- 토스 테스트 카드로만 결제 가능
- 심사/테스트 용도

### 프로덕션 환경 (심사 승인 후)
```bash
# 실제 결제용 키 (예시)
TOSS_CLIENT_KEY=live_ck_YOUR_REAL_KEY
TOSS_SECRET_KEY=live_sk_YOUR_REAL_KEY
```

**특징**:
- 실제 결제 발생
- 실제 카드로 결제
- 정산 및 세금 신고 필요

---

## 🚀 배포 시 체크리스트

### Cloud Run 배포 전

- [ ] 환경변수 설정 확인
  ```bash
  gcloud run services describe jeonghwa-app \
    --region=asia-northeast3 \
    --format="get(spec.template.spec.containers[0].env)"
  ```

- [ ] API 키 유효성 확인
  - 토스 페이먼츠 개발자센터에서 확인
  - 만료되지 않았는지 확인

- [ ] Fallback 키 확인
  - 코드에 fallback 테스트 키가 있는지 확인
  - 프로덕션에서는 fallback 사용 시 경고 로그

### Cloud Run 배포 후

- [ ] 환경변수 적용 확인
  ```bash
  # Cloud Run 로그 확인
  gcloud logging read "resource.type=cloud_run_revision AND \
    resource.labels.service_name=jeonghwa-app" \
    --limit 50 --format json
  ```

- [ ] 결제 페이지 접속 테스트
  - https://정화의서재.kr/payments/3/checkout
  - 브라우저 개발자 도구 → 콘솔 확인
  - TossPayments 객체 생성 확인

- [ ] 테스트 결제 실행
  - 테스트 카드로 결제 시도
  - 성공/실패 모두 테스트

---

## 🆘 문제 해결

### 문제 1: "TOSS_CLIENT_KEY not set" 경고

**원인**: 환경변수가 설정되지 않음

**해결**:
```bash
# Cloud Run 환경변수 설정
gcloud run services update jeonghwa-app \
  --region=asia-northeast3 \
  --update-env-vars="TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R"
```

### 문제 2: 결제창이 안 뜨는 경우

**원인**: 잘못된 클라이언트 키

**확인**:
```javascript
// 브라우저 개발자 도구 → 콘솔
console.log(clientKey);
// "test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R"
```

### 문제 3: 결제 승인 실패

**원인**: 잘못된 시크릿 키

**확인**:
```bash
# Cloud Run 로그 확인
gcloud logging read "resource.type=cloud_run_revision AND \
  resource.labels.service_name=jeonghwa-app AND \
  textPayload=~'TOSS_SECRET_KEY'" \
  --limit 10
```

### 문제 4: 로컬에서만 작동 안 함

**원인**: `.env` 파일 누락

**해결**:
```bash
# .env 파일 생성
cat > .env << EOF
TOSS_CLIENT_KEY=test_ck_26DlbXAaV0MdeAJjZ7AzrqY50Q9R
TOSS_SECRET_KEY=test_sk_EP59LybZ8B9q7lROK69nr6GYo7pR
EOF

# Rails 재시작
rails restart
```

---

## 📚 참고 자료

### 토스 페이먼츠 공식 문서
- [개발 가이드](https://docs.tosspayments.com/guides)
- [API 레퍼런스](https://docs.tosspayments.com/reference)
- [테스트 카드](https://docs.tosspayments.com/guides/test-card)

### Rails 환경변수 관리
- [dotenv-rails](https://github.com/bkeepers/dotenv)
- [Rails Credentials](https://guides.rubyonrails.org/security.html#custom-credentials)

### Google Cloud
- [Cloud Run 환경변수](https://cloud.google.com/run/docs/configuring/environment-variables)
- [Secret Manager](https://cloud.google.com/secret-manager/docs)

---

**작성일**: 2025-11-01  
**작성자**: Cursor AI  
**버전**: 1.0

