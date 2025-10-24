class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :order_id
      t.decimal :amount
      t.string :status
      t.string :payment_key
      t.datetime :approved_at
      t.text :error_message

      t.timestamps
    end
  end
end
