class RestructureTeenCategories < ActiveRecord::Migration[8.0]
  def up
    # 청소년 콘텐츠를 2개 카테고리로 재구성
    
    # 1. 청소년 콘텐츠 (읽고/보고/듣기) - 엔터테인먼트 성격
    entertainment_categories = ['만화', '애니메이션', '웹툰', '라이트노벨', '댄스']
    Course.where(age: 'teen', category: entertainment_categories).update_all(category: '청소년콘텐츠')
    
    # 2. 청소년 교육 (학습/창작/진로) - 교육 성격  
    education_categories = ['동화만들기', '게임', '진로', '자기계발', '크리에이터']
    Course.where(age: 'teen', category: education_categories).update_all(category: '청소년교육')
    
    puts "청소년 콘텐츠 카테고리 재구성 완료:"
    puts "- 청소년콘텐츠: #{Course.where(age: 'teen', category: '청소년콘텐츠').count}개"
    puts "- 청소년교육: #{Course.where(age: 'teen', category: '청소년교육').count}개"
  end
  
  def down
    # 롤백 시 원래 카테고리로 복원 (제목 기반으로 추정)
    
    # 만화 카테고리 복원
    manga_titles = ['히어로 아카데미아', '별빛 소녀의 모험', '검술의 달인', '게임 월드 서바이벌', '청춘 로맨스 스토리']
    manga_titles.each do |title|
      Course.where(age: 'teen', category: '청소년콘텐츠').where("title LIKE ?", "%#{title}%").update_all(category: '만화')
    end
    
    # 애니메이션 카테고리 복원
    anime_titles = ['드래곤의 전설', '벚꽃 고등학교', '로봇 파일럿', '농구왕의 꿈', '연극부의 기적']
    anime_titles.each do |title|
      Course.where(age: 'teen', category: '청소년콘텐츠').where("title LIKE ?", "%#{title}%").update_all(category: '애니메이션')
    end
    
    # 웹툰 카테고리 복원
    Course.where(age: 'teen', category: '청소년콘텐츠').where("title LIKE ?", "%웹툰%").update_all(category: '웹툰')
    
    # 라이트노벨 카테고리 복원
    Course.where(age: 'teen', category: '청소년콘텐츠').where("title LIKE ?", "%라이트노벨%").update_all(category: '라이트노벨')
    
    # 댄스 카테고리 복원
    Course.where(age: 'teen', category: '청소년콘텐츠').where("title LIKE ?", "%댄스%").update_all(category: '댄스')
    
    # 교육 카테고리들 복원
    Course.where(age: 'teen', category: '청소년교육').where("title LIKE ?", "%동화%").update_all(category: '동화만들기')
    Course.where(age: 'teen', category: '청소년교육').where("title LIKE ?", "%게임%").update_all(category: '게임')
    Course.where(age: 'teen', category: '청소년교육').where("title LIKE ?", "%진로%").update_all(category: '진로')
    Course.where(age: 'teen', category: '청소년교육').where("title LIKE ? OR title LIKE ?", "%자기계발%", "%문제해결%").update_all(category: '자기계발')
    Course.where(age: 'teen', category: '청소년교육').where("title LIKE ?", "%크리에이터%").update_all(category: '크리에이터')
  end
end

