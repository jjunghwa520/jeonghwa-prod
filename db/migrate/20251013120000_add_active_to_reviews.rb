class AddActiveToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :active, :boolean, default: true, null: false
    add_index :reviews, :active
  end
end


