namespace :character_3d do
  desc "Generate 3D character animation frames for video creation"
  task generate_animation_frames: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[character_3d:generate_animation_frames] Set VERTEX_PROJECT_ID env.") unless project_id
    abort("[character_3d:generate_animation_frames] Set credentials") unless cred_env && File.exist?(cred_env)

    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    negative = "text, typography, watermark, logo, brand, photorealistic, harsh lighting, busy composition, clutter, grain noise, background, floor, ground"

    # 3D 애니메이션 프레임 저장 디렉토리
    animation_dir = Rails.root.join('app', 'assets', 'images', 'generated', '3d_animation')
    FileUtils.mkdir_p(animation_dir)

    puts "🎬 3D 캐릭터 애니메이션 프레임 생성 시작..."

    # 정화 선생님 3D 걷기 애니메이션 시퀀스 (12프레임)
    jeonghwa_3d_frames = {
      # 걷기 사이클 프레임들
      "jeonghwa_3d_walk_01" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. WALKING CYCLE FRAME 1: Right foot forward, left foot back, right arm swinging forward, natural walking pose, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_walk_02" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. WALKING CYCLE FRAME 2: Mid-stride, both feet touching ground, body weight shifting, arms in neutral swing, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_walk_03" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. WALKING CYCLE FRAME 3: Left foot forward, right foot back, left arm swinging forward, opposite of frame 1, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_walk_04" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. WALKING CYCLE FRAME 4: Mid-stride opposite, completing walking cycle, natural arm swing, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      # 방향 전환 프레임들
      "jeonghwa_3d_turn_01" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. TURNING FRAME 1: Side profile view, body facing left, preparing to turn towards viewer, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_turn_02" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. TURNING FRAME 2: 45-degree turn, body rotating towards viewer, face becoming visible, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_turn_03" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. TURNING FRAME 3: Front-facing view, body fully turned towards viewer, warm smile, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      # 제스처 프레임들
      "jeonghwa_3d_gesture_01" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. GESTURE FRAME 1: Arms at sides, neutral standing position, preparing to gesture, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_gesture_02" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. GESTURE FRAME 2: Right arm extending outward, presenting gesture, professional educator pose, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_gesture_03" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. GESTURE FRAME 3: Both arms opened wide, welcoming presentation gesture, big warm smile, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      # 호흡 프레임들
      "jeonghwa_3d_breath_01" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. BREATHING FRAME 1: Neutral standing, chest slightly expanded, natural breathing pose, 3D Pixar animation style, completely transparent background, no floor or ground visible",
      
      "jeonghwa_3d_breath_02" => "3D character animation frame: Educational middle-aged female educator with East Asian features, short curly brown hair, blue cardigan, pearl necklace, black skirt. BREATHING FRAME 2: Chest slightly contracted, natural exhale pose, subtle body movement, 3D Pixar animation style, completely transparent background, no floor or ground visible"
    }

    # 곰 학생 3D 애니메이션 시퀀스 (8프레임)
    bear_3d_frames = {
      "bear_3d_waddle_01" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. WADDLING FRAME 1: Bear leaning slightly left, right paw lifted, characteristic bear waddle, adorable expression, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_waddle_02" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. WADDLING FRAME 2: Bear stepping forward, body balanced, natural bear walking motion, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_waddle_03" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. WADDLING FRAME 3: Bear leaning slightly right, left paw lifted, opposite lean, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_curious_01" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. CURIOUS FRAME 1: Bear tilting head with curiosity, ears perked up, interested expression, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_curious_02" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. CURIOUS FRAME 2: Bear leaning forward slightly, neck extended with interest, wide eyes, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_nod_01" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. NODDING FRAME 1: Bear head in neutral position, preparing to nod, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_nod_02" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. NODDING FRAME 2: Bear head tilted down slightly, mid-nod motion, agreeable expression, 3D Pixar animation style, completely transparent background, floating in air",
      
      "bear_3d_happy" => "3D character animation frame: Cute friendly brown bear with round ears, small black eyes, soft fur texture. HAPPY FRAME: Bear with joyful expression, slight smile, content and satisfied look, 3D Pixar animation style, completely transparent background, floating in air"
    }

    # 토끼 학생 3D 애니메이션 시퀀스 (10프레임)
    rabbit_3d_frames = {
      "rabbit_3d_crouch" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. CROUCH FRAME: Rabbit crouched low, hind legs bent, preparing to jump, coiled energy, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_launch" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. LAUNCH FRAME: Rabbit pushing off, body starting to lift, ears beginning to flow back, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_airborne_01" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. AIRBORNE FRAME 1: Rabbit fully in air, paws tucked under, ears flowing back, peak jump, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_airborne_02" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. AIRBORNE FRAME 2: Rabbit at highest point, ears fully back, graceful air pose, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_descend" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. DESCENDING FRAME: Rabbit coming down, front paws extending for landing, ears coming forward, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_land_01" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. LANDING FRAME 1: Front paws touching down first, hind legs still in air, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_land_02" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. LANDING FRAME 2: All paws down, body settling, completing hop cycle, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_excited_01" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. EXCITED FRAME 1: Ears perked up high, alert and enthusiastic expression, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_excited_02" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. EXCITED FRAME 2: Ears twitching with excitement, bright happy expression, 3D Pixar animation style, completely transparent background, floating in air",
      
      "rabbit_3d_point" => "3D character animation frame: Cute energetic white rabbit with long ears, round fluffy tail, bright eyes. POINTING FRAME: One front paw raised, pointing gesture, enthusiastic expression, 3D Pixar animation style, completely transparent background, floating in air"
    }

    # 모든 3D 프레임 생성
    all_3d_frames = jeonghwa_3d_frames.merge(bear_3d_frames).merge(rabbit_3d_frames)
    
    all_3d_frames.each_with_index do |(filename, prompt), index|
      puts "\n🎬 [#{index + 1}/#{all_3d_frames.size}] #{filename} 3D 프레임 생성 중..."
      
      begin
        generator.generate!(
          prompt: prompt,
          filename: filename,
          width: 1024,
          height: 1024,
          negative_prompt: negative
        )
        
        puts "    ✅ 3D 프레임 생성 완료!"
        
      rescue => e
        puts "    ❌ 오류: #{e.message}"
        next
      end

      # API 제한 대응
      sleep(2)
    end

    puts "\n🎉 3D 캐릭터 애니메이션 프레임 생성 완료!"
    puts "📁 저장 위치: app/assets/images/generated/3d_animation/"
    puts "🎬 다음 단계: 프레임들을 동영상으로 합성"
  end
  
  desc "Create videos from 3D animation frames"
  task create_videos: :environment do
    require 'open3'
    
    puts "🎬 3D 프레임을 동영상으로 합성 시작..."
    
    animation_dir = Rails.root.join('app', 'assets', 'images', 'generated', '3d_animation')
    video_dir = Rails.root.join('public', 'videos', '3d_characters')
    FileUtils.mkdir_p(video_dir)
    
    # 캐릭터별 프레임 그룹
    character_groups = {
      'jeonghwa' => {
        walking: %w[jeonghwa_3d_walk_01 jeonghwa_3d_walk_02 jeonghwa_3d_walk_03 jeonghwa_3d_walk_04],
        turning: %w[jeonghwa_3d_turn_01 jeonghwa_3d_turn_02 jeonghwa_3d_turn_03],
        gesturing: %w[jeonghwa_3d_gesture_01 jeonghwa_3d_gesture_02 jeonghwa_3d_gesture_03],
        breathing: %w[jeonghwa_3d_breath_01 jeonghwa_3d_breath_02]
      },
      'bear' => {
        waddling: %w[bear_3d_waddle_01 bear_3d_waddle_02 bear_3d_waddle_03],
        curious: %w[bear_3d_curious_01 bear_3d_curious_02],
        nodding: %w[bear_3d_nod_01 bear_3d_nod_02 bear_3d_happy]
      },
      'rabbit' => {
        hopping: %w[rabbit_3d_crouch rabbit_3d_launch rabbit_3d_airborne_01 rabbit_3d_airborne_02 rabbit_3d_descend rabbit_3d_land_01 rabbit_3d_land_02],
        excited: %w[rabbit_3d_excited_01 rabbit_3d_excited_02 rabbit_3d_point]
      }
    }
    
    # FFmpeg로 프레임을 WebM 동영상으로 변환
    character_groups.each do |character, animations|
      animations.each do |animation_name, frames|
        puts "\n🎬 #{character}_#{animation_name} 동영상 생성 중..."
        
        # 프레임 파일들이 존재하는지 확인
        frame_files = frames.map { |frame| animation_dir.join("#{frame}.jpg") }
        existing_frames = frame_files.select { |file| File.exist?(file) }
        
        if existing_frames.empty?
          puts "    ⏭️  프레임 파일이 없음"
          next
        end
        
        output_file = video_dir.join("#{character}_#{animation_name}.webm")
        
        # FFmpeg 명령어로 프레임을 WebM 동영상으로 변환
        ffmpeg_cmd = [
          "ffmpeg", "-y",
          "-framerate", "8",  # 8fps (자연스러운 속도)
          "-pattern_type", "glob",
          "-i", "#{animation_dir}/#{character}_3d_*.jpg",
          "-c:v", "libvpx-vp9",  # VP9 코덱 (고품질)
          "-pix_fmt", "yuva420p", # 알파 채널 지원
          "-auto-alt-ref", "0",
          "-lag-in-frames", "0",
          "-loop", "-1",  # 무한 루프
          "-t", "3",      # 3초 길이
          output_file.to_s
        ]
        
        begin
          stdout, stderr, status = Open3.capture3(*ffmpeg_cmd)
          
          if status.success?
            puts "    ✅ 동영상 생성 완료: #{character}_#{animation_name}.webm"
          else
            puts "    ❌ FFmpeg 오류: #{stderr}"
          end
          
        rescue => e
          puts "    ❌ 동영상 생성 실패: #{e.message}"
        end
      end
    end
    
    puts "\n🎉 3D 캐릭터 동영상 생성 완료!"
    puts "📁 저장 위치: public/videos/3d_characters/"
  end
end

