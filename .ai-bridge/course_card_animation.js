// 동화책 코스 카드 인터랙티브 애니메이션
document.addEventListener('DOMContentLoaded', function() {
  const courseCards = document.querySelectorAll('.storybook-course-card');
  
  courseCards.forEach(card => {
    // 마우스 움직임에 따른 3D 효과
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;
      
      const rotateX = (y - centerY) / 10;
      const rotateY = (centerX - x) / 10;
      
      card.style.transform = `
        perspective(1000px)
        rotateX(${rotateX}deg)
        rotateY(${rotateY}deg)
        translateZ(20px)
      `;
    });
    
    // 마우스 떠날 때 원래 상태로
    card.addEventListener('mouseleave', () => {
      card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateZ(0)';
    });
    
    // 클릭 시 책 펼침 애니메이션
    card.addEventListener('click', function(e) {
      if (!e.target.closest('.btn-enroll')) {
        this.classList.toggle('book-open');
        
        if (this.classList.contains('book-open')) {
          this.style.transform = 'perspective(1000px) rotateY(-30deg) translateZ(50px)';
          
          // 페이지 넘김 효과
          setTimeout(() => {
            const pageFlip = this.querySelector('.page-flip');
            if (pageFlip) {
              pageFlip.style.opacity = '0.95';
              pageFlip.style.transform = 'rotateY(-160deg)';
            }
          }, 100);
        } else {
          this.style.transform = 'perspective(1000px) rotateY(0) translateZ(0)';
          const pageFlip = this.querySelector('.page-flip');
          if (pageFlip) {
            pageFlip.style.opacity = '0';
            pageFlip.style.transform = 'rotateY(0deg)';
          }
        }
      }
    });
  });
  
  // 스크롤 시 카드 등장 애니메이션
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
      if (entry.isIntersecting) {
        setTimeout(() => {
          entry.target.classList.add('card-visible');
          entry.target.style.animation = 'cardFlipIn 0.6s ease forwards';
        }, index * 100);
      }
    });
  }, observerOptions);
  
  courseCards.forEach(card => {
    observer.observe(card);
  });
});

// 카드 등장 애니메이션
const style = document.createElement('style');
style.textContent = `
  @keyframes cardFlipIn {
    from {
      opacity: 0;
      transform: perspective(1000px) rotateY(90deg) translateZ(-100px);
    }
    to {
      opacity: 1;
      transform: perspective(1000px) rotateY(0) translateZ(0);
    }
  }
  
  .book-open {
    z-index: 10;
  }
`;
document.head.appendChild(style);
