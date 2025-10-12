class AddTeenSampleContent < ActiveRecord::Migration[8.0]
  def up
    # 기존 강사들 확인
    instructors = User.where(role: 'instructor')
    if instructors.empty?
      # 강사가 없으면 생성
      instructors = [
        User.create!(name: "김웹툰", email: "webtoon@example.com", password: "password", role: "instructor", bio: "웹툰 작가 및 스토리텔링 전문가"),
        User.create!(name: "박애니", email: "animation@example.com", password: "password", role: "instructor", bio: "애니메이션 감독 및 영상 제작자"),
        User.create!(name: "이소설", email: "novel@example.com", password: "password", role: "instructor", bio: "라이트노벨 작가 및 창작 지도사"),
        User.create!(name: "최댄스", email: "dance@example.com", password: "password", role: "instructor", bio: "K-POP 안무가 및 댄스 강사"),
        User.create!(name: "정게임", email: "game@example.com", password: "password", role: "instructor", bio: "게임 개발자 및 프로그래밍 강사"),
        User.create!(name: "윤진로", email: "career@example.com", password: "password", role: "instructor", bio: "진로 상담사 및 자기계발 코치"),
        User.create!(name: "강크리", email: "creator@example.com", password: "password", role: "instructor", bio: "SNS 크리에이터 및 미디어 전문가")
      ]
    end

    # 웹툰 카테고리 샘플 콘텐츠
    webtoon_courses = [
      {
        title: "📱 나만의 웹툰 캐릭터 만들기",
        description: "매력적인 웹툰 캐릭터를 디자인하고 성격을 부여하는 방법을 배웁니다. 캐릭터 시트 작성부터 표정 연출까지 체계적으로 학습합니다.",
        price: 15000,
        category: "웹툰",
        level: "beginner",
        duration: 45,
        age: "teen"
      },
      {
        title: "🎨 웹툰 배경 그리기 마스터",
        description: "웹툰에서 중요한 배경 그리기 기법을 익힙니다. 원근법부터 분위기 연출까지 프로 작가의 노하우를 전수합니다.",
        price: 22000,
        category: "웹툰",
        level: "intermediate",
        duration: 60,
        age: "teen"
      },
      {
        title: "📖 웹툰 스토리보드 제작법",
        description: "재미있는 웹툰 스토리를 구성하고 스토리보드로 표현하는 방법을 배웁니다. 연출과 컷 나누기의 기초를 익힙니다.",
        price: 18000,
        category: "웹툰",
        level: "beginner",
        duration: 50,
        age: "teen"
      }
    ]

    # 라이트노벨 카테고리 샘플 콘텐츠
    novel_courses = [
      {
        title: "📚 청소년 소설 쓰기 입문",
        description: "또래가 공감할 수 있는 청소년 소설을 쓰는 방법을 배웁니다. 캐릭터 설정부터 갈등 구조까지 체계적으로 학습합니다.",
        price: 16000,
        category: "라이트노벨",
        level: "beginner",
        duration: 40,
        age: "teen"
      },
      {
        title: "✨ 판타지 라이트노벨 창작",
        description: "마법과 모험이 가득한 판타지 라이트노벨을 창작하는 방법을 배웁니다. 세계관 설정부터 마법 시스템까지 상세히 다룹니다.",
        price: 25000,
        category: "라이트노벨",
        level: "intermediate",
        duration: 70,
        age: "teen"
      },
      {
        title: "💕 로맨스 소설 쓰기 비법",
        description: "설레는 로맨스 소설을 쓰는 노하우를 배웁니다. 감정 표현과 관계 발전 과정을 자연스럽게 그려내는 방법을 익힙니다.",
        price: 20000,
        category: "라이트노벨",
        level: "intermediate",
        duration: 55,
        age: "teen"
      }
    ]

    # 댄스 카테고리 샘플 콘텐츠
    dance_courses = [
      {
        title: "🎵 K-POP 기초 댄스 마스터",
        description: "인기 K-POP 안무의 기본 동작을 배우고 나만의 스타일을 만들어봅니다. 리듬감과 표현력을 기를 수 있습니다.",
        price: 12000,
        category: "댄스",
        level: "beginner",
        duration: 35,
        age: "teen"
      },
      {
        title: "💃 걸그룹 댄스 완전정복",
        description: "최신 걸그룹 안무를 완벽하게 마스터하는 과정입니다. 파워풀한 동작부터 섬세한 표현까지 모두 배웁니다.",
        price: 18000,
        category: "댄스",
        level: "intermediate",
        duration: 50,
        age: "teen"
      },
      {
        title: "🕺 보이그룹 댄스 챌린지",
        description: "인기 보이그룹의 시그니처 안무를 배우고 나만의 커버 댄스를 만들어봅니다. 카리스마 넘치는 퍼포먼스를 완성합니다.",
        price: 17000,
        category: "댄스",
        level: "intermediate",
        duration: 45,
        age: "teen"
      }
    ]

    # 크리에이터 카테고리 샘플 콘텐츠 (엔터테인먼트)
    creator_entertainment_courses = [
      {
        title: "📱 틱톡 바이럴 영상 만들기",
        description: "틱톡에서 인기를 끌 수 있는 바이럴 영상 제작법을 배웁니다. 트렌드 분석부터 편집 기법까지 모든 것을 다룹니다.",
        price: 14000,
        category: "크리에이터",
        level: "beginner",
        duration: 40,
        age: "teen"
      },
      {
        title: "🎬 유튜브 쇼츠 제작 마스터",
        description: "유튜브 쇼츠로 구독자를 늘리는 방법을 배웁니다. 기획부터 촬영, 편집, 썸네일 제작까지 전 과정을 익힙니다.",
        price: 19000,
        category: "크리에이터",
        level: "intermediate",
        duration: 55,
        age: "teen"
      }
    ]

    # 게임 카테고리 샘플 콘텐츠
    game_courses = [
      {
        title: "🎮 스크래치로 만드는 첫 게임",
        description: "스크래치를 이용해 간단한 게임을 만들어봅니다. 프로그래밍 기초부터 게임 로직까지 쉽게 배울 수 있습니다.",
        price: 13000,
        category: "게임",
        level: "beginner",
        duration: 40,
        age: "teen"
      },
      {
        title: "🕹️ 2D 플랫폼 게임 제작",
        description: "유니티를 사용해 2D 플랫폼 게임을 만드는 과정입니다. 캐릭터 이동부터 스테이지 디자인까지 배웁니다.",
        price: 28000,
        category: "게임",
        level: "intermediate",
        duration: 80,
        age: "teen"
      },
      {
        title: "🎯 게임 기획자 되기",
        description: "게임 기획의 기초를 배우고 나만의 게임 아이디어를 구체화하는 방법을 익힙니다. 게임 업계 진로 정보도 제공합니다.",
        price: 21000,
        category: "게임",
        level: "beginner",
        duration: 60,
        age: "teen"
      }
    ]

    # 진로/자기계발 카테고리 샘플 콘텐츠
    career_courses = [
      {
        title: "🌟 나의 꿈 찾기 프로젝트",
        description: "다양한 직업을 탐색하고 자신의 적성과 흥미를 발견하는 과정입니다. 진로 설계의 첫걸음을 시작합니다.",
        price: 11000,
        category: "진로",
        level: "beginner",
        duration: 35,
        age: "teen"
      },
      {
        title: "💪 청소년 리더십 개발",
        description: "리더십 스킬을 기르고 팀워크 능력을 향상시키는 프로그램입니다. 학교생활과 미래 직장생활에 도움이 됩니다.",
        price: 17000,
        category: "자기계발",
        level: "intermediate",
        duration: 50,
        age: "teen"
      },
      {
        title: "📈 효과적인 학습법 마스터",
        description: "공부 효율을 높이는 다양한 학습법을 배웁니다. 시간 관리부터 암기법까지 실용적인 팁을 제공합니다.",
        price: 15000,
        category: "자기계발",
        level: "beginner",
        duration: 45,
        age: "teen"
      }
    ]

    # 크리에이터 카테고리 샘플 콘텐츠 (교육)
    creator_education_courses = [
      {
        title: "📸 인스타그램 마케팅 기초",
        description: "인스타그램을 활용한 개인 브랜딩과 마케팅 방법을 배웁니다. 팔로워 늘리기부터 수익화까지 다룹니다.",
        price: 16000,
        category: "크리에이터",
        level: "beginner",
        duration: 45,
        age: "teen"
      },
      {
        title: "🎥 영상 편집 프로 되기",
        description: "프리미어 프로를 사용한 전문적인 영상 편집 기법을 배웁니다. 컬러 그레이딩부터 특수 효과까지 마스터합니다.",
        price: 24000,
        category: "크리에이터",
        level: "advanced",
        duration: 70,
        age: "teen"
      }
    ]

    # 모든 콘텐츠 배열 합치기
    all_courses = webtoon_courses + novel_courses + dance_courses + 
                  creator_entertainment_courses + game_courses + 
                  career_courses + creator_education_courses

    # 콘텐츠 생성
    all_courses.each_with_index do |course_data, index|
      instructor = instructors.sample
      
      Course.create!(
        title: course_data[:title],
        description: course_data[:description],
        price: course_data[:price],
        instructor: instructor,
        category: course_data[:category],
        level: course_data[:level],
        duration: course_data[:duration],
        age: course_data[:age],
        status: "published"
      )
    end

    puts "청소년 샘플 콘텐츠 #{all_courses.count}개가 추가되었습니다."
    puts "카테고리별 분포:"
    puts "- 웹툰: #{webtoon_courses.count}개"
    puts "- 라이트노벨: #{novel_courses.count}개"
    puts "- 댄스: #{dance_courses.count}개"
    puts "- 게임: #{game_courses.count}개"
    puts "- 진로/자기계발: #{career_courses.count}개"
    puts "- 크리에이터: #{creator_entertainment_courses.count + creator_education_courses.count}개"
  end

  def down
    # 추가된 청소년 샘플 콘텐츠 삭제
    sample_titles = [
      "📱 나만의 웹툰 캐릭터 만들기", "🎨 웹툰 배경 그리기 마스터", "📖 웹툰 스토리보드 제작법",
      "📚 청소년 소설 쓰기 입문", "✨ 판타지 라이트노벨 창작", "💕 로맨스 소설 쓰기 비법",
      "🎵 K-POP 기초 댄스 마스터", "💃 걸그룹 댄스 완전정복", "🕺 보이그룹 댄스 챌린지",
      "📱 틱톡 바이럴 영상 만들기", "🎬 유튜브 쇼츠 제작 마스터",
      "🎮 스크래치로 만드는 첫 게임", "🕹️ 2D 플랫폼 게임 제작", "🎯 게임 기획자 되기",
      "🌟 나의 꿈 찾기 프로젝트", "💪 청소년 리더십 개발", "📈 효과적인 학습법 마스터",
      "📸 인스타그램 마케팅 기초", "🎥 영상 편집 프로 되기"
    ]
    
    Course.where(title: sample_titles).destroy_all
    puts "청소년 샘플 콘텐츠가 삭제되었습니다."
  end
end

