class Course < ApplicationRecord
  # Associations
  belongs_to :instructor, class_name: "User"
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :generated_images, dependent: :nullify
  has_many :course_authors, dependent: :destroy
  has_many :authors, through: :course_authors

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :level, inclusion: { in: %w[beginner intermediate advanced] }
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[draft published archived] }
  validates :age, inclusion: { in: %w[baby toddler elementary teen], allow_blank: true }
  validates :difficulty, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Callbacks
  before_validation :set_default_status, on: :create
  after_save :clear_cache
  after_destroy :clear_cache

  # Scopes
  scope :published, -> { where(status: "published") }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_age, ->(age) { where(age: age) }
  scope :by_series, ->(series) { where(series_name: series).order(:series_order) }
  scope :search, ->(query) {
    q = "%#{query}%"
    if ActiveRecord::Base.connection.adapter_name =~ /sqlite/i
      where("LOWER(title) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)", q, q)
    else
      where("title ILIKE ? OR description ILIKE ?", q, q)
    end
  }

  def average_rating
    # 캐싱으로 성능 향상 (1시간 유지)
    Rails.cache.fetch("course:#{id}:avg_rating", expires_in: 1.hour) do
      reviews.average(:rating)&.round(1) || 0
    end
  end

  def total_students
    # 캐싱으로 성능 향상 (5분 유지)
    Rails.cache.fetch("course:#{id}:total_students", expires_in: 5.minutes) do
      enrollments.count
    end
  end

  def published?
    status == "published"
  end

  def discounted_price
    return price if discount_percentage.to_i.zero?
    price * (1 - discount_percentage.to_f / 100)
  end

  def tag_list
    tags.to_s.split(',').map(&:strip).reject(&:blank?)
  end

  def tag_list=(value)
    self.tags = Array(value).join(',')
  end

  def writer
    course_authors.find_by(role: 'writer')&.author
  end

  def illustrator
    course_authors.find_by(role: 'illustrator')&.author
  end

  def narrator
    course_authors.find_by(role: 'narrator')&.author
  end

  private

  def set_default_status
    self.status ||= "draft"
  end
  
  def clear_cache
    # 평균 평점 캐시 삭제
    Rails.cache.delete("course:#{id}:avg_rating")
    # 수강생 수 캐시 삭제
    Rails.cache.delete("course:#{id}:total_students")
  end
end
