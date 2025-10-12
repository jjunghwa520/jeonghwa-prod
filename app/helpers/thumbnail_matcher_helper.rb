module ThumbnailMatcherHelper
  # 각 동화책 제목에 가장 적합한 abstract 이미지를 매핑
  def self.get_title_specific_thumbnail(course_title, course_id)
    # 제목별 테마 매핑
    title_theme_mapping = {
      # 전자동화책 - 모험/판타지 테마
      "🦁 용감한 사자왕의 모험" => { culture: "korean", theme: "adventure", age: "elementary" },
      "🧚‍♀️ 마법 숲의 작은 요정" => { culture: "japanese", theme: "fantasy", age: "toddler" },
      "🐰 달나라 토끼의 꿈" => { culture: "korean", theme: "neutral", age: "baby" },
      "🐻 곰돌이와 꿀벌 친구들" => { culture: "western", theme: "neutral", age: "toddler" },
      "🦊 여우의 지혜로운 선택" => { culture: "korean", theme: "adventure", age: "elementary" },
      "🐧 펭귄의 얼음나라 탐험" => { culture: "western", theme: "adventure", age: "toddler" },
      "🦋 나비의 아름다운 변신" => { culture: "japanese", theme: "fantasy", age: "baby" },
      "🐢 거북이의 느린 여행" => { culture: "korean", theme: "neutral", age: "toddler" },
      "🦉 부엉이의 밤 하늘 학교" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🐿️ 다람쥐의 도토리 저금통" => { culture: "korean", theme: "neutral", age: "toddler" },

      # 구연동화 - 클래식 동화 테마
      "🎭 백설공주와 일곱 난쟁이" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🏰 신데렐라의 유리구두" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🐺 빨간모자와 늑대" => { culture: "western", theme: "adventure", age: "toddler" },
      "🐷 아기돼지 삼형제" => { culture: "western", theme: "adventure", age: "toddler" },
      "🌹 미녀와 야수" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🐸 개구리 왕자" => { culture: "western", theme: "fantasy", age: "toddler" },
      "👸 잠자는 숲속의 공주" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🏃 잭과 콩나무" => { culture: "western", theme: "adventure", age: "elementary" },
      "🍎 독이 든 사과" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🦢 미운 오리 새끼" => { culture: "korean", theme: "neutral", age: "toddler" },

      # 동화만들기 교육 - 창의/학습 테마
      "📝 동화 스토리 기획하기" => { culture: "korean", theme: "neutral", age: "elementary" },
      "🎨 동화 일러스트 그리기" => { culture: "japanese", theme: "fantasy", age: "elementary" },
      "📚 동화책 출판 완성하기" => { culture: "western", theme: "neutral", age: "elementary" },
      "🏆 동화작가 마스터 과정" => { culture: "korean", theme: "adventure", age: "elementary" },
      "✏️ 캐릭터 디자인 기초" => { culture: "japanese", theme: "fantasy", age: "toddler" },
      "🎭 대화문 작성법" => { culture: "western", theme: "adventure", age: "toddler" },
      "🌈 색채 이론과 활용" => { culture: "japanese", theme: "fantasy", age: "baby" },
      "📖 제본과 인쇄 기초" => { culture: "korean", theme: "neutral", age: "elementary" },
      "💡 창의적 발상법" => { culture: "western", theme: "fantasy", age: "elementary" },
      "🎪 동화책 전시회 준비" => { culture: "japanese", theme: "adventure", age: "elementary" }
    }

    # 제목에 맞는 테마 찾기
    theme_info = title_theme_mapping[course_title]
    
    if theme_info
      # 매핑된 테마에 따라 이미지 선택
      culture = theme_info[:culture]
      theme = theme_info[:theme]
      age = theme_info[:age]
      
      # 해당 테마의 이미지 중 course_id에 따라 선택 (1-3 중 순환)
      image_index = ((course_id - 1) % 3) + 1
      
      return "generated/abstract/#{culture}_#{theme}_#{age}_#{image_index}.jpg"
    end
    
    # 매핑이 없는 경우 기본 이미지 반환
    nil
  end

  # 제목에서 이모지를 제거하고 깔끔한 파일명 생성
  def self.clean_title_for_filename(title)
    title.gsub(/[^\w\s가-힣]/, '').strip.gsub(/\s+/, '_')
  end
end
