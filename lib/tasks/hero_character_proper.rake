namespace :hero do
  desc "Generate hero section characters using proper Vertex AI service"
  task generate_characters_proper: :environment do
    
    # 기존 VertexAiService 사용
    vertex_service = VertexAiService.new
    
    puts "🎨 히어로 캐릭터 생성 시작 (올바른 방식)"
    
    # 히어로 섹션용 캐릭터 및 요소들
    hero_elements = {
      # 메인 캐릭터 - 책을 읽는 아이
      "main_character" => "A cheerful Korean child character in 3D cartoon style, sitting cross-legged and reading a magical glowing storybook, wearing casual colorful clothes, friendly smile, soft lighting, Pixar animation style, warm and inviting atmosphere",
      
      # 플로팅 책들
      "floating_book_1" => "A magical floating storybook with golden pages and sparkles, 3D rendered, fairy tale style, soft pastel colors, dreamy atmosphere",
      
      "floating_book_2" => "An open children's book with colorful illustrations floating in the air, 3D cartoon style, rainbow colors, magical sparkles around it",
      
      "floating_book_3" => "A stack of colorful children's books floating with magical particles, 3D rendered, warm lighting, storybook aesthetic",
      
      # 동화 요소들
      "fairy_tale_elements" => "Floating fairy tale elements like stars, hearts, musical notes, and magic sparkles in 3D cartoon style, pastel colors, dreamy atmosphere",
      
      # 배경 캐릭터들
      "background_character_1" => "A cute 3D cartoon child character waving hello, Korean features, colorful casual clothes, friendly expression, Pixar style",
      
      "background_character_2" => "A happy 3D cartoon child character holding a storybook, diverse features, bright colors, joyful expression, animation style",
      
      # 마법의 요소들
      "magic_elements" => "Magical floating elements for children's storybook theme: glowing stars, colorful butterflies, floating letters, rainbow trails, 3D cartoon style"
    }

    success_count = 0
    total_count = hero_elements.length
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'hero_characters_proper')
    FileUtils.mkdir_p(output_dir)

    hero_elements.each do |filename, prompt|
      puts "\n🎨 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt}"
      
      begin
        # VertexAiService를 사용해서 이미지 생성
        image_path = vertex_service.generate_image(prompt, style: 'creative')
        
        if image_path
          # 생성된 이미지를 hero_characters_proper 폴더로 복사
          source_path = Rails.root.join('public', image_path.gsub('/', ''))
          target_path = File.join(output_dir, "#{filename}.jpg")
          
          if File.exist?(source_path)
            FileUtils.cp(source_path, target_path)
            puts "✅ 성공: #{filename}.jpg"
            success_count += 1
          else
            puts "❌ 실패: #{filename} - 소스 파일 없음"
          end
        else
          puts "❌ 실패: #{filename} - 이미지 생성 실패"
        end
        
        # API 호출 간격 조정
        sleep(2)
        
      rescue => e
        puts "❌ 오류: #{filename} - #{e.message}"
      end
    end

    puts "\n🎉 히어로 캐릭터 생성 완료!"
    puts "✅ 성공: #{success_count}/#{total_count}"
    puts "❌ 실패: #{total_count - success_count}/#{total_count}"
    
    if success_count > 0
      puts "\n📁 생성된 파일 위치: #{output_dir}"
      puts "🔗 사용 방법: asset_path('generated/hero_characters_proper/파일명.jpg')"
    end
  end
end

