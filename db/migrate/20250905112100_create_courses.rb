class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.string :category
      t.string :level
      t.integer :duration
      t.string :thumbnail
      t.string :status, default: 'draft'

      t.timestamps
    end
  end
end
