class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :role, default: 'student'
      t.text :bio
      t.string :avatar

      t.timestamps
    end
  end
end
