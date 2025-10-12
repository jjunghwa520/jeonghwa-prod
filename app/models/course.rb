class Course < ApplicationRecord
  # Associations
  belongs_to :instructor, class_name: "User"
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :generated_images, dependent: :nullify

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :level, inclusion: { in: %w[beginner intermediate advanced] }
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[draft published archived] }
  validates :age, inclusion: { in: %w[baby toddler elementary teen], allow_blank: true }

  # Callbacks
  before_validation :set_default_status, on: :create

  # Scopes
  scope :published, -> { where(status: "published") }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_age, ->(age) { where(age: age) }
  scope :search, ->(query) {
    q = "%#{query}%"
    if ActiveRecord::Base.connection.adapter_name =~ /sqlite/i
      where("LOWER(title) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)", q, q)
    else
      where("title ILIKE ? OR description ILIKE ?", q, q)
    end
  }

  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  def total_students
    enrollments.count
  end

  def published?
    status == "published"
  end

  private

  def set_default_status
    self.status ||= "draft"
  end
end
