class Review < ApplicationRecord
  belongs_to :user
  belongs_to :course, counter_cache: true

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :course_id }

  # Callbacks: 리뷰 변경 시 코스의 평점 캐시 무효화
  after_save :clear_course_cache
  after_destroy :clear_course_cache

  scope :recent, -> { order(created_at: :desc) }
  scope :active_only, -> { where(active: true) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  
  private
  
  def clear_course_cache
    Rails.cache.delete("course:#{course_id}:avg_rating")
  end
end
