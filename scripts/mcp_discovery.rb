#!/usr/bin/env ruby
# MCP 자동 발견 및 통합 스크립트

require 'net/http'
require 'json'
require 'yaml'

class MCPDiscoverySystem
  GITHUB_API = 'https://api.github.com'
  
  # MCP 검색 키워드
  SEARCH_KEYWORDS = [
    'mcp-server',
    'model-context-protocol',
    'claude-mcp',
    'anthropic-mcp',
    'ai-tool-mcp',
    'llm-integration',
    'cursor-mcp'
  ]
  
  # 주요 개발 커뮤니티 GitHub 조직
  TOP_ORGANIZATIONS = {
    usa: ['anthropics', 'openai', 'microsoft', 'google', 'vercel'],
    china: ['alibaba', 'tencent', 'baidu', 'bytedance'],
    japan: ['line', 'rakuten', 'mercari', 'cyberagent'],
    korea: ['kakao', 'naver', 'woowabros', 'toss'],
    israel: ['wix', 'monday', 'ironSource']
  }
  
  def initialize
    @discovered_mcps = []
    @evaluated_mcps = []
    @installed_mcps = []
  end
  
  # 전 세계 MCP 검색
  def discover_global_mcps
    puts "🌍 전 세계 MCP 검색 시작..."
    
    # 1. 키워드 기반 검색
    SEARCH_KEYWORDS.each do |keyword|
      puts "  🔍 검색 중: #{keyword}"
      search_github(keyword)
    end
    
    # 2. 주요 조직 검색
    TOP_ORGANIZATIONS.each do |country, orgs|
      puts "  🏴 #{country.upcase} 조직 검색 중..."
      orgs.each do |org|
        search_organization(org)
      end
    end
    
    # 3. 인기 개발자 검색
    search_top_developers
    
    puts "\n✅ 발견된 MCP: #{@discovered_mcps.count}개"
    @discovered_mcps
  end
  
  # GitHub 검색
  def search_github(keyword)
    begin
      uri = URI("#{GITHUB_API}/search/repositories?q=#{keyword}&sort=stars&per_page=10")
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        data['items'].each do |repo|
          if is_mcp_repo?(repo)
            add_mcp(repo)
          end
        end
      end
    rescue => e
      puts "    ⚠️ 검색 오류: #{e.message}"
    end
  end
  
  # 조직별 검색
  def search_organization(org)
    begin
      uri = URI("#{GITHUB_API}/orgs/#{org}/repos?type=public&per_page=100")
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        repos = JSON.parse(response.body)
        repos.each do |repo|
          if repo['name'] =~ /mcp|context|protocol|integration/i
            add_mcp(repo)
          end
        end
      end
    rescue => e
      puts "    ⚠️ 조직 검색 오류: #{e.message}"
    end
  end
  
  # 인기 개발자 검색
  def search_top_developers
    puts "  👨‍💻 인기 개발자 MCP 검색 중..."
    
    # 실제로는 더 복잡한 로직 필요
    top_developers = ['yoheinakajima', 'significant-gravitas', 'AntonOsika']
    
    top_developers.each do |dev|
      search_user_repos(dev)
    end
  end
  
  def search_user_repos(username)
    begin
      uri = URI("#{GITHUB_API}/users/#{username}/repos?per_page=100")
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        repos = JSON.parse(response.body)
        repos.each do |repo|
          if is_mcp_repo?(repo)
            add_mcp(repo)
          end
        end
      end
    rescue => e
      puts "    ⚠️ 사용자 검색 오류: #{e.message}"
    end
  end
  
  # MCP 저장소인지 확인
  def is_mcp_repo?(repo)
    # 이름 검사
    return true if repo['name'] =~ /mcp|model.context|claude.tool/i
    
    # 설명 검사
    return true if repo['description'] && repo['description'] =~ /MCP|Model Context Protocol|Claude|Anthropic/i
    
    # 토픽 검사 (있는 경우)
    if repo['topics'] && repo['topics'].is_a?(Array)
      return true if repo['topics'].any? { |t| t =~ /mcp|ai-tool|llm/i }
    end
    
    false
  end
  
  # MCP 추가
  def add_mcp(repo)
    mcp_info = {
      name: repo['name'],
      full_name: repo['full_name'],
      url: repo['html_url'],
      description: repo['description'],
      stars: repo['stargazers_count'],
      language: repo['language'],
      updated: repo['updated_at'],
      country: detect_country(repo)
    }
    
    unless @discovered_mcps.any? { |m| m[:full_name] == mcp_info[:full_name] }
      @discovered_mcps << mcp_info
      puts "    ✅ 발견: #{mcp_info[:name]} (⭐ #{mcp_info[:stars]})"
    end
  end
  
  # 국가 감지 (간단한 휴리스틱)
  def detect_country(repo)
    owner = repo['owner']['login'].downcase
    
    TOP_ORGANIZATIONS.each do |country, orgs|
      return country if orgs.any? { |org| owner.include?(org) }
    end
    
    # 언어 기반 추측
    case repo['language']
    when 'Chinese', 'zh-CN'
      :china
    when 'Japanese', 'ja'
      :japan
    when 'Korean', 'ko'
      :korea
    else
      :global
    end
  end
  
  # MCP 평가
  def evaluate_mcps
    puts "\n📊 MCP 품질 평가 중..."
    
    @discovered_mcps.each do |mcp|
      score = calculate_quality_score(mcp)
      mcp[:quality_score] = score
      mcp[:recommendation] = get_recommendation(score)
      
      @evaluated_mcps << mcp if score >= 60
    end
    
    # 점수 기준 정렬
    @evaluated_mcps.sort_by! { |m| -m[:quality_score] }
    
    puts "✅ 평가 완료: #{@evaluated_mcps.count}개 추천"
    @evaluated_mcps
  end
  
  # 품질 점수 계산
  def calculate_quality_score(mcp)
    score = 0
    
    # GitHub 스타 (최대 40점)
    score += [mcp[:stars] / 10, 40].min
    
    # 최근 업데이트 (최대 30점)
    if mcp[:updated]
      begin
        days_ago = (Time.now - Time.parse(mcp[:updated])) / 86400
        score += [30 - (days_ago / 10), 0].max
      rescue
        score += 15  # 파싱 실패 시 중간 점수
      end
    end
    
    # 설명 존재 (10점)
    score += 10 if mcp[:description] && mcp[:description].length > 20
    
    # 언어 (20점)
    preferred_languages = ['TypeScript', 'JavaScript', 'Python', 'Ruby']
    score += 20 if preferred_languages.include?(mcp[:language])
    
    score.to_i
  end
  
  # 추천 레벨
  def get_recommendation(score)
    case score
    when 80..100
      '🌟 강력 추천'
    when 60..79
      '👍 추천'
    when 40..59
      '🤔 검토 필요'
    else
      '⚠️ 주의 필요'
    end
  end
  
  # 자동 설치 제안
  def suggest_installations
    puts "\n🚀 설치 제안:"
    
    # 카테고리별 분류
    categories = {
      database: [],
      api: [],
      testing: [],
      automation: [],
      communication: [],
      other: []
    }
    
    @evaluated_mcps.each do |mcp|
      category = categorize_mcp(mcp)
      categories[category] << mcp
    end
    
    # 카테고리별 최고 추천
    categories.each do |cat, mcps|
      next if mcps.empty?
      
      puts "\n#{cat.to_s.upcase}:"
      mcps.first(3).each do |mcp|
        puts "  • #{mcp[:name]} #{mcp[:recommendation]}"
        puts "    #{mcp[:url]}"
        puts "    #{mcp[:description]}" if mcp[:description]
      end
    end
  end
  
  # MCP 카테고리 분류
  def categorize_mcp(mcp)
    name_desc = "#{mcp[:name]} #{mcp[:description]}".downcase
    
    return :database if name_desc =~ /database|postgres|mysql|mongo|redis/
    return :api if name_desc =~ /api|rest|graphql|http/
    return :testing if name_desc =~ /test|spec|jest|mocha/
    return :automation if name_desc =~ /automat|workflow|pipeline/
    return :communication if name_desc =~ /slack|discord|email|notification/
    
    :other
  end
  
  # 결과 저장
  def save_results
    # YAML 형식으로 저장
    File.open('discovered_mcps.yml', 'w') do |f|
      f.write(@evaluated_mcps.to_yaml)
    end
    
    # JSON 형식으로도 저장
    File.open('discovered_mcps.json', 'w') do |f|
      f.write(JSON.pretty_generate(@evaluated_mcps))
    end
    
    # 마크다운 리포트 생성
    generate_report
    
    puts "\n💾 결과 저장 완료:"
    puts "  • discovered_mcps.yml"
    puts "  • discovered_mcps.json"
    puts "  • mcp_discovery_report.md"
  end
  
  # 리포트 생성
  def generate_report
    File.open('mcp_discovery_report.md', 'w') do |f|
      f.puts "# MCP Discovery Report"
      f.puts "Generated: #{Time.now}"
      f.puts "\n## Summary"
      f.puts "- Total MCPs discovered: #{@discovered_mcps.count}"
      f.puts "- Recommended MCPs: #{@evaluated_mcps.count}"
      f.puts "\n## Top 10 MCPs"
      
      @evaluated_mcps.first(10).each_with_index do |mcp, i|
        f.puts "\n### #{i+1}. #{mcp[:name]}"
        f.puts "- **Score**: #{mcp[:quality_score]}/100 #{mcp[:recommendation]}"
        f.puts "- **Stars**: ⭐ #{mcp[:stars]}"
        f.puts "- **URL**: [#{mcp[:full_name]}](#{mcp[:url]})"
        f.puts "- **Description**: #{mcp[:description]}"
        f.puts "- **Language**: #{mcp[:language]}"
        f.puts "- **Country**: #{mcp[:country]}"
      end
    end
  end
  
  # 실행
  def run
    puts "="*60
    puts "🤖 MCP 자동 발견 시스템"
    puts "="*60
    
    # 1. 발견
    discover_global_mcps
    
    # 2. 평가
    evaluate_mcps
    
    # 3. 제안
    suggest_installations
    
    # 4. 저장
    save_results
    
    puts "\n" + "="*60
    puts "✅ 완료! 다음 단계:"
    puts "1. discovered_mcps.yml 파일 확인"
    puts "2. 추천 MCP 설치: npm install <mcp-name>"
    puts "3. MCP 설정 파일 업데이트"
    puts "="*60
  end
end

# 실행
if __FILE__ == $0
  discovery = MCPDiscoverySystem.new
  discovery.run
end
