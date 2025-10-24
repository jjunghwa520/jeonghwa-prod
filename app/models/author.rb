class Author < ApplicationRecord
  # Associations
  has_many :course_authors, dependent: :destroy
  has_many :courses, through: :course_authors

  # Validations
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[writer illustrator narrator producer] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }
  scope :writers, -> { where(role: 'writer') }
  scope :illustrators, -> { where(role: 'illustrator') }
  scope :narrators, -> { where(role: 'narrator') }

  def display_name
    "#{name} (#{role_name})"
  end

  def role_name
    case role
    when 'writer' then '작가'
    when 'illustrator' then '일러스트레이터'
    when 'narrator' then '성우'
    when 'producer' then '제작자'
    else role
    end
  end
end
