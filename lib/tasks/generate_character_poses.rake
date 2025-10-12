namespace :characters do
  desc "Generate character poses for sprite animation"
  task generate_poses: :environment do
    require 'net/http'
    require 'json'
    require 'base64'
    require 'fileutils'

    # Vertex AI 설정
    api_key = ENV['GEMINI_API_KEY']
    if api_key.nil?
      puts "❌ GEMINI_API_KEY 환경변수가 설정되지 않았습니다."
      exit 1
    end

    # 캐릭터별 포즈 정의
    character_poses = {
      'jeonghwa' => {
        base_description: "한국인 40대 여성 교육자, 짧은 곱슬머리, 파란 카디건, 진주 목걸이, 검은 치마",
        poses: {
          # 실제 걷기 사이클 - 8프레임 걷기 애니메이션
          'walk_cycle_1' => "걷기 프레임 1: 오른발이 뒤로, 왼발이 앞으로, 오른팔이 앞으로 스윙, 자연스러운 걸음걸이",
          'walk_cycle_2' => "걷기 프레임 2: 오른발이 지면에 닿기 시작, 왼발이 들려있음, 팔의 중간 스윙",
          'walk_cycle_3' => "걷기 프레임 3: 양발이 지면에 닿아있음, 몸의 중심이 이동하는 순간",
          'walk_cycle_4' => "걷기 프레임 4: 왼발이 뒤로, 오른발이 앞으로, 왼팔이 앞으로 스윙",
          'walk_cycle_5' => "걷기 프레임 5: 왼발이 지면에서 떨어지기 시작, 오른발이 앞으로 나아감",
          'walk_cycle_6' => "걷기 프레임 6: 왼발이 완전히 들려있음, 오른발에 체중이 실림",
          'walk_cycle_7' => "걷기 프레임 7: 양발이 다시 지면에 닿으려는 순간, 반대 방향 스윙",
          'walk_cycle_8' => "걷기 프레임 8: 사이클 완성, 다시 첫 번째 프레임으로 연결되는 자세",
          
          # 방향 전환 애니메이션 - 옆모습에서 정면으로
          'turn_side_to_front_1' => "옆모습에서 시작, 완전히 측면을 바라보고 있음",
          'turn_side_to_front_2' => "15도 회전, 약간 정면 쪽으로 몸을 돌리기 시작",
          'turn_side_to_front_3' => "30도 회전, 얼굴이 반측면을 보이기 시작",
          'turn_side_to_front_4' => "45도 회전, 얼굴의 절반이 보이는 각도",
          'turn_side_to_front_5' => "60도 회전, 얼굴이 더 많이 보이기 시작",
          'turn_side_to_front_6' => "75도 회전, 거의 정면에 가까운 각도",
          'turn_side_to_front_7' => "90도 회전 완성, 완전한 정면을 바라보는 자세",
          
          # 제스처 애니메이션 - 팔의 실제 움직임
          'gesture_start' => "팔을 몸 옆에 자연스럽게 두고 있는 시작 자세",
          'gesture_lift_1' => "오른팔을 천천히 들어올리기 시작, 어깨가 약간 올라감",
          'gesture_lift_2' => "팔이 허리 높이까지 올라온 상태, 손목이 약간 꺾임",
          'gesture_point' => "완전히 팔을 뻗어 가리키는 자세, 손가락으로 포인팅",
          'gesture_emphasize' => "포인팅하면서 약간 앞으로 몸을 기울여 강조하는 모습",
          
          # 슬라이드 2: 교육 프로그램 소개  
          'approach_teaching' => "교육자로서 다가가는 모습, 자신감 있는 표정과 자세",
          'teaching_gesture_1' => "양손을 사용해 설명하는 모습, 전문가다운 제스처",
          'teaching_gesture_2' => "한 손을 들어 포인트를 강조하는 모습, 집중된 표정",
          'professional_pose' => "전문가다운 자세로 서있는 모습, 자신감 있는 표정",
          
          # 슬라이드 3: 성공 사례 소개
          'proud_presentation_1' => "자랑스럽게 발표하는 모습, 양손을 벌리며 성과를 보여줌",
          'proud_presentation_2' => "뿌듯한 표정으로 결과를 제시하는 모습, 만족스러운 미소",
          'achievement_gesture' => "성과를 보여주는 제스처, 한 손을 위로 올리며 성공을 표현",
          'confident_pose' => "자신감 넘치는 포즈, 어깨를 펴고 당당한 자세"
        }
      },
      
      'bear' => {
        base_description: "귀여운 갈색 곰 캐릭터, 둥근 귀, 작은 눈, 부드러운 털, 친근한 표정",
        poses: {
          # 곰의 실제 뒤뚱거리며 걷기 사이클 - 6프레임
          'waddle_cycle_1' => "뒤뚱거리며 걷기 1: 왼발에 체중을 실어 왼쪽으로 기울어짐, 오른발이 살짝 들림",
          'waddle_cycle_2' => "뒤뚱거리며 걷기 2: 오른발을 앞으로 내딛는 중, 몸의 균형을 잡으려 함",
          'waddle_cycle_3' => "뒤뚱거리며 걷기 3: 오른발에 체중이 실려 오른쪽으로 기울어짐, 왼발이 뒤에",
          'waddle_cycle_4' => "뒤뚱거리며 걷기 4: 왼발을 앞으로 내딛는 중, 몸이 중앙으로 돌아옴",
          'waddle_cycle_5' => "뒤뚱거리며 걷기 5: 다시 왼발에 체중이 실려 왼쪽으로 기울어짐",
          'waddle_cycle_6' => "뒤뚱거리며 걷기 6: 사이클 완성, 다음 걸음 준비 자세",
          
          # 곰의 방향 전환 - 옆모습에서 정면으로
          'bear_turn_1' => "완전한 옆모습, 측면 프로필로 앞을 바라봄",
          'bear_turn_2' => "약간 정면 쪽으로 고개를 돌리기 시작, 귀의 각도 변화",
          'bear_turn_3' => "반측면, 한쪽 눈이 보이기 시작하는 각도",
          'bear_turn_4' => "3/4 각도, 얼굴의 대부분이 보이는 상태",
          'bear_turn_5' => "거의 정면, 양쪽 귀가 모두 보이기 시작",
          'bear_turn_6' => "완전한 정면, 둥근 얼굴이 정면을 바라봄",
          
          # 곰의 호기심 표현 - 실제 목과 머리 움직임
          'curious_start' => "평범한 정면 자세, 중립적인 표정",
          'curious_lean_forward' => "목을 앞으로 내밀며 호기심을 보이는 자세",
          'curious_tilt_left' => "고개를 왼쪽으로 기울이며 자세히 보려는 모습",
          'curious_tilt_right' => "고개를 오른쪽으로 기울이며 다른 각도로 관찰",
          'curious_eyes_wide' => "눈을 크게 뜨고 관심을 보이는 표정",
          
          # 슬라이드 2
          'study_walking' => "책을 들고 걸어가는 모습, 집중하며 공부하는 자세",
          'focused_front' => "정면에서 집중하는 모습, 진지한 표정으로 학습에 몰두",
          'reading_pose' => "책을 읽고 있는 자세, 고개를 약간 숙이고 집중",
          'thinking_pose' => "생각하는 자세, 한 손을 턱에 대고 고민하는 모습",
          
          # 슬라이드 3  
          'march_1' => "행진하는 모습, 왼발을 높이 들어 당당하게 걷기",
          'march_2' => "행진하는 모습, 오른발을 높이 들어 당당하게 걷기",
          'celebration_1' => "축하하는 동작, 양팔을 위로 올리며 기뻐하는 모습",
          'celebration_2' => "축하하는 동작, 점프하듯 기뻐하는 모습",
          'success_pose' => "성공을 표현하는 포즈, 가슴을 펴고 자랑스러운 표정"
        }
      },
      
      'rabbit' => {
        base_description: "귀여운 흰색 토끼 캐릭터, 긴 귀, 둥근 꼬리, 활발한 표정, 에너지 넘치는 모습",
        poses: {
          # 토끼의 실제 깡총깡총 뛰기 사이클 - 8프레임
          'hop_cycle_1' => "점프 준비: 뒷다리를 깊게 구부리고 앞다리를 바닥에 댄 채 몸을 낮춤",
          'hop_cycle_2' => "점프 시작: 뒷다리로 강하게 밀어 올리며 몸이 지면에서 떨어지기 시작",
          'hop_cycle_3' => "공중 상승: 모든 다리가 몸 아래로 모여있고 귀가 뒤로 날림",
          'hop_cycle_4' => "최고점: 몸이 가장 높이 올라간 상태, 다리가 자연스럽게 펼쳐짐",
          'hop_cycle_5' => "하강 시작: 중력에 의해 내려오기 시작, 앞다리가 착지 준비",
          'hop_cycle_6' => "착지 준비: 앞다리가 먼저 지면에 닿을 준비, 뒷다리는 아직 공중",
          'hop_cycle_7' => "착지 완료: 앞다리가 지면에 닿고 뒷다리가 따라서 착지",
          'hop_cycle_8' => "착지 안정화: 모든 다리가 지면에 안정적으로 닿은 상태, 다음 점프 준비",
          
          # 토끼의 방향 전환 - 옆모습에서 정면으로 (귀의 움직임 포함)
          'rabbit_turn_1' => "완전한 옆모습, 긴 귀가 측면으로 보임",
          'rabbit_turn_2' => "15도 회전, 귀 하나가 약간 앞쪽으로 향함",
          'rabbit_turn_3' => "30도 회전, 귀의 각도가 변하며 한쪽 눈이 보이기 시작",
          'rabbit_turn_4' => "45도 회전, 반측면에서 귀가 V자 모양을 만듦",
          'rabbit_turn_5' => "60도 회전, 얼굴이 많이 보이며 양쪽 귀의 각도 차이",
          'rabbit_turn_6' => "75도 회전, 거의 정면에 가까워짐",
          'rabbit_turn_7' => "90도 완성, 완전한 정면에서 양쪽 귀가 대칭적으로 보임",
          
          # 토끼의 흥분 표현 - 실제 귀와 꼬리 움직임
          'excited_start' => "평범한 자세, 귀가 자연스럽게 서있음",
          'excited_ears_up' => "흥분하여 귀가 쫑긋 완전히 세워진 상태",
          'excited_bounce_prep' => "작은 점프 준비, 몸을 살짝 낮추며 에너지 충전",
          'excited_small_hop' => "작은 흥분 점프, 네 다리가 모두 지면에서 살짝 떨어짐",
          'excited_point_gesture' => "앞다리 하나를 들어 가리키는 제스처, 귀가 앞쪽으로 향함",
          'excited_tail_twitch' => "꼬리가 흥분으로 파르르 떨리는 모습, 온몸으로 기쁨 표현",
          
          # 슬라이드 2
          'eager_approach' => "열심히 다가오는 모습, 빠른 걸음으로 에너지 넘치게",
          'hand_raise_1' => "손을 들기 시작하는 모습, 적극적으로 참여하려는 자세",
          'hand_raise_2' => "손을 높이 든 모습, 열정적으로 발표하고 싶어하는 표정",
          'enthusiastic_front' => "열정적인 정면 모습, 눈을 반짝이며 기대하는 표정",
          
          # 슬라이드 3
          'victory_jump_1' => "승리의 점프 준비, 기쁨을 표현하며 뛸 준비",
          'victory_jump_2' => "승리의 점프 최고점, 양팔을 벌리며 최고로 높이 뛰기",
          'victory_jump_3' => "승리의 점프 착지, 기쁨을 유지하며 부드럽게 착지",
          'dance_1' => "춤 동작 1, 왼쪽으로 몸을 기울이며 리듬감 있게",
          'dance_2' => "춤 동작 2, 오른쪽으로 몸을 기울이며 리듬감 있게", 
          'celebration_spin' => "축하하며 돌기, 빙글빙글 돌며 기뻐하는 모습"
        }
      }
    }

    # 각 캐릭터별로 포즈 이미지 생성
    character_poses.each do |character_name, character_data|
      puts "\n🎭 #{character_name.upcase} 캐릭터 포즈 생성 시작..."
      
      # 디렉토리 생성
      poses_dir = Rails.root.join('public', 'images', character_name, 'poses')
      FileUtils.mkdir_p(poses_dir)
      
      character_data[:poses].each do |pose_name, pose_description|
        puts "  📸 #{pose_name} 포즈 생성 중..."
        
        # 이미지 파일 경로
        image_path = poses_dir.join("#{pose_name}.png")
        
        # 이미 파일이 존재하면 스킵
        if File.exist?(image_path)
          puts "    ⏭️  이미 존재함: #{pose_name}"
          next
        end
        
        # 프롬프트 생성
        prompt = build_character_prompt(character_data[:base_description], pose_description)
        
        # Vertex AI로 이미지 생성
        begin
          image_data = generate_image_with_vertex_ai(prompt, api_key)
          
          if image_data
            # 이미지 저장
            File.open(image_path, 'wb') do |file|
              file.write(Base64.decode64(image_data))
            end
            puts "    ✅ 생성 완료: #{pose_name}"
            
            # API 호출 제한을 위한 대기
            sleep(2)
          else
            puts "    ❌ 생성 실패: #{pose_name}"
          end
          
        rescue => e
          puts "    ❌ 오류 발생: #{pose_name} - #{e.message}"
          next
        end
      end
    end
    
    puts "\n🎉 모든 캐릭터 포즈 생성이 완료되었습니다!"
    puts "📁 생성된 이미지는 public/images/[캐릭터명]/poses/ 폴더에 저장되었습니다."
  end

  private

  def build_character_prompt(base_description, pose_description)
    "Educational illustration of #{base_description}, #{pose_description}, 3D cartoon style similar to Pixar animation, isolated on transparent background, high-quality character design for children's educational platform, friendly and approachable appearance, professional illustration quality"
  end

  def generate_image_with_vertex_ai(prompt, api_key)
    uri = URI('https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:generateImage')
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-goog-api-key'] = api_key
    
    request.body = {
      prompt: prompt,
      config: {
        aspectRatio: "1:1",
        safetyFilterLevel: "block_some",
        personGeneration: "allow_adult"
      }
    }.to_json
    
    response = http.request(request)
    
    if response.code == '200'
      result = JSON.parse(response.body)
      if result['image'] && result['image']['data']
        return result['image']['data']
      end
    else
      puts "    ⚠️  API 오류: #{response.code} - #{response.body}"
    end
    
    nil
  rescue => e
    puts "    ❌ 네트워크 오류: #{e.message}"
    nil
  end
end
