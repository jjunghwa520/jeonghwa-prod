namespace :jeonghwa do
  desc "Complete background removal for all characters (Jeonghwa, Bear, Rabbit)"
  task complete_bg_removal: :environment do
    puts "🎯 모든 캐릭터 배경 완전 제거!"
    puts "👥 대상: 정화, 곰, 토끼 - 순수 캐릭터만"
    puts "🔧 다양한 ImageMagick 기법 종합 적용"
    
    # 고급 배경 제거 함수 (여러 기법 조합)
    def ultimate_background_removal(input_path, output_path, character_name)
      puts "\n🎨 #{character_name} 배경 완전 제거 시작"
      
      temp_files = []
      
      begin
        # 1단계: 기본 투명화 (흰색 배경 제거)
        temp1 = output_path.to_s.gsub('.png', '_temp1.png')
        system("magick '#{input_path}' -fuzz 20% -transparent white -transparent '#f0f0f0' -transparent '#e0e0e0' -transparent '#d0d0d0' '#{temp1}'")
        temp_files << temp1
        
        # 2단계: 회색 톤 제거
        temp2 = output_path.to_s.gsub('.png', '_temp2.png')
        system("magick '#{temp1}' -fuzz 25% -transparent '#c0c0c0' -transparent '#b0b0b0' -transparent '#a0a0a0' -transparent '#808080' '#{temp2}'")
        temp_files << temp2
        
        # 3단계: 가장자리 부드럽게 처리
        temp3 = output_path.to_s.gsub('.png', '_temp3.png')
        system("magick '#{temp2}' -alpha set -channel A -blur 0x1 +channel '#{temp3}'")
        temp_files << temp3
        
        # 4단계: 최종 알파 채널 최적화
        system("magick '#{temp3}' -alpha set -background none -compose copy -flatten '#{output_path}'")
        
        # 임시 파일들 정리
        temp_files.each { |f| File.delete(f) if File.exist?(f) }
        
        if File.exist?(output_path) && File.size(output_path) > 0
          file_size = (File.size(output_path) / 1024.0 / 1024.0).round(2)
          puts "✅ #{character_name} 완료: #{File.basename(output_path)} (#{file_size}MB)"
          return true
        else
          puts "❌ #{character_name} 실패: 파일 생성되지 않음"
          return false
        end
        
      rescue => e
        puts "❌ #{character_name} 예외: #{e.message}"
        # 임시 파일들 정리
        temp_files.each { |f| File.delete(f) if File.exist?(f) }
        return false
      end
    end

    # 극강 배경 제거 함수 (AI 스타일 세그멘테이션)
    def ai_style_segmentation(input_path, output_path, character_name)
      puts "\n🤖 #{character_name} AI 스타일 세그멘테이션"
      
      begin
        # 1단계: 엣지 검출로 주체 찾기
        edge_file = output_path.to_s.gsub('.png', '_edge.png')
        system("magick '#{input_path}' -edge 3 -negate -threshold 70% '#{edge_file}'")
        
        # 2단계: 모폴로지 연산으로 마스크 개선
        mask_file = output_path.to_s.gsub('.png', '_mask.png')
        system("magick '#{edge_file}' -morphology close disk:2 -fill white -opaque black '#{mask_file}'")
        
        # 3단계: 마스크 적용하여 배경 제거
        system("magick '#{input_path}' '#{mask_file}' -alpha off -compose copy_opacity -composite '#{output_path}'")
        
        # 4단계: 추가 정리
        system("magick '#{output_path}' -fuzz 15% -transparent white -alpha set '#{output_path}'")
        
        # 임시 파일들 정리
        [edge_file, mask_file].each { |f| File.delete(f) if File.exist?(f) }
        
        if File.exist?(output_path) && File.size(output_path) > 0
          file_size = (File.size(output_path) / 1024.0 / 1024.0).round(2)
          puts "✅ #{character_name} AI 세그멘테이션 완료: #{file_size}MB"
          return true
        else
          puts "❌ #{character_name} AI 세그멘테이션 실패"
          return false
        end
        
      rescue => e
        puts "❌ #{character_name} AI 세그멘테이션 예외: #{e.message}"
        return false
      end
    end

    begin
      # 처리할 모든 캐릭터들
      characters = [
        {
          name: "정화 (환영)",
          input: Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', 'jeonghwa_gemini_welcome.png'),
          output: Rails.root.join('public', 'images', 'characters', 'jeonghwa_pure.png')
        },
        {
          name: "정화 (기본)",
          input: Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', 'jeonghwa_gemini_main.png'),
          output: Rails.root.join('public', 'images', 'characters', 'jeonghwa_main_pure.png')
        },
        {
          name: "곰 학생",
          input: Rails.root.join('public', 'images', 'jeonghwa', 'safe', 'friendly_bear_educator.png'),
          output: Rails.root.join('public', 'images', 'characters', 'bear_pure.png')
        },
        {
          name: "토끼 학생",
          input: Rails.root.join('public', 'images', 'jeonghwa', 'safe', 'caring_rabbit_storyteller.png'),
          output: Rails.root.join('public', 'images', 'characters', 'rabbit_pure.png')
        }
      ]

      # 출력 디렉토리 생성
      FileUtils.mkdir_p(Rails.root.join('public', 'images', 'characters'))

      success_count = 0
      total_count = characters.length

      characters.each_with_index do |char, index|
        puts "━" * 70
        puts "🎨 캐릭터 처리 #{index + 1}/#{total_count}: #{char[:name]}"
        
        if File.exist?(char[:input])
          # 먼저 종합 기법 시도
          if ultimate_background_removal(char[:input], char[:output], char[:name])
            success_count += 1
          else
            # 실패 시 AI 스타일 세그멘테이션 시도
            puts "🔄 AI 세그멘테이션으로 재시도..."
            if ai_style_segmentation(char[:input], char[:output], char[:name])
              success_count += 1
            end
          end
        else
          puts "❌ #{char[:name]} 원본 파일 없음: #{char[:input]}"
        end
        
        sleep(1)
      end

      puts "\n" + "=" * 80
      puts "🎉 모든 캐릭터 배경 제거 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 순수 캐릭터 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'characters', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🎯 적용된 고급 기법들:"
        puts "  1. 다단계 투명화 (흰색→회색→가장자리)"
        puts "  2. 알파 채널 블러 처리"
        puts "  3. 배경 플래튼 최적화"
        puts "  4. AI 스타일 엣지 검출"
        puts "  5. 모폴로지 마스크 개선"
        
        puts "\n💡 사용법:"
        puts "  /images/characters/ 경로의 순수 캐릭터들 사용"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end
