class CommunityController < ApplicationController
  before_action :require_login, except: [:index]
  
  def index
    @recent_reviews = Review.active_only.includes(:user, :course).order(created_at: :desc).limit(20)
    @top_reviewers = User.joins(:reviews)
                         .group('users.id')
                         .select('users.*, COUNT(reviews.id) as review_count')
                         .order('review_count DESC')
                         .limit(10)
  end
  
  def reading_challenges
    # 독서 챌린지 목록
    @active_challenges = ReadingChallenge.active.order(created_at: :desc)
    @my_challenges = current_user&.reading_challenge_participations
  end
  
  def parent_forum
    # 부모 커뮤니티 게시판
    @topics = ForumTopic.includes(:user).order(created_at: :desc).page(params[:page])
  end
end

