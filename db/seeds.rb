# 시드 데이터 생성
puts "🎪 정화의 서재 동화책 콘텐츠 생성을 시작합니다..."

# 기존 데이터 삭제 (개발 환경에서만)
if Rails.env.development?
  puts "기존 데이터를 삭제합니다..."
  Review.destroy_all
  CartItem.destroy_all
  Enrollment.destroy_all
  Course.destroy_all
  User.destroy_all
end

# 관리자 사용자 생성
admin = User.create!(
  name: "정화",
  email: "admin@jeonghwa.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  bio: "정화의 서재 관리자입니다."
)

# 동화 작가들 생성
authors = []
author_names = ["김동화", "이이야기", "박그림", "최동심", "정마법"]

author_names.each_with_index do |name, i|
  author = User.create!(
    name: name,
    email: "author#{i+1}@jeonghwa.com",
    password: "password123",
    password_confirmation: "password123",
    role: "instructor",
    bio: "어린이들을 위한 동화를 만드는 #{name} 작가입니다. 20년간 동화책을 써왔습니다."
  )
  authors << author
end

# 부모님 사용자들 생성
parents = []

10.times do |i|
  parent = User.create!(
    name: "학부모#{i+1}",
    email: "parent#{i+1}@jeonghwa.com",
    password: "password123",
    password_confirmation: "password123",
    role: "student",
    bio: "아이와 함께 동화책을 읽는 부모입니다."
  )
  parents << parent
end

# 전자동화책 콘텐츠 생성
ebook_titles = [
  { title: "🦁 용감한 사자왕의 모험", desc: "용기를 배우는 사자왕 이야기", price: 5000 },
  { title: "🧚‍♀️ 마법 숲의 작은 요정", desc: "친구를 돕는 착한 요정 이야기", price: 4500 },
  { title: "🐰 달나라 토끼의 꿈", desc: "꿈을 이루는 토끼의 여행", price: 6000 },
  { title: "🐻 곰돌이와 꿀벌 친구들", desc: "우정을 배우는 곰돌이 이야기", price: 5500 },
  { title: "🦊 여우의 지혜로운 선택", desc: "지혜를 배우는 여우 이야기", price: 5000 },
  { title: "🐧 펭귄의 얼음나라 탐험", desc: "모험을 떠나는 펭귄 이야기", price: 4800 },
  { title: "🦋 나비의 아름다운 변신", desc: "성장하는 나비의 이야기", price: 4500 },
  { title: "🐢 거북이의 느린 여행", desc: "인내를 배우는 거북이 이야기", price: 5200 },
  { title: "🦉 부엉이의 밤 하늘 학교", desc: "지식을 나누는 부엉이 선생님", price: 5800 },
  { title: "🐿️ 다람쥐의 도토리 저금통", desc: "저축을 배우는 다람쥐 이야기", price: 4900 }
]

ebooks = []
ebook_titles.each do |book|
  course = Course.create!(
    title: book[:title],
    description: "#{book[:desc]}\n\n이 동화책은 아이들에게 소중한 가치를 전달합니다. 인터랙티브 기능과 함께 터치하면 반응하는 재미있는 요소들이 가득합니다. 전문 성우의 나레이션이 포함되어 있어 아이들이 혼자서도 즐겁게 읽을 수 있습니다.",
    price: book[:price],
    instructor: authors.sample,
    category: "전자동화책",
    level: "beginner",
    duration: 30,
    age: ["baby", "toddler", "elementary"].sample,
    status: "published"
  )
  ebooks << course
end

# 구연동화 영상 콘텐츠 생성
storytelling_titles = [
  { title: "🎭 백설공주와 일곱 난쟁이", desc: "전래동화를 새롭게 들려드립니다", price: 0 },
  { title: "🏰 신데렐라의 유리구두", desc: "꿈과 희망의 이야기", price: 0 },
  { title: "🐺 빨간모자와 늑대", desc: "조심성을 배우는 이야기", price: 0 },
  { title: "🐷 아기돼지 삼형제", desc: "노력의 중요성을 배우는 이야기", price: 0 },
  { title: "🌹 미녀와 야수", desc: "진정한 아름다움의 의미", price: 0 },
  { title: "🐸 개구리 왕자", desc: "약속의 소중함을 배우는 이야기", price: 0 },
  { title: "👸 잠자는 숲속의 공주", desc: "사랑의 힘을 보여주는 이야기", price: 0 },
  { title: "🏃 잭과 콩나무", desc: "용기와 모험의 이야기", price: 0 },
  { title: "🍎 독이 든 사과", desc: "선과 악의 대결", price: 0 },
  { title: "🦢 미운 오리 새끼", desc: "자아 발견의 이야기", price: 0 }
]

storytellings = []
storytelling_titles.each do |story|
  course = Course.create!(
    title: story[:title],
    description: "#{story[:desc]}\n\n전문 성우가 생생하게 들려주는 구연동화입니다. 아름다운 애니메이션과 효과음이 함께하여 아이들의 상상력을 자극합니다. 매달 새로운 이야기가 추가되는 구독 서비스입니다.",
    price: story[:price],
    instructor: authors.sample,
    category: "구연동화",
    level: "beginner",
    duration: 15,
    age: ["toddler", "elementary"].sample,
    status: "published"
  )
  storytellings << course
end

# 동화만들기 교육 콘텐츠 생성
education_titles = [
  { title: "📝 동화 스토리 기획하기", desc: "이야기 구조와 플롯 만들기", price: 30000 },
  { title: "🎨 동화 일러스트 그리기", desc: "그림으로 이야기 표현하기", price: 45000 },
  { title: "📚 동화책 출판 완성하기", desc: "나만의 책 만들기 A to Z", price: 60000 },
  { title: "🏆 동화작가 마스터 과정", desc: "전문 작가되기 종합과정", price: 150000 },
  { title: "✏️ 캐릭터 디자인 기초", desc: "매력적인 주인공 만들기", price: 35000 },
  { title: "🎭 대화문 작성법", desc: "생생한 대화 쓰기", price: 25000 },
  { title: "🌈 색채 이론과 활용", desc: "아름다운 색감 표현하기", price: 40000 },
  { title: "📖 제본과 인쇄 기초", desc: "책 만들기의 모든 것", price: 50000 },
  { title: "💡 창의적 발상법", desc: "아이디어 찾기와 발전시키기", price: 35000 },
  { title: "🎪 동화책 전시회 준비", desc: "작품 발표와 홍보하기", price: 45000 }
]

educations = []
education_titles.each do |edu|
  course = Course.create!(
    title: edu[:title],
    description: "#{edu[:desc]}\n\n전문 작가와 함께하는 체계적인 교육 과정입니다. 단계별 실습과 1:1 피드백을 통해 나만의 동화책을 완성할 수 있습니다. 과정 수료 후 작품 전시회 기회도 제공됩니다.",
    price: edu[:price],
    instructor: authors.sample,
    category: "동화만들기",
    level: ["beginner", "intermediate", "advanced"].sample,
    duration: rand(120..480),
    age: ["elementary", "teen"].sample,
    status: "published"
  )
  educations << course
end

# 14-16세 청소년 콘텐츠 생성
teen_manga_titles = [
  { title: "🦸‍♂️ 히어로 아카데미아", desc: "초능력 학교의 성장 이야기", price: 8000, category: "만화" },
  { title: "🌟 별빛 소녀의 모험", desc: "마법소녀의 우정과 성장", price: 7500, category: "만화" },
  { title: "⚔️ 검술의 달인", desc: "중세 판타지 액션 만화", price: 9000, category: "만화" },
  { title: "🎮 게임 월드 서바이벌", desc: "가상현실 게임 속 모험", price: 8500, category: "만화" },
  { title: "🏫 청춘 로맨스 스토리", desc: "학교 생활과 첫사랑 이야기", price: 7000, category: "만화" }
]

teen_anime_titles = [
  { title: "🎬 드래곤의 전설", desc: "용과 기사의 판타지 애니메이션", price: 12000, category: "애니메이션" },
  { title: "🌸 벚꽃 고등학교", desc: "청춘 드라마 애니메이션", price: 10000, category: "애니메이션" },
  { title: "🤖 로봇 파일럿", desc: "메카닉 액션 애니메이션", price: 15000, category: "애니메이션" },
  { title: "🏀 농구왕의 꿈", desc: "스포츠 성장 애니메이션", price: 11000, category: "애니메이션" },
  { title: "🎭 연극부의 기적", desc: "예술과 우정의 애니메이션", price: 9500, category: "애니메이션" }
]

teens = []

# 청소년 만화 콘텐츠 생성
teen_manga_titles.each do |manga|
  course = Course.create!(
    title: manga[:title],
    description: "#{manga[:desc]}\n\n14-16세 청소년을 위한 만화 콘텐츠입니다. 현대적인 그래픽과 흥미진진한 스토리로 청소년들의 관심을 끌며, 성장과 우정, 꿈에 대한 메시지를 담고 있습니다. 웹툰 형식으로 제공되어 모바일에서도 편리하게 감상할 수 있습니다.",
    price: manga[:price],
    instructor: authors.sample,
    category: manga[:category],
    level: "intermediate",
    duration: 45,
    age: "teen",
    status: "published"
  )
  teens << course
end

# 청소년 애니메이션 콘텐츠 생성
teen_anime_titles.each do |anime|
  course = Course.create!(
    title: anime[:title],
    description: "#{anime[:desc]}\n\n14-16세 청소년을 위한 애니메이션 콘텐츠입니다. 고품질 애니메이션과 감동적인 스토리로 청소년들에게 꿈과 희망을 전달합니다. 각 에피소드마다 깊이 있는 메시지와 교훈이 담겨 있어 재미와 교육적 가치를 동시에 제공합니다.",
    price: anime[:price],
    instructor: authors.sample,
    category: anime[:category],
    level: "intermediate",
    duration: 25,
    age: "teen",
    status: "published"
  )
  teens << course
end

puts "📚 동화책 콘텐츠 #{Course.count}개가 생성되었습니다."

# 수강 신청 생성
enrollments = []

parents.each do |parent|
  # 각 부모가 2-5개의 콘텐츠 구매
  sample_ebooks = ebooks.sample(rand(1..3))
  sample_education = educations.sample(rand(0..2))
  
  sample_ebooks.each do |course|
    enrollment = Enrollment.create!(
      user: parent,
      course: course,
      progress: rand(0..100),
      completed: rand(0..100) > 70
    )
    enrollments << enrollment
  end
  
  sample_education.each do |course|
    enrollment = Enrollment.create!(
      user: parent,
      course: course,
      progress: rand(0..100),
      completed: rand(0..100) > 50
    )
    enrollments << enrollment
  end
end

puts "📖 수강 신청 #{enrollments.count}개가 생성되었습니다."

# 리뷰 생성
reviews = []
review_contents = [
  "아이가 정말 좋아해요! 매일 읽어달라고 합니다.",
  "그림이 예쁘고 이야기가 재미있어요.",
  "교육적인 내용이 잘 담겨있네요.",
  "성우님 목소리가 정말 좋아요!",
  "아이와 함께 보기 좋은 콘텐츠입니다.",
  "가격 대비 내용이 알차요.",
  "인터랙티브 기능이 재미있어요.",
  "우리 아이 최애 동화책이에요!",
  "잠자기 전에 듣기 좋아요.",
  "교육 과정이 체계적이고 좋습니다."
]

enrollments.sample(40).each do |enrollment|
  review = Review.create!(
    user: enrollment.user,
    course: enrollment.course,
    rating: rand(4..5),
    content: review_contents.sample
  )
  reviews << review
end

puts "⭐ 리뷰 #{reviews.count}개가 생성되었습니다."

# 장바구니 아이템 생성
cart_items = []

parents.sample(5).each do |parent|
  available_courses = Course.all - parent.enrolled_courses
  sample_courses = available_courses.sample(rand(1..3))
  
  sample_courses.each do |course|
    cart_item = CartItem.create!(
      user: parent,
      course: course,
      quantity: 1
    )
    cart_items << cart_item
  end
end

puts "🛒 장바구니 아이템 #{cart_items.count}개가 생성되었습니다."
puts ""
puts "🎉 정화의 서재 시드 데이터 생성이 완료되었습니다!"
puts ""
puts "📊 생성된 데이터:"
puts "- 사용자: #{User.count}명 (관리자 1명, 작가 #{authors.count}명, 부모 #{parents.count}명)"
puts "- 📖 전자동화책: #{ebooks.count}개"
puts "- 🎭 구연동화: #{storytellings.count}개"
puts "- ✍️ 교육과정: #{educations.count}개"
puts "- 수강 신청: #{Enrollment.count}개"
puts "- 리뷰: #{Review.count}개"
puts "- 장바구니: #{CartItem.count}개"
puts ""
puts "🔐 테스트 계정:"
puts "관리자: admin@jeonghwa.com / password123"
puts "작가: author1@jeonghwa.com / password123"
puts "부모: parent1@jeonghwa.com / password123"