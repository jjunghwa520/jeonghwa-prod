class CreateContentPipeline < ActiveRecord::Migration[8.0]
  def change
    create_table :content_pipelines do |t|
      t.timestamps
    end
  end
end
