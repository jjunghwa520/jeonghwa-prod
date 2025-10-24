# 배포 빠른 체크리스트 ✅

**목표:** 2시간 안에 배포 완료  
**난이도:** ⭐⭐⭐☆☆ (중급)

---

## 📝 정보 수집 (30분)

### 1. VPS 정보
```
□ 회사: Vultr / DigitalOcean / Hetzner
□ 서버 IP: ___.___.___.___ 
□ 서버 위치: Seoul / Singapore / Finland
□ Root 비밀번호: ______________
```

### 2. 도메인 정보
```
□ 도메인: __________________.com
□ 등록 대행사: Cloudflare / 가비아
□ DNS A 레코드 설정 완료: ☐
□ Cloudflare Proxy OFF 확인: ☐
```

### 3. Docker Hub 정보
```
□ Docker Hub ID: ______________
□ Access Token: dckr_pat_____________
```

### 4. SSH 설정
```
□ SSH 키 생성 완료: ☐
□ Vultr에 공개키 등록: ☐
□ 서버 접속 테스트: ☐
```

### 5. 환경변수
```
□ RAILS_MASTER_KEY: (config/master.key)
□ Docker Hub Token: 위에서 준비
□ GCP 정보: (선택사항)
```

---

## 🤖 AI에게 전달할 정보

**다음 형식으로 AI에게 전달:**

```markdown
배포 준비 완료! 다음 정보로 설정 파일 생성해주세요:

**서버:**
- IP: 123.123.123.123
- 위치: Seoul
- 사용자: root

**도메인:**
- 도메인: jeonghwa-library.com
- DNS: Cloudflare

**Docker Hub:**
- ID: jeonghwa-library
- Token: dckr_pat_xxxxx

**환경변수:**
- RAILS_MASTER_KEY: [master.key 파일 내용]
```

---

## 🟢 AI 자동 작업 대기

AI가 다음을 자동 생성:
```
✅ config/deploy.yml
✅ .kamal/secrets
✅ 배포 스크립트
✅ 체크리스트
```

---

## 🚀 배포 실행 (15분)

### 서버 준비
```bash
ssh root@[IP]
apt update && apt upgrade -y
curl -fsSL https://get.docker.com | sh
docker --version
exit
```

### 로컬 준비
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
gem install kamal
docker login
```

### 배포!
```bash
kamal setup
```

### 확인
```bash
kamal app logs
# 브라우저에서 https://your-domain.com 접속
```

---

## ✅ 배포 후 확인

```bash
□ HTTPS 접속 성공
□ SSL 인증서 정상 (자물쇠 아이콘)
□ 홈페이지 로드됨
□ 강의 목록 보임
□ 이미지 로드됨
□ 로그인 테스트
□ 회원가입 테스트
```

---

## 💰 월 비용

```
VPS: ₩8,100
도메인: ₩810
총: ₩8,910/월
```

---

## 🆘 문제 시

```bash
# 로그 확인
kamal app logs

# 재배포
kamal deploy

# 롤백
kamal rollback
```

---

**준비됐으면 AI에게 정보 전달!** 🚀


