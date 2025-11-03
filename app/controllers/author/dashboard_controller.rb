class Author::DashboardController < ApplicationController
  before_action :require_author
  
  def index
    @user = current_user
    @courses = current_user.taught_courses.includes(:enrollments, :reviews)
    
    # 통계 계산
    @total_courses = @courses.count
    @total_students = Enrollment.where(course: @courses).distinct.count(:user_id)
    @total_revenue = calculate_total_revenue
    @monthly_revenue = calculate_monthly_revenue
    
    # 최근 리뷰
    @recent_reviews = Review.where(course: @courses).order(created_at: :desc).limit(5)
    
    # 수익 차트 데이터 (최근 6개월)
    @revenue_chart_data = generate_revenue_chart_data
  end
  
  private
  
  def require_author
    unless current_user&.instructor?
      flash[:error] = '작가 권한이 필요합니다.'
      redirect_to root_path
    end
  end
  
  def calculate_total_revenue
    # 실제 수익 계산 로직 (정산 모델과 연동)
    Order.joins(:course).where(courses: { instructor_id: current_user.id }).sum(:amount) * 0.7  # 70% 수수료
  end
  
  def calculate_monthly_revenue
    # 이번 달 수익
    Order.joins(:course)
         .where(courses: { instructor_id: current_user.id })
         .where('orders.created_at >= ?', Date.today.beginning_of_month)
         .sum(:amount) * 0.7
  end
  
  def generate_revenue_chart_data
    (0..5).map do |i|
      month = i.months.ago.beginning_of_month
      revenue = Order.joins(:course)
                    .where(courses: { instructor_id: current_user.id })
                    .where(created_at: month..month.end_of_month)
                    .sum(:amount) * 0.7
      { month: month.strftime('%Y-%m'), revenue: revenue }
    end.reverse
  end
end

