class CreateSettlements < ActiveRecord::Migration[8.0]
  def change
    create_table :settlements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.decimal :amount
      t.date :period_start
      t.date :period_end
      t.string :status
      t.date :payment_date

      t.timestamps
    end
  end
end
