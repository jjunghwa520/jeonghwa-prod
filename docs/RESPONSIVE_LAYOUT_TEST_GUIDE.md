# 반응형 레이아웃 테스트 가이드

**작성일:** 2025년 10월 23일  
**목적:** 카테고리 페이지 반응형 개선 결과 테스트

---

## 🎯 테스트 목표

1. ✅ 세로 긴 화면에서 히어로 높이 제한 확인
2. ✅ 첫 화면에 콘텐츠 노출 확인
3. ✅ 가로 화면에서 기존 레이아웃 유지 확인
4. ✅ 모바일 화면에서 정상 작동 확인

---

## 📱 Chrome DevTools 테스트 방법

### 1단계: DevTools 열기

**Mac:**
```
Cmd + Option + I
또는 F12
```

**Windows:**
```
Ctrl + Shift + I
또는 F12
```

### 2단계: 반응형 모드 활성화

**Mac:**
```
Cmd + Shift + M
```

**Windows:**
```
Ctrl + Shift + M
```

또는 DevTools 상단의 "Toggle Device Toolbar" 아이콘 클릭 (📱)

### 3단계: 커스텀 해상도 추가

1. **Dimensions 드롭다운** 클릭
2. **Edit...** 선택
3. **Add custom device** 클릭

**추가할 해상도:**
```
이름: Desktop Vertical FHD
너비: 1080
높이: 1920
Device pixel ratio: 1
User agent type: Desktop

이름: iPad Pro 12.9" Vertical
너비: 1024
높이: 1366
Device pixel ratio: 2
User agent type: Tablet
```

---

## 🧪 필수 테스트 체크리스트

### Test 1: 세로 긴 화면 (1080x1920) ⭐⭐⭐⭐⭐

**테스트 페이지:**
```
http://localhost:3000/courses?category=ebook
http://localhost:3000/courses?category=storytelling
http://localhost:3000/courses?category=education
http://localhost:3000/teen_content
http://localhost:3000/courses?category=teen_education
```

**확인 사항:**

1. **히어로 높이**
   - [ ] 히어로 섹션이 화면 전체를 차지하지 않는가?
   - [ ] 히어로 높이가 약 500-600px 이내인가?
   - [ ] 스크롤 없이 콘텐츠 일부가 보이는가?

2. **콘텐츠 노출**
   - [ ] 첫 화면에 강의 카드 2-3개가 보이는가?
   - [ ] 카테고리 배너(alert)가 보이는가?
   - [ ] 콘텐츠가 자연스럽게 이어지는가?

3. **여백**
   - [ ] 히어로와 콘텐츠 사이 여백이 적절한가?
   - [ ] 과도한 공백이 없는가?
   - [ ] 전체적인 균형이 맞는가?

**높이 측정 (DevTools Console):**
```javascript
// 히어로 섹션 높이 확인
document.querySelector('.hero-section-small').offsetHeight
// 또는
document.querySelector('.teen-courses-hero').offsetHeight
// 결과: 500-600px 이내여야 함

// 콘텐츠 시작 위치 확인
document.querySelector('.courses-content-section').offsetTop
// 결과: 600-700px 이내여야 함

// 화면 높이 대비 비율
(document.querySelector('.hero-section-small').offsetHeight / window.innerHeight * 100).toFixed(1) + '%'
// 결과: 30-40% 이내여야 함
```

---

### Test 2: 가로 화면 (1920x1080) ⭐⭐⭐⭐

**확인 사항:**

1. **기존 레이아웃 유지**
   - [ ] 히어로 높이가 적절한가? (약 400-500px)
   - [ ] 캐릭터 이미지가 잘 보이는가?
   - [ ] 텍스트 가독성이 좋은가?

2. **변화 비교**
   - [ ] 이전보다 콘텐츠가 더 많이 보이는가?
   - [ ] 레이아웃이 깨지지 않았는가?
   - [ ] 전체적인 디자인이 유지되는가?

**높이 측정:**
```javascript
document.querySelector('.hero-section-small').offsetHeight
// 결과: 400-500px 이내여야 함
```

---

### Test 3: 태블릿 (768x1024, 1024x768) ⭐⭐⭐

**세로 모드 (768x1024):**
```
DevTools → Dimensions → iPad
```

**확인 사항:**
- [ ] 히어로 높이가 적절한가?
- [ ] 터치 영역이 충분한가? (버튼 최소 48px)
- [ ] 텍스트가 읽기 편한가?
- [ ] 스크롤이 자연스러운가?

**가로 모드 (1024x768):**
```
DevTools → iPad 선택 후 Rotate 버튼 클릭
```

**확인 사항:**
- [ ] 레이아웃이 정상인가?
- [ ] 히어로와 콘텐츠 비율이 적절한가?

---

### Test 4: 모바일 (390x844) ⭐⭐⭐

**테스트 디바이스:**
```
DevTools → Dimensions → iPhone 12 Pro / iPhone 13 Pro
```

**확인 사항:**

1. **히어로 섹션**
   - [ ] 히어로가 컴팩트한가? (최대 400px)
   - [ ] CTA 버튼이 보이는가?
   - [ ] 타이틀이 읽기 편한가?

2. **콘텐츠**
   - [ ] 첫 화면에 강의 카드가 보이는가?
   - [ ] 터치 영역이 충분한가?
   - [ ] 스크롤이 부드러운가?

3. **성능**
   - [ ] 페이지 로드가 빠른가?
   - [ ] 스크롤 시 버벅임이 없는가?

---

## 📊 Before & After 비교 측정

### 1080x1920 화면 기준

**측정 항목:**

| 항목 | Before | After | 개선율 |
|------|--------|-------|--------|
| 히어로 높이 | ~960px (50vh) | ~550px | 42% ↓ |
| 콘텐츠 시작 위치 | ~1120px | ~680px | 39% ↓ |
| 화면 대비 히어로 비율 | 50% | 29% | 42% ↓ |
| 첫 화면 강의 카드 수 | 0개 | 2-3개 | ✅ |

**측정 방법 (Console):**
```javascript
// 전체 측정 스크립트
const hero = document.querySelector('.hero-section-small') || document.querySelector('.teen-courses-hero');
const content = document.querySelector('.courses-content-section');
const screenHeight = window.innerHeight;

console.log('=== 반응형 레이아웃 측정 ===');
console.log('화면 크기:', window.innerWidth, 'x', screenHeight);
console.log('히어로 높이:', hero.offsetHeight, 'px');
console.log('콘텐츠 시작:', content.offsetTop, 'px');
console.log('화면 대비 히어로:', (hero.offsetHeight / screenHeight * 100).toFixed(1), '%');
console.log('스크롤 필요 거리:', content.offsetTop - screenHeight, 'px');
```

---

## 🎨 시각적 확인 사항

### 디자인 품질

1. **타이포그래피**
   - [ ] 제목이 잘 읽히는가?
   - [ ] 설명 텍스트가 명확한가?
   - [ ] 줄간격이 적절한가?

2. **여백**
   - [ ] 요소 간 간격이 균형 잡혔는가?
   - [ ] 과도한 공백이 없는가?
   - [ ] 답답하지 않은가?

3. **색상**
   - [ ] 색상 대비가 충분한가?
   - [ ] 가독성이 좋은가?
   - [ ] 브랜드 아이덴티티가 유지되는가?

4. **이미지**
   - [ ] 썸네일이 선명한가?
   - [ ] 비율이 유지되는가?
   - [ ] 로딩이 빠른가?

---

## 🔍 문제 발견 시 대응

### 히어로가 너무 높을 때

**확인:**
```javascript
getComputedStyle(document.querySelector('.hero-section-small')).minHeight
getComputedStyle(document.querySelector('.hero-section-small')).maxHeight
```

**예상 결과:**
- min-height: 450px (900px 이상 화면)
- max-height: 550px (900px 이상 화면)

**문제 시:** CSS 캐시 클리어 필요

### 여백이 이상할 때

**확인:**
```javascript
getComputedStyle(document.querySelector('.courses-content-section')).paddingTop
```

**예상 결과:**
- 2rem ~ 3rem (32px ~ 48px)

**문제 시:** 브라우저 하드 리프레시 (Cmd+Shift+R / Ctrl+Shift+R)

### 레이아웃이 깨질 때

**확인:**
1. 브라우저 최신 버전인가?
2. CSS가 제대로 로드되었는가?
3. JavaScript 오류는 없는가?

**해결:**
```bash
# Rails 캐시 클리어
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
bin/rails assets:clobber
bin/rails assets:precompile

# 브라우저 하드 리프레시
```

---

## 📸 스크린샷 가이드

### 캡처 방법

**1. Full Page Screenshot (DevTools)**
```
1. DevTools 열기 (Cmd+Option+I)
2. Command Palette 열기 (Cmd+Shift+P / Ctrl+Shift+P)
3. "Capture full size screenshot" 입력 및 실행
```

**2. Viewport Screenshot**
```
1. Command Palette → "Capture screenshot"
```

**3. Node Screenshot (특정 요소)**
```
1. Elements 탭에서 요소 선택
2. 우클릭 → Capture node screenshot
```

### 권장 캡처 목록

**Before (수정 전):**
- 필요 시 Git에서 이전 버전 체크아웃 후 캡처

**After (수정 후):**
```
1. 1080x1920_전자동화책_hero.png
2. 1080x1920_전자동화책_full.png (전체 페이지)
3. 1920x1080_전자동화책_hero.png
4. 390x844_전자동화책_mobile.png
```

---

## ✅ 테스트 완료 체크리스트

### 최종 확인

- [ ] **1080x1920 (세로 FHD):** 5개 페이지 모두 확인
- [ ] **1920x1080 (가로 FHD):** 5개 페이지 모두 확인
- [ ] **iPad (768x1024):** 대표 페이지 2개 확인
- [ ] **iPhone (390x844):** 대표 페이지 2개 확인
- [ ] **Chrome 최신:** 모든 테스트 통과
- [ ] **Safari 최신:** 대표 페이지 확인
- [ ] **히어로 높이 측정:** 모두 600px 이하
- [ ] **콘텐츠 노출:** 모두 첫 화면 표시
- [ ] **Linter 오류:** 0개
- [ ] **레이아웃 깨짐:** 없음

---

## 🎯 성공 기준

### 필수 (Must Have)
1. ✅ 1080x1920 화면에서 히어로 높이 600px 이하
2. ✅ 첫 화면에 콘텐츠 최소 2개 카드 보임
3. ✅ 1920x1080 화면에서 레이아웃 정상
4. ✅ 모바일 (390x844)에서 정상 작동
5. ✅ Linter 오류 0개

### 선택 (Nice to Have)
1. ⭐ 모든 해상도에서 부드러운 전환
2. ⭐ 스크롤 거리 40% 이상 감소
3. ⭐ Before/After 비교 이미지
4. ⭐ 성능 저하 없음

---

## 📞 문제 해결

### CSS가 적용되지 않을 때

```bash
# Rails 애셋 재컴파일
cd /Users/l2dogyu/KICDA/ruby/kicda-jh
bin/rails assets:clobber
bin/rails assets:precompile

# 브라우저 캐시 완전 삭제
# Chrome: Settings → Privacy → Clear browsing data → Cached images and files
```

### 특정 해상도에서만 문제

```javascript
// 해당 해상도에서 CSS 값 확인
console.log('현재 화면:', window.innerWidth, 'x', window.innerHeight);
console.log('적용된 min-height:', getComputedStyle(document.querySelector('.hero-section-small')).minHeight);
console.log('적용된 max-height:', getComputedStyle(document.querySelector('.hero-section-small')).maxHeight);
```

### 백업 복구 필요 시

```bash
# 백업 파일 확인
ls -la app/assets/stylesheets/*.backup*

# 복구 (예시)
cp app/assets/stylesheets/unified_hero_design.scss.backup_20251023 app/assets/stylesheets/unified_hero_design.scss
```

---

## 🎊 테스트 완료 보고

### 보고 양식

```markdown
## 반응형 레이아웃 테스트 결과

**테스트일:** YYYY-MM-DD  
**테스터:** 이름  

### 테스트 환경
- 브라우저: Chrome 120.0.0
- OS: macOS 14.0

### 테스트 결과

#### 1080x1920 (세로 FHD)
- 전자동화책: ✅ / ❌
- 구연동화: ✅ / ❌
- 동화만들기: ✅ / ❌
- 청소년 콘텐츠: ✅ / ❌
- 청소년 교육: ✅ / ❌

#### 1920x1080 (가로 FHD)
- 전자동화책: ✅ / ❌
- 구연동화: ✅ / ❌

#### 측정값
- 히어로 평균 높이: XXX px
- 콘텐츠 시작 위치: XXX px
- 첫 화면 카드 수: X개

### 발견된 이슈
1. (없음 / 이슈 설명)

### 스크린샷
- (첨부 또는 경로)

### 종합 평가
✅ 합격 / ❌ 추가 수정 필요
```

---

**작성일:** 2025년 10월 23일  
**업데이트:** 필요 시 수정  
**관련 문서:** `docs/handover_2025-10-23.md`, `docs/WORK_SUMMARY_2025-10-23.md`

---

**끝.** 🎊


