# frozen_string_literal: true

namespace :storybook do
  desc "Generate storybook-style thumbnails inspired by reference site"
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
    
    puts "\n=== Generating Storybook-Style Thumbnails ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 참고 사이트 스타일 분석 기반 프롬프트
    # 동화책 주제에 맞는 구체적인 장면들
    storybook_prompts = {
      'korean' => {
        'neutral' => [
          "Beautiful illustrated storybook scene, small rabbit reading under cherry blossom tree, soft pastel watercolor style, dreamy atmosphere, warm spring colors, gentle brushstrokes",
          "Whimsical illustration of forest animals having tea party, soft pastel colors, storybook art style, cozy and warm feeling, detailed background",
          "Cute bear cub learning to paint rainbows, children's book illustration, soft watercolor texture, happy and bright mood"
        ],
        'adventure' => [
          "Brave little fox on mountain adventure, illustrated storybook style, dynamic composition, warm sunset colors, soft digital painting",
          "Young tiger exploring magical forest, adventure storybook illustration, vibrant but soft colors, exciting atmosphere",
          "Little dragon learning to fly over clouds, children's adventure book art, dynamic scene, soft pastel sky"
        ],
        'fantasy' => [
          "Magical butterfly garden with glowing flowers, fantasy storybook illustration, dreamy pastel colors, ethereal atmosphere",
          "Enchanted moonlit pond with lotus flowers, fairy tale illustration, soft blues and purples, mystical mood",
          "Rainbow bridge in cloud kingdom, fantasy children's book art, soft and dreamy, magical atmosphere"
        ]
      },
      'japanese' => {
        'neutral' => [
          "Cute panda making origami in bamboo grove, soft illustration style, gentle green tones, peaceful scene, storybook quality",
          "Happy cat family in cozy library, warm illustration, soft lighting, detailed bookshelves, children's book style",
          "Friendly owl teaching in forest school, whimsical storybook art, autumn colors, warm and inviting"
        ],
        'adventure' => [
          "Little samurai mouse on epic quest, adventure illustration, dynamic but soft style, sunset backdrop",
          "Brave penguin sailing paper boat, adventure storybook scene, ocean blues, exciting composition",
          "Young ninja cat jumping over rooftops, action illustration, twilight colors, soft digital art"
        ],
        'fantasy' => [
          "Cherry blossom fairy dancing in spring, fantasy illustration, pink petals floating, dreamy atmosphere",
          "Magical koi fish flying through starry sky, fantasy storybook art, deep blues and golds, mystical scene",
          "Moon rabbit making wishes come true, fairy tale illustration, silver moonlight, magical mood"
        ]
      },
      'western' => {
        'neutral' => [
          "Little hedgehog's bakery in autumn forest, cozy storybook illustration, warm browns and oranges, detailed scene",
          "Friendly bear teaching alphabet in meadow, educational illustration, bright and cheerful, soft style",
          "Rabbit family picnic under rainbow, heartwarming scene, soft watercolor style, happy atmosphere"
        ],
        'adventure' => [
          "Young knight mouse defending cheese castle, adventure storybook, medieval setting, warm colors",
          "Pirate raccoon searching for treasure, adventure illustration, tropical island, exciting scene",
          "Explorer bunny in hot air balloon, adventure book art, clouds and sky, dynamic composition"
        ],
        'fantasy' => [
          "Unicorn meadow at golden hour, fantasy storybook illustration, magical light, soft pastels",
          "Fairy tale castle in clouds, dreamy illustration, pink and purple sky, magical atmosphere",
          "Magic wand shop in enchanted forest, fantasy scene, glowing lights, whimsical details"
        ]
      }
    }
    
    # 연령대별 스타일 조정
    age_styles = {
      'baby' => "very simple shapes, soft rounded edges, gentle colors, minimal detail",
      'toddler' => "friendly and cute style, clear shapes, bright but soft colors",
      'elementary' => "more detailed illustration, rich storytelling elements, sophisticated composition"
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'storybook')
    FileUtils.mkdir_p(output_dir)
    
    # 더 안전한 negative prompt
    negative = "realistic human faces, photographic, scary, dark, violent, text, logo, watermark"
    
    success_count = 0
    total_attempts = 0
    
    ['baby', 'toddler', 'elementary'].each do |age_group|
      puts "\n→ Generating for #{age_group} age group..."
      
      storybook_prompts.each do |culture, preferences|
        preferences.each do |preference, prompts|
          prompts.each_with_index do |base_prompt, index|
            filename = "#{culture}_#{preference}_#{age_group}_#{index + 1}.jpg"
            filepath = output_dir.join(filename)
            
            # 연령대에 맞게 조정된 프롬프트
            adjusted_prompt = "#{base_prompt}, #{age_styles[age_group]}, high quality children's book illustration, professional artwork"
            
            puts "  → Generating #{filename}..."
            total_attempts += 1
            
            begin
              generator.generate!(
                prompt: adjusted_prompt,
                filename: "storybook/#{filename}",
                width: 400,
                height: 600,
                style_preset: "DIGITAL_ART",
                negative_prompt: negative
              )
              puts "  ✓ #{filename} generated"
              success_count += 1
            rescue => e
              puts "  ✗ #{filename} failed: #{e.message}"
              
              # 실패 시 더 추상적인 프롬프트로 재시도
              if e.message.include?("policy")
                puts "  → Retrying with more abstract prompt..."
                abstract_prompt = "Beautiful children's book illustration, #{preference} theme, soft pastel colors, #{culture == 'korean' ? 'Asian' : culture} art influence, #{age_styles[age_group]}"
                
                begin
                  generator.generate!(
                    prompt: abstract_prompt,
                    filename: "storybook/#{filename}",
                    width: 400,
                    height: 600,
                    style_preset: "DIGITAL_ART",
                    negative_prompt: negative
                  )
                  puts "  ✓ #{filename} generated (abstract version)"
                  success_count += 1
                rescue => e2
                  puts "  ✗ Abstract version also failed: #{e2.message}"
                end
              end
            end
            
            # API 제한 방지
            sleep(2)
          end
        end
      end
    end
    
    puts "\n=== Generated #{success_count}/#{total_attempts} storybook thumbnails ==="
    puts "Images saved to: #{output_dir}"
  end
  
  desc "Check and list missing thumbnails"
  task check_missing: :environment do
    puts "\n=== Checking for Missing Thumbnails ==="
    
    directories = [
      'app/assets/images/generated/storybook',
      'app/assets/images/generated/cultural',
      'app/assets/images/generated/age_groups',
      'app/assets/images/generated/kids'
    ]
    
    missing_files = []
    
    directories.each do |dir|
      dir_path = Rails.root.join(dir)
      next unless Dir.exist?(dir_path)
      
      puts "\n→ Checking #{dir}..."
      
      ['baby', 'toddler', 'elementary'].each do |age|
        ['korean', 'japanese', 'western'].each do |culture|
          ['neutral', 'adventure', 'fantasy'].each do |pref|
            (1..3).each do |index|
              filename = "#{culture}_#{pref}_#{age}_#{index}.jpg"
              filepath = dir_path.join(filename)
              
              unless File.exist?(filepath)
                svg_path = dir_path.join("#{culture}_#{pref}_#{age}_#{index}.svg")
                if File.exist?(svg_path)
                  puts "  ⚠ #{filename} missing (SVG fallback exists)"
                else
                  puts "  ✗ #{filename} missing (no fallback)"
                  missing_files << "#{dir}/#{filename}"
                end
              end
            end
          end
        end
      end
    end
    
    puts "\n=== Summary ==="
    puts "Total missing files: #{missing_files.count}"
    
    if missing_files.any?
      puts "\nMissing files:"
      missing_files.each { |f| puts "  - #{f}" }
    end
  end
end
