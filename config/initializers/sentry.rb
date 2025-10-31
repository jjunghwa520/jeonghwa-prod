if ENV["SENTRY_DSN"].present?
  begin
    require 'sentry-ruby'
    Sentry.init do |config|
      config.dsn = ENV["SENTRY_DSN"]
      config.breadcrumbs_logger = [:active_support_logger, :http_logger]
      config.environment = Rails.env
      config.traces_sample_rate = 0.2
      config.profiles_sample_rate = 0.0
    end
  rescue LoadError
    Rails.logger.warn "Sentry gem not installed; skipping Sentry initialization"
  end
end



