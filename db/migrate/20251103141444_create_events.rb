class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :discount_rate
      t.string :status
      t.string :event_type
      t.string :banner_image

      t.timestamps
    end
  end
end
