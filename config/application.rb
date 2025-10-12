require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KicdaJh
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    
    # 개발 환경에서 CSP 비활성화
    if Rails.env.development?
      config.content_security_policy_nonce_generator = nil
      config.content_security_policy_nonce_directives = []
      config.content_security_policy_report_only = false
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Asset pipeline configuration for Rails 8
    # Use Sprockets only for CSS/SCSS, JavaScript handled by importmap
    config.assets.enabled = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
  end
end
