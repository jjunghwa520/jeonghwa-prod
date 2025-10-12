class CreateGeneratedImages < ActiveRecord::Migration[8.0]
  def change
    create_table :generated_images do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      
      t.string :prompt, null: false
      t.string :image_type, null: false # banner, thumbnail, hero, course_image, profile
      t.string :style, default: 'modern'
      t.string :size, default: '1024x1024'
      t.string :status, default: 'pending' # pending, processing, completed, failed
      
      t.string :image_url
      t.text :error_message
      
      t.datetime :started_at
      t.datetime :completed_at
      t.float :generation_time # 생성 소요 시간 (초)
      
      t.integer :retry_count, default: 0
      t.json :metadata, default: {} # 추가 메타데이터 저장
      
      t.timestamps
    end
    
    add_index :generated_images, :status
    add_index :generated_images, :image_type
    add_index :generated_images, [:user_id, :status]
    add_index :generated_images, [:course_id, :image_type]
  end
end
