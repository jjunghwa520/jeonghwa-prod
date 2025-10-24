# 📊 Google Analytics 4 설치 가이드

**소요 시간**: 30분  
**비용**: 무료  
**난이도**: 쉬움

---

## 🎯 목표

- Google Analytics 4 (GA4) 계정 생성
- 측정 ID 발급
- 정화의서재 웹사이트에 추적 코드 설치
- 실시간 데이터 확인

---

## ✅ 1단계: 코드 준비 완료

**이미 완료됨!** ✅

```erb
<!-- app/views/layouts/application.html.erb -->
<% if ENV['GOOGLE_ANALYTICS_ID'].present? %>
  <script async src="https://www.googletagmanager.com/gtag/js?id=<%= ENV['GOOGLE_ANALYTICS_ID'] %>"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', '<%= ENV['GOOGLE_ANALYTICS_ID'] %>', {
      'send_page_view': true,
      'anonymize_ip': true  // 개인정보 보호
    });
  </script>
<% end %>
```

**특징**:
- ✅ 환경변수 방식 (보안)
- ✅ IP 익명화 (GDPR 준수)
- ✅ 자동 페이지뷰 추적
- ✅ 프로덕션만 작동 (개발 환경 오염 방지)

---

## 👤 2단계: Google Analytics 계정 생성 (10분)

### 2-1: Google Analytics 접속

```
1. https://analytics.google.com 접속
2. Google 계정으로 로그인
   (Gmail 계정 사용)
```

### 2-2: 계정 만들기

```
1. "측정 시작" 또는 "관리" → "계정 만들기" 클릭

2. 계정 이름 입력:
   📌 "정화의서재"

3. 계정 데이터 공유 설정:
   ✅ 권장 (모두 체크)
   - Google 제품 및 서비스
   - 벤치마킹
   - 기술 지원
   - 계정 전문가

4. "다음" 클릭
```

### 2-3: 속성 만들기

```
1. 속성 이름:
   📌 "정화의서재 웹사이트"

2. 보고 시간대:
   📌 대한민국 (GMT+09:00)

3. 통화:
   📌 대한민국 원 (₩)

4. "다음" 클릭
```

### 2-4: 비즈니스 정보

```
1. 산업 카테고리:
   📌 "교육"
   
2. 비즈니스 규모:
   📌 "소규모: 직원 1~10명"

3. 비즈니스 목표 (복수 선택 가능):
   ✅ 기준 보고서 받기
   ✅ 고객 행동 분석
   ✅ 수익 증대

4. "만들기" 클릭
5. 서비스 약관 동의 ✅
```

---

## 📊 3단계: 데이터 스트림 생성 (5분)

### 3-1: 웹 스트림 추가

```
1. "웹" 선택

2. 웹사이트 URL:
   개발: http://localhost:3000
   프로덕션: https://jeonghwa.kr
   
   📌 일단 localhost:3000으로 시작 (나중에 변경 가능)

3. 스트림 이름:
   📌 "정화의서재"

4. "스트림 만들기" 클릭
```

### 3-2: 측정 ID 복사 ⭐ 중요!

```
생성 후 화면에 표시되는 측정 ID 복사:

예시:
  📌 G-XXXXXXXXXX
  
  (실제로는 G-로 시작하는 10자리 코드)

이 ID를 꼭 메모하세요!
```

---

## 🔧 4단계: 환경변수 설정 (5분)

### 방법 1: .zshrc에 추가 (개발 환경)

```bash
# 터미널에서 실행
echo 'export GOOGLE_ANALYTICS_ID="G-XXXXXXXXXX"' >> ~/.zshrc
source ~/.zshrc

# 확인
echo $GOOGLE_ANALYTICS_ID
# → G-XXXXXXXXXX 출력되면 성공!
```

### 방법 2: .env 파일 사용 (권장)

```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh

# .env 파일 생성 또는 수정
echo "GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX" >> .env

# Gemfile에 dotenv-rails 추가 (이미 있으면 생략)
# gem 'dotenv-rails', groups: [:development, :test]

# 번들 설치
bundle install
```

### 방법 3: 프로덕션 환경 (GCP Cloud Run)

```bash
# 배포 시 환경변수 설정
gcloud run deploy jeonghwa-library \
  --set-env-vars GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX \
  --region asia-northeast3
```

---

## ✅ 5단계: 테스트 (5분)

### 5-1: 서버 재시작

```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh

# 환경변수 적용을 위해 서버 재시작
rails s
```

### 5-2: 브라우저에서 확인

```
1. http://localhost:3000 접속

2. 개발자도구 열기 (F12 또는 Cmd+Option+I)

3. Network 탭 → 필터: "gtag" 입력

4. 페이지 새로고침 (Cmd+R)

5. 확인:
   ✅ gtag/js?id=G-XXXXXXXXXX 요청 200 OK
   ✅ collect?v=2&... 요청 (페이지뷰 전송)
```

### 5-3: Google Analytics 실시간 확인

```
1. Google Analytics로 돌아가기
2. 왼쪽 메뉴 → "보고서" → "실시간"
3. 확인:
   ✅ 현재 사용자: 1 (본인)
   ✅ 페이지뷰: 증가
   ✅ 이벤트: page_view 기록됨
```

---

## 🎯 6단계: 고급 설정 (선택사항)

### 이벤트 추적 예시

```javascript
// 장바구니 추가 이벤트
gtag('event', 'add_to_cart', {
  'event_category': 'ecommerce',
  'event_label': '전자동화책: 백설공주',
  'value': 4500
});

// 코스 구매 이벤트
gtag('event', 'purchase', {
  'transaction_id': 'T12345',
  'value': 4500,
  'currency': 'KRW',
  'items': [{
    'item_id': 'course_1',
    'item_name': '백설공주',
    'item_category': '전자동화책',
    'price': 4500
  }]
});

// 코스 수강 시작
gtag('event', 'begin_course', {
  'event_category': 'engagement',
  'event_label': '구연동화: 신데렐라',
  'value': 1
});
```

### Rails 컨트롤러에서 이벤트 전송

```ruby
# app/controllers/cart_items_controller.rb
def create
  @cart_item = current_user.cart_items.build(cart_item_params)
  
  if @cart_item.save
    # GA4 이벤트 추가
    @ga_event = {
      event: 'add_to_cart',
      course_id: @cart_item.course.id,
      course_title: @cart_item.course.title,
      price: @cart_item.course.price
    }
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path }
    end
  end
end
```

---

## 🔍 7단계: 검증 체크리스트

### 기술적 검증
```bash
# 1. 환경변수 확인
echo $GOOGLE_ANALYTICS_ID
# → G-XXXXXXXXXX

# 2. HTML 소스 확인
curl http://localhost:3000 | grep "gtag"
# → <script async src="https://www.googletagmanager.com/gtag/js?id=G-...

# 3. 네트워크 요청 확인
curl -I "https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"
# → HTTP/2 200
```

### Google Analytics 대시보드 확인
```
□ 실시간 사용자 > 0
□ 페이지뷰 기록됨
□ 이벤트: page_view 존재
□ 디바이스: Desktop 또는 Mobile
□ 브라우저: Chrome 등
□ 국가: South Korea
```

---

## 💡 문제 해결

### 실시간 데이터가 안 보여요

```
원인 1: 환경변수 미설정
해결: echo $GOOGLE_ANALYTICS_ID 확인

원인 2: 서버 미재시작
해결: rails s 재시작

원인 3: 광고 차단기
해결: 브라우저 시크릿 모드 또는 광고 차단기 해제

원인 4: 측정 ID 오타
해결: GA4 대시보드에서 ID 재확인
```

### gtag/js 404 오류

```
원인: 잘못된 측정 ID
해결: 
1. GA4 → 관리 → 데이터 스트림 → 측정 ID 확인
2. 환경변수 재설정
3. 서버 재시작
```

### 이벤트가 기록 안 돼요

```
원인: 비동기 로딩
해결: 
1. gtag 함수가 로드되었는지 확인:
   window.gtag !== undefined
   
2. 이벤트 전송 후 2-3분 대기
   (GA4는 실시간이지만 약간 지연)
```

---

## 📊 주요 보고서 활용

### 1. 실시간 (Realtime)
- 현재 접속자 수
- 현재 보는 페이지
- 유입 경로

### 2. 획득 (Acquisition)
- 사용자 유입 채널 (검색, SNS, 직접)
- 캠페인 성과
- 키워드 분석

### 3. 참여도 (Engagement)
- 페이지뷰 수
- 평균 세션 시간
- 이탈률
- 가장 인기 있는 콘텐츠

### 4. 수익 창출 (Monetization)
- 전자상거래 구매
- 수익 추적
- 상품 성과

---

## 🎯 이번 주 목표 달성 확인

```
✅ Google Analytics 4 계정 생성
✅ 측정 ID 발급
✅ 환경변수 설정
✅ 추적 코드 설치 (이미 완료)
✅ 실시간 데이터 확인
```

---

## 🚀 다음 단계

### 내일: Google Search Console
```
1. Search Console 속성 추가
2. GA4로 소유권 자동 확인
3. Sitemap 제출
```

### 모레: 도메인 연결
```
1. 가비아 도메인 구매
2. Cloudflare 설정
3. 프로덕션 배포
```

---

## 📞 참고 자료

### 공식 문서
- GA4 고객센터: https://support.google.com/analytics
- 측정 프로토콜: https://developers.google.com/analytics/devguides/collection/protocol/ga4

### 내부 문서
- `docs/WEEK_PLAN_2025-10-20.md` - 전체 주간 계획
- `docs/GABIA_CLOUDFLARE_SETUP.md` - 도메인 설정
- `docs/GCP_COMPLETE_GUIDE.md` - 프로덕션 배포

---

**작성일**: 2025년 10월 20일  
**예상 소요**: 30분  
**난이도**: 쉬움

**완료 후 체크**: ✅ 실시간 보고서에 데이터 표시됨

**화이팅! 📊**


