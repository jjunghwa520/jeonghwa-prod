class Event < ApplicationRecord
  STATUSES = %w[upcoming active ended].freeze
  EVENT_TYPES = %w[sale promotion special limited].freeze
  
  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :discount_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  
  scope :active, -> { where(status: 'active').where('start_date <= ? AND end_date >= ?', Time.current, Time.current) }
  scope :upcoming, -> { where(status: 'upcoming').where('start_date > ?', Time.current) }
  scope :ended, -> { where(status: 'ended').or(where('end_date < ?', Time.current)) }
  
  def active?
    status == 'active' && start_date <= Time.current && end_date >= Time.current
  end
end
