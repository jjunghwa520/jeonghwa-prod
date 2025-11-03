class CreateInquiries < ActiveRecord::Migration[8.0]
  def change
    create_table :inquiries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.string :status
      t.text :admin_response

      t.timestamps
    end
  end
end
