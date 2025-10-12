# 캐릭터 애니메이션 레퍼런스 가이드

## 🎭 현재 캐릭터 상태 분석

### 정화 선생님
**기존 이미지**: 
- main: 정면 서있는 모습
- teaching: 교육하는 모습  
- welcome: 환영하는 모습
- sitting: 앉아있는 모습

### 곰 학생 & 토끼 학생
**기존 이미지**: 기본 정면 서있는 모습만 존재

## 🎬 필요한 애니메이션 포즈 (각 캐릭터별)

### 슬라이드 1: 새로운 콘텐츠 소개
**정화 선생님**:
1. `walk_side_left` - 좌측에서 걸어오는 옆모습
2. `walk_side_right` - 우측으로 걸어가는 옆모습  
3. `walk_front_1` - 정면 걷기 프레임 1 (왼발 앞)
4. `walk_front_2` - 정면 걷기 프레임 2 (오른발 앞)
5. `present_content` - 콘텐츠를 가리키며 소개
6. `gesture_right` - 오른쪽을 가리키는 제스처

**곰 학생**:
1. `waddle_left_1` - 뒤뚱거리며 걷기 1 (왼쪽 기울어짐)
2. `waddle_left_2` - 뒤뚱거리며 걷기 2 (오른쪽 기울어짐)
3. `side_profile_left` - 좌측 옆모습
4. `front_curious` - 정면에서 호기심 가득한 표정
5. `nod_interested` - 관심있게 고개 끄덕임

**토끼 학생**:
1. `hop_1` - 점프 준비 자세
2. `hop_2` - 공중에 떠있는 모습
3. `hop_3` - 착지 자세
4. `side_profile_right` - 우측 옆모습
5. `excited_pointing` - 흥미진진하게 가리키기

### 슬라이드 2: 교육 프로그램 소개
**정화 선생님**:
1. `approach_teaching` - 교육자로서 접근하는 모습
2. `teaching_gesture_1` - 설명하는 제스처 1
3. `teaching_gesture_2` - 설명하는 제스처 2
4. `professional_pose` - 전문가다운 자세

**곰 학생**:
1. `study_walking` - 공부하며 걷기
2. `focused_front` - 집중하는 정면 모습
3. `reading_pose` - 책 읽는 자세
4. `thinking_pose` - 생각하는 자세

**토끼 학생**:
1. `eager_approach` - 열심히 다가오기
2. `hand_raise_1` - 손 들기 1단계
3. `hand_raise_2` - 손 들기 2단계 (높이)
4. `enthusiastic_front` - 열정적인 정면 모습

### 슬라이드 3: 성공 사례 소개
**정화 선생님**:
1. `proud_presentation_1` - 자랑스럽게 발표 1
2. `proud_presentation_2` - 자랑스럽게 발표 2
3. `achievement_gesture` - 성과를 보여주는 제스처
4. `confident_pose` - 자신감 넘치는 포즈

**곰 학생**:
1. `march_1` - 행진하기 1 (왼발)
2. `march_2` - 행진하기 2 (오른발)
3. `celebration_1` - 축하 동작 1
4. `celebration_2` - 축하 동작 2
5. `success_pose` - 성공 포즈

**토끼 학생**:
1. `victory_jump_1` - 승리의 점프 1
2. `victory_jump_2` - 승리의 점프 2 (최고점)
3. `victory_jump_3` - 승리의 점프 3 (착지)
4. `dance_1` - 춤 동작 1
5. `dance_2` - 춤 동작 2
6. `celebration_spin` - 축하하며 돌기

## 🎨 이미지 생성 전략

### 1단계: 기본 포즈 확장
기존 캐릭터를 기반으로 각도와 포즈 변화

### 2단계: 걷기 프레임 생성
각 캐릭터의 특성에 맞는 걷기 사이클

### 3단계: 감정 표현 강화
각 장면에 맞는 감정과 제스처

### 4단계: 스프라이트 시트 구성
연속 애니메이션을 위한 프레임 배열

## 🔧 기술 구현 방향

1. **CSS Sprite Animation**: background-position 변경
2. **Sequential Image Loading**: 여러 이미지를 순차 표시
3. **Canvas Animation**: 더 부드러운 전환 효과
4. **WebP/AVIF 최적화**: 빠른 로딩을 위한 포맷 최적화

## 📁 파일 구조 제안

```
public/images/characters/
├── jeonghwa/
│   ├── poses/
│   │   ├── walk_side_left.png
│   │   ├── walk_front_1.png
│   │   ├── present_content.png
│   │   └── ...
│   └── sprites/
│       ├── slide1_animation.png
│       ├── slide2_animation.png
│       └── slide3_animation.png
├── bear/
│   ├── poses/
│   └── sprites/
└── rabbit/
    ├── poses/
    └── sprites/
```

