class CourseAuthor < ApplicationRecord
  belongs_to :course
  belongs_to :author

  validates :role, presence: true, inclusion: { in: %w[writer illustrator narrator] }
  validates :order, presence: true, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:order) }
  scope :by_role, ->(role) { where(role: role) }
end
