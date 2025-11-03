class Admin::AnalyticsController < Admin::BaseController
  def index
    @date_range = (30.days.ago.to_date..Date.today)
    
    # 전체 통계
    @total_users = User.count
    @total_courses = Course.count
    @total_subscriptions = Subscription.active.count
    @monthly_revenue = Order.where('created_at >= ?', Date.today.beginning_of_month).sum(:amount)
    
    # 차트 데이터
    @signup_chart_data = generate_signup_chart_data
    @revenue_chart_data = generate_revenue_chart_data
    @content_view_chart_data = generate_content_view_chart_data
    
    # 인기 콘텐츠
    @popular_courses = Course.joins(:enrollments)
                             .group('courses.id')
                             .order('COUNT(enrollments.id) DESC')
                             .limit(10)
                             .select('courses.*, COUNT(enrollments.id) as enrollment_count')
    
    # 최근 활동
    @recent_enrollments = Enrollment.includes(:user, :course).order(created_at: :desc).limit(10)
  end
  
  private
  
  def generate_signup_chart_data
    (0..29).map do |i|
      date = i.days.ago.to_date
      count = User.where(created_at: date.all_day).count
      { date: date.strftime('%m/%d'), count: count }
    end.reverse
  end
  
  def generate_revenue_chart_data
    (0..29).map do |i|
      date = i.days.ago.to_date
      amount = Order.where(created_at: date.all_day).sum(:amount)
      { date: date.strftime('%m/%d'), amount: amount }
    end.reverse
  end
  
  def generate_content_view_chart_data
    (0..29).map do |i|
      date = i.days.ago.to_date
      views = ContentView.where(viewed_at: date.all_day).count
      { date: date.strftime('%m/%d'), views: views }
    end.reverse
  end
end

