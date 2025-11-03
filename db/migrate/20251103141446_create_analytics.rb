class CreateAnalytics < ActiveRecord::Migration[8.0]
  def change
    create_table :analytics do |t|
      t.date :date
      t.string :metric_type
      t.decimal :value
      t.integer :user_count
      t.integer :course_count

      t.timestamps
    end
  end
end
