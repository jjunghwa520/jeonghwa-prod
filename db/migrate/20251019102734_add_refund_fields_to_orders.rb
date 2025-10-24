class AddRefundFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :refunded_at, :datetime
    add_column :orders, :refund_reason, :text
  end
end
