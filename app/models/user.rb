class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :taught_courses, class_name: "Course", foreign_key: "instructor_id", dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :generated_images, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :current_subscription, -> { active.order(end_date: :desc) }, class_name: 'Subscription'

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[student instructor admin] }

  # Callbacks
  before_validation :set_default_role, on: :create
  before_validation :downcase_email

  # Scopes
  scope :students, -> { where(role: "student") }
  scope :instructors, -> { where(role: "instructor") }

  def instructor?
    role == "instructor"
  end

  def student?
    role == "student"
  end

  def admin?
    role == "admin"
  end

  # 구독 관련 메서드
  def subscribed?
    current_subscription&.active? || false
  end

  def premium_subscriber?
    current_subscription&.active? && current_subscription&.premium?
  end

  def basic_subscriber?
    current_subscription&.active? && current_subscription&.plan_type == 'basic'
  end

  def subscription_status
    return 'none' unless current_subscription
    return 'expired' if current_subscription.expired?
    current_subscription.status
  end

  private

  def set_default_role
    self.role ||= "student"
  end

  def downcase_email
    self.email = email&.downcase&.strip if email.present?
  end
end
