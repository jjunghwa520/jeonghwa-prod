class CreateCourseAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :course_authors do |t|
      t.references :course, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.string :role, null: false  # writer, illustrator, narrator
      t.integer :order, default: 1

      t.timestamps
    end
    
    add_index :course_authors, [:course_id, :author_id, :role], unique: true, name: 'index_course_authors_unique'
  end
end
