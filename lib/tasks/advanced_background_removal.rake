namespace :jeonghwa do
  desc "Advanced background removal using multiple ImageMagick techniques"
  task advanced_bg_removal: :environment do
    puts "🔧 고급 ImageMagick 배경 제거 기법!"
    puts "✂️  다양한 방법으로 완전 배경 제거 시도"
    
    # 고급 배경 제거 함수들
    def remove_bg_method_1(input_path, output_path)
      puts "🔄 방법 1: Fuzz + Transparent (기본)"
      command = "magick '#{input_path}' -fuzz 15% -transparent white '#{output_path}'"
      system(command)
    end
    
    def remove_bg_method_2(input_path, output_path)
      puts "🔄 방법 2: Color Replace + Alpha"
      command = "magick '#{input_path}' -fuzz 20% -fill none -opaque white -alpha set '#{output_path}'"
      system(command)
    end
    
    def remove_bg_method_3(input_path, output_path)
      puts "🔄 방법 3: Flood Fill + Transparent"
      command = "magick '#{input_path}' -fuzz 25% -transparent '#ffffff' -transparent '#f0f0f0' -transparent '#e0e0e0' '#{output_path}'"
      system(command)
    end
    
    def remove_bg_method_4(input_path, output_path)
      puts "🔄 방법 4: Edge Detection + Mask"
      temp_mask = output_path.gsub('.png', '_mask.png')
      # 엣지 검출로 마스크 생성
      system("magick '#{input_path}' -edge 2 -negate -threshold 50% '#{temp_mask}'")
      # 마스크 적용
      system("magick '#{input_path}' '#{temp_mask}' -alpha off -compose copy_opacity -composite '#{output_path}'")
      # 임시 마스크 파일 삭제
      File.delete(temp_mask) if File.exist?(temp_mask)
    end
    
    def remove_bg_method_5(input_path, output_path)
      puts "🔄 방법 5: Subject Isolation (AI-like)"
      # 중앙 영역을 보존하고 가장자리를 투명하게
      command = "magick '#{input_path}' \\( +clone -blur 0x15 -threshold 50% \\) -alpha off -compose copy_opacity -composite '#{output_path}'"
      system(command)
    end

    begin
      # 처리할 이미지
      source_file = Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', 'jeonghwa_gemini_welcome.png')
      
      if !File.exist?(source_file)
        puts "❌ 원본 파일이 없습니다: #{source_file}"
        return
      end
      
      output_dir = Rails.root.join('public', 'images', 'jeonghwa', 'clean_bg')
      FileUtils.mkdir_p(output_dir)
      
      methods = [
        { name: "기본 투명화", method: :remove_bg_method_1 },
        { name: "컬러 교체", method: :remove_bg_method_2 },
        { name: "다중 색상 제거", method: :remove_bg_method_3 },
        { name: "엣지 검출 마스킹", method: :remove_bg_method_4 },
        { name: "AI 스타일 분리", method: :remove_bg_method_5 }
      ]
      
      success_count = 0
      
      methods.each_with_index do |method_info, index|
        output_file = File.join(output_dir, "jeonghwa_method_#{index + 1}.png")
        
        puts "━" * 70
        puts "✂️  #{method_info[:name]} (#{index + 1}/5)"
        
        begin
          send(method_info[:method], source_file, output_file)
          
          if File.exist?(output_file) && File.size(output_file) > 0
            file_size = (File.size(output_file) / 1024.0 / 1024.0).round(2)
            puts "✅ 성공: #{File.basename(output_file)} (#{file_size}MB)"
            success_count += 1
          else
            puts "❌ 실패: 파일 생성되지 않음"
          end
        rescue => e
          puts "❌ 예외: #{e.message}"
        end
        
        sleep(1)
      end
      
      puts "\n" + "=" * 70
      puts "🎉 고급 배경 제거 완료!"
      puts "✅ 성공: #{success_count}/5"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(File.join(output_dir, '*')).each_with_index do |file, i|
          puts "  #{i+1}. #{File.basename(file)} - #{methods[i][:name]}"
        end
        
        puts "\n💡 사용법:"
        puts "  각 방법의 결과를 확인하고 가장 좋은 것을 선택하세요"
        puts "  파일 경로: /images/jeonghwa/clean_bg/jeonghwa_method_X.png"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
    end
  end
end

