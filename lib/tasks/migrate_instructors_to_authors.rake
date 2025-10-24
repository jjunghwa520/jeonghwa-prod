namespace :authors do
  desc "Migrate existing course instructors to Author system"
  task migrate_from_instructors: :environment do
    puts "=" * 80
    puts "🔄 기존 강사(instructor)를 Author 시스템으로 마이그레이션"
    puts "=" * 80
    puts ""
    
    migrated_count = 0
    skipped_count = 0
    error_count = 0
    
    Course.find_each do |course|
      begin
        # 이미 작가가 있으면 스킵
        if course.writer.present?
          puts "  ⏭️  #{course.title} - 이미 작가 있음"
          skipped_count += 1
          next
        end
        
        # instructor가 있으면 Author로 변환
        if course.instructor.present?
          instructor = course.instructor
          
          # Author 찾거나 생성
          author = Author.find_or_create_by(
            name: instructor.name
          ) do |a|
            a.role = 'writer'
            a.bio = instructor.bio || "#{instructor.name} 작가입니다."
            a.active = true
          end
          
          # CourseAuthor 연결
          unless course.course_authors.exists?(author: author, role: 'writer')
            course.course_authors.create!(
              author: author,
              role: 'writer',
              order: 1
            )
            
            puts "  ✅ #{course.title} → #{author.name} (작가) 연결됨"
            migrated_count += 1
          else
            puts "  ⏭️  #{course.title} - 이미 연결됨"
            skipped_count += 1
          end
        else
          puts "  ⚠️  #{course.title} - instructor 없음"
          skipped_count += 1
        end
        
      rescue => e
        puts "  ❌ #{course.title} - 오류: #{e.message}"
        error_count += 1
      end
    end
    
    puts ""
    puts "=" * 80
    puts "📊 마이그레이션 결과"
    puts "=" * 80
    puts "  ✅ 성공: #{migrated_count}개"
    puts "  ⏭️  스킵: #{skipped_count}개"
    puts "  ❌ 오류: #{error_count}개"
    puts "  📚 총 코스: #{Course.count}개"
    puts "  👥 총 작가: #{Author.count}개"
    puts ""
    puts "=" * 80
  end
  
  desc "Verify Author migration"
  task verify_migration: :environment do
    puts "=" * 80
    puts "🔍 Author 마이그레이션 검증"
    puts "=" * 80
    puts ""
    
    total = Course.count
    with_writer = Course.joins(:course_authors).where(course_authors: { role: 'writer' }).distinct.count
    without_writer = total - with_writer
    
    puts "총 코스: #{total}개"
    puts "작가 있음: #{with_writer}개 (#{(with_writer.to_f / total * 100).round(1)}%)"
    puts "작가 없음: #{without_writer}개 (#{(without_writer.to_f / total * 100).round(1)}%)"
    puts ""
    
    if without_writer > 0
      puts "⚠️  작가 없는 코스:"
      Course.left_joins(:course_authors)
            .where(course_authors: { id: nil })
            .limit(10)
            .each do |course|
        puts "  - #{course.id}: #{course.title}"
      end
    else
      puts "✅ 모든 코스에 작가가 연결되어 있습니다!"
    end
    
    puts ""
    puts "=" * 80
  end
end

