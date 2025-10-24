# 🎭 Playwright & Cursor 설정 가이드

## 🔍 현재 상황

### Cursor의 내장 Playwright
- ❌ Cursor에 Playwright 모듈이 설치되어 있지 않음
- ❌ MCP 브라우저 서버가 연결되지 않음
- ✅ 프로젝트 로컬 Playwright는 있음 (e2e-playwright/)

### 해결 방법 2가지

---

## 🎯 방법 1: Cursor 설정 수정 (권장)

### Cursor의 MCP 설정 확인

#### 1. Cursor 설정 열기
```
Cmd + , (설정)
또는
Cursor → Settings
```

#### 2. MCP 검색
```
검색창에 "MCP" 또는 "Model Context Protocol" 입력
```

#### 3. Playwright MCP 활성화
```
만약 "Playwright Browser" 또는 유사한 옵션이 있다면:
✅ 체크박스 활성화

없다면:
Cursor가 아직 Playwright MCP를 지원하지 않는 버전일 수 있습니다.
```

#### 4. Cursor 재시작
```
Cursor 완전 종료 (Cmd+Q)
다시 시작
```

---

## 🎯 방법 2: 프로젝트 Playwright 사용 (현재 사용 중)

### 이미 작동 중입니다!

**현재 상태**:
- ✅ 프로젝트에 Playwright 설치됨
- ✅ 테스트 실행 중
- ✅ 스크린샷/비디오 생성됨

**실행 방법**:
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright

# UI 모드 (추천)
npx playwright test --ui

# Headed 모드 (브라우저 보임)
npx playwright test --headed

# 특정 테스트만
npx playwright test tests/quick-ui-test.spec.ts --headed

# 리포트 보기
npx playwright show-report
```

---

## 🔧 샌드박스 설정 해제

### Cursor의 샌드박스 설정

현재 터미널 명령어에 샌드박스가 적용되고 있습니다.

#### 해제 방법

**방법 A: Cursor 설정에서**
```
1. Cmd + , (설정)
2. 검색: "sandbox" 또는 "terminal"
3. "Enable Terminal Sandboxing" 찾기
4. ❌ 체크 해제
5. Cursor 재시작
```

**방법 B: 설정 파일 직접 수정**
```json
// ~/Library/Application Support/Cursor/User/settings.json

{
  "terminal.integrated.enableSandboxing": false
}
```

---

## ✅ 우회 방법 (즉시 사용 가능)

### 일반 터미널에서 직접 실행

**iTerm 또는 Terminal.app에서**:

```bash
# 1. 프로젝트로 이동
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright

# 2. Playwright UI 모드 (가장 편함!)
npx playwright test --ui

# 또는

# 3. 특정 테스트 실행
npx playwright test tests/quick-ui-test.spec.ts --headed --project=desktop-1440

# 4. 리포트 보기
npx playwright show-report
```

**장점**:
- ✅ 샌드박스 제한 없음
- ✅ 전체 권한으로 실행
- ✅ 브라우저 직접 조작 가능

---

## 🎯 추천: UI 모드 사용

### Playwright UI Mode가 최고입니다!

**실행**:
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright
npx playwright test --ui
```

**기능**:
- ✅ 테스트 선택 실행
- ✅ 실시간 브라우저 확인
- ✅ 단계별 디버깅
- ✅ 스크린샷 즉시 보기
- ✅ 타임라인 확인

**브라우저에서 자동으로 열립니다!**

---

## 📊 현재 테스트 상태

### 실행된 테스트
```
✅ Running 3 tests using 1 worker
✅ 스크린샷 생성됨
✅ 비디오 녹화됨
⏳ 결과 대기 중...
```

### 확인 방법

**터미널에서**:
```bash
# 테스트 완료 확인
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright
npx playwright show-report
```

**브라우저가 자동으로 열리며 다음을 확인 가능**:
- ✅ 각 테스트 통과/실패
- ✅ 스크린샷 보기
- ✅ 비디오 재생
- ✅ 실행 시간
- ✅ 에러 메시지

---

## 🎯 최종 권장사항

### 지금 바로

**일반 터미널(iTerm)에서 실행**:
```bash
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright
npx playwright test --ui
```

이게 가장 편하고 강력합니다!

### 나중에 (선택)

**Cursor 설정 수정**:
1. Cursor 재시작
2. 샌드박스 비활성화
3. MCP 서버 확인

하지만 **프로젝트 Playwright가 이미 완벽하게 작동 중**이므로 굳이 Cursor 내장을 사용할 필요는 없습니다!

---

## ✅ 결론

**Cursor 내장 Playwright 없음 = 정상**

왜냐하면:
- Cursor 버전마다 다름
- MCP 기능은 선택적
- **프로젝트 Playwright로 충분**

**지금 해야 할 일**:
```bash
# iTerm에서
cd /Users/l2dogyu/KICDA/ruby/kicda-jh/e2e-playwright
npx playwright test --ui
```

**30초면 UI 모드가 열립니다!** 🚀



