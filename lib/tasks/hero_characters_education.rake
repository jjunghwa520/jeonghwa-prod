namespace :hero do
  desc "Generate educational character illustrations using strategic prompting"
  task generate_educational_characters: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'googleauth'

    # Google Cloud 설정
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || "gen-lang-client-0492798913"
    location = ENV['GOOGLE_CLOUD_LOCATION'] || "us-central1"
    
    puts "🎨 교육용 캐릭터 일러스트 생성 시작!"
    puts "📚 전략적 프롬프팅 기법 적용"
    puts "🔧 프로젝트 ID: #{project_id}"
    puts "🌍 위치: #{location}"
    
    # 서비스 계정 키 파일 경로
    key_file_path = Rails.root.join('config', 'google_service_account.json')

    # 액세스 토큰 생성 함수
    def get_access_token(key_file_path)
      scope = ['https://www.googleapis.com/auth/cloud-platform']
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file_path),
        scope: scope
      )
      token = authorizer.fetch_access_token!
      token['access_token']
    end

    # 교육용 이미지 생성 함수
    def generate_educational_image(access_token, project_id, location, prompt, filename)
      model_name = "imagegeneration@006"
      endpoint = "projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_name}:predict"
      
      uri = URI("https://#{location}-aiplatform.googleapis.com/v1/#{endpoint}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      
      payload = {
        instances: [{ prompt: prompt }],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
          safetyFilterLevel: "block_some",
          personGeneration: "allow_adult",
          includeRaiReason: false
        }
      }
      
      request.body = payload.to_json
      
      puts "\n🎨 생성 중: #{filename}"
      puts "📝 프롬프트: #{prompt[0..100]}..."
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['predictions'] && result['predictions'][0] && result['predictions'][0]['bytesBase64Encoded']
          image_data = Base64.decode64(result['predictions'][0]['bytesBase64Encoded'])
          
          output_dir = Rails.root.join('public', 'images', 'generated', 'hero_educational')
          FileUtils.mkdir_p(output_dir)
          
          file_path = File.join(output_dir, "#{filename}.jpg")
          File.open(file_path, 'wb') { |file| file.write(image_data) }
          
          puts "✅ 성공: #{filename}.jpg (#{(image_data.size / 1024.0 / 1024.0).round(2)}MB)"
          return true
        else
          puts "❌ 실패: #{filename} - 이미지 데이터 없음"
          return false
        end
      else
        error_body = JSON.parse(response.body) rescue response.body
        puts "❌ 실패: #{filename} - HTTP #{response.code}"
        puts "📄 오류: #{error_body.dig('error', 'message') || error_body}"
        return false
      end
    rescue => e
      puts "❌ 예외: #{filename} - #{e.message}"
      return false
    end

    begin
      access_token = get_access_token(key_file_path)
      puts "🔑 액세스 토큰 획득 완료\n"
      
      # 전략적 프롬프팅 기법을 적용한 교육용 캐릭터 프롬프트
      educational_characters = {
        "main_reading_student" => "Educational illustration of a friendly student character sitting cross-legged in a bright classroom environment, enthusiastically reading a colorful storybook with magical glowing pages, cartoon mascot style for children's learning materials, Pixar-quality 3D rendering with soft pastel colors, pedagogical content design, school poster artwork",
        
        "study_buddy_waving" => "Classroom mascot character design showing an encouraging study buddy waving hello with a warm smile, holding educational materials and school supplies, children's textbook illustration style, cartoon rendering for learning app avatar, academic theme with bright and cheerful atmosphere, educational poster quality",
        
        "learning_companion" => "Educational cartoon illustration of a helpful learning companion character holding a stack of colorful storybooks in a library setting, mascot design for pedagogical materials, friendly student helper with encouraging expression, children's book illustration style, academic environment with warm lighting",
        
        "reading_mascot" => "School mascot character illustration showing a young learner deeply engaged with a magical floating book in a cozy reading corner, educational materials design style, cartoon artwork for classroom poster, learning-focused theme with sparkles and stars around the book, textbook character quality",
        
        "study_group_leader" => "Educational illustration of an inspiring student character leading a study session, surrounded by floating books and learning materials, cartoon style for children's educational app, classroom mascot design with academic props, pedagogical artwork with bright and motivating atmosphere",
        
        "library_helper" => "Children's textbook illustration featuring a friendly library helper mascot organizing colorful storybooks on floating shelves, educational character design for learning materials, cartoon style with academic setting, school poster artwork quality with warm and inviting colors",
        
        "knowledge_explorer" => "Educational mascot character exploring a magical world of knowledge with floating books creating a rainbow path, illustration for children's learning materials, cartoon style study buddy design, pedagogical content with inspiring academic theme, textbook quality artwork",
        
        "story_narrator" => "Classroom poster illustration of an animated story narrator character sitting on a stack of giant books, educational mascot design for reading programs, cartoon style with theatrical gestures and expressive features, children's book illustration quality, academic storytelling theme"
      }

      success_count = 0
      total_count = educational_characters.length

      educational_characters.each_with_index do |(filename, prompt), index|
        puts "━" * 50
        puts "📚 생성 #{index + 1}/#{total_count}"
        
        if generate_educational_image(access_token, project_id, location, prompt, filename)
          success_count += 1
        end
        
        # API 호출 간격 (할당량 고려)
        sleep(5) if index < total_count - 1
      end

      puts "\n" + "=" * 50
      puts "🎉 교육용 캐릭터 생성 완료!"
      puts "✅ 성공: #{success_count}/#{total_count}"
      puts "❌ 실패: #{total_count - success_count}/#{total_count}"
      
      if success_count > 0
        puts "\n📁 생성된 파일들:"
        Dir.glob(Rails.root.join('public', 'images', 'generated', 'hero_educational', '*')).each do |file|
          puts "  - #{File.basename(file)}"
        end
        
        puts "\n🔗 사용법:"
        puts "  <img src=\"/images/generated/hero_educational/파일명.jpg\">"
        puts "\n💡 팁: 브라우저 캐시 문제시 ?v=<%= Time.current.to_i %> 추가"
      end

    rescue => e
      puts "❌ 전체 작업 실패: #{e.message}"
      puts "📍 위치: #{e.backtrace.first}"
    end
  end
end

