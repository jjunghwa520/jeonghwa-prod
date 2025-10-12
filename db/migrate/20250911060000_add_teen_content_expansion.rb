class AddTeenContentExpansion < ActiveRecord::Migration[8.0]
  def up
    # 청소년 전용 새로운 콘텐츠 추가
    author_ids = User.where(role: 'instructor').pluck(:id)
    
    # 웹툰/라이트노벨 카테고리
    webtoon_contents = [
      {
        title: "📱 웹툰 스토리텔링 기법",
        description: "인기 웹툰의 스토리텔링 기법을 분석하고 나만의 웹툰 스토리를 만들어보는 과정입니다. 캐릭터 설정부터 플롯 구성까지 체계적으로 학습합니다.",
        price: 25000,
        category: "웹툰",
        level: "intermediate",
        duration: 60,
        age: "teen"
      },
      {
        title: "🎨 디지털 웹툰 그리기",
        description: "디지털 도구를 활용한 웹툰 제작 과정을 배웁니다. 클립스튜디오, 포토샵 등을 활용한 실전 웹툰 제작 기법을 익힙니다.",
        price: 35000,
        category: "웹툰",
        level: "intermediate",
        duration: 90,
        age: "teen"
      },
      {
        title: "📚 라이트노벨 창작 입문",
        description: "청소년이 좋아하는 라이트노벨 장르의 특징을 이해하고, 나만의 라이트노벨을 창작하는 방법을 배웁니다.",
        price: 20000,
        category: "라이트노벨",
        level: "beginner",
        duration: 45,
        age: "teen"
      }
    ]
    
    # 게임/코딩 카테고리
    game_contents = [
      {
        title: "🎮 게임 기획 및 스토리 설계",
        description: "게임의 기본 구조와 재미 요소를 이해하고, 간단한 게임을 기획해보는 과정입니다. 게임 업계 진로 정보도 포함됩니다.",
        price: 30000,
        category: "게임",
        level: "beginner",
        duration: 75,
        age: "teen"
      },
      {
        title: "💻 스크래치로 시작하는 게임 코딩",
        description: "스크래치를 활용해 간단한 게임을 만들어보며 프로그래밍의 기초를 익힙니다. 청소년 눈높이에 맞춘 쉬운 설명으로 진행됩니다.",
        price: 25000,
        category: "게임",
        level: "beginner",
        duration: 60,
        age: "teen"
      }
    ]
    
    # 진로/자기계발 카테고리
    career_contents = [
      {
        title: "🌟 청소년 진로 탐색",
        description: "다양한 직업군을 탐색하고 자신의 적성과 흥미를 발견하는 과정입니다. 실제 직업인 인터뷰와 체험 활동이 포함됩니다.",
        price: 15000,
        category: "진로",
        level: "beginner",
        duration: 40,
        age: "teen"
      },
      {
        title: "💪 청소년 자기계발 프로젝트",
        description: "목표 설정, 시간 관리, 학습법 등 청소년 시기에 필요한 자기계발 스킬을 배웁니다. 실천 가능한 구체적 방법을 제시합니다.",
        price: 18000,
        category: "자기계발",
        level: "beginner",
        duration: 50,
        age: "teen"
      },
      {
        title: "🎯 창의적 문제해결 워크숍",
        description: "다양한 문제 상황에서 창의적으로 해결책을 찾는 방법을 배웁니다. 팀 프로젝트와 개인 과제를 통해 실전 경험을 쌓습니다.",
        price: 22000,
        category: "자기계발",
        level: "intermediate",
        duration: 55,
        age: "teen"
      }
    ]
    
    # 트렌드/문화 카테고리
    trend_contents = [
      {
        title: "📸 SNS 콘텐츠 크리에이터 되기",
        description: "인스타그램, 틱톡, 유튜브 등 SNS 플랫폼에서 인기 있는 콘텐츠를 만드는 방법을 배웁니다. 영상 편집과 마케팅 기초도 포함됩니다.",
        price: 28000,
        category: "크리에이터",
        level: "beginner",
        duration: 70,
        age: "teen"
      },
      {
        title: "🎵 K-POP 댄스 안무 배우기",
        description: "인기 K-POP 댄스 안무를 배우고, 나만의 안무를 창작해보는 과정입니다. 댄스의 기본기부터 표현력까지 종합적으로 학습합니다.",
        price: 20000,
        category: "댄스",
        level: "beginner",
        duration: 45,
        age: "teen"
      }
    ]
    
    all_contents = webtoon_contents + game_contents + career_contents + trend_contents
    
    all_contents.each do |content|
      Course.create!(
        title: content[:title],
        description: content[:description],
        price: content[:price],
        instructor_id: author_ids.sample,
        category: content[:category],
        level: content[:level],
        duration: content[:duration],
        age: content[:age],
        status: "published"
      )
    end
    
    puts "청소년 콘텐츠 #{all_contents.count}개가 추가되었습니다."
  end
  
  def down
    # 추가된 청소년 콘텐츠 삭제
    categories_to_remove = ["웹툰", "라이트노벨", "게임", "진로", "자기계발", "크리에이터", "댄스"]
    Course.where(age: "teen", category: categories_to_remove).destroy_all
  end
end

