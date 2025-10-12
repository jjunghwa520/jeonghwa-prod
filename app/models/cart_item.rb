class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id }
  validates :quantity, numericality: { greater_than: 0 }

  before_create :set_added_at

  def total_price
    course.price * quantity
  end

  private

  def set_added_at
    self.added_at = Time.current
  end
end
