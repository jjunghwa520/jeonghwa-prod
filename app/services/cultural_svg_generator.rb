# frozen_string_literal: true

class CulturalSvgGenerator
  class << self
    def generate(culture, preference, age_group)
      case culture
      when 'korean'
        korean_style(preference, age_group)
      when 'japanese'
        japanese_style(preference, age_group)
      when 'western'
        western_style(preference, age_group)
      else
        default_style(preference, age_group)
      end
    end
    
    private
    
    def korean_style(preference, age_group)
      colors = {
        'neutral' => ['#8B4513', '#D2691E', '#F4A460', '#FFF8DC'],
        'adventure' => ['#DC143C', '#FF6347', '#FFD700', '#8B0000'],
        'fantasy' => ['#FFB6C1', '#FFC0CB', '#E6E6FA', '#DDA0DD']
      }
      
      palette = colors[preference] || colors['neutral']
      
      <<~SVG
        <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="hanji" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
              <rect width="40" height="40" fill="#{palette[3]}" opacity="0.3"/>
              <circle cx="20" cy="20" r="15" fill="none" stroke="#{palette[0]}" stroke-width="0.5" opacity="0.2"/>
            </pattern>
            <linearGradient id="koreanGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" style="stop-color:#{palette[0]};stop-opacity:0.8" />
              <stop offset="100%" style="stop-color:#{palette[1]};stop-opacity:0.8" />
            </linearGradient>
          </defs>
          
          <!-- 한지 텍스처 배경 -->
          <rect width="400" height="600" fill="#{palette[3]}"/>
          <rect width="400" height="600" fill="url(#hanji)"/>
          
          <!-- 전통 문양 -->
          <g transform="translate(200, 300)">
            <!-- 태극 모양 간소화 -->
            <circle cx="0" cy="-50" r="40" fill="#{palette[0]}" opacity="0.6"/>
            <circle cx="0" cy="50" r="40" fill="#{palette[1]}" opacity="0.6"/>
            
            <!-- 전통 구름 문양 -->
            <path d="M -100 0 Q -80 -20, -60 0 T -20 0 T 20 0 T 60 0 T 100 0" 
                  stroke="#{palette[2]}" stroke-width="3" fill="none" opacity="0.5"/>
            
            #{preference == 'adventure' ? adventure_elements(palette) : ''}
            #{preference == 'fantasy' ? fantasy_elements(palette) : ''}
          </g>
          
          <!-- 연령대별 단순화 -->
          #{age_simplification(age_group)}
        </svg>
      SVG
    end
    
    def japanese_style(preference, age_group)
      colors = {
        'neutral' => ['#FF69B4', '#FFB6C1', '#FFF0F5', '#FFE4E1'],
        'adventure' => ['#FF4500', '#FF6347', '#FFD700', '#DC143C'],
        'fantasy' => ['#9370DB', '#DA70D6', '#DDA0DD', '#E6E6FA']
      }
      
      palette = colors[preference] || colors['neutral']
      
      <<~SVG
        <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <radialGradient id="japaneseGrad">
              <stop offset="0%" style="stop-color:#{palette[3]};stop-opacity:1" />
              <stop offset="100%" style="stop-color:#{palette[2]};stop-opacity:1" />
            </radialGradient>
          </defs>
          
          <!-- 배경 -->
          <rect width="400" height="600" fill="url(#japaneseGrad)"/>
          
          <!-- 벚꽃 패턴 -->
          <g>
            #{(0..5).map { |i| sakura_flower(50 + i * 60, 100 + i * 80, palette[0], 20 + i * 5) }.join}
          </g>
          
          <!-- 중앙 캐릭터 실루엣 -->
          <g transform="translate(200, 300)">
            #{preference == 'adventure' ? manga_action_silhouette(palette) : ''}
            #{preference == 'fantasy' ? magical_girl_silhouette(palette) : ''}
            #{preference == 'neutral' ? kawaii_character(palette) : ''}
          </g>
          
          <!-- 만화 효과선 -->
          #{preference == 'adventure' ? speed_lines(palette[1]) : ''}
          
          #{age_simplification(age_group)}
        </svg>
      SVG
    end
    
    def western_style(preference, age_group)
      colors = {
        'neutral' => ['#4169E1', '#87CEEB', '#F0E68C', '#FFFACD'],
        'adventure' => ['#FF0000', '#0000FF', '#FFD700', '#228B22'],
        'fantasy' => ['#FF1493', '#FF69B4', '#DDA0DD', '#E6E6FA']
      }
      
      palette = colors[preference] || colors['neutral']
      
      <<~SVG
        <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="westernGrad" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" style="stop-color:#{palette[2]};stop-opacity:1" />
              <stop offset="100%" style="stop-color:#{palette[3]};stop-opacity:1" />
            </linearGradient>
          </defs>
          
          <!-- 스토리북 배경 -->
          <rect width="400" height="600" fill="url(#westernGrad)"/>
          
          <!-- 동화책 프레임 -->
          <rect x="20" y="20" width="360" height="560" fill="none" 
                stroke="#{palette[0]}" stroke-width="8" rx="15"/>
          
          <g transform="translate(200, 300)">
            #{preference == 'adventure' ? comic_hero(palette) : ''}
            #{preference == 'fantasy' ? fairy_tale_castle(palette) : ''}
            #{preference == 'neutral' ? storybook_scene(palette) : ''}
          </g>
          
          <!-- 장식 요소 -->
          #{decorative_stars(palette[1])}
          
          #{age_simplification(age_group)}
        </svg>
      SVG
    end
    
    def sakura_flower(x, y, color, size)
      <<~SVG
        <g transform="translate(#{x}, #{y}) rotate(#{rand(360)})">
          #{(0..4).map { |i| 
            angle = i * 72
            "<ellipse cx='0' cy='0' rx='#{size/2}' ry='#{size/3}' 
                      fill='#{color}' opacity='0.6' 
                      transform='rotate(#{angle})'/>"
          }.join}
          <circle cx="0" cy="0" r="#{size/4}" fill="white" opacity="0.8"/>
        </g>
      SVG
    end
    
    def adventure_elements(palette)
      <<~SVG
        <polygon points="-50,-20 -30,-40 -10,-20 10,-40 30,-20 50,-40" 
                 fill="#{palette[1]}" opacity="0.7"/>
      SVG
    end
    
    def fantasy_elements(palette)
      <<~SVG
        <circle cx="0" cy="0" r="60" fill="none" stroke="#{palette[2]}" 
                stroke-width="2" stroke-dasharray="5,5" opacity="0.5"/>
        #{(0..7).map { |i|
          angle = i * 45
          x = 60 * Math.cos(angle * Math::PI / 180)
          y = 60 * Math.sin(angle * Math::PI / 180)
          "<circle cx='#{x}' cy='#{y}' r='8' fill='#{palette[1]}' opacity='0.6'/>"
        }.join}
      SVG
    end
    
    def speed_lines(color)
      <<~SVG
        <g opacity="0.3">
          #{(0..8).map { |i|
            y = 50 + i * 60
            "<line x1='0' y1='#{y}' x2='400' y2='#{y}' stroke='#{color}' stroke-width='2'/>"
          }.join}
        </g>
      SVG
    end
    
    def manga_action_silhouette(palette)
      <<~SVG
        <g>
          <ellipse cx="0" cy="-30" rx="40" ry="50" fill="#{palette[0]}" opacity="0.7"/>
          <rect x="-30" y="20" width="60" height="80" fill="#{palette[1]}" opacity="0.7" rx="10"/>
          <polygon points="-60,40 -30,20 -35,60" fill="#{palette[0]}" opacity="0.6"/>
          <polygon points="60,40 30,20 35,60" fill="#{palette[0]}" opacity="0.6"/>
        </g>
      SVG
    end
    
    def magical_girl_silhouette(palette)
      <<~SVG
        <g>
          <circle cx="0" cy="-20" r="35" fill="#{palette[2]}" opacity="0.7"/>
          <path d="M -40 20 Q -30 0, 0 10 Q 30 0, 40 20 L 30 80 L -30 80 Z" 
                fill="#{palette[1]}" opacity="0.7"/>
          <polygon points="0,-55 -10,-40 -5,-45 0,-35 5,-45 10,-40" fill="#{palette[0]}" opacity="0.8"/>
        </g>
      SVG
    end
    
    def kawaii_character(palette)
      <<~SVG
        <g>
          <circle cx="0" cy="0" r="60" fill="#{palette[1]}" opacity="0.8"/>
          <circle cx="-20" cy="-10" r="8" fill="#{palette[0]}"/>
          <circle cx="20" cy="-10" r="8" fill="#{palette[0]}"/>
          <path d="M -15 15 Q 0 25, 15 15" stroke="#{palette[0]}" stroke-width="3" fill="none"/>
        </g>
      SVG
    end
    
    def comic_hero(palette)
      <<~SVG
        <g>
          <rect x="-40" y="-60" width="80" height="100" fill="#{palette[0]}" opacity="0.8" rx="10"/>
          <polygon points="0,-60 -50,-80 50,-80" fill="#{palette[1]}" opacity="0.9"/>
          <circle cx="0" cy="0" r="25" fill="#{palette[2]}" opacity="0.7"/>
        </g>
      SVG
    end
    
    def fairy_tale_castle(palette)
      <<~SVG
        <g>
          <rect x="-60" y="20" width="120" height="60" fill="#{palette[0]}" opacity="0.7"/>
          <polygon points="-70,20 0,-40 70,20" fill="#{palette[1]}" opacity="0.8"/>
          <rect x="-20" y="-40" width="10" height="30" fill="#{palette[0]}" opacity="0.6"/>
          <rect x="10" y="-40" width="10" height="30" fill="#{palette[0]}" opacity="0.6"/>
          <polygon points="-25,-40 -15,-55 -5,-40" fill="#{palette[2]}" opacity="0.9"/>
          <polygon points="5,-40 15,-55 25,-40" fill="#{palette[2]}" opacity="0.9"/>
        </g>
      SVG
    end
    
    def storybook_scene(palette)
      <<~SVG
        <g>
          <rect x="-70" y="-40" width="140" height="80" fill="white" opacity="0.9" rx="5"/>
          <rect x="-65" y="-35" width="130" height="70" fill="none" stroke="#{palette[0]}" stroke-width="2"/>
          #{(0..3).map { |i|
            y = -25 + i * 15
            "<line x1='-55' y1='#{y}' x2='55' y2='#{y}' stroke='#{palette[0]}' stroke-width='1' opacity='0.3'/>"
          }.join}
        </g>
      SVG
    end
    
    def decorative_stars(color)
      positions = [[50, 50], [350, 50], [50, 550], [350, 550], [100, 150], [300, 450]]
      positions.map do |x, y|
        <<~SVG
          <g transform="translate(#{x}, #{y})">
            <polygon points="0,-10 3,-3 10,-2 4,3 6,10 0,5 -6,10 -4,3 -10,-2 -3,-3" 
                     fill="#{color}" opacity="0.5"/>
          </g>
        SVG
      end.join
    end
    
    def age_simplification(age_group)
      case age_group
      when 'baby'
        <<~SVG
          <rect width="400" height="600" fill="white" opacity="0.3"/>
        SVG
      when 'toddler'
        <<~SVG
          <rect width="400" height="600" fill="white" opacity="0.1"/>
        SVG
      else
        ''
      end
    end
    
    def default_style(preference, age_group)
      <<~SVG
        <svg viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
          <rect width="400" height="600" fill="#F0F0F0"/>
          <text x="200" y="300" text-anchor="middle" font-size="24" fill="#999">
            #{preference} - #{age_group}
          </text>
        </svg>
      SVG
    end
  end
end
