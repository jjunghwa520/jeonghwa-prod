class ContentView < ApplicationRecord
  belongs_to :user
  belongs_to :course
  
  validates :viewed_at, presence: true
  validates :duration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  scope :recent, -> { order(viewed_at: :desc) }
  scope :this_month, -> { where('viewed_at >= ?', Date.today.beginning_of_month) }
  
  # 통계 메서드
  def self.total_views_for_course(course)
    where(course: course).count
  end
  
  def self.total_duration_for_course(course)
    where(course: course).sum(:duration)
  end
  
  def self.unique_viewers_for_course(course)
    where(course: course).distinct.count(:user_id)
  end
end
