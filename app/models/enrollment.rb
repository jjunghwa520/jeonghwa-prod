class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id }
  validates :progress, inclusion: { in: 0..100 }

  before_create :set_enrolled_at
  
  # Callbacks: 수강 등록 변경 시 코스의 수강생 수 캐시 무효화
  after_save :clear_course_cache
  after_destroy :clear_course_cache

  scope :completed, -> { where(completed: true) }
  scope :in_progress, -> { where(completed: false) }

  private

  def set_enrolled_at
    self.enrolled_at = Time.current
  end
  
  def clear_course_cache
    Rails.cache.delete("course:#{course_id}:total_students")
  end
end
