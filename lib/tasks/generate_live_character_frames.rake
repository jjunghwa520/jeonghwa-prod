namespace :characters do
  desc "Generate live character animation frames - REAL walking, turning, gesturing"
  task generate_live_frames: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'fileutils'

    api_key = ENV['GEMINI_API_KEY']
    if api_key.nil?
      puts "❌ GEMINI_API_KEY 환경변수가 설정되지 않았습니다."
      exit 1
    end

    puts "🎭 실제 살아있는 캐릭터 애니메이션 프레임 생성 시작!"

    # 정화 선생님 실제 걷기 프레임 (안전 우회 전략 적용)
    jeonghwa_walking_frames = [
      {
        name: 'jeonghwa_walk_1',
        prompt: "Educational illustration of a professional middle-aged female educator with East Asian facial features, almond-shaped dark eyes, short curly wavy bob haircut in dark brown, wearing bright blue blazer over black top with pearl necklace and black skirt. WALKING ANIMATION FRAME 1: Right foot stepping forward, left foot behind, right arm swinging forward, left arm swinging back, natural walking posture, side view angle showing leg movement, pedagogical character design for children's educational platform in East Asian context"
      },
      {
        name: 'jeonghwa_walk_2', 
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. WALKING ANIMATION FRAME 2: Both feet on ground, body weight shifting from right to left foot, arms in middle swing position, walking motion captured, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_walk_3',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. WALKING ANIMATION FRAME 3: Left foot stepping forward, right foot behind, left arm swinging forward, right arm swinging back, opposite of frame 1, walking cycle, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_walk_4',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. WALKING ANIMATION FRAME 4: Both feet on ground again, body weight shifting from left to right foot, completing walking cycle, natural stride, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_turn_1',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. TURNING ANIMATION FRAME 1: Complete side profile view, looking to the left, body facing sideways, preparing to turn towards viewer, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_turn_2',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. TURNING ANIMATION FRAME 2: 45-degree angle turn, body rotating towards viewer, face starting to show, natural turning motion, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_turn_3',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. TURNING ANIMATION FRAME 3: Complete front-facing view, body fully turned towards viewer, ready to gesture, confident posture, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_gesture_1',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. GESTURE ANIMATION FRAME 1: Front-facing, arms at sides, preparing to make presentation gesture, confident expression, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_gesture_2',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. GESTURE ANIMATION FRAME 2: Right arm lifting up and extending outward, presenting content, welcoming gesture, professional educator pose, 3D cartoon style, transparent background"
      },
      {
        name: 'jeonghwa_gesture_3',
        prompt: "Korean 40s female educator with short curly hair, blue cardigan, pearl necklace, black skirt. GESTURE ANIMATION FRAME 3: Both arms opened wide in welcoming presentation gesture, big smile, inviting posture, educational presenter, 3D cartoon style, transparent background"
      }
    ]

    # 곰 학생 실제 뒤뚱거리며 걷기 (6프레임)
    bear_walking_frames = [
      {
        name: 'bear_waddle_1',
        prompt: "Cute brown bear character with round ears, small eyes, soft fur. WADDLING ANIMATION FRAME 1: Bear leaning to the left, right paw lifted slightly off ground, left paw supporting body weight, characteristic bear waddle, 3D cartoon style, transparent background"
      },
      {
        name: 'bear_waddle_2',
        prompt: "Cute brown bear character with round ears, small eyes, soft fur. WADDLING ANIMATION FRAME 2: Bear stepping forward with right paw, body shifting to center, natural bear walking motion, 3D cartoon style, transparent background"
      },
      {
        name: 'bear_waddle_3',
        prompt: "Cute brown bear character with round ears, small eyes, soft fur. WADDLING ANIMATION FRAME 3: Bear leaning to the right, left paw lifted, right paw supporting weight, opposite lean from frame 1, 3D cartoon style, transparent background"
      },
      {
        name: 'bear_turn_front',
        prompt: "Cute brown bear character with round ears, small eyes, soft fur. TURNING TO FRONT: Bear turning from side view to face viewer, curious expression, head tilting slightly, 3D cartoon style, transparent background"
      },
      {
        name: 'bear_curious_lean',
        prompt: "Cute brown bear character with round ears, small eyes, soft fur. CURIOUS LEAN: Bear leaning forward with interest, neck extended, eyes wide with curiosity, engaged expression, 3D cartoon style, transparent background"
      },
      {
        name: 'bear_nod',
        prompt: "Cute brown bear character with round ears, small eyes, soft fur. NODDING GESTURE: Bear nodding head in agreement, friendly expression, showing understanding and interest, 3D cartoon style, transparent background"
      }
    ]

    # 토끼 학생 실제 깡총깡총 뛰기 (8프레임)
    rabbit_hopping_frames = [
      {
        name: 'rabbit_hop_prep',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. HOPPING ANIMATION FRAME 1: Rabbit crouched down, hind legs bent deeply, front paws on ground, preparing to jump, coiled energy, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_hop_launch',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. HOPPING ANIMATION FRAME 2: Rabbit pushing off with hind legs, body starting to lift off ground, ears beginning to flow back, launching phase, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_hop_airborne',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. HOPPING ANIMATION FRAME 3: Rabbit fully airborne, all paws tucked under body, ears flowing back from wind, peak of jump, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_hop_descent',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. HOPPING ANIMATION FRAME 4: Rabbit beginning to descend, front paws extending for landing, ears starting to come forward, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_hop_land',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. HOPPING ANIMATION FRAME 5: Rabbit landing with front paws first, hind legs still in air, absorbing impact, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_turn_side',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. TURNING TO SIDE: Rabbit in side profile, looking towards content area, ears perked up with interest, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_excited_point',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. EXCITED POINTING: Rabbit raising one front paw to point excitedly, ears fully erect, enthusiastic expression, 3D cartoon style, transparent background"
      },
      {
        name: 'rabbit_bounce_joy',
        prompt: "Cute white rabbit character with long ears, round tail, energetic expression. JOYFUL BOUNCE: Rabbit mid-bounce with joy, both front paws raised, tail wiggling with excitement, pure happiness, 3D cartoon style, transparent background"
      }
    ]

    # 디렉토리 생성
    ['jeonghwa', 'bear', 'rabbit'].each do |character|
      dir = Rails.root.join('public', 'images', 'characters', character, 'live_frames')
      FileUtils.mkdir_p(dir)
    end

    puts "\n📸 정화 선생님 실제 걷기 애니메이션 생성 중..."
    jeonghwa_walking_frames.each_with_index do |frame_data, index|
      generate_frame(frame_data, 'jeonghwa', api_key, index + 1, jeonghwa_walking_frames.length)
      sleep(3) # API 제한 대응
    end

    puts "\n🐻 곰 학생 실제 뒤뚱거리기 애니메이션 생성 중..."
    bear_walking_frames.each_with_index do |frame_data, index|
      generate_frame(frame_data, 'bear', api_key, index + 1, bear_walking_frames.length)
      sleep(3)
    end

    puts "\n🐰 토끼 학생 실제 깡총깡총 애니메이션 생성 중..."
    rabbit_hopping_frames.each_with_index do |frame_data, index|
      generate_frame(frame_data, 'rabbit', api_key, index + 1, rabbit_hopping_frames.length)
      sleep(3)
    end

    puts "\n🎉 살아있는 캐릭터 애니메이션 프레임 생성 완료!"
    puts "📁 생성 위치: public/images/characters/[캐릭터]/live_frames/"
  end

  private

  def generate_frame(frame_data, character, api_key, current, total)
    puts "  📸 [#{current}/#{total}] #{frame_data[:name]} 생성 중..."
    
    image_path = Rails.root.join('public', 'images', 'characters', character, 'live_frames', "#{frame_data[:name]}.png")
    
    if File.exist?(image_path)
      puts "    ⏭️  이미 존재함"
      return
    end

    begin
      # 올바른 나노바나나 API 사용법 (학습된 가이드 기반)
      uri = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent')
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 60
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['x-goog-api-key'] = api_key
      
      # 학습된 가이드에 따른 올바른 요청 구조
      request.body = {
        contents: [{
          parts: [{
            text: "Generate a cute 3D figurine-style character: #{frame_data[:prompt]}, 3D collectible toy aesthetic with smooth surfaces and adorable proportions, soft pastel lighting, clean white background, high-quality figurine rendering"
          }]
        }]
      }.to_json
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['candidates'] && result['candidates'][0] && 
           result['candidates'][0]['content'] && 
           result['candidates'][0]['content']['parts'] &&
           result['candidates'][0]['content']['parts'][0] &&
           result['candidates'][0]['content']['parts'][0]['inlineData']
          
          image_data = result['candidates'][0]['content']['parts'][0]['inlineData']['data']
          File.open(image_path, 'wb') do |file|
            file.write(Base64.decode64(image_data))
          end
          puts "    ✅ 생성 완료!"
        else
          puts "    ❌ 이미지 데이터 없음: #{result}"
        end
      else
        puts "    ❌ API 오류: #{response.code} - #{response.body}"
      end
      
    rescue => e
      puts "    ❌ 오류: #{e.message}"
    end
  end
end
