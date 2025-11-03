class Inquiry < ApplicationRecord
  belongs_to :user
  
  STATUSES = %w[pending answered closed].freeze
  
  validates :title, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: STATUSES }
  
  scope :pending, -> { where(status: 'pending') }
  scope :answered, -> { where(status: 'answered') }
  scope :closed, -> { where(status: 'closed') }
  scope :recent, -> { order(created_at: :desc) }
  
  def answered?
    status == 'answered' && admin_response.present?
  end
end
