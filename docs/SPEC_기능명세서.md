# 기능명세서 - 정화의 서재

생성일: 2025-11-03


## User

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| name | string | - | |
| email | string | - | |
| password_digest | string | - | |
| role | string | - | |
| bio | text | - | |
| avatar | string | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계

- has_many: taught_courses (Course)
- has_many: enrollments (Enrollment)
- has_many: enrolled_courses (Course)
- has_many: reviews (Review)
- has_many: cart_items (CartItem)
- has_many: generated_images (GeneratedImage)
- has_many: subscriptions (Subscription)
- has_one: current_subscription (Subscription)

## Course

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| title | string | - | |
| description | text | - | |
| price | decimal | - | |
| instructor_id | integer | - | NOT NULL |
| category | string | - | |
| level | string | - | |
| duration | integer | - | |
| thumbnail | string | - | |
| status | string | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |
| age | string | - | |
| video_url | string | - | |
| ebook_pages_root | string | - | |
| subtitle | string | - | |
| series_name | string | - | |
| series_order | integer | - | |
| tags | string | - | |
| difficulty | integer | - | |
| discount_percentage | integer | - | |
| production_date | date | - | |
| reviews_count | integer | - | NOT NULL |

### 관계

- belongs_to: instructor (User)
- has_many: enrollments (Enrollment)
- has_many: students (User)
- has_many: reviews (Review)
- has_many: cart_items (CartItem)
- has_many: generated_images (GeneratedImage)
- has_many: course_authors (CourseAuthor)
- has_many: authors (Author)

## Subscription

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| plan_type | string | - | NOT NULL |
| status | string | - | NOT NULL |
| start_date | date | - | NOT NULL |
| end_date | date | - | NOT NULL |
| price | decimal | - | NOT NULL |
| auto_renew | boolean | - | |
| payment_key | string | - | |
| billing_key | string | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계

- belongs_to: user (User)

## Event

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| title | string | - | |
| description | text | - | |
| start_date | datetime | - | |
| end_date | datetime | - | |
| discount_rate | integer | - | |
| status | string | - | |
| event_type | string | - | |
| banner_image | string | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계


## Inquiry

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| title | string | - | |
| content | text | - | |
| status | string | - | |
| admin_response | text | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계

- belongs_to: user (User)

## Settlement

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| course_id | integer | - | NOT NULL |
| amount | decimal | - | |
| period_start | date | - | |
| period_end | date | - | |
| status | string | - | |
| payment_date | date | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계

- belongs_to: user (User)
- belongs_to: course (Course)

## ContentView

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| course_id | integer | - | NOT NULL |
| viewed_at | datetime | - | |
| duration | integer | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계

- belongs_to: user (User)
- belongs_to: course (Course)

## Review

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| course_id | integer | - | NOT NULL |
| rating | integer | - | |
| content | text | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |
| active | boolean | - | NOT NULL |

### 관계

- belongs_to: user (User)
- belongs_to: course (Course)

## Order

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| course_id | integer | - | NOT NULL |
| order_id | string | - | |
| amount | decimal | - | |
| status | string | - | |
| payment_key | string | - | |
| approved_at | datetime | - | |
| error_message | text | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |
| refunded_at | datetime | - | |
| refund_reason | text | - | |

### 관계

- belongs_to: user (User)
- belongs_to: course (Course)

## Enrollment

### 속성

| 필드명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | - | NOT NULL |
| user_id | integer | - | NOT NULL |
| course_id | integer | - | NOT NULL |
| enrolled_at | datetime | - | |
| progress | integer | - | |
| completed | boolean | - | |
| created_at | datetime | - | NOT NULL |
| updated_at | datetime | - | NOT NULL |

### 관계

- belongs_to: user (User)
- belongs_to: course (Course)
