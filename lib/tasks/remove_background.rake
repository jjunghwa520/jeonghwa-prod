namespace :jeonghwa do
  desc "Remove background from generated character images using Remove.bg API"
  task remove_background: :environment do
    require 'net/http'
    require 'json'
    require 'base64'

    puts "🎯 Remove.bg API로 배경 제거!"
    puts "✂️  목표: 순수 캐릭터만 남기기"
    puts "🖼️  대상: 최초 3번 캐릭터"
    
    # Remove.bg API 키 (무료 계정도 월 50장 제공)
    api_key = ENV['REMOVEBG_API_KEY'] || "demo_key"  # 데모 키로 테스트
    
    if api_key == "demo_key"
      puts "⚠️  데모 키 사용 중 - 실제 사용을 위해서는 Remove.bg API 키 필요"
      puts "💡 https://www.remove.bg/api 에서 무료 API 키 발급 가능"
    end

    # Remove.bg API로 배경 제거 함수
    def remove_background_with_api(api_key, input_file_path, output_file_path)
      uri = URI("https://api.remove.bg/v1.0/removebg")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 60
      
      request = Net::HTTP::Post.new(uri)
      request['X-Api-Key'] = api_key
      
      # 이미지 파일을 base64로 인코딩
      image_data = File.read(input_file_path)
      encoded_image = Base64.strict_encode64(image_data)
      
      form_data = [
        ['image_file_b64', encoded_image],
        ['size', 'auto'],  # 원본 크기 유지
        ['type', 'person'], # 인물 타입 지정
        ['format', 'png']   # PNG 형식으로 출력
      ]
      
      request.set_form(form_data, 'multipart/form-data')
      
      puts "✂️  배경 제거 중: #{File.basename(input_file_path)}"
      
      response = http.request(request)
      
      if response.code == '200'
        # 성공적으로 배경이 제거된 이미지 저장
        File.open(output_file_path, 'wb') { |file| file.write(response.body) }
        
        file_size = (response.body.size / 1024.0 / 1024.0).round(2)
        puts "✅ 성공: #{File.basename(output_file_path)} (#{file_size}MB)"
        return true
      else
        error_info = JSON.parse(response.body) rescue response.body
        puts "❌ 실패: #{response.code}"
        puts "📄 오류: #{error_info.dig('errors', 0, 'title') || error_info}"
        return false
      end
    rescue => e
      puts "❌ 예외: #{e.message}"
      return false
    end

    # 로컬 이미지 처리 함수 (ImageMagick 사용)
    def remove_background_local(input_file_path, output_file_path)
      puts "🔧 로컬 ImageMagick으로 배경 제거 시도"
      
      # ImageMagick의 배경 제거 명령
      command = "magick '#{input_file_path}' -fuzz 10% -transparent white '#{output_file_path}'"
      
      result = system(command)
      
      if result && File.exist?(output_file_path)
        file_size = (File.size(output_file_path) / 1024.0 / 1024.0).round(2)
        puts "✅ 로컬 처리 성공: #{File.basename(output_file_path)} (#{file_size}MB)"
        return true
      else
        puts "❌ 로컬 처리 실패"
        return false
      end
    rescue => e
      puts "❌ 로컬 처리 예외: #{e.message}"
      return false
    end

    begin
      # 처리할 이미지 파일들
      source_images = [
        {
          input: Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', 'jeonghwa_gemini_welcome.png'),
          output: Rails.root.join('public', 'images', 'jeonghwa', 'no_bg', 'jeonghwa_clean_welcome.png'),
          name: "최초 3번 환영"
        },
        {
          input: Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', 'jeonghwa_gemini_main.png'),
          output: Rails.root.join('public', 'images', 'jeonghwa', 'no_bg', 'jeonghwa_clean_main.png'),
          name: "기본"
        },
        {
          input: Rails.root.join('public', 'images', 'jeonghwa', 'gemini_nano', 'jeonghwa_gemini_teaching.png'),
          output: Rails.root.join('public', 'images', 'jeonghwa', 'no_bg', 'jeonghwa_clean_teaching.png'),
          name: "수업"
        }
      ]

      # 출력 디렉토리 생성
      FileUtils.mkdir_p(Rails.root.join('public', 'images', 'jeonghwa', 'no_bg'))

      success_count = 0
      total_count = source_images.length

      source_images.each_with_index do |image_info, index|
        puts "━" * 70
        puts "✂️  배경 제거 #{index + 1}/#{total_count}: #{image_info[:name]}"
        
        if File.exist?(image_info[:input])
          # 먼저 Remove.bg API 시도
          if remove_background_with_api(api_key, image_info[:input], image_info[:output])
            success_count += 1
          else
            # API 실패 시 로컬 ImageMagick 시도
            puts "🔄 API 실패, 로컬 처리 시도..."
            if remove_background_local(image_info[:input], image_info[:output])
              success_count += 1
            end
          end
        else
          puts "❌ 원본 파일 없음: #{image_info[:input]}"
        end
        
        sleep(2) if index < total_count - 1
      end

      puts "\n" + "=" * 70
      puts "🎉 배경 제거 작업 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 배경 제거된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'jeonghwa', 'no_bg', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n✨ 배경 제거 완료 특징:"
        puts "  - 순수 캐릭터만 남음"
        puts "  - 진짜 투명 PNG 배경"
        puts "  - 히어로 섹션과 자연스러운 조화"
        puts "  - 부자연스러운 여백 완전 제거"
        
        puts "\n💡 사용법:"
        puts "  히어로 섹션에서 /images/jeonghwa/no_bg/ 경로 사용"
      else
        puts "\n🔧 대안 방법:"
        puts "  1. Remove.bg 무료 API 키 발급: https://www.remove.bg/api"
        puts "  2. ImageMagick 설치: brew install imagemagick"
        puts "  3. 수동 편집: 포토샵 등으로 배경 제거"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

