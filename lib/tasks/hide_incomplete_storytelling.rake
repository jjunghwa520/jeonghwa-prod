namespace :content do
  desc "구연동화 비디오 없는 코스 숨기기"
  task hide_incomplete_storytelling: :environment do
    puts "=== 구연동화 비디오 없는 코스 숨기기 ==="
    
    storytelling_courses = Course.where(category: '구연동화')
    hidden_count = 0
    kept_count = 0
    
    storytelling_courses.each do |course|
      video_dir = Rails.root.join('public', 'videos', course.id.to_s)
      has_video = File.exist?(video_dir.join('main.mp4')) || 
                  File.exist?(video_dir.join('main.webm')) ||
                  Dir.glob(video_dir.join('*.mp4')).any? ||
                  Dir.glob(video_dir.join('*.webm')).any?
      
      if has_video
        puts "✅ Course #{course.id}: #{course.title} - 비디오 있음, 유지"
        kept_count += 1
      else
        puts "❌ Course #{course.id}: #{course.title} - 비디오 없음, 숨김 처리"
        course.update(status: 'archived')
        hidden_count += 1
      end
    end
    
    puts ""
    puts "=== 작업 완료 ==="
    puts "유지: #{kept_count}개"
    puts "숨김: #{hidden_count}개"
    puts "총합: #{storytelling_courses.count}개"
  end
  
  desc "숨긴 구연동화 코스 복구"
  task restore_storytelling: :environment do
    puts "=== 구연동화 코스 복구 ==="
    
    hidden_courses = Course.where(category: '구연동화', status: 'archived')
    hidden_courses.update_all(status: 'published')
    
    puts "복구된 코스: #{hidden_courses.count}개"
  end
end

