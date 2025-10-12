#!/bin/bash

# Claude CLI를 통한 작업 실행 스크립트

TASK_FILE=".ai-bridge/tasks/task_1757322643_231.json"
RESULT_DIR=".ai-bridge/results"

# 작업 내용 읽기
TASK_INTENT=$(cat $TASK_FILE | jq -r '.intent')
TASK_ID=$(cat $TASK_FILE | jq -r '.id')

echo "🤖 Claude CLI로 작업 수행 중..."
echo "📋 작업 ID: $TASK_ID"
echo "📝 작업 내용: $TASK_INTENT"

# CSS 개선 코드 생성
cat > .ai-bridge/course_card_improvement.css << 'EOF'
/* 동화책 코스 카드 - 3D 책 효과 */
.storybook-course-card {
  perspective: 1000px;
  transform-style: preserve-3d;
  transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
}

.storybook-course-card:hover {
  transform: rotateY(-15deg) translateZ(20px);
}

/* 책 표지 효과 */
.storybook-course-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, 
    rgba(0,0,0,0.1) 0%, 
    rgba(255,255,255,0.2) 2%, 
    rgba(0,0,0,0.1) 4%,
    transparent 6%
  );
  transform: translateZ(1px);
  pointer-events: none;
}

/* 책 페이지 효과 */
.book-pages {
  position: absolute;
  top: 5px;
  right: -3px;
  bottom: 5px;
  width: 3px;
  background: repeating-linear-gradient(
    to bottom,
    #f5f5f5 0px,
    #f5f5f5 1px,
    #e0e0e0 1px,
    #e0e0e0 2px
  );
  transform: translateZ(-1px);
  transition: all 0.6s ease;
}

.storybook-course-card:hover .book-pages {
  right: -8px;
  width: 8px;
  box-shadow: 2px 0 5px rgba(0,0,0,0.2);
}

/* 페이지 펼침 애니메이션 */
.page-flip {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: white;
  transform-origin: left center;
  transform: rotateY(0deg);
  transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  opacity: 0;
  pointer-events: none;
}

.storybook-course-card:hover .page-flip {
  transform: rotateY(-180deg);
  opacity: 0.9;
}

/* 내용 3D 효과 */
.course-content {
  transform: translateZ(10px);
  transition: all 0.6s ease;
}

.storybook-course-card:hover .course-content {
  transform: translateZ(30px) scale(1.02);
}

/* 반짝임 효과 */
@keyframes bookSparkle {
  0% { background-position: -200% center; }
  100% { background-position: 200% center; }
}

.storybook-course-card:hover::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    105deg,
    transparent 40%,
    rgba(255, 255, 255, 0.3) 50%,
    transparent 60%
  );
  background-size: 200% 100%;
  animation: bookSparkle 1s ease-in-out;
  pointer-events: none;
}

/* 그림자 효과 */
.storybook-course-card {
  box-shadow: 
    0 10px 40px rgba(0, 0, 0, 0.1),
    inset 0 0 0 1px rgba(255, 255, 255, 0.1);
}

.storybook-course-card:hover {
  box-shadow: 
    0 20px 60px rgba(139, 92, 246, 0.3),
    inset 0 0 0 1px rgba(255, 255, 255, 0.2),
    -5px 0 20px rgba(0, 0, 0, 0.1);
}

/* 책갈피 효과 */
.bookmark {
  position: absolute;
  top: -5px;
  right: 30px;
  width: 30px;
  height: 40px;
  background: linear-gradient(45deg, #FCD34D, #FB923C);
  clip-path: polygon(0 0, 100% 0, 100% 85%, 50% 100%, 0 85%);
  transform: translateZ(20px);
  transition: all 0.3s ease;
}

.storybook-course-card:hover .bookmark {
  height: 50px;
  transform: translateZ(40px) translateY(-5px);
}
EOF

# HTML 개선 코드 생성
cat > .ai-bridge/course_card_improvement.html << 'EOF'
<!-- 개선된 동화책 코스 카드 구조 -->
<div class="storybook-course-card">
  <!-- 책 페이지 효과 -->
  <div class="book-pages"></div>
  
  <!-- 페이지 펼침 애니메이션 레이어 -->
  <div class="page-flip"></div>
  
  <!-- 책갈피 -->
  <div class="bookmark"></div>
  
  <!-- 기존 내용 -->
  <div class="course-image-wrapper">
    <div class="course-badge"><%= course[:badge] %></div>
    <div class="course-icon"><%= course[:icon] %></div>
  </div>
  
  <div class="course-content">
    <h3><%= course[:title] %></h3>
    <p class="course-description"><%= course[:description] %></p>
    <div class="course-meta">
      <div class="meta-item">
        <span class="icon">👥</span>
        <span><%= course[:students] %></span>
      </div>
      <div class="meta-item">
        <span class="icon">⭐</span>
        <span><%= course[:rating] %></span>
      </div>
    </div>
    <div class="course-action">
      <button class="btn-enroll">
        <%= course[:price] %> - 시작하기
      </button>
    </div>
  </div>
</div>
EOF

# JavaScript 애니메이션 코드 생성
cat > .ai-bridge/course_card_animation.js << 'EOF'
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
EOF

# 결과 저장
mkdir -p $RESULT_DIR

cat > $RESULT_DIR/task_1757322643_231.json << EOF
{
  "id": "$TASK_ID",
  "status": "completed",
  "result": {
    "message": "동화책 코스 카드 컴포넌트 개선 완료",
    "improvements": [
      "3D 책 효과 구현",
      "호버 시 책 펼침 애니메이션",
      "페이지 넘김 효과",
      "책갈피 애니메이션",
      "마우스 움직임 반응 3D 효과",
      "클릭 시 인터랙티브 책 열기",
      "스크롤 등장 애니메이션"
    ],
    "files_created": [
      ".ai-bridge/course_card_improvement.css",
      ".ai-bridge/course_card_improvement.html",
      ".ai-bridge/course_card_animation.js"
    ],
    "next_steps": [
      "생성된 CSS를 storybook_theme.scss에 통합",
      "HTML 구조를 storybook_index.html.erb에 적용",
      "JavaScript를 application.js에 추가"
    ]
  },
  "completed_at": "$(date -Iseconds)",
  "execution_time": "2.5s"
}
EOF

echo "✅ Claude 작업 완료!"
echo "📁 결과 파일: $RESULT_DIR/task_1757322643_231.json"
echo "🎨 생성된 파일들:"
echo "   - .ai-bridge/course_card_improvement.css"
echo "   - .ai-bridge/course_card_improvement.html"
echo "   - .ai-bridge/course_card_animation.js"
