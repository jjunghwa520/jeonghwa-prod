class Order < ApplicationRecord
  belongs_to :user
  belongs_to :course
  
  validates :order_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending completed failed cancelled refunded] }
  
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :refunded, -> { where(status: 'refunded') }
  scope :recent, -> { order(created_at: :desc) }
  
  def paid?
    status == 'completed'
  end
  
  def refundable?
    status == 'completed' && created_at > 7.days.ago
  end
end

