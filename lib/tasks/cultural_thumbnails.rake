# frozen_string_literal: true

namespace :cultural do
  desc "Generate culturally diverse thumbnails with different art styles"
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
    
    puts "\n=== Generating Culturally Diverse Thumbnails ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 문화권별, 성향별 프롬프트 정의
    cultural_styles = {
      'korean' => {
        'neutral' => [
          "Traditional Korean folk tale illustration, hanji paper texture, soft watercolor style, muted earth tones, minimalist composition",
          "Korean traditional painting style, soft brush strokes, nature elements, mountains and rivers, peaceful atmosphere",
          "Korean folk art style, simple geometric patterns, traditional color palette, warm and inviting"
        ],
        'adventure' => [
          "Dynamic Korean historical adventure scene, traditional warriors, vibrant colors, action composition, manhwa style",
          "Korean mythology inspired action scene, tigers and dragons, bold brush strokes, energetic composition",
          "Traditional Korean hero tale, dynamic movement, bright colors, comic book style adaptation"
        ],
        'fantasy' => [
          "Korean fairy tale princess, hanbok inspired fantasy, soft pastel colors, dreamy atmosphere, magical elements",
          "Korean palace fantasy scene, cherry blossoms, ethereal lighting, romantic atmosphere",
          "Traditional Korean fantasy world, mystical creatures, soft watercolor style, magical atmosphere"
        ]
      },
      'japanese' => {
        'neutral' => [
          "Soft anime style illustration, school setting, bright and cheerful, slice of life atmosphere",
          "Kawaii style educational content, cute mascot characters, pastel colors, simple shapes",
          "Japanese manga style, clean lines, everyday scenes, warm and friendly atmosphere"
        ],
        'adventure' => [
          "Shonen manga action scene, dynamic poses, speed lines, intense energy, bold composition",
          "Adventure anime style, heroic characters, dramatic lighting, action packed scene",
          "Japanese RPG game art style, fantasy adventure, vibrant colors, epic composition"
        ],
        'fantasy' => [
          "Magical girl anime style, sparkles and ribbons, pink and purple palette, dreamy atmosphere",
          "Fantasy shoujo manga style, romantic castle, soft lighting, floral elements",
          "Japanese fantasy illustration, mythical creatures, ethereal atmosphere, delicate art style"
        ]
      },
      'western' => {
        'neutral' => [
          "Classic storybook illustration, watercolor style, warm colors, cozy atmosphere",
          "European fairy tale art, detailed illustration, rich textures, timeless quality",
          "Modern western cartoon style, clean vector art, bright primary colors, friendly design"
        ],
        'adventure' => [
          "Comic book superhero style, dynamic action, bold colors, dramatic angles",
          "Adventure cartoon style, exploration theme, vibrant landscape, exciting atmosphere",
          "Western animation action scene, fluid movement, cinematic composition"
        ],
        'fantasy' => [
          "Disney princess style illustration, magical castle, sparkling effects, dreamy colors",
          "Fantasy storybook art, enchanted forest, mystical lighting, whimsical details",
          "Fairy tale illustration, magical creatures, soft pastels, romantic atmosphere"
        ]
      }
    }
    
    # 연령대별 조정
    age_adjustments = {
      'baby' => "simple shapes, high contrast, basic colors, minimal details",
      'toddler' => "bright colors, friendly characters, playful atmosphere",
      'elementary' => "detailed illustration, rich storytelling, sophisticated composition"
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'cultural')
    FileUtils.mkdir_p(output_dir)
    
    negative = "scary, violent, inappropriate, text, logo, watermark, photorealistic human faces"
    
    success_count = 0
    total_attempts = 0
    
    ['baby', 'toddler', 'elementary'].each do |age_group|
      puts "\n→ Generating for #{age_group} age group..."
      
      cultural_styles.each do |culture, preferences|
        preferences.each do |preference, prompts|
          prompts.take(1).each_with_index do |base_prompt, index|
            filename = "#{culture}_#{preference}_#{age_group}_#{index + 1}.jpg"
            filepath = output_dir.join(filename)
            
            # 연령대에 맞게 프롬프트 조정
            adjusted_prompt = "#{base_prompt}, #{age_adjustments[age_group]}, high quality digital art"
            
            puts "  → Generating #{filename}..."
            total_attempts += 1
            
            begin
              generator.generate!(
                prompt: adjusted_prompt,
                filename: "cultural/#{filename}",
                width: 400,
                height: 600,
                style_preset: "DIGITAL_ART",
                negative_prompt: negative
              )
              puts "  ✓ #{filename} generated"
              success_count += 1
            rescue => e
              puts "  ✗ #{filename} failed: #{e.message}"
              
              # 정책 위반 시 대체 프롬프트 시도
              if e.message.include?("policy")
                puts "  → Retrying with safer prompt..."
                safer_prompt = base_prompt.gsub(/anime|manga|shoujo|shonen|kawaii|disney|princess/, '')
                                         .gsub(/Korean|Japanese|Western/, 'traditional')
                                         .gsub(/folk tale|fairy tale/, 'story')
                safer_prompt = "Abstract illustration in #{culture} art style, #{preference} theme, #{age_adjustments[age_group]}"
                
                begin
                  generator.generate!(
                    prompt: safer_prompt,
                    filename: "cultural/#{filename}",
                    width: 400,
                    height: 600,
                    style_preset: "DIGITAL_ART",
                    negative_prompt: negative
                  )
                  puts "  ✓ #{filename} generated (with safer prompt)"
                  success_count += 1
                rescue => e2
                  puts "  ✗ Retry also failed: #{e2.message}"
                end
              end
            end
            
            # API 제한 방지
            sleep(3)
          end
        end
      end
    end
    
    puts "\n=== Generated #{success_count}/#{total_attempts} cultural thumbnails successfully ==="
    
    # 실패한 이미지에 대한 대체 SVG 생성
    if success_count < total_attempts
      puts "\n→ Generating fallback SVGs for failed images..."
      require_relative '../../app/services/cultural_svg_generator'
      
      ['baby', 'toddler', 'elementary'].each do |age_group|
        cultural_styles.keys.each do |culture|
          ['neutral', 'adventure', 'fantasy'].each do |preference|
            (0..0).each do |index|
              filename = "#{culture}_#{preference}_#{age_group}_#{index + 1}"
              jpg_path = output_dir.join("#{filename}.jpg")
              svg_path = output_dir.join("#{filename}.svg")
              
              unless File.exist?(jpg_path)
                puts "  → Creating fallback SVG: #{filename}.svg"
                svg_content = CulturalSvgGenerator.generate(culture, preference, age_group)
                File.write(svg_path, svg_content)
                puts "  ✓ SVG created"
              end
            end
          end
        end
      end
    end
  end
end
