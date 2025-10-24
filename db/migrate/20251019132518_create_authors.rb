class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.text :bio
      t.string :profile_image
      t.string :role, null: false  # writer, illustrator, narrator, producer
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :authors, :name
    add_index :authors, :role
  end
end
