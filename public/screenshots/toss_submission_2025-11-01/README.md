# 토스 페이먼츠 심사 제출용 스크린샷

**캡처 일시**: 2025-11-01  
**사이트**: https://정화의서재.kr  

## 📸 자동 캡처된 스크린샷

1. ✅ **홈페이지**: 01_homepage_main.png
2. ✅ **로그인 페이지**: 02_login_page.png
3. ✅ **환불 정책**: 03_refund_policy.png
4. ✅ **사업자 정보**: 04_business_info_footer.png

## 🖱️ 수동 캡처 필요 (브라우저에서 직접)

### 방법: Chrome 개발자 도구 사용

1. **상품 상세 페이지** (로그인 필요)
   ```bash
   1. https://정화의서재.kr/login 접속
   2. parent1@jeonghwa.com / password123 로그인
   3. https://정화의서재.kr/courses/3 접속 (₩6,000)
   4. F12 → Cmd+Shift+P → "Capture full size screenshot"
   5. 저장: 05_product_detail_6000.png
   ```

2. **최고가 상품 페이지**
   ```bash
   1. https://정화의서재.kr/courses/24 접속 (₩150,000)
   2. F12 → Cmd+Shift+P → "Capture full size screenshot"
   3. 저장: 06_highest_price_150000.png
   ```

3. **결제 페이지 (약관 동의 전)**
   ```bash
   1. 로그인 후 https://정화의서재.kr/payments/3/checkout
   2. F12 → Cmd+Shift+P → "Capture full size screenshot"
   3. 저장: 07_checkout_before_agree.png
   ```

4. **결제 페이지 (약관 동의 후)**
   ```bash
   1. 같은 페이지에서 "전체 동의" 체크
   2. F12 → Cmd+Shift+P → "Capture full size screenshot"
   3. 저장: 08_checkout_after_agree.png
   ```

5. **토스 결제창** (가장 중요!)
   ```bash
   1. 결제 페이지에서 "토스페이먼츠로 결제하기" 클릭
   2. 팝업 또는 새 탭에서 토스 결제창 확인
   3. Cmd+Shift+4 (맥) 또는 Print Screen (윈도우)
   4. 저장: 09_toss_payment_widget.png
   ```

## 📋 토스 페이먼츠 제출 정보

### 필수 URL
- 상품/서비스: https://정화의서재.kr
- 환불 정책: https://정화의서재.kr/pages/terms

### 테스트 계정
- ID: parent1@jeonghwa.com
- PW: password123

### 상품 정보
- 최저가: ₩4,500 (전자동화책)
- 중간가: ₩6,000 (달나라 토끼의 꿈)
- 최고가: ₩150,000 (동화작가 마스터 과정)

### 사업자 정보
- 상호: 정화의서재
- 대표: 권정화
- 사업자등록번호: 869-30-01778
- 통신판매업: 2025-인천부평-2012호

## 🚀 빠른 수동 캡처 가이드

```bash
# Chrome에서 한 번에 캡처하기

# 1. 정화의서재.kr 접속
# 2. F12 (개발자 도구 열기)
# 3. Cmd+Shift+P (맥) 또는 Ctrl+Shift+P (윈도우)
# 4. "screenshot" 입력
# 5. "Capture full size screenshot" 선택
# 6. 자동 다운로드됨
```

## ✅ PPT 슬라이드 구성

1. 표지
2. 홈페이지 (01_homepage_main.png)
3. 상품 상세 (05_product_detail_6000.png)
4. 최고가 상품 (06_highest_price_150000.png)
5. 로그인 (02_login_page.png)
6. 결제 - 약관 전 (07_checkout_before_agree.png)
7. 결제 - 약관 후 (08_checkout_after_agree.png)
8. **토스 결제창** (09_toss_payment_widget.png) ⭐
9. 환불 정책 (03_refund_policy.png)
10. 사업자 정보 (04_business_info_footer.png)
