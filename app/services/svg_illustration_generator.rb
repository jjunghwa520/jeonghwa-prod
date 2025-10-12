# frozen_string_literal: true

class SvgIllustrationGenerator
  class << self
    def hero_background
      <<~SVG
        <svg viewBox="0 0 1920 920" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice">
          <defs>
            <linearGradient id="skyGradient" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" style="stop-color:#FFE5CC;stop-opacity:1" />
              <stop offset="50%" style="stop-color:#FFD4B8;stop-opacity:1" />
              <stop offset="100%" style="stop-color:#FFC4A3;stop-opacity:1" />
            </linearGradient>
            
            <radialGradient id="sunGlow">
              <stop offset="0%" style="stop-color:#FFF9E6;stop-opacity:0.8" />
              <stop offset="50%" style="stop-color:#FFE5B4;stop-opacity:0.4" />
              <stop offset="100%" style="stop-color:#FFD4A3;stop-opacity:0" />
            </radialGradient>
            
            <filter id="softGlow">
              <feGaussianBlur stdDeviation="3"/>
            </filter>
          </defs>
          
          <!-- 하늘 배경 -->
          <rect width="1920" height="920" fill="url(#skyGradient)"/>
          
          <!-- 태양 빛 -->
          <circle cx="1600" cy="200" r="300" fill="url(#sunGlow)" opacity="0.6"/>
          
          <!-- 구름들 -->
          <g opacity="0.3">
            <ellipse cx="300" cy="150" rx="120" ry="40" fill="white" filter="url(#softGlow)"/>
            <ellipse cx="350" cy="160" rx="100" ry="35" fill="white" filter="url(#softGlow)"/>
            <ellipse cx="1400" cy="250" rx="150" ry="45" fill="white" filter="url(#softGlow)"/>
            <ellipse cx="1450" cy="260" rx="120" ry="40" fill="white" filter="url(#softGlow)"/>
          </g>
          
          <!-- 동화책 캐릭터 실루엣 (토끼, 곰, 여우) -->
          <g opacity="0.25">
            <!-- 토끼 -->
            <ellipse cx="200" cy="600" rx="40" ry="50" fill="#8B7355"/>
            <ellipse cx="200" cy="550" rx="30" ry="35" fill="#8B7355"/>
            <ellipse cx="185" cy="530" rx="8" ry="20" fill="#8B7355"/>
            <ellipse cx="215" cy="530" rx="8" ry="20" fill="#8B7355"/>
            
            <!-- 곰 -->
            <ellipse cx="400" cy="620" rx="60" ry="70" fill="#6B5D54"/>
            <ellipse cx="400" cy="560" rx="45" ry="45" fill="#6B5D54"/>
            <circle cx="375" cy="540" r="15" fill="#6B5D54"/>
            <circle cx="425" cy="540" r="15" fill="#6B5D54"/>
            
            <!-- 여우 -->
            <ellipse cx="600" cy="610" rx="45" ry="55" fill="#D2691E"/>
            <polygon points="600,560 580,530 590,570" fill="#D2691E"/>
            <polygon points="600,560 620,530 610,570" fill="#D2691E"/>
            <path d="M 640 630 Q 660 640, 670 620" stroke="#D2691E" stroke-width="15" fill="none"/>
          </g>
          
          <!-- 열린 책 모양 -->
          <g opacity="0.2" transform="translate(900, 400)">
            <!-- 왼쪽 페이지 -->
            <path d="M 0 0 Q -100 20, -150 100 L -150 300 Q -100 280, 0 300 Z" fill="#FFF8E7"/>
            <!-- 오른쪽 페이지 -->
            <path d="M 0 0 Q 100 20, 150 100 L 150 300 Q 100 280, 0 300 Z" fill="#FFF8E7"/>
            <!-- 책등 -->
            <rect x="-5" y="0" width="10" height="300" fill="#8B4513"/>
            
            <!-- 페이지 선 -->
            <path d="M -130 50 L -20 50" stroke="#E0D5C7" stroke-width="1" opacity="0.5"/>
            <path d="M -130 100 L -20 100" stroke="#E0D5C7" stroke-width="1" opacity="0.5"/>
            <path d="M -130 150 L -20 150" stroke="#E0D5C7" stroke-width="1" opacity="0.5"/>
            <path d="M 20 50 L 130 50" stroke="#E0D5C7" stroke-width="1" opacity="0.5"/>
            <path d="M 20 100 L 130 100" stroke="#E0D5C7" stroke-width="1" opacity="0.5"/>
            <path d="M 20 150 L 130 150" stroke="#E0D5C7" stroke-width="1" opacity="0.5"/>
          </g>
          
          <!-- 무지개 -->
          <g opacity="0.15">
            <path d="M 1300 400 Q 1500 200, 1700 400" stroke="#FF6B6B" stroke-width="20" fill="none"/>
            <path d="M 1300 420 Q 1500 220, 1700 420" stroke="#FFA500" stroke-width="20" fill="none"/>
            <path d="M 1300 440 Q 1500 240, 1700 440" stroke="#FFD700" stroke-width="20" fill="none"/>
            <path d="M 1300 460 Q 1500 260, 1700 460" stroke="#90EE90" stroke-width="20" fill="none"/>
            <path d="M 1300 480 Q 1500 280, 1700 480" stroke="#87CEEB" stroke-width="20" fill="none"/>
          </g>
          
          <!-- 별들과 반짝임 -->
          <g opacity="0.4">
            <circle cx="100" cy="100" r="2" fill="#FFD700">
              <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite"/>
            </circle>
            <circle cx="300" cy="80" r="2" fill="#FFD700">
              <animate attributeName="opacity" values="0.4;1;0.4" dur="2.5s" repeatCount="indefinite"/>
            </circle>
            <circle cx="500" cy="120" r="2" fill="#FFD700">
              <animate attributeName="opacity" values="0.4;1;0.4" dur="3s" repeatCount="indefinite"/>
            </circle>
            <circle cx="1700" cy="100" r="2" fill="#FFD700">
              <animate attributeName="opacity" values="0.4;1;0.4" dur="2.2s" repeatCount="indefinite"/>
            </circle>
          </g>
          
          <!-- 풍선들 -->
          <g opacity="0.3">
            <ellipse cx="1500" cy="600" rx="25" ry="35" fill="#FF6B9D"/>
            <line x1="1500" y1="635" x2="1500" y2="700" stroke="#666" stroke-width="1"/>
            
            <ellipse cx="1550" cy="580" rx="25" ry="35" fill="#4ECDC4"/>
            <line x1="1550" y1="615" x2="1550" y2="680" stroke="#666" stroke-width="1"/>
            
            <ellipse cx="1450" cy="590" rx="25" ry="35" fill="#FFE66D"/>
            <line x1="1450" y1="625" x2="1450" y2="690" stroke="#666" stroke-width="1"/>
          </g>
        </svg>
      SVG
    end

    def category_ebook
      <<~SVG
        <svg viewBox="0 0 1600 600" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice">
          <defs>
            <filter id="paperTextureEbook">
              <feTurbulence type="fractalNoise" baseFrequency="0.02" numOctaves="3" seed="5" />
              <feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.02 0"/>
            </filter>
          </defs>
          
          <!-- 배경 -->
          <rect width="1600" height="600" fill="#FFF9F0"/>
          <rect width="1600" height="600" fill="white" filter="url(#paperTextureEbook)"/>
          
          <!-- 책 페이지 레이어 -->
          <g opacity="0.2">
            <rect x="100" y="100" width="400" height="400" rx="8" fill="#E8F5E9" transform="rotate(-3 300 300)"/>
            <rect x="120" y="120" width="400" height="400" rx="8" fill="#F3E5F5" transform="rotate(-1 320 320)"/>
            <rect x="140" y="140" width="400" height="400" rx="8" fill="#E3F2FD" transform="rotate(1 340 340)"/>
            
            <!-- 책등 -->
            <rect x="90" y="100" width="20" height="400" fill="#3E4C59" opacity="0.5"/>
          </g>
          
          <!-- 점묘 텍스처 -->
          <g opacity="0.1">
            <circle cx="800" cy="200" r="2" fill="#81C784"/>
            <circle cx="850" cy="250" r="1.5" fill="#81C784"/>
            <circle cx="900" cy="180" r="2" fill="#81C784"/>
            <circle cx="820" cy="300" r="1" fill="#81C784"/>
          </g>
          
          <!-- 잉크 라인 -->
          <g opacity="0.15">
            <path d="M 1000 150 L 1400 150" stroke="#3E4C59" stroke-width="1"/>
            <path d="M 1000 200 L 1350 200" stroke="#3E4C59" stroke-width="0.5"/>
            <path d="M 1000 250 L 1380 250" stroke="#3E4C59" stroke-width="0.5"/>
          </g>
        </svg>
      SVG
    end

    def category_storytelling
      <<~SVG
        <svg viewBox="0 0 1600 600" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice">
          <defs>
            <radialGradient id="spotlight">
              <stop offset="0%" style="stop-color:#FFF3E0;stop-opacity:0.3" />
              <stop offset="100%" style="stop-color:#FFF3E0;stop-opacity:0" />
            </radialGradient>
          </defs>
          
          <!-- 배경 -->
          <rect width="1600" height="600" fill="#FFF5EE"/>
          
          <!-- 무대 커튼 -->
          <g opacity="0.2">
            <path d="M 0 0 Q 200 100, 150 600 L 0 600 Z" fill="#FF9A76"/>
            <path d="M 1600 0 Q 1400 100, 1450 600 L 1600 600 Z" fill="#FF9A76"/>
          </g>
          
          <!-- 스포트라이트 -->
          <ellipse cx="800" cy="300" rx="400" ry="200" fill="url(#spotlight)"/>
          
          <!-- 별과 리본 -->
          <g opacity="0.25">
            <!-- 별들 -->
            <polygon points="400,150 410,180 440,180 415,200 425,230 400,210 375,230 385,200 360,180 390,180" fill="#FFD93D"/>
            <polygon points="1200,100 1206,115 1221,115 1209,125 1215,140 1200,130 1185,140 1191,125 1179,115 1194,115" fill="#FFD93D"/>
            
            <!-- 리본 -->
            <path d="M 700 400 Q 750 350, 800 400 T 900 400" stroke="#FF6B9D" stroke-width="3" fill="none"/>
          </g>
          
          <!-- 부드러운 비네팅 -->
          <rect width="1600" height="600" fill="none" stroke="url(#spotlight)" stroke-width="100" opacity="0.1"/>
        </svg>
      SVG
    end

    def category_education
      <<~SVG
        <svg viewBox="0 0 1600 600" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice">
          <defs>
            <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
              <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#E0F2F1" stroke-width="0.5"/>
            </pattern>
          </defs>
          
          <!-- 배경 -->
          <rect width="1600" height="600" fill="#F5FFFA"/>
          <rect width="1600" height="600" fill="url(#grid)"/>
          
          <!-- 연필 스케치 라인 -->
          <g opacity="0.15">
            <path d="M 200 200 Q 300 180, 400 200 T 600 200" stroke="#6D4C41" stroke-width="2" fill="none" stroke-linecap="round"/>
            <path d="M 250 300 Q 350 280, 450 300 T 650 300" stroke="#795548" stroke-width="1.5" fill="none" stroke-linecap="round"/>
          </g>
          
          <!-- 색연필/파스텔 질감 -->
          <g opacity="0.2">
            <rect x="800" y="150" width="200" height="300" rx="10" fill="#B2DFDB" transform="rotate(-5 900 300)"/>
            <rect x="850" y="180" width="180" height="250" rx="10" fill="#C8E6C9" transform="rotate(3 940 305)"/>
            <rect x="900" y="200" width="150" height="200" rx="10" fill="#FFCCBC" transform="rotate(-2 975 300)"/>
          </g>
          
          <!-- 스탬프 질감 -->
          <g opacity="0.3">
            <circle cx="1200" cy="200" r="30" fill="#4DB6AC"/>
            <circle cx="1250" cy="250" r="25" fill="#81C784"/>
            <circle cx="1180" cy="280" r="20" fill="#FFB74D"/>
          </g>
          
          <!-- 물감 자국 -->
          <g opacity="0.1">
            <ellipse cx="300" cy="450" rx="80" ry="40" fill="#FF9E80" transform="rotate(-10 300 450)"/>
            <ellipse cx="400" cy="480" rx="60" ry="30" fill="#80CBC4" transform="rotate(15 400 480)"/>
          </g>
        </svg>
      SVG
    end

    def book_cover_placeholder(category = 'ebook')
      colors = {
        'ebook' => ['#E8F5E9', '#81C784', '#4CAF50'],
        'storytelling' => ['#FFF3E0', '#FFB74D', '#FF9800'],
        'education' => ['#E3F2FD', '#64B5F6', '#2196F3']
      }
      
      palette = colors[category] || colors['ebook']
      
      <<~SVG
        <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <filter id="roughPaper">
              <feTurbulence type="fractalNoise" baseFrequency="0.02" numOctaves="5" result="noise" seed="1"/>
              <feColorMatrix in="noise" type="saturate" values="0"/>
              <feComponentTransfer>
                <feFuncA type="discrete" tableValues="0 0.1 0.1 0.1 0.2 0.2 0.3 0.3 0.4 0.5"/>
              </feComponentTransfer>
              <feComposite operator="over" in2="SourceGraphic"/>
            </filter>
          </defs>
          
          <!-- 책 배경 -->
          <rect width="400" height="600" fill="#{palette[0]}" filter="url(#roughPaper)"/>
          
          <!-- 책등 -->
          <rect x="0" y="0" width="30" height="600" fill="#{palette[2]}" opacity="0.8"/>
          
          <!-- 장식 패턴 -->
          <g opacity="0.3">
            <circle cx="200" cy="150" r="60" fill="#{palette[1]}"/>
            <rect x="150" y="250" width="100" height="100" rx="10" fill="#{palette[1]}" transform="rotate(15 200 300)"/>
            <polygon points="200,400 250,450 200,500 150,450" fill="#{palette[2]}"/>
          </g>
          
          <!-- 제목 영역 -->
          <rect x="50" y="450" width="300" height="80" rx="5" fill="white" opacity="0.5"/>
        </svg>
      SVG
    end
  end

  # 다양한 아트 스타일의 동화책 썸네일 생성
  def self.generate_diverse_storybook(category, index, age_group = 'toddler')
    # 다양한 아트 스타일 정의
    art_styles = ['watercolor', 'sketch', 'cartoon', 'minimalist', 'vintage', 'geometric']
    style = art_styles[index % art_styles.length]
    
    colors = get_style_colors(style, age_group)

    case category
    when 'ebook'
      generate_styled_ebook_svg(colors, index, style)
    when 'storytelling'
      generate_styled_video_svg(colors, index, style)
    else # education
      generate_styled_education_svg(colors, index, style)
    end
  end

  private

  def self.get_style_colors(style, age_group)
    case age_group
    when 'baby'
      case style
      when 'watercolor'
        { primary: '#FFE5E5', secondary: '#E5F3FF', accent: '#FFF5E5', character: '#FFB6C1' }
      when 'sketch'
        { primary: '#F5F5F5', secondary: '#E8E8E8', accent: '#D3D3D3', character: '#A9A9A9' }
      when 'cartoon'
        { primary: '#FFB6C1', secondary: '#87CEEB', accent: '#98FB98', character: '#DDA0DD' }
      when 'minimalist'
        { primary: '#FFFFFF', secondary: '#F8F8FF', accent: '#F0F8FF', character: '#E6E6FA' }
      when 'vintage'
        { primary: '#F5DEB3', secondary: '#DEB887', accent: '#D2B48C', character: '#BC8F8F' }
      else # geometric
        { primary: '#FFE4E1', secondary: '#E0FFFF', accent: '#F0FFF0', character: '#FFF8DC' }
      end
    when 'toddler'
      case style
      when 'watercolor'
        { primary: '#FFE4B5', secondary: '#E0FFE0', accent: '#FFE4E1', character: '#87CEEB' }
      when 'sketch'
        { primary: '#F0F0F0', secondary: '#DCDCDC', accent: '#C0C0C0', character: '#808080' }
      when 'cartoon'
        { primary: '#FF6347', secondary: '#32CD32', accent: '#1E90FF', character: '#FF69B4' }
      when 'minimalist'
        { primary: '#FFFAFA', secondary: '#F5F5DC', accent: '#FDF5E6', character: '#F0F8FF' }
      when 'vintage'
        { primary: '#DEB887', secondary: '#D2691E', accent: '#CD853F', character: '#A0522D' }
      else # geometric
        { primary: '#FFD700', secondary: '#00CED1', accent: '#FF1493', character: '#32CD32' }
      end
    else # elementary
      case style
      when 'watercolor'
        { primary: '#F0E68C', secondary: '#DDA0DD', accent: '#98FB98', character: '#F4A460' }
      when 'sketch'
        { primary: '#E5E5E5', secondary: '#B8B8B8', accent: '#969696', character: '#696969' }
      when 'cartoon'
        { primary: '#4169E1', secondary: '#FF4500', accent: '#228B22', character: '#DC143C' }
      when 'minimalist'
        { primary: '#F8F8FF', secondary: '#E6E6FA', accent: '#D8BFD8', character: '#DDA0DD' }
      when 'vintage'
        { primary: '#CD853F', secondary: '#A0522D', accent: '#8B4513', character: '#654321' }
      else # geometric
        { primary: '#FF6B35', secondary: '#004E89', accent: '#1A936F', character: '#88498F' }
      end
    end
  end

  def self.generate_styled_ebook_svg(colors, index, style)
    case style
    when 'watercolor'
      generate_watercolor_ebook_svg(colors, index)
    when 'sketch'
      generate_sketch_ebook_svg(colors, index)
    when 'cartoon'
      generate_cartoon_ebook_svg(colors, index)
    when 'minimalist'
      generate_minimalist_ebook_svg(colors, index)
    when 'vintage'
      generate_vintage_ebook_svg(colors, index)
    else # geometric
      generate_geometric_ebook_svg(colors, index)
    end
  end

  def self.generate_watercolor_ebook_svg(colors, index)
    <<~SVG
      <svg viewBox="0 0 300 400" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <filter id="watercolor">
            <feTurbulence baseFrequency="0.04" numOctaves="3"/>
            <feDisplacementMap in="SourceGraphic" scale="8"/>
          </filter>
        </defs>
        <rect width="300" height="400" fill="#{colors[:primary]}" filter="url(#watercolor)"/>
        <circle cx="150" cy="200" r="80" fill="#{colors[:character]}" opacity="0.8" filter="url(#watercolor)"/>
        <rect x="100" y="320" width="100" height="60" fill="#{colors[:accent]}" opacity="0.7"/>
        <text x="150" y="350" text-anchor="middle" font-family="serif" font-size="14" fill="#{colors[:secondary]}">수채화 동화</text>
      </svg>
    SVG
  end

  def self.generate_sketch_ebook_svg(colors, index)
    <<~SVG
      <svg viewBox="0 0 300 400" xmlns="http://www.w3.org/2000/svg">
        <rect width="300" height="400" fill="#{colors[:primary]}" stroke="#{colors[:character]}" stroke-width="2"/>
        <path d="M50 100 Q150 50 250 100 Q200 200 150 180 Q100 200 50 100" fill="none" stroke="#{colors[:character]}" stroke-width="3"/>
        <circle cx="150" cy="200" r="60" fill="none" stroke="#{colors[:character]}" stroke-width="2" stroke-dasharray="5,5"/>
        <text x="150" y="350" text-anchor="middle" font-family="monospace" font-size="14" fill="#{colors[:character]}">스케치 동화</text>
      </svg>
    SVG
  end

  def self.generate_cartoon_ebook_svg(colors, index)
    <<~SVG
      <svg viewBox="0 0 300 400" xmlns="http://www.w3.org/2000/svg">
        <rect width="300" height="400" fill="#{colors[:primary]}"/>
        <circle cx="150" cy="150" r="50" fill="#{colors[:character]}" stroke="#000" stroke-width="3"/>
        <circle cx="135" cy="140" r="8" fill="#000"/>
        <circle cx="165" cy="140" r="8" fill="#000"/>
        <path d="M130 170 Q150 180 170 170" fill="none" stroke="#000" stroke-width="3"/>
        <rect x="100" y="250" width="100" height="80" fill="#{colors[:accent]}" stroke="#000" stroke-width="3"/>
        <text x="150" y="350" text-anchor="middle" font-family="comic sans ms" font-size="16" fill="#000">만화 동화</text>
      </svg>
    SVG
  end

  def self.generate_minimalist_ebook_svg(colors, index)
    <<~SVG
      <svg viewBox="0 0 300 400" xmlns="http://www.w3.org/2000/svg">
        <rect width="300" height="400" fill="#{colors[:primary]}"/>
        <rect x="100" y="150" width="100" height="100" fill="#{colors[:character]}"/>
        <line x1="50" y1="300" x2="250" y2="300" stroke="#{colors[:accent]}" stroke-width="1"/>
        <text x="150" y="350" text-anchor="middle" font-family="helvetica" font-size="12" fill="#{colors[:character]}">미니멀 동화</text>
      </svg>
    SVG
  end

  def self.generate_vintage_ebook_svg(colors, index)
    <<~SVG
      <svg viewBox="0 0 300 400" xmlns="http://www.w3.org/2000/svg">
        <rect width="300" height="400" fill="#{colors[:primary]}"/>
        <rect x="20" y="20" width="260" height="360" fill="none" stroke="#{colors[:character]}" stroke-width="4"/>
        <rect x="40" y="40" width="220" height="320" fill="none" stroke="#{colors[:accent]}" stroke-width="2"/>
        <circle cx="150" cy="200" r="70" fill="#{colors[:character]}" opacity="0.8"/>
        <text x="150" y="350" text-anchor="middle" font-family="times" font-size="14" fill="#{colors[:character]}">빈티지 동화</text>
      </svg>
    SVG
  end

  def self.generate_geometric_ebook_svg(colors, index)
    <<~SVG
      <svg viewBox="0 0 300 400" xmlns="http://www.w3.org/2000/svg">
        <rect width="300" height="400" fill="#{colors[:primary]}"/>
        <polygon points="150,100 200,150 150,200 100,150" fill="#{colors[:character]}"/>
        <rect x="100" y="250" width="100" height="50" fill="#{colors[:accent]}"/>
        <polygon points="75,350 150,300 225,350" fill="#{colors[:secondary]}"/>
        <text x="150" y="380" text-anchor="middle" font-family="arial" font-size="12" fill="#{colors[:character]}">기하학 동화</text>
      </svg>
    SVG
  end

  def self.generate_styled_video_svg(colors, index, style)
    # 비슷한 패턴으로 비디오용 SVG 생성
    generate_styled_ebook_svg(colors, index, style)
  end

  def self.generate_styled_education_svg(colors, index, style)
    # 비슷한 패턴으로 교육용 SVG 생성  
    generate_styled_ebook_svg(colors, index, style)
  end
end
