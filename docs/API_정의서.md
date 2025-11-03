# API 정의서 - 정화의 서재

생성일: 2025-11-03
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
