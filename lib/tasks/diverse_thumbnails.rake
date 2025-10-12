# frozen_string_literal: true

namespace :diverse do
  desc "Generate diverse style thumbnails for different age groups"
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
    
    puts "\n=== Generating Diverse Style Thumbnails by Age Group ==="
    generator = VertexImageGenerator.new(project_id: project_id, credentials_path: cred_env)
    
    # 연령대별 다양한 스타일 프롬프트
    age_groups = {
      'baby' => { # 0-3세
        'ebook' => [
          "Simple shapes and primary colors illustration, minimalist baby book style, soft rounded edges",
          "Cute animal faces in flat design, pastel baby colors, simple geometric style",
          "Soft watercolor baby book illustration, gentle pastel tones, dreamy atmosphere"
        ],
        'storytelling' => [
          "Soft puppet show for babies, gentle pastel stage, simple shapes illustration",
          "Baby mobile style illustration with stars and moon, soft colors, minimalist",
          "Gentle nursery rhyme scene, soft watercolor style, calming colors"
        ],
        'education' => [
          "Baby sensory play illustration, high contrast shapes, primary colors",
          "Simple stacking blocks illustration, soft 3D render style, baby colors",
          "Finger painting abstract art, bright baby-safe colors, playful texture"
        ]
      },
      'toddler' => { # 4-7세
        'ebook' => [
          "Vibrant cartoon storybook illustration, Disney-inspired style, magical atmosphere",
          "Cute kawaii style illustration, Japanese anime influence, bright colors",
          "Modern vector art storybook, flat design with gradients, trendy illustration"
        ],
        'storytelling' => [
          "Colorful puppet theater, Pixar-style 3D look, bright stage lights",
          "Musical theater stage illustration, Broadway style, dramatic lighting",
          "Adventure theater scene, comic book style illustration, dynamic composition"
        ],
        'education' => [
          "STEAM learning tools illustration, modern educational style, bright colors",
          "Art class supplies in isometric style, trendy 3D illustration, vibrant",
          "Creative workshop scene, paper craft style, collage aesthetic"
        ]
      },
      'elementary' => { # 8-12세
        'ebook' => [
          "Fantasy adventure book cover, realistic digital painting style, epic scene",
          "Mystery novel illustration, graphic novel style, dramatic shadows",
          "Science fiction book art, futuristic style, neon accents on dark"
        ],
        'storytelling' => [
          "Professional theater stage, realistic lighting, dramatic atmosphere",
          "Cinema screen illustration, movie poster style, epic composition",
          "YouTube studio setup, modern content creator style, tech aesthetic"
        ],
        'education' => [
          "Digital art tablet and stylus, tech illustration style, modern design",
          "Coding and robotics theme, tech education style, futuristic elements",
          "Science lab equipment, educational poster style, detailed illustration"
        ]
      }
    }
    
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'age_groups')
    FileUtils.mkdir_p(output_dir)
    
    negative = "scary, violent, inappropriate content, text, logo, watermark"
    
    success_count = 0
    
    age_groups.each do |age_group, categories|
      puts "\n→ Generating for #{age_group} age group..."
      
      categories.each do |category, prompts|
        prompts.each_with_index do |prompt, index|
          filename = "#{age_group}_#{category}_#{index + 1}.jpg"
          filepath = output_dir.join(filename)
          
          puts "  → Generating #{filename}..."
          
          begin
            generator.generate!(
              prompt: prompt + ", high quality digital art, professional illustration",
              filename: "age_groups/#{filename}",
              width: 400,
              height: 600,
              style_preset: "DIGITAL_ART",
              negative_prompt: negative
            )
            puts "  ✓ #{filename} generated"
            success_count += 1
          rescue => e
            puts "  ✗ #{filename} failed: #{e.message}"
          end
          
          # API 제한 방지
          sleep(2)
        end
      end
    end
    
    puts "\n=== Generated #{success_count} diverse thumbnails successfully ==="
  end
end
