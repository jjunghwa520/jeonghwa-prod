class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan_type, null: false, default: 'basic'  # 'basic', 'premium'
      t.string :status, null: false, default: 'active'  # 'active', 'cancelled', 'expired', 'paused'
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :auto_renew, default: true
      t.string :payment_key  # 토스페이먼츠 자동결제 키
      t.string :billing_key  # 토스페이먼츠 빌링키

      t.timestamps
    end
    
    add_index :subscriptions, [:user_id, :status]
    add_index :subscriptions, :plan_type
  end
end
