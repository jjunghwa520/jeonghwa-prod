# 정화의 서재 표준 캐릭터 레퍼런스

## 🎭 표준 캐릭터 정의

### 1. 정화 선생님 (메인 캐릭터)
**표준 이미지**: `public/images/refined/jeonghwa_refined_isnet-general-use.png`
**대체 이미지**: `public/images/refined/jeonghwa_magic_wand_refined.png`

**캐릭터 특징**:
- 한국인 40대 여성 교육자
- 짧은 곱슬머리 (갈색)
- 파란 카디건 + 진주 목걸이 + 검은 치마
- 따뜻하고 친근한 미소
- 전문가다운 자신감 있는 자세

### 2. 곰 학생 (보조 캐릭터)
**표준 이미지**: `public/images/separated/bear_separated.png`

**캐릭터 특징**:
- 귀여운 갈색 곰
- 둥근 귀, 작은 검은 눈
- 부드러운 털 질감
- 느긋하고 온순한 성격
- 뒤뚱거리며 걷는 특징

### 3. 토끼 학생 (보조 캐릭터)  
**표준 이미지**: `public/images/separated/rabbit_separated.png`

**캐릭터 특징**:
- 귀여운 흰색 토끼
- 긴 귀, 둥근 꼬리
- 활발하고 에너지 넘치는 성격
- 깡총깡총 뛰어다니는 특징
- 호기심 많고 적극적

## 🎬 필요한 애니메이션 프레임

### 정화 선생님 애니메이션 세트
1. **걷기 사이클** (8프레임)
   - walk_1: 오른발 앞, 왼발 뒤, 오른팔 앞으로 스윙
   - walk_2: 양발 지면 접촉, 중심 이동
   - walk_3: 왼발 앞, 오른발 뒤, 왼팔 앞으로 스윙
   - walk_4: 양발 지면 접촉, 중심 이동 (반대)
   - walk_5-8: 사이클 반복

2. **방향 전환** (6프레임)
   - turn_1: 완전 옆모습 (측면)
   - turn_2: 30도 회전
   - turn_3: 45도 회전 (반측면)
   - turn_4: 60도 회전
   - turn_5: 75도 회전
   - turn_6: 완전 정면

3. **제스처 애니메이션** (5프레임)
   - gesture_1: 팔을 옆에 둔 시작 자세
   - gesture_2: 오른팔 들기 시작
   - gesture_3: 팔이 허리 높이
   - gesture_4: 완전히 뻗어 가리키기
   - gesture_5: 양팔 벌려 환영하기

### 곰 학생 애니메이션 세트
1. **뒤뚱거리며 걷기** (6프레임)
   - waddle_1: 왼쪽으로 기울어짐, 오른발 들림
   - waddle_2: 오른발 앞으로 내딛기
   - waddle_3: 오른쪽으로 기울어짐, 왼발 뒤
   - waddle_4: 왼발 앞으로 내딛기
   - waddle_5-6: 사이클 반복

2. **호기심 표현** (4프레임)
   - curious_1: 평범한 자세
   - curious_2: 목 앞으로 내밀기
   - curious_3: 고개 기울이기
   - curious_4: 눈 크게 뜨기

### 토끼 학생 애니메이션 세트
1. **깡총깡총 뛰기** (8프레임)
   - hop_1: 점프 준비 (뒷다리 구부림)
   - hop_2: 점프 시작 (지면 이탈)
   - hop_3: 공중 상승 (다리 모음)
   - hop_4: 최고점 (다리 펼침)
   - hop_5: 하강 시작
   - hop_6: 착지 준비 (앞다리 먼저)
   - hop_7: 착지 완료
   - hop_8: 안정화

2. **흥분 표현** (4프레임)
   - excited_1: 평범한 자세
   - excited_2: 귀 쫑긋 세우기
   - excited_3: 작은 점프
   - excited_4: 앞다리로 가리키기

## 🗂️ 파일 정리 계획

### 삭제할 불필요한 이미지들
- `/images/jeonghwa/safe/` (다른 캐릭터들)
- `/images/jeonghwa/korean/` (중복 버전들)
- `/images/jeonghwa/teacher/` (중복 버전들)
- `/images/jeonghwa/accurate/` (중복 버전들)
- `/images/characters/` (혼재된 캐릭터들)

### 유지할 표준 이미지들
- `public/images/refined/jeonghwa_refined_isnet-general-use.png` ✅
- `public/images/separated/bear_separated.png` ✅  
- `public/images/separated/rabbit_separated.png` ✅

## 🎯 최종 목표

**일관된 3명의 캐릭터**가 **각 슬라이드에서 동일하게 유지**되면서, **실제 움직이는 애니메이션**을 보여주는 시스템 구축

