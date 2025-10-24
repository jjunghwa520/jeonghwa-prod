# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://localhost:3000"  # 프로덕션에서는 실제 도메인으로 변경
SitemapGenerator::Sitemap.public_path = 'public/'
SitemapGenerator::Sitemap.sitemaps_path = ''

SitemapGenerator::Sitemap.create do
  # 홈페이지
  add root_path, priority: 1.0, changefreq: 'daily'
  
  # 정적 페이지
  add terms_path, priority: 0.5, changefreq: 'monthly'
  add privacy_path, priority: 0.5, changefreq: 'monthly'
  add community_path, priority: 0.6, changefreq: 'weekly' rescue nil
  
  # 카테고리별 페이지
  add courses_path, priority: 0.9, changefreq: 'daily'
  add courses_path(category: 'ebook'), priority: 0.9, changefreq: 'daily'
  add courses_path(category: 'storytelling'), priority: 0.9, changefreq: 'daily'
  add courses_path(category: 'education'), priority: 0.9, changefreq: 'daily'
  add teen_content_path, priority: 0.8, changefreq: 'weekly' rescue nil
  
  # 발행된 코스 (published만)
  Course.where(status: 'published').find_each do |course|
    add course_path(course), 
        priority: 0.8, 
        changefreq: 'weekly',
        lastmod: course.updated_at
    
    # 전자동화책은 리더 페이지도 추가
    if course.category == '전자동화책' || course.category == 'ebook'
      add read_course_path(course),
          priority: 0.7,
          changefreq: 'monthly',
          lastmod: course.updated_at
    end
    
    # 구연동화는 watch 페이지 추가
    if course.category == '구연동화'
      add watch_course_path(course),
          priority: 0.7,
          changefreq: 'monthly',
          lastmod: course.updated_at rescue nil
    end
  end
  
  # 작가 페이지 (instructor 역할만)
  User.where(role: 'instructor').find_each do |instructor|
    add user_path(instructor),
        priority: 0.6,
        changefreq: 'monthly',
        lastmod: instructor.updated_at rescue nil
  end
end

