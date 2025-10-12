// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "bootstrap"

// Controllers import removed to avoid stimulus-loading errors
// import "controllers"

// Custom JavaScript for InfLearn Clone
document.addEventListener('DOMContentLoaded', function() {
    console.log('InfLearn Clone loaded successfully!');
});
import "./storybook_card"
import "./character_sprite_animator"
