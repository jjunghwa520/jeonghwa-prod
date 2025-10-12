class AddAgeTocourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :age, :string
  end
end
