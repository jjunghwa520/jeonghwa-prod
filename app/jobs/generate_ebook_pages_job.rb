class GenerateEbookPagesJob < ApplicationJob
  queue_as :default
  
  def perform(course_id, page_count = 15)
    # Rake 태스크 호출
    system("cd #{Rails.root} && bin/rake content:generate_ebook_pages[#{course_id},#{page_count}]")
  end
end

