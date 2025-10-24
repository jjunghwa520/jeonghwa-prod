# 가비아 도메인 + Cloudflare DNS 완벽 가이드

**목표:** 한글(.kr) 도메인 + Cloudflare 무료 기능 + GCP 통합  
**시간:** 30분  
**비용:** ₩18,000/년 (도메인만)

---

## 🎯 전체 아키텍처

```
가비아 (.kr 도메인 등록)
    ↓ (네임서버 변경)
Cloudflare (무료 DNS + CDN + SSL)
    ↓
Google Cloud Platform
├─ Cloud Run (Rails 앱)
├─ Cloud Storage (이미지)
└─ Vertex AI (이미지 생성)
```

---

## 📋 Step 1: 가비아 도메인 구매

### 1-1: 가비아 회원가입

```
1. https://www.gabia.com 접속
2. 우측 상단 "회원가입"
3. 이메일/비밀번호/휴대폰 인증
4. 로그인
```

### 1-2: 도메인 검색 및 구매

```
1. 검색창에 원하는 도메인 입력
   예: jeonghwa
   예: 정화의서재

2. 확장자 선택
   □ .kr (추천) - ₩18,000/년
   □ .co.kr (사업자) - ₩20,000/년
   □ .com - ₩15,000/년

3. "등록가능" 확인 후 장바구니

4. 등록 정보 입력
   - 한글 이름/주소
   - 연락처/이메일
   
5. 결제 (신용카드/계좌이체)

6. 구매 완료!
```

**저장할 정보:**
```
📌 도메인: jeonghwa.kr
📌 가비아 계정: your-email@gmail.com
📌 가비아 비밀번호: ********
```

---

## 📋 Step 2: Cloudflare 무료 플랜 설정

### 2-1: Cloudflare 계정 생성

```
1. https://dash.cloudflare.com 접속
2. Sign Up
3. 이메일/비밀번호 입력
4. 이메일 인증
5. 로그인
```

### 2-2: 사이트 추가 (무료)

```
1. "Add a Site" 클릭

2. 도메인 입력
   예: jeonghwa.kr

3. 플랜 선택
   ✅ Free $0/month 선택 ⭐

4. "Continue" 클릭

5. DNS 레코드 스캔 대기 (1-2분)

6. "Continue" 클릭
```

### 2-3: Cloudflare 네임서버 확인

Cloudflare가 제공하는 네임서버 **꼭 메모!**

```
예시:
📌 bob.ns.cloudflare.com
📌 dee.ns.cloudflare.com

(실제로는 다른 이름이 나올 수 있음)
```

---

## 📋 Step 3: 가비아에서 네임서버 변경

### 3-1: 가비아 로그인

```
1. https://www.gabia.com 로그인

2. 마이페이지 → 도메인 관리

3. 구매한 도메인 (jeonghwa.kr) 선택
```

### 3-2: 네임서버 변경

```
1. "네임서버 설정" 또는 "정보변경" 클릭

2. "네임서버 변경" 선택

3. "직접 입력" 또는 "다른 네임서버 사용" 선택

4. Cloudflare 네임서버 입력:
   
   네임서버 1: bob.ns.cloudflare.com
   네임서버 2: dee.ns.cloudflare.com
   
   ※ Cloudflare에서 받은 실제 네임서버 입력!

5. "적용" 또는 "저장" 클릭

6. 확인 메시지 확인

완료! ✅
```

**주의:**
- DNS 전파 시간: 몇 분 ~ 24시간
- 보통 10-30분 내에 완료

---

## 📋 Step 4: Cloudflare DNS 설정 확인

### 4-1: 전파 확인

```
1. Cloudflare Dashboard로 돌아가기

2. "Quick Scan Complete" 메시지 확인

3. Status 확인
   - Pending: 아직 전파 중
   - Active: 완료! ✅

※ 최대 24시간 대기
```

### 4-2: DNS 레코드 추가 (나중에)

배포 시 GCP 서버 IP를 받은 후:

```
1. Cloudflare → DNS → Records

2. Add record
   - Type: A
   - Name: @ (루트 도메인)
   - IPv4 address: [GCP Cloud Run IP]
   - Proxy status: DNS only (회색 구름) ⚠️
   - TTL: Auto

3. Add record (www)
   - Type: CNAME
   - Name: www
   - Target: jeonghwa.kr
   - Proxy status: DNS only
   - TTL: Auto

4. Save
```

---

## 📋 Step 5: Cloudflare 무료 기능 활성화

### 5-1: SSL/TLS 설정

```
1. Cloudflare → SSL/TLS

2. Overview
   - Encryption mode: Full (strict) ✅

3. Edge Certificates
   - Always Use HTTPS: ON ✅
   - Automatic HTTPS Rewrites: ON ✅
   - Minimum TLS Version: 1.2 ✅

완료!
```

### 5-2: 속도 최적화

```
1. Speed → Optimization

2. 활성화:
   ✅ Auto Minify (JavaScript, CSS, HTML)
   ✅ Brotli
   ✅ Early Hints
   ✅ Rocket Loader (선택)

3. Save
```

### 5-3: 캐싱 설정

```
1. Caching → Configuration

2. Caching Level: Standard

3. Browser Cache TTL: 4 hours (권장)

4. Always Online: ON ✅

5. Save
```

---

## 🤖 AI 자동화 설정

### Cloudflare API Token 생성

```
1. Profile → API Tokens

2. Create Token

3. Template: Edit zone DNS

4. Permissions:
   - Zone - DNS - Edit
   - Zone - Zone Settings - Read

5. Zone Resources:
   - Include - Specific zone - jeonghwa.kr

6. Continue

7. Create Token

8. 토큰 복사 및 저장 ⚠️
   (다시 볼 수 없음!)
```

**저장:**
```
📌 Cloudflare API Token: xxxxxxxxxxxxxxxxxxxxx
📌 Zone ID: (DNS 페이지에서 확인)
```

---

## ✅ 완료 확인 체크리스트

### 가비아
```
□ 도메인 구매 완료
□ 네임서버를 Cloudflare로 변경 완료
□ 상태: 정상
```

### Cloudflare
```
□ 사이트 추가 완료 (Free 플랜)
□ DNS Active 상태 확인
□ SSL/TLS 설정 완료
□ 캐싱 설정 완료
□ API Token 생성 완료
```

---

## 💰 비용 정리

```
가비아 도메인 (.kr):
  ₩18,000/년 (₩1,500/월)

Cloudflare (무료 플랜):
  DNS: 무료
  CDN: 무료
  SSL: 무료
  DDoS 보호: 무료
  API: 무료

총 비용:
  ₩18,000/년 = ₩1,500/월
```

---

## 🎯 다음 단계

### GCP Cloud Run 배포 시

```
1. Cloud Run에서 서비스 배포

2. Cloud Run 제공 URL 확인
   예: https://jeonghwa-xxxxx-an.a.run.app

3. Cloudflare에서 DNS 설정
   - Type: CNAME
   - Name: @
   - Target: ghs.googlehosted.com
   
   또는
   
   - Type: A
   - Name: @
   - IPv4: [Cloud Run IP]

4. Cloud Run에서 커스텀 도메인 매핑
   gcloud run domain-mappings create \
     --service=jeonghwa-library \
     --domain=jeonghwa.kr

5. SSL 자동 발급 (Cloudflare + GCP)

완료! 🎉
```

---

## ⚠️ 주의사항

### 1. Proxy Status (중요!)

```
Cloudflare DNS 설정 시:

❌ Proxied (주황 구름) - 사용하면 안 됨!
   → Cloud Run SSL 충돌

✅ DNS only (회색 구름) - 반드시 이것!
   → GCP와 직접 연결
```

### 2. DNS 전파 시간

```
네임서버 변경 후:
- 최소: 10-30분
- 최대: 24-48시간
- 평균: 1-2시간

확인:
nslookup jeonghwa.kr
```

### 3. SSL 인증서

```
GCP Cloud Run:
- Let's Encrypt 자동 발급
- 자동 갱신
- Cloudflare와 무관

Cloudflare:
- Universal SSL (무료)
- Edge 인증서만
```

---

## 🎓 고급 기능 (선택)

### Cloudflare Workers (엣지 컴퓨팅)

```
무료 플랜:
- 100,000 요청/일
- 사용 예:
  * 이미지 리사이징
  * A/B 테스트
  * 리다이렉트
  * 간단한 API
```

### Cloudflare Pages (정적 사이트)

```
무료 플랜:
- 무제한 사이트
- 자동 빌드/배포
- 사용 예:
  * 랜딩 페이지
  * 문서 사이트
  * 블로그
```

---

## 📞 문제 해결

### DNS가 Active 안 됨

```
1. 가비아 네임서버 변경 확인
   - 마이페이지 → 도메인 관리
   - 네임서버 정보 확인

2. Cloudflare 네임서버 재확인
   - Dashboard → Overview
   - 정확히 입력했는지 확인

3. 최대 24시간 대기
```

### SSL 오류

```
1. Cloudflare SSL 설정 확인
   - Full (strict) 모드

2. Cloud Run 인증서 확인
   gcloud run domain-mappings describe \
     --domain=jeonghwa.kr

3. DNS Proxy 확인
   - DNS only (회색 구름)
```

---

## ✅ 최종 확인

모든 설정 완료 후:

```bash
# DNS 확인
nslookup jeonghwa.kr

# SSL 확인
curl -I https://jeonghwa.kr

# 속도 테스트
curl -w "@curl-format.txt" -o /dev/null -s https://jeonghwa.kr
```

---

**작성일:** 2025년 10월 23일  
**다음 문서:** GCP Cloud Run 배포 가이드

**완료!** 🎉

