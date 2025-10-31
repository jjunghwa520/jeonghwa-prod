export function initAppUI() {
  document.addEventListener('DOMContentLoaded', function() {
    const navbar = document.getElementById('mainNav');
    if (navbar) {
      window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
          navbar.classList.add('scrolled');
        } else {
          navbar.classList.remove('scrolled');
        }
      });
    }

    const scrollTopBtn = document.getElementById('scrollTop');
    if (scrollTopBtn) {
      window.addEventListener('scroll', function() {
        if (window.scrollY > 300) {
          scrollTopBtn.classList.add('show');
        } else {
          scrollTopBtn.classList.remove('show');
        }
      });
      scrollTopBtn.addEventListener('click', function() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    }

    const toasts = document.querySelectorAll('.toast-modern');
    toasts.forEach(toast => {
      toast.setAttribute('role', 'status');
      toast.setAttribute('aria-live', 'polite');
      setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
      }, 5000);
    });
  });
}

// Auto-init
initAppUI();



