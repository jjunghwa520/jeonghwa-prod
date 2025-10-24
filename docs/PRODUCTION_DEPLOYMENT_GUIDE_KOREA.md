# 한국 상용화 완전 가이드 - 도메인부터 배포까지

**목표:** 정화의 서재를 실제 서비스로 런칭  
**예상 소요:** 총 4-6시간  
**예상 비용:** 월 $7-10 (₩9,000-13,000)  

---

## 📋 전체 프로세스 개요

### 🔵 사용자 작업 (수동)
```
1. VPS 계정 생성 및 서버 구매 (30분)
2. 도메인 구매 및 DNS 설정 (30분)
3. Docker Hub 계정 생성 (10분)
4. SSH 키 생성 및 서버 접속 (20분)
5. 환경변수 값 전달 (10분)
```

### 🟢 AI 자동화 가능 (자동)
```
1. Kamal 설정 파일 수정 ✅
2. Docker 설정 최적화 ✅
3. 환경변수 파일 생성 ✅
4. 배포 스크립트 작성 ✅
5. SSL 인증서 설정 ✅
6. 데이터베이스 마이그레이션 ✅
```

---

## 🎯 Phase 1: 사전 준비 (사용자 작업)

### Step 1-1: VPS 서버 구매 ⏱️ 30분

**추천 VPS (한국 사용자 최적화):**

#### 옵션 A: Vultr (서울 리전) 🏆 추천
```yaml
장점:
  - 한국 데이터센터 (서울)
  - 시간당 과금 ($0.009/시간)
  - 월 $6 (₩8,000)
  - 신용카드/PayPal 결제
  
사양 (Regular Performance):
  - CPU: 1 vCore
  - RAM: 1GB
  - SSD: 25GB
  - 트래픽: 1TB/월
  
가격: $6/월 (₩8,000)
가입: https://www.vultr.com
```

#### 옵션 B: DigitalOcean (싱가포르 리전)
```yaml
장점:
  - 안정적인 서비스
  - 한국과 가까움 (싱가포르)
  - 월 $6 (₩8,000)
  
사양 (Basic Droplet):
  - CPU: 1 vCore
  - RAM: 1GB
  - SSD: 25GB
  - 트래픽: 1TB/월
  
가격: $6/월
가입: https://www.digitalocean.com
```

#### 옵션 C: Hetzner (가성비 최고)
```yaml
장점:
  - 가장 저렴 (€4.5/월 = ₩6,500)
  - 2GB RAM (다른 곳보다 2배)
  
단점:
  - 유럽 서버 (핀란드)
  - 한국에서 약간 느림 (200-300ms)
  
사양 (CX22):
  - CPU: 2 vCore
  - RAM: 2GB
  - SSD: 40GB
  - 트래픽: 20TB/월
  
가격: €4.5/월 (₩6,500)
가입: https://www.hetzner.com
```

**🎯 최종 추천: Vultr (서울)**

**구매 절차:**
```
1. https://www.vultr.com 접속
2. "Sign Up" 클릭
3. 이메일/비밀번호 입력
4. 이메일 인증
5. 결제 수단 추가 (신용카드)
6. "Deploy New Server" 클릭
7. 설정:
   - Choose Server: Cloud Compute - Shared CPU
   - Server Location: Seoul, South Korea 선택 ✅
   - Server Type: Ubuntu 24.04 LTS x64
   - Server Size: Regular Performance - $6/mo
   - Additional Features: 
     * Enable IPv6 체크 ✅
     * Enable Auto Backups 체크 (선택, +$1.20/월)
8. "Deploy Now" 클릭
9. 3-5분 대기 (서버 생성)
10. IP 주소 확인 및 저장 ✅
```

**저장해야 할 정보:**
```
📌 서버 IP 주소: XXX.XXX.XXX.XXX
📌 Root 비밀번호: (이메일로 전송됨)
📌 서버 위치: Seoul, South Korea
```

---

### Step 1-2: 도메인 구매 ⏱️ 30분

**추천 도메인 등록 대행사:**

#### 옵션 A: Cloudflare Registrar 🏆 추천
```yaml
장점:
  - 원가 판매 (수수료 없음)
  - 무료 DNS
  - 무료 CDN
  - 무료 DDoS 보호
  - 한국어 지원

가격:
  - .com: $9.77/년 (₩13,000)
  - .kr: 등록 불가
  
가입: https://dash.cloudflare.com
```

#### 옵션 B: 가비아 (한국 도메인 필요 시)
```yaml
장점:
  - 한국 업체
  - .kr 도메인 등록 가능
  - 한국어 고객센터

가격:
  - .com: ₩15,000/년
  - .kr: ₩18,000/년
  - .co.kr: ₩20,000/년

가입: https://www.gabia.com
```

**🎯 추천: Cloudflare (.com 도메인)**

**구매 절차 (Cloudflare):**
```
1. https://dash.cloudflare.com 접속
2. "Register a Domain" 클릭
3. 원하는 도메인 검색
   예: jeonghwa-library.com
   예: jeonghwa-book.com
   예: storybook-jh.com
4. 구매 진행
5. 결제 (신용카드)
6. 도메인 확인 ✅
```

**구매 절차 (가비아 - .kr 도메인):**
```
1. https://www.gabia.com 접속
2. 도메인 검색
   예: 정화서재.kr
   예: jeonghwa.co.kr
3. 사업자 정보 입력 (사업자등록번호 필요)
4. 구매 진행
5. 결제
```

**저장해야 할 정보:**
```
📌 구매한 도메인: jeonghwa-library.com
📌 등록 대행사: Cloudflare
📌 Cloudflare 계정: your-email@example.com
```

---

### Step 1-3: DNS 설정 ⏱️ 10분

**Cloudflare DNS 설정:**
```
1. Cloudflare Dashboard 로그인
2. 구매한 도메인 클릭
3. DNS → Records 메뉴
4. "Add record" 클릭
5. 설정:
   - Type: A
   - Name: @ (루트 도메인)
   - IPv4 address: [Vultr 서버 IP]
   - Proxy status: OFF (회색 구름) ⚠️ 중요!
   - TTL: Auto
6. "Save" 클릭
7. www 서브도메인 추가 (선택):
   - Type: CNAME
   - Name: www
   - Target: jeonghwa-library.com
   - Proxy status: OFF
8. "Save" 클릭
```

**확인:**
```bash
# 10-20분 후 터미널에서 확인
nslookup jeonghwa-library.com

# 결과에 Vultr IP가 나오면 성공
```

---

### Step 1-4: Docker Hub 계정 생성 ⏱️ 10분

**Docker Hub는 Docker 이미지 저장소입니다.**

```
1. https://hub.docker.com 접속
2. "Sign Up" 클릭
3. 정보 입력:
   - Docker ID: jeonghwa-library (소문자, 하이픈만)
   - Email: your-email@example.com
   - Password: 강력한 비밀번호
4. 이메일 인증
5. 로그인
6. Account Settings → Security 이동
7. "New Access Token" 클릭
8. 설정:
   - Description: Kamal Deploy
   - Permissions: Read, Write, Delete
9. "Generate" 클릭
10. 토큰 복사 및 저장 ✅ (다시 볼 수 없음!)
```

**저장해야 할 정보:**
```
📌 Docker Hub ID: jeonghwa-library
📌 Access Token: dckr_pat_XXXXXXXXXXXXXXXXX
```

---

### Step 1-5: SSH 키 생성 ⏱️ 20분

**Mac/Linux:**
```bash
# 1. SSH 키 생성
ssh-keygen -t ed25519 -C "your-email@example.com"
# Enter 키 3번 (기본값 사용)

# 2. 공개키 복사
cat ~/.ssh/id_ed25519.pub

# 3. Vultr에 공개키 등록
# Vultr Dashboard → Account → SSH Keys → Add SSH Key
# Label: MacBook Pro
# SSH Key: (위에서 복사한 내용 붙여넣기)

# 4. 서버 접속 테스트
ssh root@[Vultr_IP]
# yes 입력
# 접속 성공하면 exit
```

**Windows (PowerShell):**
```powershell
# 1. SSH 키 생성
ssh-keygen -t ed25519 -C "your-email@example.com"
# Enter 키 3번

# 2. 공개키 복사
type $env:USERPROFILE\.ssh\id_ed25519.pub

# 3. Vultr에 등록 (위와 동일)

# 4. 접속 테스트
ssh root@[Vultr_IP]
```

**저장해야 할 정보:**
```
📌 SSH 키 위치: ~/.ssh/id_ed25519
📌 서버 접속 명령: ssh root@[Vultr_IP]
```

---

## 🎯 Phase 2: AI 자동화 작업 준비

### Step 2-1: 필요한 정보 전달 📝

**AI에게 다음 정보를 전달해주세요:**

```markdown
## 배포 정보

### 서버 정보
- VPS IP: XXX.XXX.XXX.XXX
- 서버 위치: Seoul, South Korea
- SSH 사용자: root

### 도메인 정보
- 도메인: jeonghwa-library.com
- DNS 등록 대행사: Cloudflare

### Docker Hub 정보
- Docker Hub ID: jeonghwa-library
- Access Token: dckr_pat_XXXXX (비밀)

### 환경변수 정보
- RAILS_MASTER_KEY: (config/master.key 파일 내용)
- GOOGLE_APPLICATION_CREDENTIALS: (필요 시)
- VERTEX_PROJECT_ID: your-gcp-project-id
- TOSS_CLIENT_KEY: live_ck_XXXXX (나중에)
- TOSS_SECRET_KEY: live_sk_XXXXX (나중에)
```

---

## 🟢 Phase 3: AI 자동 설정 작업

**이 부분은 제가 자동으로 처리합니다. 사용자는 정보만 전달하면 됩니다.**

### AI가 자동으로 하는 작업:

1. ✅ `config/deploy.yml` 수정
   - 서버 IP 설정
   - 도메인 설정
   - Docker Hub 설정

2. ✅ `.kamal/secrets` 파일 생성
   - 환경변수 암호화
   - 보안 설정

3. ✅ `config/deploy.local.yml` 생성
   - 로컬 테스트 설정

4. ✅ 배포 전 체크리스트 생성

5. ✅ 배포 스크립트 작성

6. ✅ 롤백 스크립트 작성

---

## 🚀 Phase 4: 실제 배포 (사용자 작업)

### Step 4-1: 서버 초기 설정 ⏱️ 10분

```bash
# 1. 서버 접속
ssh root@[Vultr_IP]

# 2. 시스템 업데이트
apt update && apt upgrade -y

# 3. Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 4. Docker 확인
docker --version
# Docker version 27.x.x 출력되면 성공

# 5. 로그아웃
exit
```

### Step 4-2: Kamal 설치 및 설정 ⏱️ 5분

```bash
# 로컬 맥에서 실행
cd /Users/l2dogyu/KICDA/ruby/kicda-jh

# Kamal 설치 (이미 설치됨)
gem install kamal

# Kamal 버전 확인
kamal version

# Docker Hub 로그인
docker login
# Username: jeonghwa-library
# Password: [Access Token]
```

### Step 4-3: 첫 배포 ⏱️ 15-20분

```bash
# 1. Kamal 초기 설정
kamal setup

# 진행 상황 (예상):
# - Docker 컨테이너 준비
# - 데이터베이스 마이그레이션
# - 애셋 프리컴파일
# - SSL 인증서 발급 (Let's Encrypt)
# - 서버 시작

# 2. 배포 확인
kamal app logs

# 3. 브라우저에서 접속
# https://jeonghwa-library.com
```

**예상 출력:**
```
Acquiring the deploy lock
Building the image
Pushing the image
Healthcheck passed
Booting app on [IP]
```

---

## 🔍 Phase 5: 배포 후 확인

### 확인 체크리스트

```bash
# 1. 서버 상태 확인
kamal app exec 'bin/rails runner "puts Rails.env"'
# => production

# 2. 데이터베이스 확인
kamal app exec 'bin/rails runner "puts User.count"'
# => 숫자 출력

# 3. SSL 인증서 확인
# 브라우저에서 https://jeonghwa-library.com 접속
# 자물쇠 아이콘 확인

# 4. 로그 확인
kamal app logs -f

# 5. 콘솔 접속 (테스트)
kamal app exec --interactive --reuse "bin/rails console"
# Rails 콘솔이 열리면 성공
# exit로 종료
```

---

## 📊 예상 비용 정리

### 월간 비용 (₩ 기준, 1$ = ₩1,350)

```yaml
필수 비용:
  VPS (Vultr Seoul): $6/월 = ₩8,100/월
  도메인 (Cloudflare): $9.77/년 = ₩810/월
  Docker Hub (무료): $0
  소계: ₩8,910/월

선택 비용:
  VPS 백업: $1.20/월 = ₩1,620/월
  추가 스토리지: $1/월 = ₩1,350/월
  
총계:
  기본: ₩8,910/월 (약 ₩9,000)
  백업 포함: ₩10,530/월 (약 ₩11,000)
```

### 연간 비용
```
기본: ₩106,920/년 (약 ₩107,000)
백업 포함: ₩126,360/년 (약 ₩126,000)
```

---

## 🛠️ 자주 사용하는 명령어

### 일상 운영

```bash
# 로그 확인 (실시간)
kamal app logs -f

# 앱 재시작
kamal app restart

# 새 버전 배포
git push origin main
kamal deploy

# 서버 상태 확인
kamal app details

# Rails 콘솔 접속
kamal app exec --interactive --reuse "bin/rails console"

# 데이터베이스 마이그레이션
kamal app exec "bin/rails db:migrate"
```

### 문제 해결

```bash
# 이전 버전으로 롤백
kamal rollback [version]

# 컨테이너 재시작
kamal app restart

# 서버 SSH 접속
ssh root@[Vultr_IP]

# Docker 컨테이너 확인
kamal app exec "docker ps"

# 디스크 용량 확인
kamal app exec "df -h"

# 메모리 사용량 확인
kamal app exec "free -m"
```

---

## ⚠️ 주의사항

### 보안

1. **비밀번호 관리**
   ```
   ❌ GitHub에 커밋 금지:
   - .kamal/secrets
   - config/master.key
   - .env
   
   ✅ .gitignore 확인:
   .kamal/secrets*
   config/master.key
   .env*
   ```

2. **방화벽 설정**
   ```bash
   # Vultr 방화벽 (권장)
   # Dashboard → Firewall → Add Firewall Group
   # 규칙:
   # - SSH (22): Your IP만 허용
   # - HTTP (80): 모든 IP 허용
   # - HTTPS (443): 모든 IP 허용
   ```

3. **정기 백업**
   ```bash
   # 데이터베이스 백업 (매일)
   kamal app exec "bin/rails db:backup"
   
   # 파일 백업
   # Vultr Auto Backups 활성화 ($1.20/월)
   ```

### 성능

1. **모니터링**
   ```bash
   # 리소스 사용량 확인
   kamal app exec "htop"
   
   # 로그 크기 확인
   kamal app exec "du -sh /rails/log"
   
   # 로그 정리 (주 1회)
   kamal app exec "bin/rails log:clear"
   ```

2. **업그레이드 시점**
   ```
   다음과 같을 때 서버 업그레이드:
   - 메모리 사용률 > 80%
   - CPU 사용률 > 70% (지속)
   - 디스크 사용률 > 80%
   - 응답 속도 > 3초
   ```

---

## 🆘 문제 해결 가이드

### 배포 실패 시

```bash
# 1. 로그 확인
kamal app logs

# 2. 상세 로그
kamal deploy --verbose

# 3. 컨테이너 상태
ssh root@[IP]
docker ps -a

# 4. 네트워크 확인
ping jeonghwa-library.com

# 5. DNS 확인
nslookup jeonghwa-library.com
```

### SSL 인증서 오류

```bash
# 1. 인증서 갱신
kamal proxy renew_ssl

# 2. 프록시 재시작
kamal proxy restart

# 3. DNS 재확인
# Cloudflare Proxy OFF 확인 (회색 구름)
```

### 데이터베이스 오류

```bash
# 1. 마이그레이션 상태 확인
kamal app exec "bin/rails db:migrate:status"

# 2. 마이그레이션 실행
kamal app exec "bin/rails db:migrate"

# 3. 롤백
kamal app exec "bin/rails db:rollback"
```

---

## 📞 긴급 연락처

### VPS 문제
- Vultr 지원: https://my.vultr.com/support/
- 응답 시간: 1-4시간

### 도메인 문제
- Cloudflare 지원: https://dash.cloudflare.com/support
- 한국어 커뮤니티: https://community.cloudflare.com

### Rails 문제
- Rails 가이드: https://guides.rubyonrails.org
- 커뮤니티: https://discuss.rubyonrails.org

---

## 📋 배포 전 최종 체크리스트

### 필수 확인 사항

- [ ] **VPS 구매 완료**
  - [ ] 서버 IP 확보
  - [ ] Root 비밀번호 확보
  - [ ] 서버 위치: Seoul

- [ ] **도메인 구매 완료**
  - [ ] 도메인 등록
  - [ ] DNS A 레코드 설정
  - [ ] Cloudflare Proxy OFF

- [ ] **Docker Hub 준비**
  - [ ] 계정 생성
  - [ ] Access Token 발급

- [ ] **SSH 설정 완료**
  - [ ] SSH 키 생성
  - [ ] Vultr에 공개키 등록
  - [ ] 서버 접속 테스트

- [ ] **환경변수 준비**
  - [ ] RAILS_MASTER_KEY
  - [ ] Docker Hub Token
  - [ ] (선택) GCP 인증 정보

- [ ] **서버 초기 설정**
  - [ ] Docker 설치
  - [ ] 방화벽 설정

- [ ] **AI에 정보 전달**
  - [ ] 서버 IP
  - [ ] 도메인
  - [ ] Docker Hub ID
  - [ ] 환경변수

---

## 🎉 배포 성공 후

### 다음 단계

1. **Google Analytics 설정** (선택)
2. **Google Search Console 등록** (SEO)
3. **Sentry 오류 추적** (선택)
4. **Uptime 모니터링** (UptimeRobot 무료)
5. **정기 백업 자동화**

### 운영 루틴

**매일:**
- 로그 확인 (`kamal app logs`)
- 에러 확인

**매주:**
- 백업 확인
- 디스크 용량 확인
- 보안 업데이트

**매월:**
- 비용 확인
- 성능 모니터링
- 사용자 피드백 수집

---

**작성일:** 2025년 10월 23일  
**업데이트:** 배포 후 경험 반영 예정  
**문의:** 각 단계에서 문제 발생 시 AI에게 질문

---

## 🚀 준비되셨나요?

**다음 단계:**
1. 위 정보들을 모두 수집하세요
2. AI에게 전달하세요
3. AI가 설정 파일을 자동 생성합니다
4. 배포 명령어 실행!

**예상 시간:**
- 사전 준비: 1.5-2시간
- AI 설정: 즉시
- 배포: 15-20분
- **총: 2-2.5시간**

화이팅! 🎊


