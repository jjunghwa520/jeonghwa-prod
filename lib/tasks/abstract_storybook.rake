# frozen_string_literal: true

namespace :abstract do
  desc "Generate abstract storybook-style thumbnails"
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
    
    puts "\n=== Generating Abstract Storybook Thumbnails ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 추상적이고 안전한 프롬프트 - 동물이나 캐릭터 언급 없이
    abstract_prompts = {
      'korean' => {
        'neutral' => [
          "Abstract illustration with soft pastel colors, cherry blossom petals floating, warm spring atmosphere, watercolor texture, dreamy composition",
          "Gentle abstract scene with nature elements, soft green and pink tones, peaceful mood, illustrated book style",
          "Warm abstract composition with rainbow colors, soft brushstrokes, happy atmosphere, storybook quality"
        ],
        'adventure' => [
          "Dynamic abstract illustration, warm sunset colors, flowing movement, energetic composition, soft digital art",
          "Abstract adventure scene with mountains and clouds, vibrant colors, exciting atmosphere, illustrated style",
          "Bold abstract composition with sky and clouds, dynamic shapes, adventure theme, soft painting"
        ],
        'fantasy' => [
          "Magical abstract garden with glowing elements, pastel purple and pink, dreamy atmosphere, fantasy illustration",
          "Ethereal abstract scene with moon and stars, soft blues and silvers, mystical mood, storybook art",
          "Abstract rainbow bridge in clouds, soft fantasy colors, magical atmosphere, illustrated style"
        ]
      },
      'japanese' => {
        'neutral' => [
          "Abstract bamboo grove illustration, soft green tones, peaceful atmosphere, minimalist storybook style",
          "Warm abstract library scene, cozy colors, soft lighting, illustrated book aesthetic",
          "Abstract autumn forest, warm orange and yellow, peaceful mood, storybook illustration"
        ],
        'adventure' => [
          "Abstract ocean waves, dynamic composition, adventure theme, soft blue tones, illustrated style",
          "Dynamic abstract sky scene, sunset colors, exciting atmosphere, storybook quality",
          "Abstract cityscape at twilight, adventure mood, soft colors, illustrated art"
        ],
        'fantasy' => [
          "Abstract cherry blossoms floating, pink petals, dreamy atmosphere, fantasy illustration",
          "Mystical abstract night sky with stars, deep blues and golds, magical mood, storybook art",
          "Abstract moonlight scene, silver and blue tones, fantasy atmosphere, illustrated style"
        ]
      },
      'western' => {
        'neutral' => [
          "Abstract autumn forest scene, warm browns and oranges, cozy atmosphere, storybook illustration",
          "Bright abstract meadow, cheerful colors, educational theme, soft illustrated style",
          "Abstract picnic scene with rainbow, happy colors, warm atmosphere, storybook quality"
        ],
        'adventure' => [
          "Abstract castle silhouette, adventure theme, warm medieval colors, illustrated style",
          "Tropical abstract island scene, adventure mood, bright colors, storybook illustration",
          "Abstract hot air balloon in clouds, adventure theme, soft sky colors, illustrated art"
        ],
        'fantasy' => [
          "Abstract magical meadow, golden hour lighting, fantasy atmosphere, soft pastel illustration",
          "Dreamy abstract castle in clouds, pink and purple sky, fairy tale mood, storybook art",
          "Abstract enchanted forest, glowing lights, magical atmosphere, illustrated fantasy style"
        ]
      }
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'abstract')
    FileUtils.mkdir_p(output_dir)
    
    # 매우 안전한 negative prompt
    negative = "people, person, human, face, body, animal, creature, character, text, logo, watermark, violent, scary, dark"
    
    success_count = 0
    total_attempts = 0
    failed_files = []
    
    ['baby', 'toddler', 'elementary'].each do |age_group|
      puts "\n→ Generating for #{age_group} age group..."
      
      age_modifier = case age_group
      when 'baby'
        "very simple shapes, soft colors, minimal detail"
      when 'toddler'
        "simple and friendly style, bright soft colors"
      else
        "detailed illustration, rich colors, sophisticated"
      end
      
      abstract_prompts.each do |culture, preferences|
        preferences.each do |preference, prompts|
          prompts.each_with_index do |base_prompt, index|
            filename = "#{culture}_#{preference}_#{age_group}_#{index + 1}.jpg"
            filepath = output_dir.join(filename)
            
            # 안전한 프롬프트
            safe_prompt = "#{base_prompt}, #{age_modifier}, high quality digital art, professional illustration, abstract storybook style"
            
            puts "  → Generating #{filename}..."
            total_attempts += 1
            
            begin
              generator.generate!(
                prompt: safe_prompt,
                filename: "abstract/#{filename}",
                width: 400,
                height: 600,
                style_preset: "DIGITAL_ART",
                negative_prompt: negative
              )
              puts "  ✓ #{filename} generated"
              success_count += 1
            rescue => e
              puts "  ✗ #{filename} failed: #{e.message[0..100]}..."
              failed_files << filename
              
              # 더 추상적인 버전으로 재시도
              if e.message.include?("policy")
                puts "  → Retrying with ultra-safe prompt..."
                ultra_safe = "Abstract geometric shapes, #{preference == 'neutral' ? 'calm' : preference == 'adventure' ? 'dynamic' : 'dreamy'} composition, soft colors, #{culture == 'korean' ? 'Asian' : culture} art influence, abstract illustration"
                
                begin
                  generator.generate!(
                    prompt: ultra_safe,
                    filename: "abstract/#{filename}",
                    width: 400,
                    height: 600,
                    style_preset: "DIGITAL_ART",
                    negative_prompt: negative
                  )
                  puts "  ✓ #{filename} generated (ultra-safe version)"
                  success_count += 1
                  failed_files.pop
                rescue => e2
                  puts "  ✗ Ultra-safe also failed"
                end
              end
            end
            
            # API 제한 방지
            sleep(2)
          end
        end
      end
    end
    
    puts "\n=== Generated #{success_count}/#{total_attempts} abstract thumbnails ==="
    
    if failed_files.any?
      puts "\n=== Failed files (#{failed_files.count}): ==="
      failed_files.each { |f| puts "  - #{f}" }
    end
  end
end
