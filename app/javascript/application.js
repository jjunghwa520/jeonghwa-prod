// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "bootstrap"

// Controllers import removed to avoid stimulus-loading errors
// import "controllers"

// Custom JavaScript for InfLearn Clone
function resetPreviewClasses() {
  const html = document.documentElement;
  const removeList = [
    'style-clean','style-soft','style-editorial','style-dark','style-minimal','style-storytelling',
    'concept-c1','concept-c2','concept-c3','concept-c4','concept-c5','concept-c6','concept-c7','concept-c8'
  ];
  removeList.forEach(c => html.classList.remove(c));
}

function onLoad() {
  console.log('InfLearn Clone loaded successfully!');
  const isPreview = window.location.pathname.indexOf('/hero_preview') === 0;
  resetPreviewClasses();
  // Scope style/concept classes to preview page only (content wrappers handle styles elsewhere)
  if (isPreview) {
    try {
      const params = new URLSearchParams(window.location.search);
      const style = params.get('style');
      if (style && ['clean','soft','editorial','dark','minimal','storytelling'].includes(style)) {
        document.documentElement.classList.add(`style-${style}`);
      }
      const concept = params.get('concept');
      if (concept && /^c[1-8]$/.test(concept)) {
        document.documentElement.classList.add(`concept-${concept}`);
      }
    } catch(e) { /* no-op */ }
  }
}

document.addEventListener('turbo:load', onLoad);
document.addEventListener('DOMContentLoaded', onLoad);
import "./storybook_card"
import "./character_sprite_animator"
