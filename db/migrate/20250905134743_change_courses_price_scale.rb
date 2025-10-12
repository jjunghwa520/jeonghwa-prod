class ChangeCoursesPriceScale < ActiveRecord::Migration[8.0]
  def change
    change_column :courses, :price, :decimal, precision: 10, scale: 2
  end
end
