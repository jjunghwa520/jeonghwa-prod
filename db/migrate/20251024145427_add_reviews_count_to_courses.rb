class AddReviewsCountToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :reviews_count, :integer, default: 0, null: false
    
    # 기존 데이터의 카운터 초기화
    reversible do |dir|
      dir.up do
        Course.find_each do |course|
          Course.reset_counters(course.id, :reviews)
        end
      end
    end
  end
end
