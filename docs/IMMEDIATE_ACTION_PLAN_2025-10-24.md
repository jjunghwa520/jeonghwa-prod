# ⚡ 즉시 실행 액션 플랜

**작성일**: 2025-10-24  
**목표**: 1주일 내 Critical 이슈 해결  
**상태**: 🔴 긴급

---

## 🎯 1주일 Sprint 목표

### ✅ 완료된 작업 (오늘)

1. **PaymentsController 수정** ✅
   - `set_course` 메서드에 에러 처리 추가
   - 환경 변수 로깅 추가

2. **환경 변수 개선** ✅
   - `ENV.fetch` 패턴 적용
   - 테스트 키 경고 로깅

3. **UI 버그 수정** ✅
   - 프로필 드롭다운 투명도 개선

---

## 📋 Day 1-2: 데이터베이스 마이그레이션

### PostgreSQL 전환

#### 1. Gemfile 수정
```ruby
# Gemfile

# 제거
# gem "sqlite3", ">= 1.4"

# 추가
gem "pg", "~> 1.5"
```

#### 2. database.yml 수정
```yaml
# config/database.yml

production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  database: jeonghwa_production
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>
  port: <%= ENV.fetch('DB_PORT', 5432) %>
```

#### 3. 실행 단계
```bash
# 1. Gemfile 수정
bundle install

# 2. 로컬 PostgreSQL 설치 (Mac)
brew install postgresql@16
brew services start postgresql@16

# 3. 데이터베이스 생성
createdb jeonghwa_development
createdb jeonghwa_test

# 4. 마이그레이션
rails db:migrate
rails db:seed

# 5. 테스트
rails console
> User.count
> Course.count
```

---

## 📋 Day 3: Rate Limiting 추가

### Rack::Attack 설정

#### 1. Gemfile
```ruby
gem 'rack-attack'
```

#### 2. 설정 파일 생성
```ruby
# config/initializers/rack_attack.rb

class Rack::Attack
  ### 로그인 보호 ###
  
  # 로그인 시도 제한: IP당 15분에 5번
  throttle('login/ip', limit: 5, period: 15.minutes) do |req|
    req.ip if req.path == '/login' && req.post?
  end
  
  # 로그인 시도 제한: 이메일당 1시간에 10번
  throttle('login/email', limit: 10, period: 1.hour) do |req|
    if req.path == '/login' && req.post?
      req.params['email'].to_s.downcase.presence
    end
  end
  
  ### API 보호 ###
  
  # API 요청: IP당 1분에 60번
  throttle('api/ip', limit: 60, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end
  
  ### 회원가입 보호 ###
  
  # 회원가입: IP당 1시간에 3번
  throttle('signup/ip', limit: 3, period: 1.hour) do |req|
    req.ip if req.path == '/signup' && req.post?
  end
  
  ### 결제 보호 ###
  
  # 결제 요청: IP당 10분에 5번
  throttle('payment/ip', limit: 5, period: 10.minutes) do |req|
    req.ip if req.path.start_with?('/payments/') && req.post?
  end
  
  ### 차단된 요청 처리 ###
  
  self.throttled_responder = lambda do |env|
    [
      429,
      { 'Content-Type' => 'text/html' },
      ['<html><body><h1>너무 많은 요청입니다</h1><p>잠시 후 다시 시도해주세요.</p></body></html>']
    ]
  end
end
```

#### 3. application.rb에 활성화
```ruby
# config/application.rb

config.middleware.use Rack::Attack
```

---

## 📋 Day 4: 에러 모니터링 (Sentry)

### Sentry 통합

#### 1. Gemfile
```ruby
gem "sentry-ruby"
gem "sentry-rails"
```

#### 2. 설정
```bash
bundle install
bundle exec sentry init
```

#### 3. 설정 파일 수정
```ruby
# config/initializers/sentry.rb

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
  # 환경별 설정
  config.enabled_environments = %w[production staging]
  
  # 성능 모니터링
  config.traces_sample_rate = 0.5
  
  # 필터링
  config.excluded_exceptions += [
    'ActionController::RoutingError',
    'ActiveRecord::RecordNotFound'
  ]
end
```

---

## 📋 Day 5: 보안 헤더 추가

### Secure Headers 설정

#### 1. Gemfile
```ruby
gem 'secure_headers'
```

#### 2. 설정 파일
```ruby
# config/initializers/secure_headers.rb

SecureHeaders::Configuration.default do |config|
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]
  
  config.csp = {
    default_src: %w['self'],
    script_src: %w['self' 'unsafe-inline' https://cdn.jsdelivr.net https://www.googletagmanager.com],
    style_src: %w['self' 'unsafe-inline' https://fonts.googleapis.com],
    img_src: %w['self' data: https: blob:],
    font_src: %w['self' https://fonts.gstatic.com],
    connect_src: %w['self' https://api.tosspayments.com],
    frame_src: %w['self'],
    media_src: %w['self' blob:],
    object_src: %w['none'],
    base_uri: %w['self']
  }
  
  config.hsts = "max-age=31536000; includeSubDomains; preload"
end
```

---

## 📋 Day 6-7: 클라우드 스토리지 준비

### Google Cloud Storage 설정

#### 1. GCP 설정
```bash
# GCP Console에서:
# 1. Cloud Storage 버킷 생성
# 2. 서비스 계정 생성
# 3. 키 파일 다운로드 (google_storage_key.json)
```

#### 2. Gemfile
```ruby
gem "google-cloud-storage", "~> 1.47"
```

#### 3. storage.yml
```yaml
# config/storage.yml

google:
  service: GCS
  project: <%= ENV['GCS_PROJECT'] %>
  credentials: <%= ENV['GCS_CREDENTIALS_PATH'] %>
  bucket: <%= ENV['GCS_BUCKET'] %>

# 개발/테스트는 로컬
development:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

production:
  service: GCS
  project: <%= ENV['GCS_PROJECT'] %>
  credentials: <%= ENV['GCS_CREDENTIALS_PATH'] %>
  bucket: <%= ENV['GCS_BUCKET'] %>
```

#### 4. application.rb
```ruby
# config/environments/production.rb

config.active_storage.service = :google
```

#### 5. 마이그레이션 스크립트
```ruby
# lib/tasks/migrate_to_gcs.rake

namespace :storage do
  desc "Migrate files from local to GCS"
  task migrate_to_gcs: :environment do
    require 'fileutils'
    
    puts "Starting migration to GCS..."
    
    # 전자책 이미지
    Dir.glob(Rails.root.join('public/ebooks/**/*.{jpg,png}')).each do |file|
      relative_path = file.sub(Rails.root.join('public').to_s, '')
      puts "Uploading: #{relative_path}"
      # GCS 업로드 로직
    end
    
    # 비디오 파일
    Dir.glob(Rails.root.join('public/videos/**/*.{mp4,webm,ts,m3u8}')).each do |file|
      relative_path = file.sub(Rails.root.join('public').to_s, '')
      puts "Uploading: #{relative_path}"
      # GCS 업로드 로직
    end
    
    puts "Migration completed!"
  end
end
```

---

## 📋 추가 필수 작업

### 1. 환경 변수 정리

#### .env.example 생성
```bash
# .env.example

# Database
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432

# Toss Payments
TOSS_CLIENT_KEY=your_client_key
TOSS_SECRET_KEY=your_secret_key

# Google Cloud
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
GCS_PROJECT=your-project-id
GCS_BUCKET=jeonghwa-storage
GCS_CREDENTIALS_PATH=config/google_storage_key.json

# Sentry
SENTRY_DSN=https://your-sentry-dsn

# Email (SendGrid)
SENDGRID_API_KEY=your_api_key
EMAIL_FROM=noreply@jeonghwa.com

# Rails
SECRET_KEY_BASE=your_secret_key_base
RAILS_ENV=production
RAILS_LOG_LEVEL=info
```

### 2. .gitignore 업데이트
```
# .gitignore

/.env
/.env.local
/.env.production
/config/google_storage_key.json
/config/credentials/*.key
```

### 3. 프로덕션 체크리스트
```markdown
# PRODUCTION_CHECKLIST.md

## 배포 전 필수 확인

- [ ] 모든 환경 변수 설정 (.env.production)
- [ ] PostgreSQL 연결 테스트
- [ ] GCS 버킷 권한 확인
- [ ] Sentry DSN 설정
- [ ] SMTP 설정 테스트
- [ ] SSL 인증서 확인
- [ ] 도메인 DNS 설정
- [ ] Kamal 설정 검증
- [ ] Docker 이미지 빌드 테스트
- [ ] 백업 스크립트 테스트
- [ ] 모니터링 대시보드 접근
- [ ] 비상 연락망 구성
```

---

## 🧪 Playwright 테스트 수정

### admin-homepage-integration.spec.ts 수정

```typescript
// e2e-playwright/tests/admin-homepage-integration.spec.ts

// ❌ 문제: fixture@33 에러
test.describe('🔗 관리자 ↔ 홈페이지 실시간 통합 테스트', () => {
  let adminPage: Page;
  let homePage: Page;

  test.beforeEach(async ({ page }) => {
    adminPage = page;
    // ...
  });
  
  // ✅ 수정: context 사용
  test.describe('🔗 관리자 ↔ 홈페이지 실시간 통합 테스트', () => {
    test('전체 통합 플로우', async ({ browser }) => {
      const adminContext = await browser.newContext();
      const homeContext = await browser.newContext();
      
      const adminPage = await adminContext.newPage();
      const homePage = await homeContext.newPage();
      
      // 테스트 진행
      // ...
      
      await adminContext.close();
      await homeContext.close();
    });
  });
});
```

---

## 📊 주간 진행 추적

### Week 1 Sprint Board

| 작업 | 담당 | 상태 | 완료일 |
|------|------|------|--------|
| PaymentsController 수정 | AI | ✅ 완료 | 2025-10-24 |
| 환경 변수 개선 | AI | ✅ 완료 | 2025-10-24 |
| UI 드롭다운 수정 | AI | ✅ 완료 | 2025-10-24 |
| PostgreSQL 전환 | - | ⏳ 대기 | - |
| Rate Limiting | - | ⏳ 대기 | - |
| Sentry 통합 | - | ⏳ 대기 | - |
| Secure Headers | - | ⏳ 대기 | - |

---

## 🎯 다음 즉시 작업

### 1. PostgreSQL 전환 (최우선)

**실행 명령어**:
```bash
# 1. Gemfile 수정
# gem "sqlite3" 제거
# gem "pg" 추가

# 2. Bundle 설치
bundle install

# 3. PostgreSQL 설치 및 시작
brew install postgresql@16
brew services start postgresql@16

# 4. 데이터베이스 생성
createdb jeonghwa_development
createdb jeonghwa_test

# 5. 마이그레이션
rails db:migrate
rails db:seed

# 6. 확인
rails console
```

### 2. Rate Limiting

**실행 명령어**:
```bash
# 1. Gem 추가
bundle add rack-attack

# 2. 설정 파일 생성
# (위의 설정 내용 참고)

# 3. 재시작 및 테스트
```

### 3. Sentry

**실행 명령어**:
```bash
# 1. 계정 생성
# https://sentry.io

# 2. Gem 추가
bundle add sentry-ruby sentry-rails

# 3. 초기화
bundle exec sentry init

# 4. DSN 설정
# .env에 SENTRY_DSN 추가

# 5. 테스트
rails console
> Sentry.capture_message("Test message")
```

---

## 📝 코드 개선 체크리스트

### 컨트롤러 최적화

#### CoursesController
```ruby
# app/controllers/courses_controller.rb

def index
  @courses = Course.published
                   .includes(:instructor, :reviews) # ✅ 추가됨
                   .by_category(params[:category])
                   .by_age(params[:age])
                   .page(params[:page])
                   .per(12)
end

def show
  @course = Course.published
                  .includes(:instructor, :reviews, students: :user) # ✅ N+1 방지
                  .find(params[:id])
end
```

#### Admin::CoursesController
```ruby
# app/controllers/admin/courses_controller.rb

def index
  @courses = Course.includes(:instructor, :students, :reviews) # ✅ N+1 방지
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(20)
end
```

### 모델 개선

#### Course
```ruby
# app/models/course.rb

# ✅ 캐싱 추가
def average_rating
  Rails.cache.fetch("course:#{id}:avg_rating", expires_in: 1.hour) do
    reviews.average(:rating)&.round(1) || 0
  end
end

def total_students
  Rails.cache.fetch("course:#{id}:total_students", expires_in: 5.minutes) do
    enrollments.count
  end
end
```

---

## 🔐 보안 강화 체크리스트

### 즉시 적용 가능

- [x] PaymentsController 에러 처리 ✅
- [x] 환경 변수 로깅 ✅
- [ ] Rate Limiting (Rack::Attack)
- [ ] Secure Headers
- [ ] CSRF 토큰 검증 확인
- [ ] 세션 타임아웃 (30분)
- [ ] 비밀번호 정책 강화
- [ ] XSS 방어 재검증

### 구현 코드

#### 세션 타임아웃
```ruby
# config/initializers/session_store.rb

Rails.application.config.session_store :cookie_store, 
  key: '_jeonghwa_session',
  expire_after: 30.minutes,
  httponly: true,
  secure: Rails.env.production?,
  same_site: :lax
```

#### 비밀번호 정책
```ruby
# app/models/user.rb

validates :password, 
  length: { minimum: 8 },
  format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
    message: "는 대문자, 소문자, 숫자를 모두 포함해야 합니다"
  },
  if: :password_required?
```

---

## 📈 성능 최적화 Quick Wins

### 1. 이미지 Lazy Loading
```erb
<!-- app/views/courses/_course_card.html.erb -->

<img src="<%= course.thumbnail %>" 
     loading="lazy"
     alt="<%= course.title %>">
```

### 2. 프래그먼트 캐싱
```erb
<!-- app/views/courses/index.html.erb -->

<% cache ['courses', @courses.cache_key_with_version] do %>
  <% @courses.each do |course| %>
    <% cache course do %>
      <%= render 'course_card', course: course %>
    <% end %>
  <% end %>
<% end %>
```

### 3. 쿼리 카운터 (개발 환경)
```ruby
# Gemfile (development group)

group :development do
  gem 'bullet'
end

# config/environments/development.rb

config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

---

## 🧪 테스트 개선 플랜

### 단위 테스트 추가

#### 1. Model Tests
```ruby
# test/models/course_test.rb

class CourseTest < ActiveSupport::TestCase
  test "discounted_price calculates correctly" do
    course = courses(:one)
    course.price = 10000
    course.discount_percentage = 20
    assert_equal 8000, course.discounted_price
  end
  
  test "tag_list splits tags correctly" do
    course = courses(:one)
    course.tags = "동물,우정,교훈"
    assert_equal ["동물", "우정", "교훈"], course.tag_list
  end
end
```

#### 2. Controller Tests
```ruby
# test/controllers/courses_controller_test.rb

class CoursesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_url
    assert_response :success
    assert_select '.course-card', minimum: 1
  end
  
  test "should filter by category" do
    get courses_url(category: 'ebook')
    assert_response :success
    assert_select '.course-card'
  end
end
```

### E2E 테스트 수정

```bash
# Playwright fixture 문제 해결
cd e2e-playwright
npm test -- --project=desktop-1440
```

---

## 📊 일일 진행 보고

### Day 1: 2025-10-24 ✅
- [x] Critical 이슈 분석 완료
- [x] PaymentsController 수정
- [x] 환경 변수 개선
- [x] UI 버그 수정
- [x] 상용화 평가 보고서 작성

### Day 2: 2025-10-25 (예정)
- [ ] PostgreSQL 설치
- [ ] 데이터베이스 마이그레이션
- [ ] 데이터 검증

### Day 3: 2025-10-26 (예정)
- [ ] Rate Limiting 추가
- [ ] Sentry 통합
- [ ] 테스트

### Day 4: 2025-10-27 (예정)
- [ ] Secure Headers
- [ ] 세션 타임아웃
- [ ] 보안 테스트

### Day 5-7: 2025-10-28~30 (예정)
- [ ] GCS 설정
- [ ] 파일 마이그레이션 준비
- [ ] 문서 업데이트

---

## 🎯 성공 지표

### Week 1 목표
- ✅ Critical 이슈 0개
- ✅ PostgreSQL 전환 완료
- ✅ Rate Limiting 활성화
- ✅ 에러 모니터링 작동

### 검증 방법
```bash
# 1. PostgreSQL 확인
rails console
> ActiveRecord::Base.connection.adapter_name
# => "PostgreSQL"

# 2. Rate Limiting 테스트
# 연속 6번 로그인 시도 → 429 에러 발생 확인

# 3. Sentry 테스트
rails console
> Sentry.capture_message("Test")
# Sentry 대시보드에서 메시지 확인

# 4. 보안 헤더 확인
curl -I https://your-domain.com
# X-Frame-Options, CSP 등 확인
```

---

## 📞 지원 및 문의

### 기술 지원
- **문서**: `/docs` 디렉토리
- **이슈**: GitHub Issues
- **긴급**: Slack #dev-emergency

### 외부 서비스 지원
- **Sentry**: https://sentry.io/support
- **GCP**: https://cloud.google.com/support
- **Toss**: https://docs.tosspayments.com

---

## ✅ 완료 확인

Week 1 완료 시:
- [ ] 모든 Critical 이슈 해결
- [ ] PostgreSQL 마이그레이션
- [ ] Rate Limiting 작동
- [ ] Sentry 에러 수신
- [ ] 로컬 환경 정상 작동
- [ ] 스테이징 배포 성공

**다음 단계**: Phase 2 진행 (Week 2-5)

---

**작성자**: AI Assistant  
**승인자**: 프로젝트 매니저 검토 필요  
**업데이트**: 매일 EOD



