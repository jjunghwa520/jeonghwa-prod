class Analytic < ApplicationRecord
  METRIC_TYPES = %w[daily_signups daily_revenue churn_rate avg_content_views].freeze
  
  validates :date, presence: true, uniqueness: { scope: :metric_type }
  validates :metric_type, presence: true, inclusion: { in: METRIC_TYPES }
  
  scope :daily_signups, -> { where(metric_type: 'daily_signups') }
  scope :daily_revenue, -> { where(metric_type: 'daily_revenue') }
  scope :churn_rate, -> { where(metric_type: 'churn_rate') }
  scope :avg_content_views, -> { where(metric_type: 'avg_content_views') }
  scope :recent_days, ->(days = 30) { where('date >= ?', days.days.ago.to_date).order(date: :desc) }
  
  # 통계 생성 메서드
  def self.generate_daily_stats(date = Date.today)
    # 일일 가입자
    create_or_update(date, 'daily_signups', user_count: User.where(created_at: date.all_day).count)
    
    # 일일 매출
    revenue = Order.where(created_at: date.all_day).sum(:amount)
    create_or_update(date, 'daily_revenue', value: revenue)
    
    # 평균 콘텐츠 열람 수
    avg_views = ContentView.where(viewed_at: date.all_day).group(:user_id).count.values.sum.to_f / 
                User.where(created_at: ...date.end_of_day).count
    create_or_update(date, 'avg_content_views', value: avg_views)
  end
  
  private
  
  def self.create_or_update(date, metric_type, attributes = {})
    record = find_or_initialize_by(date: date, metric_type: metric_type)
    record.update(attributes)
  end
end
