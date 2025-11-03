class Settlement < ApplicationRecord
  belongs_to :user  # instructor/author
  belongs_to :course, optional: true  # 특정 콘텐츠 또는 전체
  
  STATUSES = %w[pending approved paid].freeze
  COMMISSION_RATE = 0.7  # 작가에게 70% 지급
  
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :period_start, presence: true
  validates :period_end, presence: true
  
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :paid, -> { where(status: 'paid') }
  scope :this_month, -> { where('period_start >= ?', Date.today.beginning_of_month) }
  
  # 특정 기간의 정산 생성
  def self.create_monthly_settlement(user, start_date, end_date)
    courses = user.taught_courses
    total_revenue = 0
    
    courses.each do |course|
      # 콘텐츠별 조회 수와 시청 시간 기반 수익 계산
      views = ContentView.where(course: course, viewed_at: start_date..end_date).count
      total_duration = ContentView.where(course: course, viewed_at: start_date..end_date).sum(:duration) || 0
      
      # 구매 수익
      purchase_revenue = Order.joins(:enrollment)
                              .where(enrollments: { course: course })
                              .where(created_at: start_date..end_date)
                              .sum(:amount)
      
      # 구독 기반 수익 (조회수 * 가중치)
      subscription_revenue = calculate_subscription_revenue(course, views, total_duration)
      
      course_total = (purchase_revenue + subscription_revenue) * COMMISSION_RATE
      total_revenue += course_total
    end
    
    create(
      user: user,
      amount: total_revenue,
      period_start: start_date,
      period_end: end_date,
      status: 'pending'
    )
  end
  
  # 승인
  def approve!
    update(status: 'approved')
  end
  
  # 지급 완료
  def mark_as_paid!
    update(status: 'paid', payment_date: Date.today)
  end
  
  private
  
  def self.calculate_subscription_revenue(course, views, total_duration)
    # 구독 수익 풀에서 비율에 따라 분배
    total_subscription_revenue = Subscription.where(
      status: 'active',
      created_at: ...Date.today
    ).sum(:price)
    
    # 조회 수와 시청 시간 기반 가중치
    weight = (views * 10) + (total_duration / 60.0)  # 조회수 더 높은 가중치
    
    # 전체 조회 가중치 대비 비율
    total_weight = ContentView.where(viewed_at: Date.today.beginning_of_month..Date.today).count * 10
    
    return 0 if total_weight == 0
    
    (total_subscription_revenue * (weight / total_weight.to_f))
  end
end
