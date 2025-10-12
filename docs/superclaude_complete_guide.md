# 🚀 SuperClaude & MCP 완전 가이드

## 📦 **설치 완료 목록**

### ✅ **1. SuperClaude CLI**
- 터미널에서 Claude 사용 가능
- 설치 위치: 전역 npm 패키지

### ✅ **2. MCP 서버들**
| MCP 서버 | 용도 | 상태 |
|---------|------|------|
| **rails-kicda** | Rails 전용 명령 | ✅ 설정 완료 |
| **filesystem** | 파일 시스템 접근 | ✅ 설정 완료 |
| **memory** | 대화 내용 기억 | ✅ 설정 완료 |
| **github** | GitHub 통합 | ⚠️ Token 필요 |
| **postgres** | PostgreSQL 연동 | ⚠️ DB 설정 필요 |
| **puppeteer** | 웹 스크래핑 | ✅ 사용 가능 |

## 🎯 **SuperClaude 터미널 사용법**

### 기본 명령어
```bash
# SuperClaude 시작
superclaude

# 특정 작업 공간으로 시작
superclaude --workspace kicda

# 단일 명령 실행
superclaude "User 모델을 생성해줘"

# MCP 서버 지정
superclaude --mcp rails-kicda "새로운 기능을 추가해줘"
```

### Rails 개발 단축키
```bash
# 모델 생성
superclaude dev:model Article title:string content:text

# 마이그레이션
superclaude dev:migrate

# 테스트 실행
superclaude dev:test

# 콘솔 실행
superclaude dev:console
```

## 🔧 **Rails MCP 서버 기능**

### 사용 가능한 도구들

#### 1. **rails_generate**
```
"Article 모델을 title과 content로 생성해줘"
"PostsController를 생성해줘"
"User 스캐폴드를 만들어줘"
```

#### 2. **rails_db**
```
"데이터베이스 마이그레이션 실행해줘"
"데이터베이스를 리셋해줘"
"시드 데이터를 생성해줘"
```

#### 3. **rails_test**
```
"모든 테스트를 실행해줘"
"user_test.rb만 테스트해줘"
"통합 테스트만 실행해줘"
```

#### 4. **bundle**
```
"새로운 gem을 설치해줘"
"bundle update를 실행해줘"
"devise gem을 추가해줘"
```

#### 5. **git**
```
"현재 상태를 확인해줘"
"모든 변경사항을 커밋해줘"
"'새 기능 추가'라는 메시지로 커밋해줘"
```

#### 6. **ai_assistant**
```
"블로그 시스템을 완전히 구현해줘"
"사용자 인증 시스템을 추가해줘"
"결제 시스템을 통합해줘"
```

## 💡 **활용 시나리오**

### 시나리오 1: 완전 자동 개발
```bash
# 터미널에서
superclaude "전자상거래 기능을 추가해줘. Product 모델, Cart 시스템, 결제까지 모두 구현해"

# 자동으로 실행되는 작업:
1. Product, Cart, Order 모델 생성
2. 컨트롤러 및 뷰 생성
3. 라우트 설정
4. 마이그레이션 실행
5. 테스트 코드 작성
6. Git 커밋
```

### 시나리오 2: 대화형 개발
```bash
superclaude
> "현재 프로젝트 상태를 확인해줘"
> "User 모델에 profile 필드를 추가해줘"
> "테스트를 실행하고 문제가 있으면 수정해줘"
> "변경사항을 커밋해줘"
```

### 시나리오 3: Claude Desktop과 연동
1. Claude Desktop: 복잡한 로직 설계
2. SuperClaude: 터미널에서 빠른 실행
3. Cursor AI: 세부 코드 편집

## 🔐 **API 키 설정 (선택사항)**

### GitHub Token 설정
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="your-token-here"
```

### PostgreSQL 연결
```bash
export DATABASE_URL="postgresql://user:password@localhost:5432/kicda_development"
```

## 🚨 **트러블슈팅**

### MCP 서버 오류 시
```bash
# MCP 서버 재설치
cd ~/.config/claude-mcp/servers
npm install

# 권한 문제 해결
chmod +x /Users/l2dogyu/KICDA/ruby/kicda-jh/mcp-servers/rails-mcp.js

# 로그 확인
tail -f ~/Library/Logs/Claude/*.log
```

### SuperClaude 연결 문제
```bash
# 설정 초기화
rm -rf ~/.superclaude
superclaude --init

# MCP 서버 테스트
superclaude --test-mcp rails-kicda
```

## 🎉 **축하합니다!**

이제 완벽한 AI 자동화 개발 환경이 구축되었습니다:

- **Claude Desktop**: GUI 인터페이스
- **SuperClaude**: 터미널 인터페이스
- **Cursor AI**: IDE 통합
- **MCP 서버들**: 완전 자동화

**모든 도구가 통합되어 진정한 "의도 → 실행" 시스템이 완성되었습니다!** 🚀

## 📝 **다음 단계**

1. Claude Desktop 재시작
2. 터미널에서 `superclaude` 실행
3. "프로젝트 상태를 확인해줘"로 테스트
4. 복잡한 기능 구현 요청

---

*문제가 있으면 `/docs/superclaude_complete_guide.md`를 참조하세요*
