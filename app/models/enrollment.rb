class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id }
  validates :progress, inclusion: { in: 0..100 }

  before_create :set_enrolled_at

  scope :completed, -> { where(completed: true) }
  scope :in_progress, -> { where(completed: false) }

  private

  def set_enrolled_at
    self.enrolled_at = Time.current
  end
end
