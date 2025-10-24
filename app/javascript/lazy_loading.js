// Lazy Loading for Images and Videos
document.addEventListener('turbo:load', () => {
  // Intersection Observer for lazy loading
  const imageObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const img = entry.target;
        const src = img.dataset.src;
        
        if (src) {
          img.src = src;
          img.removeAttribute('data-src');
          observer.unobserve(img);
          
          img.addEventListener('load', () => {
            img.classList.add('loaded');
          });
        }
      }
    });
  }, {
    rootMargin: '50px 0px',  // 뷰포트 50px 전에 로드 시작
    threshold: 0.01
  });
  
  // 모든 data-src 이미지 관찰
  const lazyImages = document.querySelectorAll('img[data-src]');
  lazyImages.forEach(img => imageObserver.observe(img));
  
  // 썸네일 이미지 사전 로딩 (리더 뷰어)
  const readerThumbs = document.querySelectorAll('.reader-thumb-panel img[data-page]');
  if (readerThumbs.length > 0) {
    // 현재 페이지 ±3 범위만 로드
    const currentPage = parseInt(document.querySelector('.reader-page-num')?.textContent) || 1;
    
    readerThumbs.forEach(thumb => {
      const pageNum = parseInt(thumb.dataset.page);
      if (Math.abs(pageNum - currentPage) <= 3) {
        const src = thumb.dataset.src;
        if (src) {
          thumb.src = src;
          thumb.removeAttribute('data-src');
        }
      }
    });
  }
});

// Service Worker 등록 (오프라인 캐싱)
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then(registration => {
        console.log('✅ Service Worker 등록 성공:', registration.scope);
      })
      .catch(error => {
        console.log('❌ Service Worker 등록 실패:', error);
      });
  });
}

