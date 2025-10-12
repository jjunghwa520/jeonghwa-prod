class HomeController < ApplicationController
  layout 'storybook', only: [:storybook_index]
  def index
    @featured_courses = Course.published.limit(6)
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
    @teen_content_courses = Course.published.where(category: '청소년콘텐츠').limit(8)
    @teen_education_courses = Course.published.where(category: '청소년교육').limit(8)
    @featured_teen_courses = Course.published.where(age: 'teen').limit(6)
  end
end
