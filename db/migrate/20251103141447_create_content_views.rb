class CreateContentViews < ActiveRecord::Migration[8.0]
  def change
    create_table :content_views do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :viewed_at
      t.integer :duration

      t.timestamps
    end
  end
end
