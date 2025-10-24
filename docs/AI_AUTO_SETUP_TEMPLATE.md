# AI 자동 설정 템플릿

**이 문서는 AI가 참조하는 템플릿입니다.**

---

## 사용자가 전달할 정보 형식

```yaml
deployment_info:
  server:
    ip: "123.123.123.123"
    location: "Seoul"
    user: "root"
  
  domain:
    name: "jeonghwa-library.com"
    registrar: "Cloudflare"
  
  docker_hub:
    username: "jeonghwa-library"
    token: "dckr_pat_xxxxx"
  
  secrets:
    rails_master_key: "xxxxx"
    google_credentials: "optional"
    vertex_project_id: "optional"
```

---

## AI가 생성할 파일들

### 1. config/deploy.yml

```yaml
# Name of your application
service: jeonghwa_library

# Name of the container image
image: {docker_hub_username}/jeonghwa_library

# Deploy to these servers
servers:
  web:
    - {server_ip}

# SSL and domain configuration
proxy:
  ssl: true
  host: {domain_name}

# Docker Hub credentials
registry:
  username: {docker_hub_username}
  password:
    - KAMAL_REGISTRY_PASSWORD

# Environment variables
env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true
    RAILS_LOG_LEVEL: info
    RAILS_SERVE_STATIC_FILES: true

# Console aliases
aliases:
  console: app exec --interactive --reuse "bin/rails console"
  shell: app exec --interactive --reuse "bash"
  logs: app logs -f
  dbc: app exec --interactive --reuse "bin/rails dbconsole"

# Persistent storage for SQLite and uploads
volumes:
  - "jeonghwa_storage:/rails/storage"

# Asset path for zero-downtime deployments
asset_path: /rails/public/assets

# Builder configuration
builder:
  arch: amd64

# Health check
healthcheck:
  path: /up
  interval: 10s
  timeout: 5s
```

### 2. .kamal/secrets

```bash
# Docker Hub token for image push/pull
KAMAL_REGISTRY_PASSWORD={docker_hub_token}

# Rails master key for credentials
RAILS_MASTER_KEY={rails_master_key}

# Google Cloud (optional)
# GOOGLE_APPLICATION_CREDENTIALS={google_credentials}
# VERTEX_PROJECT_ID={vertex_project_id}

# Toss Payments (add later)
# TOSS_CLIENT_KEY=live_ck_xxxxx
# TOSS_SECRET_KEY=live_sk_xxxxx
```

### 3. .kamal/hooks/pre-deploy

```bash
#!/bin/sh

# Pre-deployment checks
echo "🔍 Running pre-deployment checks..."

# Check if Rails master key exists
if [ ! -f config/master.key ]; then
  echo "❌ config/master.key not found!"
  exit 1
fi

# Check if Docker is logged in
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Docker is not running or not logged in!"
  exit 1
fi

echo "✅ Pre-deployment checks passed!"
```

### 4. .kamal/hooks/post-deploy

```bash
#!/bin/sh

# Post-deployment tasks
echo "🚀 Running post-deployment tasks..."

# Run database migrations
kamal app exec "bin/rails db:migrate"

# Clear cache
kamal app exec "bin/rails cache:clear"

# Warm up the app
curl -f https://{domain_name}/up || exit 1

echo "✅ Deployment successful!"
echo "🌐 Visit: https://{domain_name}"
```

---

## AI 생성 프로세스

### Step 1: 정보 검증
```
- 서버 IP 형식 확인
- 도메인 형식 확인
- Docker Hub ID 형식 확인
- 필수 시크릿 확인
```

### Step 2: 파일 생성
```
1. config/deploy.yml 생성
2. .kamal/secrets 생성
3. 훅 스크립트 생성
4. .gitignore 업데이트
```

### Step 3: 사용자에게 전달
```
- 생성된 파일 요약
- 다음 단계 안내
- 배포 명령어 제공
```

---

## 사용자 작업 체크리스트

AI가 생성 후 사용자가 해야 할 일:

```bash
# 1. .kamal 디렉토리 권한 설정
chmod 700 .kamal
chmod 600 .kamal/secrets

# 2. 훅 스크립트 실행 권한
chmod +x .kamal/hooks/*

# 3. Docker Hub 로그인
docker login
# Username: {docker_hub_username}
# Password: {docker_hub_token}

# 4. 서버에 Docker 설치 (한 번만)
ssh root@{server_ip} 'curl -fsSL https://get.docker.com | sh'

# 5. 첫 배포
kamal setup

# 6. 확인
kamal app logs
```

---

## 배포 후 검증 스크립트

```bash
#!/bin/bash

echo "🔍 Deployment Verification"
echo "=========================="

# 1. HTTPS 체크
echo -n "HTTPS: "
curl -sf https://{domain_name}/up > /dev/null && echo "✅" || echo "❌"

# 2. SSL 인증서 체크
echo -n "SSL Certificate: "
openssl s_client -connect {domain_name}:443 -servername {domain_name} < /dev/null 2>/dev/null | grep "Verify return code: 0" > /dev/null && echo "✅" || echo "❌"

# 3. 앱 상태 체크
echo -n "App Health: "
curl -sf https://{domain_name}/up | grep "ok" > /dev/null && echo "✅" || echo "❌"

# 4. 로그 확인
echo -n "Checking logs: "
kamal app logs --tail 10 | grep -i error > /dev/null && echo "⚠️  Errors found" || echo "✅"

echo "=========================="
echo "Deployment verification complete!"
```

---

## 트러블슈팅 가이드

### 배포 실패 시

```bash
# 1. 상세 로그
kamal deploy --verbose

# 2. 서버 접속하여 수동 확인
ssh root@{server_ip}
docker ps -a
docker logs kicda_jh-web-1

# 3. 환경변수 확인
kamal app exec "env | grep RAILS"

# 4. 재배포
kamal deploy --skip-push
```

### SSL 인증서 오류

```bash
# 1. DNS 전파 확인 (최대 24시간)
nslookup {domain_name}

# 2. Cloudflare Proxy 확인 (반드시 OFF)
# Cloudflare Dashboard → DNS → Records → Proxy Status (회색 구름)

# 3. 인증서 수동 갱신
kamal proxy renew_ssl
```

### 데이터베이스 마이그레이션 실패

```bash
# 1. 마이그레이션 상태 확인
kamal app exec "bin/rails db:migrate:status"

# 2. 수동 마이그레이션
kamal app exec "bin/rails db:migrate RAILS_ENV=production"

# 3. 롤백 (필요시)
kamal app exec "bin/rails db:rollback RAILS_ENV=production"
```

---

## 성공 기준

배포 성공 확인:

```
✅ kamal setup 명령 성공
✅ https://{domain_name} 접속 가능
✅ SSL 인증서 정상 (브라우저 자물쇠 아이콘)
✅ 홈페이지 정상 로드
✅ 강의 목록 표시
✅ 이미지 로드 정상
✅ kamal app logs에 에러 없음
✅ 메모리 사용률 < 80%
```

---

**AI 사용 시나리오:**

1. 사용자가 정보 전달
2. AI가 이 템플릿 참조하여 파일 생성
3. 사용자가 생성된 파일로 배포 실행
4. 성공! 🎉


