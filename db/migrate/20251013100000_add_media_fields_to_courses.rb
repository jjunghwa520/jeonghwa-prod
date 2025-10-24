class AddMediaFieldsToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :video_url, :string
    add_column :courses, :ebook_pages_root, :string
  end
end



