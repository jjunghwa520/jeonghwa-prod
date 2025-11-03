namespace :docs do
  desc "모든 기획 산출물 생성"
  task generate_all: :environment do
    puts "📚 기획 산출물 생성 시작..."
    
    Rake::Task['docs:generate_ia'].invoke
    Rake::Task['docs:generate_flowchart'].invoke
    Rake::Task['docs:generate_wbs'].invoke
    Rake::Task['docs:generate_spec'].invoke
    Rake::Task['docs:generate_api'].invoke
    
    puts "✅ 모든 산출물 생성 완료!"
  end
  
  desc "IA (정보구조도) 생성"
  task generate_ia: :environment do
    ia_content = <<~MD
      # IA (정보구조도) - 정화의 서재
      
      생성일: #{Time.current.strftime('%Y-%m-%d')}
      
      ## 1. 사이트 구조
      
      ```
      정화의서재 (/)
      │
      ├── 홈 (/)
      │   ├── Hero 배너
      │   ├── 카테고리 (0-3세, 4-7세, 8-13세, 14-16세)
      │   └── 추천 콘텐츠
      │
      ├── 콘텐츠 둘러보기 (/courses)
      │   ├── 전체 목록
      │   ├── 연령대별 필터
      │   ├── 카테고리별 필터
      │   └── 콘텐츠 상세 (/courses/:id)
      │       ├── 상세 정보
      │       ├── 리뷰
      │       ├── 구매/열람
      │       └── 관련 콘텐츠
      │
      ├── 구독 (/subscriptions)
      │   ├── 플랜 선택 (/subscriptions/new)
      │   │   ├── 일반 회원 (₩9,900/월)
      │   │   └── 프리미엄 (₩19,900/월)
      │   └── 내 구독 관리 (/subscriptions)
      │       ├── 현재 구독 상태
      │       ├── 구독 이력
      │       └── 취소/일시중지/재개
      │
      ├── 이벤트 (/events)
      │   ├── 진행중 이벤트
      │   ├── 예정 이벤트
      │   └── 이벤트 상세 (/events/:id)
      │
      ├── 문의 (/inquiries)
      │   ├── 내 문의 목록
      │   └── 새 문의 작성 (/inquiries/new)
      │
      ├── 커뮤니티 (/community)
      │   ├── 독서 챌린지
      │   └── 학부모 포럼
      │
      ├── 마이페이지 (/users/:id/dashboard)
      │   ├── 내 강좌
      │   ├── 주문 내역
      │   └── 프로필 관리
      │
      ├── 장바구니 (/cart_items)
      │   ├── 담은 콘텐츠 목록
      │   └── 전체 결제
      │
      ├── 결제 (/payments)
      │   ├── 결제하기 (/payments/:course_id/checkout)
      │   ├── 결제 완료 (/payments/confirm)
      │   └── 결제 실패 (/payments/fail)
      │
      ├── 작가 (/author)
      │   └── 대시보드 (/author/dashboard)
      │       ├── 수익 통계
      │       ├── 내 콘텐츠
      │       └── 최근 리뷰
      │
      ├── 관리자 (/admin)
      │   ├── 대시보드 (/admin)
      │   ├── 콘텐츠 관리 (/admin/courses)
      │   ├── 작가 관리 (/admin/authors)
      │   ├── 회원 관리 (/admin/users)
      │   ├── 리뷰 관리 (/admin/reviews)
      │   ├── 이벤트 관리 (/admin/events)
      │   ├── 문의 관리 (/admin/inquiries)
      │   ├── 통계/리포트 (/admin/analytics)
      │   └── AI 생성기 (/admin/content_generator)
      │
      ├── 정책 (/pages)
      │   ├── 이용약관 (/pages/terms)
      │   └── 개인정보처리방침 (/pages/privacy)
      │
      └── 인증 (/sessions)
          ├── 로그인 (/login)
          ├── 로그아웃 (/logout)
          └── 회원가입 (/signup)
      ```
      
      ## 2. 사용자 유형별 접근 권한
      
      ### 비회원
      - 홈, 콘텐츠 목록 (제한적), 이벤트, 로그인/회원가입
      
      ### 일반 회원
      - 비회원 + 콘텐츠 구매, 리뷰 작성, 마이페이지, 문의
      
      ### 일반 구독자
      - 일반 회원 + 월 10개 콘텐츠 무료 열람
      
      ### 프리미엄 구독자
      - 일반 구독자 + 무제한 콘텐츠 열람, 신규 콘텐츠 우선 제공
      
      ### 작가
      - 일반 회원 + 작가 대시보드, 수익 확인, 콘텐츠 관리
      
      ### 관리자
      - 전체 접근 권한
    MD
    
    File.write('docs/IA_정보구조도.md', ia_content)
    puts "✅ IA 정보구조도 생성: docs/IA_정보구조도.md"
  end
  
  desc "플로우차트 생성"
  task generate_flowchart: :environment do
    flowchart_content = <<~MD
      # 플로우차트 - 정화의 서재
      
      생성일: #{Time.current.strftime('%Y-%m-%d')}
      
      ## 1. 회원가입 플로우
      
      ```
      [시작] → [회원가입 페이지 접속]
        ↓
      [이메일/비밀번호 입력]
        ↓
      [유효성 검증] ─No→ [오류 메시지] → [재입력]
        ↓ Yes
      [회원 정보 저장]
        ↓
      [자동 로그인]
        ↓
      [홈페이지로 리다이렉트]
        ↓
      [완료]
      ```
      
      ## 2. 콘텐츠 구매 플로우
      
      ```
      [시작] → [콘텐츠 상세 페이지]
        ↓
      [구매하기 클릭]
        ↓
      [로그인 여부 확인] ─No→ [로그인 페이지] → [로그인 후 복귀]
        ↓ Yes
      [이미 구매?] ─Yes→ [콘텐츠 열람]
        ↓ No
      [결제 페이지 (/payments/checkout)]
        ↓
      [토스페이먼츠 결제 위젯]
        ↓
      [결제 승인 요청]
        ↓
      [결제 성공?] ─No→ [결제 실패 페이지] → [재시도/취소]
        ↓ Yes
      [Enrollment 생성]
        ↓
      [결제 완료 페이지]
        ↓
      [콘텐츠 열람 가능]
        ↓
      [완료]
      ```
      
      ## 3. 구독 신청 플로우
      
      ```
      [시작] → [구독 플랜 페이지]
        ↓
      [일반/프리미엄 선택]
        ↓
      [자동갱신 설정]
        ↓
      [로그인 여부 확인] ─No→ [로그인]
        ↓ Yes
      [구독 생성 (status: pending)]
        ↓
      [결제 페이지]
        ↓
      [빌링키 발급 + 결제]
        ↓
      [결제 성공?] ─No→ [실패 처리]
        ↓ Yes
      [구독 활성화 (status: active)]
        ↓
      [완료]
      ```
      
      ## 4. DRM 콘텐츠 열람 플로우
      
      ```
      [시작] → [콘텐츠 열람 요청]
        ↓
      [접근 권한 확인]
        ├─ 구매 여부?
        ├─ 구독 여부?
        └─ 관리자/작가?
        ↓
      [권한 없음?] ─Yes→ [구매/구독 안내]
        ↓ No
      [워터마크 생성]
        ↓
      [보안 토큰 발급 (JWT)]
        ↓
      [DRM 보호 뷰어 로드]
        ↓
      [조회 기록 저장 (ContentView)]
        ↓
      [시청 시간 추적 시작]
        ↓
      [콘텐츠 표시]
        ↓
      [완료]
      ```
      
      ## 5. 작가 정산 플로우
      
      ```
      [매월 1일 자동 실행]
        ↓
      [지난 달 데이터 수집]
        ├─ ContentView (조회수, 시청시간)
        ├─ Order (구매 매출)
        └─ Subscription (구독 수익 풀)
        ↓
      [콘텐츠별 수익 계산]
        ├─ 구매 수익
        └─ 구독 수익 분배
        ↓
      [작가 수수료 적용 (70%)]
        ↓
      [Settlement 생성 (status: pending)]
        ↓
      [관리자 승인 대기]
        ↓
      [승인?] ─No→ [반려]
        ↓ Yes
      [status: approved]
        ↓
      [계좌 이체 처리]
        ↓
      [status: paid]
        ↓
      [완료]
      ```
    MD
    
    File.write('docs/FLOWCHART_플로우차트.md', flowchart_content)
    puts "✅ 플로우차트 생성: docs/FLOWCHART_플로우차트.md"
  end
  
  desc "WBS (작업분류표) 생성"
  task generate_wbs: :environment do
    wbs_content = <<~MD
      # WBS (Work Breakdown Structure) - 정화의 서재
      
      생성일: #{Time.current.strftime('%Y-%m-%d')}
      
      ## 프로젝트 개요
      - 프로젝트명: 정화의 서재 홈페이지 MVP 구축
      - 기간: 2025-08-20 ~ 2025-10-30 (약 2.5개월)
      - 예산: 18,150,000원 (VAT 포함)
      
      ## 1. 기획 단계 (1주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 1.1 | 요구사항 분석 | PM | 2일 | ✅ 완료 |
      | 1.2 | IA 설계 | 기획 | 1일 | ✅ 완료 |
      | 1.3 | 플로우차트 작성 | 기획 | 1일 | ✅ 완료 |
      | 1.4 | WBS 작성 | PM | 0.5일 | ✅ 완료 |
      | 1.5 | 기능명세서 작성 | 기획 | 1.5일 | ✅ 완료 |
      
      ## 2. 디자인 단계 (2주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 2.1 | 스타일 가이드 | 디자이너 | 2일 | ✅ 완료 |
      | 2.2 | 메인 페이지 디자인 | 디자이너 | 3일 | ✅ 완료 |
      | 2.3 | 콘텐츠 페이지 디자인 | 디자이너 | 3일 | ✅ 완료 |
      | 2.4 | 관리자 페이지 디자인 | 디자이너 | 2일 | ✅ 완료 |
      | 2.5 | 반응형 디자인 | 디자이너 | 2일 | ✅ 완료 |
      | 2.6 | AI 캐릭터 생성 | AI 엔지니어 | 2일 | ✅ 완료 |
      
      ## 3. 백엔드 개발 (4주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 3.1 | Rails 프로젝트 초기화 | 백엔드 | 1일 | ✅ 완료 |
      | 3.2 | 데이터베이스 설계 | 백엔드 | 2일 | ✅ 완료 |
      | 3.3 | 사용자 인증 시스템 | 백엔드 | 3일 | ✅ 완료 |
      | 3.4 | 콘텐츠 CRUD | 백엔드 | 3일 | ✅ 완료 |
      | 3.5 | 결제 시스템 (토스) | 백엔드 | 4일 | ✅ 완료 |
      | 3.6 | 구독 시스템 | 백엔드 | 3일 | ✅ 완료 |
      | 3.7 | 정산 로직 | 백엔드 | 3일 | ✅ 완료 |
      | 3.8 | DRM 시스템 | 백엔드 | 2일 | ✅ 완료 |
      | 3.9 | 통계 시스템 | 백엔드 | 2일 | ✅ 완료 |
      | 3.10 | API 개발 | 백엔드 | 3일 | ✅ 완료 |
      
      ## 4. 프론트엔드 개발 (4주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 4.1 | TailwindCSS 설정 | 프론트 | 1일 | ✅ 완료 |
      | 4.2 | 메인 페이지 | 프론트 | 3일 | ✅ 완료 |
      | 4.3 | 콘텐츠 목록/상세 | 프론트 | 4일 | ✅ 완료 |
      | 4.4 | 전자동화책 리더 | 프론트 | 3일 | ✅ 완료 |
      | 4.5 | 회원가입/로그인 | 프론트 | 2일 | ✅ 완료 |
      | 4.6 | 마이페이지 | 프론트 | 2일 | ✅ 완료 |
      | 4.7 | 장바구니 | 프론트 | 2일 | ✅ 완료 |
      | 4.8 | 결제 페이지 | 프론트 | 2일 | ✅ 완료 |
      | 4.9 | 구독 페이지 | 프론트 | 2일 | ✅ 완료 |
      | 4.10 | 이벤트 페이지 | 프론트 | 1일 | ✅ 완료 |
      | 4.11 | 문의 페이지 | 프론트 | 1일 | ✅ 완료 |
      | 4.12 | 관리자 페이지 | 프론트 | 5일 | ✅ 완료 |
      | 4.13 | 작가 대시보드 | 프론트 | 2일 | ✅ 완료 |
      
      ## 5. AI 통합 (1주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 5.1 | Vertex AI 설정 | AI 엔지니어 | 1일 | ✅ 완료 |
      | 5.2 | 썸네일 생성 시스템 | AI 엔지니어 | 2일 | ✅ 완료 |
      | 5.3 | 40개 썸네일 생성 | AI 엔지니어 | 2일 | ✅ 완료 |
      | 5.4 | 캐릭터 이미지 생성 | AI 엔지니어 | 1일 | ✅ 완료 |
      
      ## 6. 인프라 & DevOps (1주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 6.1 | GCP Cloud Run 설정 | DevOps | 1일 | ✅ 완료 |
      | 6.2 | GitHub Actions CI/CD | DevOps | 2일 | ✅ 완료 |
      | 6.3 | 도메인 연결 | DevOps | 0.5일 | ✅ 완료 |
      | 6.4 | SSL 인증서 | DevOps | 0.5일 | ✅ 완료 |
      | 6.5 | 모니터링 설정 | DevOps | 1일 | ✅ 완료 |
      
      ## 7. 테스트 (1주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 7.1 | E2E 테스트 작성 | QA | 3일 | ✅ 완료 |
      | 7.2 | 결제 플로우 테스트 | QA | 2일 | ✅ 완료 |
      | 7.3 | 크로스 브라우징 | QA | 1일 | ✅ 완료 |
      | 7.4 | 반응형 테스트 | QA | 1일 | ✅ 완료 |
      
      ## 8. 배포 및 인수인계 (0.5주)
      | 작업 ID | 작업명 | 담당 | 예상 시간 | 상태 |
      |---------|--------|------|-----------|------|
      | 8.1 | 프로덕션 배포 | DevOps | 0.5일 | ✅ 완료 |
      | 8.2 | 인수인계 문서 작성 | PM | 1일 | ✅ 완료 |
      | 8.3 | 교육 및 인계 | PM | 0.5일 | ✅ 완료 |
      
      ## 총 작업 통계
      - 총 작업 항목: 60개
      - 완료: 60개 (100%)
      - 총 예상 시간: 약 70일
      - 실제 소요 시간: 약 70일 (2.5개월)
    MD
    
    File.write('docs/WBS_작업분류표.md', wbs_content)
    puts "✅ WBS 작업분류표 생성: docs/WBS_작업분류표.md"
  end
  
  desc "기능명세서 생성"
  task generate_spec: :environment do
    puts "📝 기능명세서 생성 중..."
    
    spec_content = "# 기능명세서 - 정화의 서재\n\n생성일: #{Time.current.strftime('%Y-%m-%d')}\n\n"
    
    # 모든 모델 순회
    models = [User, Course, Subscription, Event, Inquiry, Settlement, ContentView, Review, Order, Enrollment]
    
    models.each do |model|
      spec_content += "\n## #{model.name}\n\n"
      spec_content += "### 속성\n\n"
      spec_content += "| 필드명 | 타입 | 설명 | 제약조건 |\n"
      spec_content += "|--------|------|------|----------|\n"
      
      model.columns.each do |column|
        spec_content += "| #{column.name} | #{column.type} | - | "
        spec_content += "NOT NULL " if !column.null
        spec_content += "|\n"
      end
      
      spec_content += "\n### 관계\n\n"
      model.reflect_on_all_associations.each do |assoc|
        spec_content += "- #{assoc.macro}: #{assoc.name} (#{assoc.class_name})\n"
      end
    end
    
    File.write('docs/SPEC_기능명세서.md', spec_content)
    puts "✅ 기능명세서 생성: docs/SPEC_기능명세서.md"
  end
  
  desc "API 정의서 생성"
  task generate_api: :environment do
    api_content = <<~MD
      # API 정의서 - 정화의 서재
      
      생성일: #{Time.current.strftime('%Y-%m-%d')}
      Base URL: https://정화의서재.kr
      
      ## 인증
      - 세션 기반 인증 (Cookie)
      - CSRF 토큰 필요
      
      ## 1. 사용자 관련 API
      
      ### 회원가입
      ```
      POST /users
      Content-Type: application/json
      
      Request:
      {
        "user": {
          "name": "홍길동",
          "email": "user@example.com",
          "password": "password123",
          "password_confirmation": "password123"
        }
      }
      
      Response (201 Created):
      {
        "id": 1,
        "name": "홍길동",
        "email": "user@example.com",
        "role": "student"
      }
      ```
      
      ### 로그인
      ```
      POST /login
      
      Request:
      {
        "email": "user@example.com",
        "password": "password123"
      }
      
      Response (200 OK):
      {
        "message": "로그인 성공",
        "user": {
          "id": 1,
          "name": "홍길동",
          "email": "user@example.com"
        }
      }
      ```
      
      ## 2. 콘텐츠 관련 API
      
      ### 콘텐츠 목록 조회
      ```
      GET /courses
      
      Query Parameters:
      - category: string (선택)
      - age_range: string (선택)
      - page: integer (기본값: 1)
      
      Response (200 OK):
      {
        "courses": [
          {
            "id": 1,
            "title": "백설공주",
            "description": "...",
            "price": 5000,
            "category": "fairy_tale",
            "age_range": "4-7",
            "thumbnail_url": "/assets/...",
            "rating": 4.5,
            "reviews_count": 10
          }
        ],
        "meta": {
          "total": 40,
          "page": 1,
          "per_page": 12
        }
      }
      ```
      
      ### 콘텐츠 상세 조회
      ```
      GET /courses/:id
      
      Response (200 OK):
      {
        "id": 1,
        "title": "백설공주",
        "description": "...",
        "price": 5000,
        "instructor": {
          "id": 2,
          "name": "권정화"
        },
        "reviews": [...],
        "enrolled": false
      }
      ```
      
      ## 3. 구독 관련 API
      
      ### 구독 생성
      ```
      POST /subscriptions
      
      Request:
      {
        "plan_type": "premium",
        "auto_renew": true
      }
      
      Response (201 Created):
      {
        "id": 1,
        "plan_type": "premium",
        "status": "pending",
        "price": 19900,
        "start_date": "2025-11-03",
        "end_date": "2025-12-03"
      }
      ```
      
      ### 구독 취소
      ```
      PATCH /subscriptions/:id/cancel
      
      Response (200 OK):
      {
        "message": "구독이 취소되었습니다",
        "subscription": {
          "id": 1,
          "status": "cancelled"
        }
      }
      ```
      
      ## 4. 결제 관련 API
      
      ### 결제 요청
      ```
      GET /payments/:course_id/checkout
      
      Response (200 OK):
      HTML 페이지 또는:
      {
        "payment_key": "...",
        "order_id": "...",
        "amount": 5000
      }
      ```
      
      ### 결제 확인
      ```
      GET /payments/confirm
      
      Query Parameters:
      - paymentKey: string
      - orderId: string
      - amount: integer
      
      Response (200 OK):
      {
        "message": "결제가 완료되었습니다",
        "order": {...}
      }
      ```
      
      ## 5. 관리자 API
      
      ### 콘텐츠 생성 (관리자)
      ```
      POST /admin/courses
      
      Request:
      {
        "course": {
          "title": "신데렐라",
          "description": "...",
          "price": 5000,
          "category": "fairy_tale",
          "age_range": "4-7"
        }
      }
      
      Response (201 Created):
      {
        "id": 2,
        "title": "신데렐라",
        ...
      }
      ```
      
      ### 통계 조회 (관리자)
      ```
      GET /admin/analytics
      
      Response (200 OK):
      {
        "total_users": 1000,
        "total_courses": 40,
        "monthly_revenue": 5000000,
        "signup_chart": [...],
        "revenue_chart": [...]
      }
      ```
      
      ## 6. DRM 관련 API
      
      ### DRM 보호 콘텐츠 접근
      ```
      GET /courses/:id/secure_view
      
      Response (200 OK):
      HTML 페이지 + 워터마크
      또는:
      {
        "url": "/courses/1/secure_view",
        "token": "jwt_token...",
        "watermark": "user@example.com - 2025-11-03 14:30",
        "expires_at": 1699012800
      }
      ```
      
      ### 시청 시간 추적
      ```
      POST /courses/:id/track_duration
      
      Request:
      {
        "duration": 300
      }
      
      Response (200 OK):
      {}
      ```
      
      ## 7. 이벤트 관련 API
      
      ### 이벤트 목록
      ```
      GET /events
      
      Response (200 OK):
      {
        "active_events": [...],
        "upcoming_events": [...],
        "ended_events": [...]
      }
      ```
      
      ## 8. 문의 관련 API
      
      ### 문의 작성
      ```
      POST /inquiries
      
      Request:
      {
        "inquiry": {
          "title": "결제 문의",
          "content": "결제가 안되요"
        }
      }
      
      Response (201 Created):
      {
        "id": 1,
        "title": "결제 문의",
        "status": "pending"
      }
      ```
      
      ## 응답 코드
      - 200: 성공
      - 201: 생성 성공
      - 400: 잘못된 요청
      - 401: 인증 필요
      - 403: 권한 없음
      - 404: 찾을 수 없음
      - 422: 유효성 검증 실패
      - 500: 서버 오류
    MD
    
    File.write('docs/API_정의서.md', api_content)
    puts "✅ API 정의서 생성: docs/API_정의서.md"
  end
end

