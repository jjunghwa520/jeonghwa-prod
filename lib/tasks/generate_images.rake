# frozen_string_literal: true

namespace :images do
  desc "Generate high-quality images using multiple sources"
  task generate: :environment do
    puts "\n=== 고품질 이미지 생성 시작 ==="
    
    # 1. SVG 일러스트레이션 생성
    puts "\n→ SVG 일러스트레이션 생성 중..."
    generate_svg_illustrations
    
    # 2. Unsplash API로 실제 이미지 다운로드 시도
    if ENV['UNSPLASH_ACCESS_KEY']
      puts "\n→ Unsplash에서 고품질 이미지 다운로드 중..."
      downloader = UnsplashImageDownloader.new
      downloader.download_curated_images
    else
      puts "\n→ Unsplash API 키가 없어 SVG만 생성합니다."
      puts "  고품질 사진을 원하시면 UNSPLASH_ACCESS_KEY를 설정하세요."
    end
    
    # 3. 커스텀 썸네일 생성
    puts "\n→ 카테고리별 썸네일 생성 중..."
    generate_course_thumbnails
    
    puts "\n=== 이미지 생성 완료 ==="
    puts "생성된 이미지들: app/assets/images/generated/"
  end

  def generate_svg_illustrations
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated')
    FileUtils.mkdir_p(output_dir)
    
    # 메인 배너 및 카테고리 이미지
    images = {
      'hero_main.svg' => SvgIllustrationGenerator.hero_background,
      'category_ebook.svg' => SvgIllustrationGenerator.category_ebook,
      'category_storytelling.svg' => SvgIllustrationGenerator.category_storytelling,
      'category_education.svg' => SvgIllustrationGenerator.category_education
    }
    
    images.each do |filename, content|
      path = output_dir.join(filename)
      File.write(path, content)
      puts "  ✓ #{filename} 생성 완료"
    end
  end

  def generate_course_thumbnails
    output_dir = Rails.root.join('app', 'assets', 'images', 'generated', 'thumbnails')
    FileUtils.mkdir_p(output_dir)
    
    # 각 카테고리별로 6개씩 썸네일 생성
    categories = ['ebook', 'storytelling', 'education']
    
    categories.each do |category|
      6.times do |i|
        filename = "#{category}_#{i + 1}.svg"
        path = output_dir.join(filename)
        
        # 각 썸네일마다 약간 다른 시드값으로 변형
        svg_content = generate_unique_thumbnail(category, i)
        File.write(path, svg_content)
        puts "  ✓ #{filename} 생성 완료"
      end
    end
  end

  def generate_unique_thumbnail(category, index)
    colors = {
      'ebook' => [
        ['#FFE5CC', '#FFD4B8', '#FF9A76'],
        ['#E3F2FD', '#B3E5FC', '#4FC3F7'],
        ['#F3E5F5', '#E1BEE7', '#BA68C8'],
        ['#FFF3E0', '#FFE0B2', '#FFB74D'],
        ['#FCE4EC', '#F8BBD0', '#F06292'],
        ['#E0F7FA', '#B2EBF2', '#4DD0E1']
      ],
      'storytelling' => [
        ['#FFF3E0', '#FFCC80', '#FF9800'],
        ['#FFEBEE', '#FFCDD2', '#EF5350'],
        ['#FCE4EC', '#F8BBD0', '#F06292'],
        ['#F3E5F5', '#E1BEE7', '#BA68C8'],
        ['#EDE7F6', '#D1C4E9', '#9575CD'],
        ['#E8EAF6', '#C5CAE9', '#7986CB']
      ],
      'education' => [
        ['#E0F7FA', '#B2EBF2', '#4DD0E1'],
        ['#E8F5E9', '#C8E6C9', '#81C784'],
        ['#F1F8E9', '#DCEDC8', '#AED581'],
        ['#F9FBE7', '#F0F4C3', '#DCE775'],
        ['#FFF9C4', '#FFF59D', '#FFF176'],
        ['#FFF3E0', '#FFE0B2', '#FFB74D']
      ]
    }
    
    palette = colors[category][index % 6]
    characters = generate_storybook_characters(category, index)
    
    <<~SVG
      <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <radialGradient id="bgGrad#{index}">
            <stop offset="0%" style="stop-color:#{palette[0]};stop-opacity:1" />
            <stop offset="100%" style="stop-color:#{palette[1]};stop-opacity:1" />
          </radialGradient>
          
          <filter id="softShadow#{index}">
            <feGaussianBlur in="SourceAlpha" stdDeviation="3"/>
            <feOffset dx="2" dy="2" result="offsetblur"/>
            <feComponentTransfer>
              <feFuncA type="linear" slope="0.2"/>
            </feComponentTransfer>
            <feMerge>
              <feMergeNode/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
          
          <pattern id="sparkles#{index}" x="0" y="0" width="50" height="50" patternUnits="userSpaceOnUse">
            <circle cx="10" cy="10" r="1" fill="white" opacity="0.5">
              <animate attributeName="opacity" values="0;1;0" dur="#{2 + index * 0.3}s" repeatCount="indefinite"/>
            </circle>
            <circle cx="35" cy="25" r="1" fill="white" opacity="0.5">
              <animate attributeName="opacity" values="0;1;0" dur="#{2.5 + index * 0.2}s" repeatCount="indefinite"/>
            </circle>
            <circle cx="25" cy="40" r="1" fill="white" opacity="0.5">
              <animate attributeName="opacity" values="0;1;0" dur="#{3 + index * 0.4}s" repeatCount="indefinite"/>
            </circle>
          </pattern>
        </defs>
        
        <!-- 배경 -->
        <rect width="400" height="600" fill="url(#bgGrad#{index})"/>
        <rect width="400" height="600" fill="url(#sparkles#{index})" opacity="0.6"/>
        
        <!-- 구름 배경 -->
        <ellipse cx="100" cy="100" rx="60" ry="30" fill="white" opacity="0.2"/>
        <ellipse cx="320" cy="150" rx="70" ry="35" fill="white" opacity="0.15"/>
        
        <!-- 책 표지 프레임 -->
        <rect x="20" y="20" width="360" height="560" rx="15" fill="none" stroke="#{palette[2]}" stroke-width="4" opacity="0.3"/>
        
        <!-- 동화 캐릭터/일러스트 -->
        #{characters}
        
        <!-- 장식 요소들 -->
        <g opacity="0.4">
          #{generate_storybook_decorations(index, palette)}
        </g>
        
        <!-- 제목 영역 -->
        <rect x="40" y="480" width="320" height="80" rx="10" fill="white" opacity="0.8" filter="url(#softShadow#{index})"/>
        
        <!-- 카테고리 배지 -->
        <circle cx="350" cy="50" r="25" fill="#{palette[2]}" opacity="0.8"/>
        <text x="350" y="55" text-anchor="middle" fill="white" font-size="20" font-weight="bold">#{index + 1}</text>
      </svg>
    SVG
  end

  def generate_storybook_characters(category, index)
    if category == 'ebook'
      # 전자책: 책 읽는 동물들
      case index % 6
      when 0
        # 책 읽는 토끼
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="50" ry="60" fill="#8B7355" opacity="0.7"/>
            <ellipse cx="0" cy="-40" rx="35" ry="40" fill="#8B7355" opacity="0.7"/>
            <ellipse cx="-15" cy="-60" rx="10" ry="25" fill="#8B7355" opacity="0.7"/>
            <ellipse cx="15" cy="-60" rx="10" ry="25" fill="#8B7355" opacity="0.7"/>
            <rect x="-30" y="-10" width="60" height="40" rx="5" fill="#4A90E2" opacity="0.5"/>
            <circle cx="-10" cy="-35" r="3" fill="black"/>
            <circle cx="10" cy="-35" r="3" fill="black"/>
          </g>
        SVG
      when 1
        # 안경 쓴 부엉이
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="60" ry="70" fill="#6B5D54" opacity="0.7"/>
            <ellipse cx="0" cy="-35" rx="45" ry="45" fill="#6B5D54" opacity="0.7"/>
            <circle cx="-15" cy="-35" r="15" fill="white" opacity="0.8"/>
            <circle cx="15" cy="-35" r="15" fill="white" opacity="0.8"/>
            <circle cx="-15" cy="-35" r="8" fill="black"/>
            <circle cx="15" cy="-35" r="8" fill="black"/>
            <path d="M -30 -35 L 30 -35" stroke="black" stroke-width="2" fill="none"/>
            <polygon points="0,-20 -5,-10 5,-10" fill="#FFA500" opacity="0.8"/>
          </g>
        SVG
      when 2
        # 책 든 여우
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="45" ry="65" fill="#D2691E" opacity="0.7"/>
            <polygon points="0,-40 -20,-70 -10,-30" fill="#D2691E" opacity="0.7"/>
            <polygon points="0,-40 20,-70 10,-30" fill="#D2691E" opacity="0.7"/>
            <path d="M 30 20 Q 50 30, 60 10" stroke="#D2691E" stroke-width="15" fill="none" opacity="0.7"/>
            <rect x="-25" y="-5" width="50" height="35" rx="3" fill="#2ECC71" opacity="0.6"/>
            <circle cx="-8" cy="-25" r="3" fill="black"/>
            <circle cx="8" cy="-25" r="3" fill="black"/>
          </g>
        SVG
      when 3
        # 펜 든 고양이
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="50" ry="60" fill="#808080" opacity="0.7"/>
            <ellipse cx="0" cy="-35" rx="40" ry="35" fill="#808080" opacity="0.7"/>
            <polygon points="-25,-50 -20,-70 -10,-55" fill="#808080" opacity="0.7"/>
            <polygon points="25,-50 20,-70 10,-55" fill="#808080" opacity="0.7"/>
            <path d="M 35 10 Q 55 15, 65 5" stroke="#808080" stroke-width="12" fill="none" opacity="0.7"/>
            <rect x="20" y="-10" width="5" height="40" rx="2" fill="#8B4513" opacity="0.8"/>
            <polygon points="22.5,-10 20,-15 25,-15" fill="#FFD700" opacity="0.8"/>
          </g>
        SVG
      when 4
        # 책 위의 나비
        <<~SVG
          <g transform="translate(200, 250)">
            <rect x="-60" y="20" width="120" height="80" rx="5" fill="#8B4513" opacity="0.6"/>
            <rect x="-55" y="25" width="110" height="70" rx="3" fill="#FFF8DC" opacity="0.8"/>
            <ellipse cx="0" cy="-20" rx="30" ry="40" fill="#FF69B4" opacity="0.6" transform="rotate(-20 0 -20)"/>
            <ellipse cx="0" cy="-20" rx="30" ry="40" fill="#FF69B4" opacity="0.6" transform="rotate(20 0 -20)"/>
            <ellipse cx="0" cy="-10" rx="5" ry="15" fill="#4B0082" opacity="0.8"/>
          </g>
        SVG
      else
        # 별과 달
        <<~SVG
          <g transform="translate(200, 250)">
            <path d="M 0 -50 Q -30 -50, -30 -20 Q -10 -40, 0 -50" fill="#FFD700" opacity="0.7"/>
            <polygon points="0,20 10,50 -5,30 5,30 -10,50" fill="#FFD700" opacity="0.6"/>
            <polygon points="-50,0 -40,30 -55,10 -45,10 -60,30" fill="#FFD700" opacity="0.5"/>
            <polygon points="50,0 60,30 45,10 55,10 40,30" fill="#FFD700" opacity="0.5"/>
          </g>
        SVG
      end
    elsif category == 'storytelling'
      # 구연동화: 무대와 캐릭터
      case index % 6
      when 0
        # 무대 위 곰
        <<~SVG
          <g transform="translate(200, 250)">
            <rect x="-100" y="50" width="200" height="10" fill="#8B4513" opacity="0.5"/>
            <ellipse cx="0" cy="0" rx="60" ry="70" fill="#8B4513" opacity="0.7"/>
            <ellipse cx="0" cy="-45" rx="45" ry="45" fill="#8B4513" opacity="0.7"/>
            <circle cx="-20" cy="-45" r="15" fill="#8B4513" opacity="0.7"/>
            <circle cx="20" cy="-45" r="15" fill="#8B4513" opacity="0.7"/>
            <path d="M -60 -20 Q -80 -10, -70 10" stroke="#8B4513" stroke-width="20" fill="none" opacity="0.7"/>
            <path d="M 60 -20 Q 80 -10, 70 10" stroke="#8B4513" stroke-width="20" fill="none" opacity="0.7"/>
          </g>
        SVG
      when 1
        # 왕관 쓴 사자
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="65" ry="75" fill="#FFA500" opacity="0.7"/>
            <ellipse cx="0" cy="-40" rx="50" ry="50" fill="#FFA500" opacity="0.7"/>
            <polygon points="-30,-70 -20,-90 -10,-70 0,-90 10,-70 20,-90 30,-70" fill="#FFD700" opacity="0.8"/>
            <circle cx="-45" cy="-30" r="35" fill="#FF8C00" opacity="0.5"/>
            <circle cx="45" cy="-30" r="35" fill="#FF8C00" opacity="0.5"/>
            <circle cx="0" cy="-10" r="30" fill="#FF8C00" opacity="0.5"/>
          </g>
        SVG
      when 2
        # 마술 모자와 토끼
        <<~SVG
          <g transform="translate(200, 250)">
            <rect x="-40" y="-20" width="80" height="60" fill="#000" opacity="0.7"/>
            <ellipse cx="0" cy="-20" rx="50" ry="10" fill="#000" opacity="0.7"/>
            <ellipse cx="0" cy="20" rx="50" ry="10" fill="#000" opacity="0.7"/>
            <ellipse cx="0" cy="0" rx="25" ry="30" fill="white" opacity="0.8"/>
            <ellipse cx="-8" cy="-20" rx="5" ry="15" fill="white" opacity="0.8"/>
            <ellipse cx="8" cy="-20" rx="5" ry="15" fill="white" opacity="0.8"/>
          </g>
        SVG
      when 3
        # 춤추는 발레리나 백조
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="40" ry="50" fill="white" opacity="0.8"/>
            <path d="M 0 -30 Q 20 -60, 10 -80" stroke="white" stroke-width="15" fill="none" opacity="0.8"/>
            <ellipse cx="10" cy="-80" rx="15" ry="20" fill="white" opacity="0.8"/>
            <path d="M -30 20 Q -50 30, -60 40" stroke="white" stroke-width="10" fill="none" opacity="0.8"/>
            <path d="M 30 20 Q 50 30, 60 40" stroke="white" stroke-width="10" fill="none" opacity="0.8"/>
            <polygon points="0,50 -30,80 30,80" fill="#FFB6C1" opacity="0.6"/>
          </g>
        SVG
      when 4
        # 서커스 코끼리
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="70" ry="80" fill="#808080" opacity="0.7"/>
            <path d="M 0 -30 Q 30 -20, 35 10" stroke="#808080" stroke-width="25" fill="none" opacity="0.7"/>
            <ellipse cx="-50" cy="-20" rx="30" ry="40" fill="#808080" opacity="0.6"/>
            <ellipse cx="50" cy="-20" rx="30" ry="40" fill="#808080" opacity="0.6"/>
            <circle cx="0" cy="80" r="30" fill="#FF1493" opacity="0.6"/>
          </g>
        SVG
      else
        # 별 무대
        <<~SVG
          <g transform="translate(200, 250)">
            <polygon points="0,-60 20,-20 60,-10 30,20 40,60 0,40 -40,60 -30,20 -60,-10 -20,-20" fill="#FFD700" opacity="0.6"/>
            <polygon points="0,-30 10,-10 30,-5 15,10 20,30 0,20 -20,30 -15,10 -30,-5 -10,-10" fill="#FFA500" opacity="0.8"/>
          </g>
        SVG
      end
    else
      # 교육: 창작 도구들
      case index % 6
      when 0
        # 팔레트와 붓
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="0" cy="0" rx="80" ry="60" fill="#8B4513" opacity="0.6"/>
            <circle cx="-30" cy="-20" r="15" fill="#FF0000" opacity="0.7"/>
            <circle cx="0" cy="-20" r="15" fill="#00FF00" opacity="0.7"/>
            <circle cx="30" cy="-20" r="15" fill="#0000FF" opacity="0.7"/>
            <circle cx="-15" cy="10" r="15" fill="#FFFF00" opacity="0.7"/>
            <circle cx="15" cy="10" r="15" fill="#FF00FF" opacity="0.7"/>
            <rect x="60" y="-40" width="8" height="80" rx="4" fill="#8B4513" opacity="0.8"/>
            <ellipse cx="64" cy="-50" rx="10" ry="15" fill="#FF69B4" opacity="0.8"/>
          </g>
        SVG
      when 1
        # 연필과 지우개
        <<~SVG
          <g transform="translate(200, 250)">
            <rect x="-10" y="-60" width="20" height="120" fill="#FFD700" opacity="0.8"/>
            <polygon points="-10,-60 0,-80 10,-60" fill="#FFC0CB" opacity="0.8"/>
            <polygon points="-10,60 0,75 10,60" fill="#000" opacity="0.8"/>
            <rect x="30" y="-30" width="15" height="60" fill="#FF69B4" opacity="0.7"/>
            <rect x="30" y="-40" width="15" height="10" fill="#C0C0C0" opacity="0.8"/>
          </g>
        SVG
      when 2
        # 가위와 풀
        <<~SVG
          <g transform="translate(200, 250)">
            <ellipse cx="-20" cy="-20" rx="25" ry="40" fill="none" stroke="#C0C0C0" stroke-width="5" opacity="0.8" transform="rotate(-30 -20 -20)"/>
            <ellipse cx="20" cy="-20" rx="25" ry="40" fill="none" stroke="#C0C0C0" stroke-width="5" opacity="0.8" transform="rotate(30 20 -20)"/>
            <circle cx="-20" cy="30" r="8" fill="#FF0000" opacity="0.7"/>
            <circle cx="20" cy="30" r="8" fill="#FF0000" opacity="0.7"/>
            <rect x="-50" y="50" width="30" height="40" rx="5" fill="#4169E1" opacity="0.7"/>
            <rect x="-45" y="45" width="20" height="10" fill="white" opacity="0.8"/>
          </g>
        SVG
      when 3
        # 크레용 세트
        <<~SVG
          <g transform="translate(200, 250)">
            <rect x="-30" y="-40" width="10" height="80" fill="#FF0000" opacity="0.8" transform="rotate(-10 -25 0)"/>
            <rect x="-10" y="-40" width="10" height="80" fill="#FFA500" opacity="0.8" transform="rotate(-5 -5 0)"/>
            <rect x="10" y="-40" width="10" height="80" fill="#FFFF00" opacity="0.8" transform="rotate(5 15 0)"/>
            <rect x="30" y="-40" width="10" height="80" fill="#00FF00" opacity="0.8" transform="rotate(10 35 0)"/>
            <polygon points="-27,-42 -25,-50 -23,-42" fill="#8B0000" opacity="0.8" transform="rotate(-10 -25 0)"/>
            <polygon points="-7,-42 -5,-50 -3,-42" fill="#FF4500" opacity="0.8" transform="rotate(-5 -5 0)"/>
            <polygon points="13,-42 15,-50 17,-42" fill="#FFD700" opacity="0.8" transform="rotate(5 15 0)"/>
            <polygon points="33,-42 35,-50 37,-42" fill="#006400" opacity="0.8" transform="rotate(10 35 0)"/>
          </g>
        SVG
      when 4
        # 종이 비행기
        <<~SVG
          <g transform="translate(200, 250)">
            <polygon points="0,-60 -80,20 0,-20 80,20" fill="white" opacity="0.8" stroke="#4169E1" stroke-width="2"/>
            <polygon points="0,-20 -40,40 0,0 40,40" fill="#87CEEB" opacity="0.6"/>
            <path d="M 0 -60 L 0 0" stroke="#4169E1" stroke-width="2" fill="none"/>
          </g>
        SVG
      else
        # 무지개 연필
        <<~SVG
          <g transform="translate(200, 250)">
            <rect x="-15" y="-60" width="30" height="120" fill="url(#rainbow)" opacity="0.8"/>
            <defs>
              <linearGradient id="rainbow" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#FF0000;stop-opacity:1" />
                <stop offset="16.66%" style="stop-color:#FFA500;stop-opacity:1" />
                <stop offset="33.33%" style="stop-color:#FFFF00;stop-opacity:1" />
                <stop offset="50%" style="stop-color:#00FF00;stop-opacity:1" />
                <stop offset="66.66%" style="stop-color:#0000FF;stop-opacity:1" />
                <stop offset="83.33%" style="stop-color:#4B0082;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#8B00FF;stop-opacity:1" />
              </linearGradient>
            </defs>
            <polygon points="-15,60 0,75 15,60" fill="#4B0082" opacity="0.8"/>
            <polygon points="-15,-60 0,-75 15,-60" fill="#FFB6C1" opacity="0.8"/>
          </g>
        SVG
      end
    end
  end

  def generate_storybook_decorations(index, palette)
    case index % 4
    when 0
      # 별과 하트
      <<~SVG
        <polygon points="50,50 55,65 70,65 58,75 63,90 50,80 37,90 42,75 30,65 45,65" fill="#{palette[2]}" opacity="0.3"/>
        <path d="M 320 50 C 320 40, 330 30, 340 40 C 350 30, 360 40, 360 50 Q 340 70, 340 80 Q 340 70, 320 50 Z" fill="#FF69B4" opacity="0.3"/>
      SVG
    when 1
      # 구름과 무지개
      <<~SVG
        <ellipse cx="60" cy="400" rx="40" ry="20" fill="white" opacity="0.3"/>
        <ellipse cx="90" cy="405" rx="35" ry="18" fill="white" opacity="0.25"/>
        <path d="M 250 100 Q 300 50, 350 100" stroke="#{palette[2]}" stroke-width="3" fill="none" opacity="0.3"/>
        <path d="M 250 110 Q 300 60, 350 110" stroke="#{palette[1]}" stroke-width="3" fill="none" opacity="0.3"/>
      SVG
    when 2
      # 꽃과 나비
      <<~SVG
        <circle cx="70" cy="420" r="15" fill="#{palette[1]}" opacity="0.3"/>
        <circle cx="55" cy="410" r="12" fill="#{palette[1]}" opacity="0.25"/>
        <circle cx="85" cy="410" r="12" fill="#{palette[1]}" opacity="0.25"/>
        <circle cx="55" cy="430" r="12" fill="#{palette[1]}" opacity="0.25"/>
        <circle cx="85" cy="430" r="12" fill="#{palette[1]}" opacity="0.25"/>
        <ellipse cx="320" cy="400" rx="15" ry="20" fill="#{palette[2]}" opacity="0.3" transform="rotate(-20 320 400)"/>
        <ellipse cx="320" cy="400" rx="15" ry="20" fill="#{palette[2]}" opacity="0.3" transform="rotate(20 320 400)"/>
      SVG
    else
      # 음표와 리본
      <<~SVG
        <ellipse cx="80" cy="80" rx="8" ry="12" fill="#{palette[2]}" opacity="0.3"/>
        <rect x="87" y="70" width="3" height="30" fill="#{palette[2]}" opacity="0.3"/>
        <path d="M 87 70 Q 95 65, 100 70" stroke="#{palette[2]}" stroke-width="2" fill="none" opacity="0.3"/>
        <path d="M 280 420 Q 300 410, 320 420 T 360 420" stroke="#{palette[1]}" stroke-width="4" fill="none" opacity="0.3"/>
      SVG
    end
  end

  def generate_decorative_elements(index, color)
    patterns = [
      # 원형 패턴
      <<~PATTERN,
        <circle cx="200" cy="200" r="80" fill="#{color}" opacity="0.3"/>
        <circle cx="250" cy="250" r="60" fill="#{color}" opacity="0.2"/>
        <circle cx="150" cy="150" r="40" fill="#{color}" opacity="0.3"/>
      PATTERN
      
      # 사각형 패턴
      <<~PATTERN,
        <rect x="120" y="150" width="160" height="160" rx="20" fill="#{color}" opacity="0.3" transform="rotate(15 200 230)"/>
        <rect x="150" y="180" width="100" height="100" rx="15" fill="#{color}" opacity="0.2" transform="rotate(-10 200 230)"/>
      PATTERN
      
      # 다각형 패턴
      <<~PATTERN,
        <polygon points="200,100 280,200 240,320 160,320 120,200" fill="#{color}" opacity="0.3"/>
        <polygon points="200,150 250,200 230,270 170,270 150,200" fill="#{color}" opacity="0.2"/>
      PATTERN
      
      # 물결 패턴
      <<~PATTERN,
        <path d="M 100 250 Q 150 200, 200 250 T 300 250" stroke="#{color}" stroke-width="20" fill="none" opacity="0.3"/>
        <path d="M 100 300 Q 150 250, 200 300 T 300 300" stroke="#{color}" stroke-width="15" fill="none" opacity="0.2"/>
      PATTERN
      
      # 별 패턴
      <<~PATTERN,
        <polygon points="200,120 220,180 280,180 230,220 250,280 200,240 150,280 170,220 120,180 180,180" fill="#{color}" opacity="0.3"/>
      PATTERN
      
      # 나선 패턴
      <<~PATTERN
        <path d="M 200 200 Q 250 150, 300 200 T 200 300 Q 150 250, 200 200" stroke="#{color}" stroke-width="15" fill="none" opacity="0.3"/>
      PATTERN
    ]
    
    patterns[index % patterns.length]
  end
end
