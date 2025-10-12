// 동적 히어로 캐러셀 JavaScript
class HeroCarousel {
  constructor() {
    this.currentSlide = 1;
    this.totalSlides = 3;
    this.autoPlayInterval = null;
    this.autoPlayDelay = 3000; // 3초
    
    this.init();
  }
  
  init() {
    this.bindEvents();
    this.startAutoPlay();
  }
  
  bindEvents() {
    // 인디케이터 클릭 이벤트
    const indicators = document.querySelectorAll('.slide-indicators .indicator');
    indicators.forEach((indicator, index) => {
      indicator.addEventListener('click', () => {
        this.goToSlide(index + 1);
      });
    });
    
    // 네비게이션 화살표 클릭 이벤트
    const prevBtn = document.querySelector('.slide-nav .prev-btn');
    const nextBtn = document.querySelector('.slide-nav .next-btn');
    
    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        this.prevSlide();
      });
    }
    
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        this.nextSlide();
      });
    }
    
    // 키보드 이벤트
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') {
        this.prevSlide();
      } else if (e.key === 'ArrowRight') {
        this.nextSlide();
      }
    });
    
    // 마우스 호버 시 자동재생 일시정지
    const carousel = document.querySelector('.hero-carousel-section');
    if (carousel) {
      carousel.addEventListener('mouseenter', () => {
        this.stopAutoPlay();
      });
      
      carousel.addEventListener('mouseleave', () => {
        this.startAutoPlay();
      });
    }
    
    // 터치 이벤트 (모바일)
    this.bindTouchEvents();
  }
  
  bindTouchEvents() {
    const carousel = document.querySelector('.hero-carousel-container');
    if (!carousel) return;
    
    let startX = 0;
    let currentX = 0;
    let isDragging = false;
    
    carousel.addEventListener('touchstart', (e) => {
      startX = e.touches[0].clientX;
      isDragging = true;
      this.stopAutoPlay();
    });
    
    carousel.addEventListener('touchmove', (e) => {
      if (!isDragging) return;
      currentX = e.touches[0].clientX;
    });
    
    carousel.addEventListener('touchend', (e) => {
      if (!isDragging) return;
      isDragging = false;
      
      const diffX = startX - currentX;
      const threshold = 50;
      
      if (diffX > threshold) {
        this.nextSlide();
      } else if (diffX < -threshold) {
        this.prevSlide();
      }
      
      this.startAutoPlay();
    });
  }
  
  goToSlide(slideNumber) {
    if (slideNumber === this.currentSlide) return;
    
    // 현재 슬라이드 비활성화
    const currentSlideEl = document.querySelector(`.hero-slide[data-slide="${this.currentSlide}"]`);
    if (currentSlideEl) {
      currentSlideEl.classList.remove('active');
    }
    
    // 현재 인디케이터 비활성화
    const currentIndicator = document.querySelector(`.slide-indicators .indicator:nth-child(${this.currentSlide})`);
    if (currentIndicator) {
      currentIndicator.classList.remove('active');
    }
    
    // 새 슬라이드 활성화
    const newSlideEl = document.querySelector(`.hero-slide[data-slide="${slideNumber}"]`);
    if (newSlideEl) {
      newSlideEl.classList.add('active');
    }
    
    // 새 인디케이터 활성화
    const newIndicator = document.querySelector(`.slide-indicators .indicator:nth-child(${slideNumber})`);
    if (newIndicator) {
      newIndicator.classList.add('active');
    }
    
    this.currentSlide = slideNumber;
    
    // 캐릭터 애니메이션 트리거
    this.triggerCharacterAnimations();
  }
  
  nextSlide() {
    const nextSlide = this.currentSlide >= this.totalSlides ? 1 : this.currentSlide + 1;
    this.goToSlide(nextSlide);
  }
  
  prevSlide() {
    const prevSlide = this.currentSlide <= 1 ? this.totalSlides : this.currentSlide - 1;
    this.goToSlide(prevSlide);
  }
  
  startAutoPlay() {
    this.stopAutoPlay(); // 기존 인터벌 정리
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
  
  triggerCharacterAnimations() {
    // 현재 슬라이드의 캐릭터들에게 특별한 애니메이션 클래스 추가
    const currentSlideEl = document.querySelector(`.hero-slide[data-slide="${this.currentSlide}"]`);
    if (!currentSlideEl) return;
    
    const characters = currentSlideEl.querySelectorAll('.character');
    characters.forEach((character, index) => {
      // 애니메이션 리셋
      character.style.animation = 'none';
      character.offsetHeight; // 리플로우 강제 실행
      
      // 새로운 애니메이션 적용
      setTimeout(() => {
        character.style.animation = '';
      }, 50);
    });
    
    // 말풍선 애니메이션 트리거
    const speechBubble = currentSlideEl.querySelector('.speech-bubble');
    if (speechBubble) {
      speechBubble.style.animation = 'none';
      speechBubble.offsetHeight;
      setTimeout(() => {
        speechBubble.style.animation = '';
      }, 100);
    }
  }
  
  // 페이지 가시성 변경 시 자동재생 제어
  handleVisibilityChange() {
    if (document.hidden) {
      this.stopAutoPlay();
    } else {
      this.startAutoPlay();
    }
  }
}

// DOM 로드 완료 시 초기화
document.addEventListener('DOMContentLoaded', () => {
  // 히어로 캐러셀이 있는 경우에만 초기화
  if (document.querySelector('.hero-carousel-section')) {
    const heroCarousel = new HeroCarousel();
    
    // 페이지 가시성 변경 이벤트 바인딩
    document.addEventListener('visibilitychange', () => {
      heroCarousel.handleVisibilityChange();
    });
  }
});

// 추가적인 캐릭터 인터랙션 효과
class CharacterInteractions {
  constructor() {
    this.init();
  }
  
  init() {
    this.addClickInteractions();
    this.addHoverEffects();
  }
  
  addClickInteractions() {
    // 캐릭터 클릭 시 특별한 반응
    const characters = document.querySelectorAll('.character-img');
    characters.forEach(character => {
      character.addEventListener('click', (e) => {
        this.triggerClickAnimation(e.target);
      });
    });
  }
  
  addHoverEffects() {
    // 말풍선 호버 효과
    const speechBubbles = document.querySelectorAll('.speech-bubble');
    speechBubbles.forEach(bubble => {
      bubble.addEventListener('mouseenter', () => {
        bubble.style.transform = 'scale(1.1)';
        bubble.style.zIndex = '10';
      });
      
      bubble.addEventListener('mouseleave', () => {
        bubble.style.transform = 'scale(1)';
        bubble.style.zIndex = '4';
      });
    });
  }
  
  triggerClickAnimation(character) {
    // 클릭된 캐릭터에 특별한 애니메이션 추가
    character.style.transform = 'scale(1.2) rotate(5deg)';
    character.style.transition = 'transform 0.3s ease';
    
    setTimeout(() => {
      character.style.transform = '';
    }, 300);
    
    // 파티클 효과 추가 (선택사항)
    this.createParticleEffect(character);
  }
  
  createParticleEffect(element) {
    const rect = element.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    
    // 간단한 파티클 효과
    for (let i = 0; i < 5; i++) {
      const particle = document.createElement('div');
      particle.innerHTML = ['⭐', '✨', '💫', '🌟'][Math.floor(Math.random() * 4)];
      particle.style.position = 'fixed';
      particle.style.left = centerX + 'px';
      particle.style.top = centerY + 'px';
      particle.style.fontSize = '1.5rem';
      particle.style.pointerEvents = 'none';
      particle.style.zIndex = '1000';
      
      document.body.appendChild(particle);
      
      // 랜덤한 방향으로 이동
      const angle = (Math.PI * 2 * i) / 5;
      const distance = 100;
      const endX = centerX + Math.cos(angle) * distance;
      const endY = centerY + Math.sin(angle) * distance;
      
      particle.animate([
        { 
          transform: 'translate(0, 0) scale(0)', 
          opacity: 1 
        },
        { 
          transform: `translate(${endX - centerX}px, ${endY - centerY}px) scale(1)`, 
          opacity: 0 
        }
      ], {
        duration: 1000,
        easing: 'ease-out'
      }).onfinish = () => {
        particle.remove();
      };
    }
  }
}

// 캐릭터 인터랙션도 초기화
document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('.character-img')) {
    new CharacterInteractions();
  }
});

