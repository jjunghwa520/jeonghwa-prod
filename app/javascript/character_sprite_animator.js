// 캐릭터 스프라이트 애니메이션 시스템
class CharacterSpriteAnimator {
  constructor() {
    this.characters = {
      jeonghwa: {
        element: null,
        currentAnimation: null,
        animations: {
          slide1: {
            frames: [
              // 실제 걷기 사이클 (2초)
              '/images/jeonghwa/poses/walk_cycle_1.png',
              '/images/jeonghwa/poses/walk_cycle_2.png',
              '/images/jeonghwa/poses/walk_cycle_3.png',
              '/images/jeonghwa/poses/walk_cycle_4.png',
              '/images/jeonghwa/poses/walk_cycle_5.png',
              '/images/jeonghwa/poses/walk_cycle_6.png',
              '/images/jeonghwa/poses/walk_cycle_7.png',
              '/images/jeonghwa/poses/walk_cycle_8.png',
              // 방향 전환 (1.5초)
              '/images/jeonghwa/poses/turn_side_to_front_1.png',
              '/images/jeonghwa/poses/turn_side_to_front_2.png',
              '/images/jeonghwa/poses/turn_side_to_front_3.png',
              '/images/jeonghwa/poses/turn_side_to_front_4.png',
              '/images/jeonghwa/poses/turn_side_to_front_5.png',
              '/images/jeonghwa/poses/turn_side_to_front_6.png',
              '/images/jeonghwa/poses/turn_side_to_front_7.png',
              // 제스처 애니메이션 (2.5초)
              '/images/jeonghwa/poses/gesture_start.png',
              '/images/jeonghwa/poses/gesture_lift_1.png',
              '/images/jeonghwa/poses/gesture_lift_2.png',
              '/images/jeonghwa/poses/gesture_point.png',
              '/images/jeonghwa/poses/gesture_emphasize.png'
            ],
            duration: 6000, // 6초
            loop: true
          },
          slide2: {
            frames: [
              '/images/jeonghwa/poses/approach_teaching.png',
              '/images/jeonghwa/poses/teaching_gesture_1.png',
              '/images/jeonghwa/poses/teaching_gesture_2.png',
              '/images/jeonghwa/poses/professional_pose.png'
            ],
            duration: 6000,
            loop: true
          },
          slide3: {
            frames: [
              '/images/jeonghwa/poses/proud_presentation_1.png',
              '/images/jeonghwa/poses/proud_presentation_2.png',
              '/images/jeonghwa/poses/achievement_gesture.png',
              '/images/jeonghwa/poses/confident_pose.png'
            ],
            duration: 6000,
            loop: true
          }
        }
      },
      bear: {
        element: null,
        currentAnimation: null,
        animations: {
          slide1: {
            frames: [
              // 실제 뒤뚱거리며 걷기 사이클 (3초)
              '/images/bear/poses/waddle_cycle_1.png',
              '/images/bear/poses/waddle_cycle_2.png',
              '/images/bear/poses/waddle_cycle_3.png',
              '/images/bear/poses/waddle_cycle_4.png',
              '/images/bear/poses/waddle_cycle_5.png',
              '/images/bear/poses/waddle_cycle_6.png',
              // 방향 전환 (2초)
              '/images/bear/poses/bear_turn_1.png',
              '/images/bear/poses/bear_turn_2.png',
              '/images/bear/poses/bear_turn_3.png',
              '/images/bear/poses/bear_turn_4.png',
              '/images/bear/poses/bear_turn_5.png',
              '/images/bear/poses/bear_turn_6.png',
              // 호기심 표현 (3초)
              '/images/bear/poses/curious_start.png',
              '/images/bear/poses/curious_lean_forward.png',
              '/images/bear/poses/curious_tilt_left.png',
              '/images/bear/poses/curious_tilt_right.png',
              '/images/bear/poses/curious_eyes_wide.png'
            ],
            duration: 8000, // 8초
            loop: true
          },
          slide2: {
            frames: [
              '/images/bear/poses/study_walking.png',
              '/images/bear/poses/focused_front.png',
              '/images/bear/poses/reading_pose.png',
              '/images/bear/poses/thinking_pose.png'
            ],
            duration: 8000,
            loop: true
          },
          slide3: {
            frames: [
              '/images/bear/poses/march_1.png',
              '/images/bear/poses/march_2.png',
              '/images/bear/poses/celebration_1.png',
              '/images/bear/poses/celebration_2.png',
              '/images/bear/poses/success_pose.png'
            ],
            duration: 8000,
            loop: true
          }
        }
      },
      rabbit: {
        element: null,
        currentAnimation: null,
        animations: {
          slide1: {
            frames: [
              // 실제 깡총깡총 뛰기 사이클 (3초)
              '/images/rabbit/poses/hop_cycle_1.png',
              '/images/rabbit/poses/hop_cycle_2.png',
              '/images/rabbit/poses/hop_cycle_3.png',
              '/images/rabbit/poses/hop_cycle_4.png',
              '/images/rabbit/poses/hop_cycle_5.png',
              '/images/rabbit/poses/hop_cycle_6.png',
              '/images/rabbit/poses/hop_cycle_7.png',
              '/images/rabbit/poses/hop_cycle_8.png',
              // 방향 전환 (2초)  
              '/images/rabbit/poses/rabbit_turn_1.png',
              '/images/rabbit/poses/rabbit_turn_2.png',
              '/images/rabbit/poses/rabbit_turn_3.png',
              '/images/rabbit/poses/rabbit_turn_4.png',
              '/images/rabbit/poses/rabbit_turn_5.png',
              '/images/rabbit/poses/rabbit_turn_6.png',
              '/images/rabbit/poses/rabbit_turn_7.png',
              // 흥분 표현 (2초)
              '/images/rabbit/poses/excited_start.png',
              '/images/rabbit/poses/excited_ears_up.png',
              '/images/rabbit/poses/excited_bounce_prep.png',
              '/images/rabbit/poses/excited_small_hop.png',
              '/images/rabbit/poses/excited_point_gesture.png',
              '/images/rabbit/poses/excited_tail_twitch.png'
            ],
            duration: 7000, // 7초
            loop: true
          },
          slide2: {
            frames: [
              '/images/rabbit/poses/eager_approach.png',
              '/images/rabbit/poses/hand_raise_1.png',
              '/images/rabbit/poses/hand_raise_2.png',
              '/images/rabbit/poses/enthusiastic_front.png'
            ],
            duration: 7000,
            loop: true
          },
          slide3: {
            frames: [
              '/images/rabbit/poses/victory_jump_1.png',
              '/images/rabbit/poses/victory_jump_2.png',
              '/images/rabbit/poses/victory_jump_3.png',
              '/images/rabbit/poses/dance_1.png',
              '/images/rabbit/poses/dance_2.png',
              '/images/rabbit/poses/celebration_spin.png'
            ],
            duration: 7000,
            loop: true
          }
        }
      }
    };
    
    this.currentSlide = 1;
    this.animationIntervals = {};
  }
  
  init() {
    this.bindCharacterElements();
    this.preloadImages();
  }
  
  bindCharacterElements() {
    // 캐릭터 이미지 요소들 찾기
    this.characters.jeonghwa.element = document.querySelector('.jeonghwa-character .character-img');
    this.characters.bear.element = document.querySelector('.bear-character .character-img');
    this.characters.rabbit.element = document.querySelector('.rabbit-character .character-img');
  }
  
  preloadImages() {
    // 모든 프레임 이미지를 미리 로드
    Object.keys(this.characters).forEach(characterName => {
      const character = this.characters[characterName];
      Object.keys(character.animations).forEach(animationName => {
        const animation = character.animations[animationName];
        animation.frames.forEach(frameSrc => {
          const img = new Image();
          img.src = frameSrc;
        });
      });
    });
  }
  
  startSlideAnimation(slideNumber) {
    this.currentSlide = slideNumber;
    this.stopAllAnimations();
    
    // 각 캐릭터의 해당 슬라이드 애니메이션 시작
    Object.keys(this.characters).forEach(characterName => {
      this.startCharacterAnimation(characterName, `slide${slideNumber}`);
    });
  }
  
  startCharacterAnimation(characterName, animationName) {
    const character = this.characters[characterName];
    const animation = character.animations[animationName];
    
    if (!character.element || !animation) {
      console.warn(`Character ${characterName} or animation ${animationName} not found`);
      return;
    }
    
    let currentFrame = 0;
    const frameInterval = animation.duration / animation.frames.length;
    
    // 첫 번째 프레임 표시
    this.showFrame(character.element, animation.frames[currentFrame]);
    
    // 애니메이션 인터벌 설정
    const intervalId = setInterval(() => {
      currentFrame = (currentFrame + 1) % animation.frames.length;
      this.showFrame(character.element, animation.frames[currentFrame]);
    }, frameInterval);
    
    this.animationIntervals[`${characterName}_${animationName}`] = intervalId;
    character.currentAnimation = animationName;
  }
  
  showFrame(element, frameSrc) {
    if (element) {
      element.src = frameSrc;
      
      // 이미지 로드 실패 시 대체 이미지 사용
      element.onerror = () => {
        console.warn(`Failed to load frame: ${frameSrc}`);
        // 기존 이미지를 대체 이미지로 사용
        if (element.classList.contains('jeonghwa-img')) {
          element.src = '/images/refined/jeonghwa_refined_isnet-general-use.png';
        } else if (element.classList.contains('bear-img')) {
          element.src = '/images/separated/bear_separated.png';
        } else if (element.classList.contains('rabbit-img')) {
          element.src = '/images/separated/rabbit_separated.png';
        }
      };
    }
  }
  
  stopAllAnimations() {
    // 모든 애니메이션 인터벌 정리
    Object.keys(this.animationIntervals).forEach(key => {
      clearInterval(this.animationIntervals[key]);
      delete this.animationIntervals[key];
    });
  }
  
  // 현재 이미지 기반으로 임시 프레임 생성 (이미지가 준비되기 전까지)
  generateTemporaryFrames(characterName, slideNumber) {
    const character = this.characters[characterName];
    const baseImages = {
      jeonghwa: '/images/refined/jeonghwa_refined_isnet-general-use.png',
      bear: '/images/separated/bear_separated.png', 
      rabbit: '/images/separated/rabbit_separated.png'
    };
    
    // 임시로 기존 이미지를 사용하되, CSS 변형을 적용
    const tempFrames = [];
    const baseImage = baseImages[characterName];
    
    for (let i = 0; i < 5; i++) {
      tempFrames.push(baseImage);
    }
    
    character.animations[`slide${slideNumber}`].frames = tempFrames;
  }
}

// 기존 히어로 캐러셀과 통합
class IntegratedHeroCarousel {
  constructor() {
    this.spriteAnimator = new CharacterSpriteAnimator();
    this.currentSlide = 1;
    this.totalSlides = 3;
    this.autoPlayInterval = null;
    this.autoPlayDelay = 3000;
  }
  
  init() {
    this.spriteAnimator.init();
    this.bindEvents();
    this.startAutoPlay();
    
    // 첫 번째 슬라이드 애니메이션 시작
    this.spriteAnimator.startSlideAnimation(1);
  }
  
  bindEvents() {
    // 기존 네비게이션 이벤트는 그대로 유지
    const indicators = document.querySelectorAll('.slide-indicators .indicator');
    indicators.forEach((indicator, index) => {
      indicator.addEventListener('click', () => {
        this.goToSlide(index + 1);
      });
    });
    
    const prevBtn = document.querySelector('.slide-nav .prev-btn');
    const nextBtn = document.querySelector('.slide-nav .next-btn');
    
    if (prevBtn) prevBtn.addEventListener('click', () => this.prevSlide());
    if (nextBtn) nextBtn.addEventListener('click', () => this.nextSlide());
    
    // 키보드 이벤트
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') this.prevSlide();
      else if (e.key === 'ArrowRight') this.nextSlide();
    });
    
    // 마우스 호버 이벤트
    const carousel = document.querySelector('.hero-carousel-section');
    if (carousel) {
      carousel.addEventListener('mouseenter', () => this.stopAutoPlay());
      carousel.addEventListener('mouseleave', () => this.startAutoPlay());
    }
  }
  
  goToSlide(slideNumber) {
    if (slideNumber === this.currentSlide) return;
    
    console.log('Going to slide:', slideNumber);
    
    // 기존 슬라이드 전환 로직
    const currentSlideEl = document.querySelector(`.hero-slide[data-slide="${this.currentSlide}"]`);
    if (currentSlideEl) currentSlideEl.classList.remove('active');
    
    const currentIndicator = document.querySelector(`.slide-indicators .indicator[data-slide="${this.currentSlide}"]`);
    if (currentIndicator) currentIndicator.classList.remove('active');
    
    const newSlideEl = document.querySelector(`.hero-slide[data-slide="${slideNumber}"]`);
    if (newSlideEl) newSlideEl.classList.add('active');
    
    const newIndicator = document.querySelector(`.slide-indicators .indicator[data-slide="${slideNumber}"]`);
    if (newIndicator) newIndicator.classList.add('active');
    
    this.currentSlide = slideNumber;
    
    // 캐릭터 스프라이트 애니메이션 시작
    this.spriteAnimator.startSlideAnimation(slideNumber);
  }
  
  nextSlide() {
    const nextSlideNum = this.currentSlide >= this.totalSlides ? 1 : this.currentSlide + 1;
    this.goToSlide(nextSlideNum);
  }
  
  prevSlide() {
    const prevSlideNum = this.currentSlide <= 1 ? this.totalSlides : this.currentSlide - 1;
    this.goToSlide(prevSlideNum);
  }
  
  startAutoPlay() {
    this.stopAutoPlay();
    this.autoPlayInterval = setInterval(() => {
      this.nextSlide();
    }, this.autoPlayDelay);
  }
  
  stopAutoPlay() {
    if (this.autoPlayInterval) {
      clearInterval(this.autoPlayInterval);
      this.autoPlayInterval = null;
    }
  }
}

// 초기화
document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelector('.hero-carousel-section')) {
    console.log('Initializing Integrated Hero Carousel with Sprite Animation...');
    window.heroCarousel = new IntegratedHeroCarousel();
    window.heroCarousel.init();
  }
});
