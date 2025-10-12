class ReviewsController < ApplicationController
  before_action :require_login
  before_action :set_course
  before_action :set_review, only: [ :destroy ]
  before_action :check_enrollment, only: [ :create ]

  def create
    @review = @course.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      flash[:notice] = "리뷰가 작성되었습니다."
    else
      flash[:alert] = "리뷰 작성에 실패했습니다."
    end

    redirect_to @course
  end

  def destroy
    if @review.user == current_user || current_user.admin?
      @review.destroy
      flash[:notice] = "리뷰가 삭제되었습니다."
    else
      flash[:alert] = "권한이 없습니다."
    end

    redirect_to @course
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_review
    @review = @course.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :content)
  end

  def check_enrollment
    unless current_user.enrolled_courses.include?(@course)
      flash[:alert] = "수강한 강의만 리뷰를 작성할 수 있습니다."
      redirect_to @course
    end
  end
end
