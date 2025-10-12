# frozen_string_literal: true

namespace :title_specific do
  desc "Generate thumbnails that match specific storybook titles"
  task generate_thumbnails: :environment do
    project_id = ENV["VERTEX_PROJECT_ID"] || "gen-lang-client-0492798913"
    cred_env = ENV["VERTEX_CREDENTIALS"] || ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    
    default_cred = Rails.root.join("config", "google_service_account.json")
    if cred_env.nil? && File.exist?(default_cred)
      cred_env = default_cred.to_s
    end
    
    unless project_id && cred_env && File.exist?(cred_env)
      puts "Vertex AI credentials not configured."
      return
    end
    
    puts "\n=== Generating Title-Specific Thumbnails ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 실제 동화책 제목과 매칭되는 구체적인 프롬프트
    title_specific_prompts = {
      'korean' => {
        'neutral' => {
          "벚꽃 피는 언덕" => "Soft watercolor illustration of cherry blossom hill, pink petals floating, gentle spring scene, Korean traditional art style",
          "신비로운 숲속" => "Mysterious forest with tall trees, soft green and blue tones, magical atmosphere, Korean folk art style",
          "무지개 계곡" => "Rainbow arching over peaceful valley, pastel colors, dreamy landscape, Korean traditional painting style",
          "달빛 호수" => "Moonlight reflecting on calm lake, silver and blue tones, serene night scene, Korean art style",
          "꽃피는 정원" => "Blooming garden with colorful flowers, soft pastel colors, peaceful atmosphere, Korean traditional style"
        },
        'adventure' => {
          "용의 보물" => "Dragon's treasure cave with golden coins, warm colors, adventure theme, Korean fantasy art style",
          "산 정상의 성" => "Castle on mountain peak, dramatic sky, adventure atmosphere, Korean traditional art style",
          "바다의 모험" => "Ocean adventure scene with waves, blue and white tones, dynamic composition, Korean art style"
        },
        'fantasy' => {
          "요정의 나라" => "Fairy land with magical flowers, soft pastel colors, fantasy atmosphere, Korean traditional style",
          "마법의 성" => "Enchanted castle with glowing windows, purple and gold tones, magical scene, Korean fantasy art",
          "별빛 정원" => "Starlit garden with twinkling lights, deep blue and silver, magical atmosphere, Korean art style"
        }
      },
      'japanese' => {
        'neutral' => {
          "벚꽃 피는 언덕" => "Cherry blossom hill in anime style, soft pink petals, gentle spring scene, Japanese illustration",
          "신비로운 숲속" => "Mysterious forest in manga style, tall bamboo and trees, soft green tones, Japanese art",
          "무지개 계곡" => "Rainbow valley in anime style, bright pastel colors, dreamy landscape, Japanese illustration",
          "달빛 호수" => "Moonlit lake in anime style, silver reflections, peaceful night scene, Japanese art",
          "꽃피는 정원" => "Blooming garden in kawaii style, colorful flowers, cute atmosphere, Japanese illustration"
        },
        'adventure' => {
          "용의 보물" => "Dragon treasure in anime style, golden cave, adventure theme, Japanese manga art",
          "산 정상의 성" => "Mountain castle in anime style, dramatic sky, adventure atmosphere, Japanese illustration",
          "바다의 모험" => "Ocean adventure in anime style, dynamic waves, blue tones, Japanese manga art"
        },
        'fantasy' => {
          "요정의 나라" => "Fairy land in anime style, magical flowers, soft pastels, Japanese fantasy art",
          "마법의 성" => "Magic castle in anime style, glowing elements, purple tones, Japanese fantasy illustration",
          "별빛 정원" => "Starlit garden in anime style, twinkling lights, deep blues, Japanese magical art"
        }
      },
      'western' => {
        'neutral' => {
          "벚꽃 피는 언덕" => "Cherry blossom hill in Disney style, soft pink petals, gentle spring scene, Western illustration",
          "신비로운 숲속" => "Mysterious forest in storybook style, tall trees, soft green tones, Western art",
          "무지개 계곡" => "Rainbow valley in Disney style, bright colors, dreamy landscape, Western illustration",
          "달빛 호수" => "Moonlit lake in storybook style, silver reflections, peaceful night, Western art",
          "꽃피는 정원" => "Blooming garden in Disney style, colorful flowers, cheerful atmosphere, Western illustration"
        },
        'adventure' => {
          "용의 보물" => "Dragon treasure in Disney style, golden cave, adventure theme, Western fantasy art",
          "산 정상의 성" => "Mountain castle in storybook style, dramatic sky, adventure atmosphere, Western illustration",
          "바다의 모험" => "Ocean adventure in Disney style, dynamic waves, blue tones, Western art"
        },
        'fantasy' => {
          "요정의 나라" => "Fairy land in Disney style, magical flowers, soft pastels, Western fantasy art",
          "마법의 성" => "Magic castle in storybook style, glowing elements, purple tones, Western fantasy illustration",
          "별빛 정원" => "Starlit garden in Disney style, twinkling lights, deep blues, Western magical art"
        }
      }
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'title_specific')
    FileUtils.mkdir_p(output_dir)
    
    # 안전한 negative prompt
    negative = "realistic human faces, people, characters, text, logo, watermark, scary, dark, violent"
    
    success_count = 0
    total_attempts = 0
    
    ['baby', 'toddler', 'elementary'].each do |age_group|
      puts "\n→ Generating for #{age_group} age group..."
      
      age_modifier = case age_group
      when 'baby'
        "very simple shapes, soft colors, minimal detail, child-friendly"
      when 'toddler'
        "simple and cute style, bright soft colors, friendly"
      else
        "detailed illustration, rich colors, sophisticated composition"
      end
      
      title_specific_prompts.each do |culture, preferences|
        preferences.each do |preference, title_prompts|
          title_prompts.each do |title, prompt|
            filename = "#{culture}_#{preference}_#{age_group}_#{title.gsub(/\s+/, '_')}.jpg"
            filepath = output_dir.join(filename)
            
            # 제목에 맞는 구체적인 프롬프트
            specific_prompt = "#{prompt}, #{age_modifier}, high quality children's book illustration, professional artwork"
            
            puts "  → Generating #{filename} for '#{title}'..."
            total_attempts += 1
            
            begin
              generator.generate!(
                prompt: specific_prompt,
                filename: "title_specific/#{filename}",
                width: 400,
                height: 600,
                style_preset: "DIGITAL_ART",
                negative_prompt: negative
              )
              puts "  ✓ #{filename} generated"
              success_count += 1
            rescue => e
              puts "  ✗ #{filename} failed: #{e.message[0..100]}..."
              
              # 실패 시 더 추상적인 버전으로 재시도
              if e.message.include?("policy")
                puts "  → Retrying with safer prompt..."
                safe_prompt = "Abstract illustration representing '#{title}', #{preference} theme, #{culture} art influence, #{age_modifier}, soft colors"
                
                begin
                  generator.generate!(
                    prompt: safe_prompt,
                    filename: "title_specific/#{filename}",
                    width: 400,
                    height: 600,
                    style_preset: "DIGITAL_ART",
                    negative_prompt: negative
                  )
                  puts "  ✓ #{filename} generated (safe version)"
                  success_count += 1
                rescue => e2
                  puts "  ✗ Safe version also failed"
                end
              end
            end
            
            # API 제한 방지
            sleep(2)
          end
        end
      end
    end
    
    puts "\n=== Generated #{success_count}/#{total_attempts} title-specific thumbnails ==="
  end
end
