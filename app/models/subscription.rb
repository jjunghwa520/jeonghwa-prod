class Subscription < ApplicationRecord
  belongs_to :user

  # 플랜 타입
  PLAN_TYPES = {
    basic: { name: '일반 회원', price: 9900, description: '월 10개 콘텐츠 열람 가능' },
    premium: { name: '프리미엄 회원', price: 19900, description: '무제한 콘텐츠 열람 + 신규 콘텐츠 우선 제공' }
  }.freeze

  # 상태
  STATUSES = %w[active cancelled expired paused].freeze

  # Validations
  validates :plan_type, presence: true, inclusion: { in: PLAN_TYPES.keys.map(&:to_s) }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :active, -> { where(status: 'active').where('end_date >= ?', Date.today) }
  scope :expired, -> { where('end_date < ?', Date.today) }
  scope :basic, -> { where(plan_type: 'basic') }
  scope :premium, -> { where(plan_type: 'premium') }
  scope :auto_renewing, -> { where(auto_renew: true) }

  # 현재 유효한 구독인지 확인
  def active?
    status == 'active' && end_date >= Date.today
  end

  # 만료 여부
  def expired?
    end_date < Date.today
  end

  # 프리미엄 플랜 여부
  def premium?
    plan_type == 'premium'
  end

  # 남은 일수
  def days_remaining
    return 0 if expired?
    (end_date - Date.today).to_i
  end

  # 자동 갱신
  def renew!
    return false unless auto_renew? && active?
    
    self.start_date = end_date + 1.day
    self.end_date = start_date + 1.month
    save
  end

  # 취소
  def cancel!
    update(status: 'cancelled', auto_renew: false)
  end

  # 일시 중지
  def pause!
    update(status: 'paused')
  end

  # 재개
  def resume!
    update(status: 'active') if paused?
  end

  def paused?
    status == 'paused'
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, '종료일은 시작일보다 이후여야 합니다')
    end
  end
end
