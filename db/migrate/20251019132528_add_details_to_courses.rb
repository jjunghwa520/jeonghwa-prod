class AddDetailsToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :subtitle, :string
    add_column :courses, :series_name, :string
    add_column :courses, :series_order, :integer
    add_column :courses, :tags, :string  # 쉼표로 구분된 태그
    add_column :courses, :difficulty, :integer, default: 3  # 1-5
    add_column :courses, :discount_percentage, :integer, default: 0
    add_column :courses, :production_date, :date
    
    add_index :courses, :series_name
    add_index :courses, [:series_name, :series_order]
  end
end
