class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :taught_courses, class_name: "Course", foreign_key: "instructor_id", dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :generated_images, dependent: :destroy

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

  private

  def set_default_role
    self.role ||= "student"
  end

  def downcase_email
    self.email = email&.downcase&.strip if email.present?
  end
end
