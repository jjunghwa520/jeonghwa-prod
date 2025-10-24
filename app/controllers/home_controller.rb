class HomeController < ApplicationController
  layout 'storybook', only: [:storybook_index]
  def index
    @home_courses = Course.published.includes(:instructor)
    @featured_courses = @home_courses.limit(6)
    @categories = Course.published.distinct.pluck(:category).compact
    @popular_courses = Course.published
                            .joins(:enrollments)
                            .group("courses.id")
                            .order("COUNT(enrollments.id) DESC")
                            .limit(4)
  end
  
  def storybook_index
    @featured_courses = Course.published.limit(4)
    @categories = Course.published.distinct.pluck(:category).compact
    @popular_courses = Course.published
                            .joins(:enrollments)
                            .group("courses.id")
                            .order("COUNT(enrollments.id) DESC")
                            .limit(4)
  end
  
  def teen_content
    # 관리자가 아니면 준비중 페이지 표시
    unless logged_in? && current_user.admin?
      render 'coming_soon', layout: 'application'
      return
    end
    
    @teen_content_courses = Course.published.where(category: '청소년콘텐츠').limit(8)
    @teen_education_courses = Course.published.where(category: '청소년교육').limit(8)
    @featured_teen_courses = Course.published.where(age: 'teen').limit(6)
  end

  def hero_preview
    @design = (params[:design].presence || 'a').to_s.downcase
    @variant = (params[:variant].presence || 'base').to_s.downcase
    @style = (params[:style].presence || 'clean').to_s.downcase
  end
end
