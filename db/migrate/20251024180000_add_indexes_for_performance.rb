class AddIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    add_index :courses, [:status, :category]
    add_index :courses, [:status, :age]
    add_index :reviews, [:course_id, :created_at]
    add_index :orders, [:user_id, :status]
    add_index :orders, :order_id, unique: true
  end
end


