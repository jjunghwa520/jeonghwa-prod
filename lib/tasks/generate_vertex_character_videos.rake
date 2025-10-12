namespace :vertex_videos do
  desc "Generate character videos using Vertex AI Veo 3 (OAuth, 2025 spec)"
  task generate: :environment do
    require 'json'
    require 'base64'
    require 'fileutils'

    project_id = ENV["VERTEX_PROJECT_ID"] || ENV["GOOGLE_CLOUD_PROJECT_ID"]
    location   = ENV["VERTEX_LOCATION"] || "us-central1"
    cred_env   = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]

    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end

    abort("[vertex_videos:generate] Set VERTEX_PROJECT_ID/GOOGLE_CLOUD_PROJECT_ID env.") unless project_id
    abort("[vertex_videos:generate] Set credentials") unless cred_env && File.exist?(cred_env)

    puts "🎬 Vertex AI Veo 3 캐릭터 동영상 생성 시작 (#{location})"

    # 저장 디렉토리
    video_dir = Rails.root.join('public', 'videos', 'vertex_characters')
    FileUtils.mkdir_p(video_dir)

    # 프롬프트 사전
    character_video_prompts = {
      "jeonghwa_walking_animation" => "Educational animation of a professional middle-aged female educator with East Asian facial features, short curly dark-brown hair, cozy blue cardigan over black top with pearl necklace, black skirt. CHARACTER WALKING: walk from left to right, turn to face viewer, open arms in welcoming gesture. Smooth realistic 3D motion, full body, transparent background, Pixar-like 3D cartoon style.",
      "jeonghwa_teaching_animation" => "Educational animation of a professional middle-aged female educator with East Asian facial features, short curly dark-brown hair, cozy blue cardigan over black top with pearl necklace, black skirt. TEACHING: pointing at content, nodding approvingly, gentle explaining gestures. Smooth realistic 3D motion, full body, transparent background, Pixar-like 3D cartoon style.",
      "jeonghwa_presenting_animation" => "Educational animation of a professional middle-aged female educator with East Asian facial features, short curly dark-brown hair, cozy blue cardigan over black top with pearl necklace, black skirt. PRESENTING: proud gesture, hands showing achievements, confident expression. Smooth realistic 3D motion, full body, transparent background, Pixar-like 3D cartoon style.",
      "bear_curious_animation" => "Cute friendly brown bear mascot with round ears and soft fur. CURIOUS: waddle to center, tilt head, lean forward to observe, then nod with understanding. Smooth 3D motion, transparent background, Pixar-like 3D cartoon style.",
      "bear_studying_animation" => "Cute friendly brown bear mascot. STUDYING: focus on learning, small nods, glance up with interest. Smooth 3D motion, transparent background, Pixar-like 3D cartoon style.",
      "bear_celebrating_animation" => "Cute friendly brown bear mascot. CELEBRATION: happy victory dance, raise paws, joyful nods. Smooth 3D motion, transparent background, Pixar-like 3D cartoon style.",
      "rabbit_hopping_animation" => "Cute energetic white rabbit mascot with long ears and round fluffy tail. HOPPING: hop from right to left, ears bounce, turn and point excitedly. Smooth 3D motion, transparent background, Pixar-like 3D cartoon style.",
      "rabbit_eager_animation" => "Cute energetic white rabbit mascot. EAGER: bouncing with excitement, raise paw, ears perked. Smooth 3D motion, transparent background, Pixar-like 3D cartoon style.",
      "rabbit_victory_animation" => "Cute energetic white rabbit mascot. VICTORY: jump with joy, victory hops, ears flying. Smooth 3D motion, transparent background, Pixar-like 3D cartoon style."
    }

    # ONLY/MATCH 필터
    only  = ENV["ONLY"]
    match = ENV["MATCH"]
    keys  = character_video_prompts.keys
    keys  = keys.select { |k| k == only } if only
    keys  = keys.select { |k| k.include?(match) } if match

    if keys.empty?
      puts "⚠️ 생성할 항목이 없습니다. (ONLY/MATCH 확인)"
      next
    end

    # 올바른 엔드포인트 (Veo는 predictLongRunning 사용)
    model_id = ENV['VIDEO_MODEL'] || "veo-2.0-generate-001"
    endpoint = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_id}:predictLongRunning"

    keys.each_with_index do |video_key, index|
      prompt = character_video_prompts[video_key]
      puts "\n🎬 [#{index + 1}/#{keys.size}] #{video_key} 생성 중..."

      video_filename = "#{video_key}.mp4"
      video_path = video_dir.join(video_filename)
      if File.exist?(video_path)
        puts "    ⏭️  이미 존재함: #{video_filename}"
        next
      end

      begin
        token = fetch_access_token(cred_env)

        # 올바른 Veo API 요청 바디 (predictLongRunning용)
        body = {
          instances: [
            {
              prompt: prompt
            }
          ],
          parameters: {
            video_config: {
              duration_seconds: (ENV['DURATION']&.to_i || 5),
              frames_per_second: (ENV['FPS']&.to_i || 24),
              resolution: ENV['RESOLUTION'] || '720p'
            }
          }
        }

        res = http_post_json(endpoint, body, token)

        if res.is_a?(Net::HTTPSuccess)
          json = JSON.parse(res.body)
          puts "    📋 응답: #{json.keys}"

          # LRO 오퍼레이션 (Veo는 항상 LRO)
          if json["name"]
            op_name = json["name"]
            puts "    ⏳ 장기 실행 작업 시작: #{op_name}"
            final = poll_operation(op_name, token, location)
            if final && final["done"]
              puts "    🎬 작업 완료! 응답 구조: #{final.keys}"
              
              # 다양한 응답 구조 지원
              video_b64 = dig_video_base64(final["response"]) || dig_video_base64(final)
              if video_b64
                File.binwrite(video_path, Base64.decode64(video_b64))
                puts "    ✅ 동영상 생성 완료!"
              else
                uri = dig_video_gcs_uri(final["response"]) || dig_video_gcs_uri(final)
                if uri
                  puts "    📦 GCS URI 결과: #{uri}"
                  # GCS에서 다운로드 시도
                  if download_from_gcs(uri, video_path, token)
                    puts "    ✅ GCS에서 동영상 다운로드 완료!"
                  else
                    puts "    ❌ GCS 다운로드 실패"
                  end
                else
                  puts "    ❌ 동영상 데이터 없음. 전체 응답:"
                  puts "    #{final.to_json[0..1000]}"
                end
              end
            else
              puts "    ❌ 오퍼레이션 폴링 실패 또는 미완료"
            end
          else
            puts "    ❌ LRO 작업명 없음: #{json}"
          end
        else
          puts "    ❌ Vertex 오류: #{res.code} #{res.body[0..500]}"
        end
      rescue => e
        puts "    ❌ 오류: #{e.message}"
      end

      sleep(5)
    end

    puts "\n🎉 Vertex AI Veo 3 동영상 생성 완료!"
    puts "📁 저장 위치: public/videos/vertex_characters/"
  end

  private

  def fetch_access_token(credentials_path)
    require 'googleauth'
    scopes = ['https://www.googleapis.com/auth/cloud-platform']
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(credentials_path),
      scope: scopes
    )
    token_hash = authorizer.fetch_access_token!
    token_hash['access_token'] || authorizer.access_token
  end

  def http_post_json(url, body, token)
    require 'net/http'
    require 'uri'
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 600
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{token}"
    req.body = JSON.dump(body)
    http.request(req)
  end

  def http_get_json(url, token)
    require 'net/http'
    require 'uri'
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"
    res = http.request(req)
    return nil unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end

  def poll_operation(name, token, location)
    op_url = "https://#{location}-aiplatform.googleapis.com/v1/#{name}"
    deadline = Time.now + (ENV['POLL_TIMEOUT']&.to_i || 300)  # 5분으로 단축
    poll_count = 0
    
    puts "      폴링 URL: #{op_url}"
    
    loop do
      poll_count += 1
      puts "      폴링 #{poll_count}회차..."
      
      sleep 15  # 15초 간격으로 폴링
      json = http_get_json(op_url, token)
      
      if json.nil?
        puts "      폴링 응답 없음"
        return nil
      end
      
      puts "      폴링 응답: #{json.keys} (done: #{json['done']})"
      
      if json["done"]
        puts "      ✅ 작업 완료!"
        return json
      end
      
      if json["error"]
        puts "      ❌ 작업 오류: #{json['error']}"
        return json
      end
      
      if Time.now > deadline
        puts "      ⏰ 폴링 타임아웃"
        break
      end
      
      # 진행 상황 표시
      if json["metadata"]
        puts "      📊 진행 상황: #{json['metadata']}"
      end
    end
    nil
  end

  # 다양한 응답 스키마 지원
  def dig_video_base64(json)
    return nil unless json.is_a?(Hash)
    # predictions[0].bytesBase64Encoded
    b64 = json.dig('predictions', 0, 'bytesBase64Encoded')
    return b64 if b64
    # predictions[0].videoBytes
    b64 = json.dig('predictions', 0, 'videoBytes')
    return b64 if b64
    # candidates[0].content.parts[*].inlineData.data (generative-style)
    parts = json.dig('candidates', 0, 'content', 'parts')
    if parts.is_a?(Array)
      item = parts.find { |p| p.is_a?(Hash) && p.dig('inlineData', 'mimeType')&.include?('video') }
      return item.dig('inlineData', 'data') if item
    end
    nil
  end

  def dig_video_gcs_uri(json)
    return nil unless json.is_a?(Hash)
    json.dig('predictions', 0, 'gcsUri') || json.dig('response', 'gcsUri') || json.dig('gcsUri')
  end

  def download_from_gcs(gcs_uri, local_path, token)
    return false unless gcs_uri&.start_with?('gs://')
    
    # gs://bucket/path를 https://storage.googleapis.com/bucket/path로 변환
    http_uri = gcs_uri.sub('gs://', 'https://storage.googleapis.com/')
    
    begin
      uri = URI(http_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Bearer #{token}"
      
      res = http.request(req)
      if res.is_a?(Net::HTTPSuccess)
        File.binwrite(local_path, res.body)
        return true
      else
        puts "      GCS 다운로드 오류: #{res.code} #{res.message}"
        return false
      end
    rescue => e
      puts "      GCS 다운로드 예외: #{e.message}"
      return false
    end
  end
end
