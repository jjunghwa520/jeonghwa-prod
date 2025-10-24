module Admin
  class ReviewsController < BaseController
    before_action :set_review, only: [:update, :destroy]

    def index
      @reviews = Review.order(created_at: :desc).includes(:user, :course).limit(200)
      @q = params[:q].to_s.strip
      if @q.present?
        @reviews = @reviews.select { |r| r.user.name.include?(@q) || r.user.email.include?(@q) || r.course.title.include?(@q) }
      end
    end

    def update
      if params[:active].present?
        @review.update(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
      end
      redirect_to admin_reviews_path, notice: '리뷰 상태가 업데이트되었습니다.'
    end

    def destroy
      @review.destroy
      redirect_to admin_reviews_path, notice: '리뷰가 삭제되었습니다.'
    end

    private

    def set_review
      @review = Review.find(params[:id])
    end
  end
end


