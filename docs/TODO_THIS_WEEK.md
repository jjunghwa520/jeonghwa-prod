# ✅ 이번 주 해야 할 일 (3일)

**날짜**: 2025년 10월 20일 (일) - 10월 22일 (화)  
**목표**: SEO 기본 설정 + 도메인 준비 완료

---

## 🎉 자동 준비 완료 (제가 했습니다!)

### ✅ Google Analytics 4 준비
```
□ 추적 코드 레이아웃 추가 완료
□ 환경변수 방식 설정 (GOOGLE_ANALYTICS_ID)
□ IP 익명화 (anonymize_ip: true)
□ 개인정보 보호 준수
```

**파일**: `app/views/layouts/application.html.erb` (48-61번 라인)

---

### ✅ robots.txt 프로덕션 준비
```
□ Sitemap 링크: https://jeonghwa.kr/sitemap.xml.gz
□ 관리자 페이지 차단 (/admin/)
□ 중복 콘텐츠 차단 (쿼리 파라미터)
□ 크롤링 속도 조절 (1초 대기)
```

**파일**: `public/robots.txt`

---

### ✅ sitemap.xml 자동 생성
```
□ sitemap_generator gem 설치됨
□ sitemap.xml.gz 이미 생성됨
□ 자동 업데이트 설정됨
```

**파일**: `public/sitemap.xml.gz`

---

### ✅ Open Graph 메타태그
```
□ og_meta_tags 헬퍼 구현 완료
□ 코스 상세 페이지 적용 ✅
□ 코스 목록 페이지 적용 ✅
□ 홈페이지 적용 ✅
□ Twitter Card 지원 ✅
```

**파일**: `app/helpers/application_helper.rb` (60-74번 라인)

---

## 👤 사용자님이 직접 하실 것

### Day 1: Google Analytics 계정 생성 (30분)

#### 1. GA4 계정 만들기
```
1. https://analytics.google.com 접속
2. "측정 시작" 클릭
3. 계정 이름: "정화의서재"
4. 속성 이름: "정화의서재 웹사이트"
5. 데이터 스트림 생성 (웹)
   - URL: https://jeonghwa.kr (또는 임시 localhost:3000)
   - 스트림 이름: 정화의서재
```

#### 2. 측정 ID 복사 ⭐
```
예시: G-XXXXXXXXXX

이 ID를 꼭 메모하세요!
```

#### 3. 환경변수 설정
```bash
# 방법 1: .zshrc
echo 'export GOOGLE_ANALYTICS_ID="G-XXXXXXXXXX"' >> ~/.zshrc
source ~/.zshrc

# 방법 2: .env 파일 (권장)
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
echo "GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX" >> .env
```

#### 4. 서버 재시작 및 확인
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
rails s

# 브라우저: http://localhost:3000
# 개발자도구 → Network → "gtag" 검색
# Google Analytics → 실시간 보고서 확인
```

**📖 상세 가이드**: `docs/GOOGLE_ANALYTICS_SETUP.md`

---

### Day 2: Search Console 등록 (20분)

#### 1. Search Console 속성 추가
```
1. https://search.google.com/search-console 접속
2. "속성 추가" → "URL 접두어"
3. URL: https://jeonghwa.kr
4. 소유권 확인: "Google Analytics" 선택 (자동 확인!)
```

#### 2. Sitemap 제출
```
1. Search Console → Sitemaps
2. 새 사이트맵 추가: sitemap.xml.gz
3. 제출 클릭
4. 상태 확인: "성공" (24시간 내)
```

#### 3. 주요 페이지 색인 요청
```
URL 검사 → 색인 생성 요청:
- https://jeonghwa.kr (홈)
- https://jeonghwa.kr/courses (코스 목록)
- https://jeonghwa.kr/courses/1 (인기 코스)
```

**📖 상세 가이드**: `docs/SEARCH_CONSOLE_SETUP.md`

---

### Day 3: 도메인 구매 + Cloudflare (60분)

#### 1. 가비아 도메인 구매 (30분)
```
1. https://www.gabia.com 접속
2. 회원가입/로그인
3. 도메인 검색: jeonghwa.kr (또는 정화의서재.kr)
4. 가격 확인: ₩18,000/년
5. 구매 및 등록 정보 입력:
   - 상호: 정화의서재
   - 사업자번호: 869-30-01778
   - 주소: 인천광역시 부평구 마장로 264번길 33
```

#### 2. Cloudflare 무료 플랜 (20분)
```
1. https://dash.cloudflare.com 회원가입
2. "Add a Site" → jeonghwa.kr
3. 플랜: Free $0/month 선택
4. Cloudflare 네임서버 확인 (메모!)
   예: bob.ns.cloudflare.com
       dee.ns.cloudflare.com
```

#### 3. 가비아 네임서버 변경 (10분)
```
1. 가비아 → 마이페이지 → 도메인 관리
2. jeonghwa.kr 선택 → 네임서버 변경
3. Cloudflare 네임서버 입력
4. 적용 → DNS 전파 대기 (10-30분)
```

#### 4. Cloudflare API Token 생성
```
1. Profile → API Tokens
2. Create Token → "Edit zone DNS"
3. Zone: jeonghwa.kr
4. 토큰 복사 및 저장:
   📌 CLOUDFLARE_API_TOKEN=xxxxx
   📌 CLOUDFLARE_ZONE_ID=xxxxx
```

**📖 상세 가이드**: `docs/GABIA_CLOUDFLARE_SETUP.md`

---

## 💰 예상 비용

```
가비아 도메인 (.kr): ₩18,000/년 (₩1,500/월)
Cloudflare Free: 무료
Google Analytics: 무료
Search Console: 무료

총 비용: ₩18,000/년 = ₩1,500/월
```

---

## 🎯 성공 기준

### Google Analytics ✅
```
□ 측정 ID 발급 완료
□ 환경변수 설정 완료
□ 실시간 보고서에 데이터 표시
□ 페이지뷰 기록됨
```

### Search Console ✅
```
□ 속성 추가 완료
□ 소유권 확인 완료
□ Sitemap 제출 완료
□ 주요 페이지 색인 요청 완료
```

### 도메인 + Cloudflare ✅
```
□ 도메인 구매 완료
□ Cloudflare 계정 생성
□ 네임서버 변경 완료
□ DNS Active 상태 확인
□ API Token 발급 완료
```

---

## 🚀 완료 후 다음 단계

### 1주일 후
```
□ Search Console 색인 상태 확인 (20-30개 예상)
□ Google Analytics 데이터 분석
□ 검색 키워드 파악
```

### 2주일 후
```
□ GCP Cloud Run 프로덕션 배포
□ 커스텀 도메인 매핑 (jeonghwa.kr)
□ SSL 인증서 자동 발급 확인
□ HTTPS 작동 확인
```

### 1개월 후
```
□ SEO 성과 분석:
  - 검색 노출수: 100+
  - 클릭수: 5+
  - 평균 게재순위: 50위 이내
□ 전환율 분석 (방문 → 가입 → 구매)
```

---

## 📞 도움말

### 문서 위치
```
docs/
├─ WEEK_PLAN_2025-10-20.md (전체 주간 계획)
├─ GOOGLE_ANALYTICS_SETUP.md (GA4 설치)
├─ SEARCH_CONSOLE_SETUP.md (Search Console)
├─ GABIA_CLOUDFLARE_SETUP.md (도메인)
├─ GCP_COMPLETE_GUIDE.md (GCP 배포)
└─ FINAL_HANDOVER_2025-10-19.md (전체 인수인계)
```

### 검증 명령어
```bash
# 환경변수 확인
echo $GOOGLE_ANALYTICS_ID

# 서버 상태
curl http://localhost:3000

# DNS 확인
nslookup jeonghwa.kr

# Sitemap 확인
curl http://localhost:3000/sitemap.xml.gz -I
```

---

## ⏰ 예상 소요 시간

```
Day 1 (GA4): 30분
Day 2 (Search Console): 20분
Day 3 (도메인): 60분

총: 110분 (약 2시간)
```

---

## 🎊 완료 체크리스트

### 자동 준비 (완료!) ✅
- [x] Google Analytics 코드 추가
- [x] robots.txt 작성
- [x] sitemap.xml 생성
- [x] Open Graph 메타태그

### Day 1: Google Analytics
- [ ] GA4 계정 생성
- [ ] 측정 ID 발급
- [ ] 환경변수 설정
- [ ] 실시간 데이터 확인

### Day 2: Search Console
- [ ] 속성 추가
- [ ] 소유권 확인
- [ ] Sitemap 제출
- [ ] 색인 요청

### Day 3: 도메인
- [ ] 가비아 도메인 구매
- [ ] Cloudflare 설정
- [ ] 네임서버 변경
- [ ] DNS 전파 확인

---

**화이팅! 🚀**

**다음 작업**: GCP Cloud Run 프로덕션 배포  
**예상 런칭일**: 2025년 11월 초


