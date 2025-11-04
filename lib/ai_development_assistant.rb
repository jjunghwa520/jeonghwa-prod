# AI 개발 어시스턴트
# 사용자 의도를 파악하고 자동으로 개발을 수행하는 시스템

require 'yaml'
require 'json'

class AiDevelopmentAssistant
  attr_reader :config, :context, :history
  
  def initialize
    @config = YAML.load_file(Rails.root.join('config', 'ai_automation_config.yml'))
    @context = {}
    @history = []
    @mcp_tools = {}
  end
  
  # 사용자 의도 분석 및 실행
  def execute_intent(user_intent)
    log("사용자 요청: #{user_intent}")
    
    # 1. 의도 분석
    analysis = analyze_intent(user_intent)
    log("분석 결과: #{analysis}")
    
    # 2. 필요한 도구 확인
    required_tools = identify_required_tools(analysis)
    log("필요 도구: #{required_tools}")
    
    # 3. MCP 도구 설치 (필요시)
    install_mcp_tools(required_tools)
    
    # 4. 개발 계획 수립
    plan = create_development_plan(analysis)
    log("개발 계획: #{plan}")
    
    # 5. 실행
    results = execute_plan(plan)
    
    # 6. 검증
    validation = validate_results(results)
    
    # 7. 피드백 루프
    if validation[:success]
      log("✅ 작업 완료!")
      return results
    else
      log("⚠️ 문제 발견, 자동 수정 시도...")
      fixed_results = auto_fix_issues(validation[:issues])
      return fixed_results
    end
  end
  
  private
  
  # 의도 분석 (실제로는 Claude API 호출)
  def analyze_intent(intent)
    # 간단한 키워드 기반 분석 (실제로는 AI 사용)
    analysis = {
      type: detect_intent_type(intent),
      entities: extract_entities(intent),
      requirements: extract_requirements(intent),
      priority: determine_priority(intent)
    }
    
    analysis
  end
  
  def detect_intent_type(intent)
    case intent.downcase
    when /추가|생성|만들/
      :create
    when /수정|변경|업데이트/
      :update
    when /삭제|제거/
      :delete
    when /테스트|검증/
      :test
    when /배포|디플로이/
      :deploy
    else
      :unknown
    end
  end
  
  def extract_entities(intent)
    entities = []
    
    # 모델 관련
    entities << :model if intent =~ /모델|테이블|스키마/
    
    # 컨트롤러 관련
    entities << :controller if intent =~ /컨트롤러|API|엔드포인트/
    
    # 뷰 관련
    entities << :view if intent =~ /뷰|화면|UI|페이지/
    
    # 기능 관련
    entities << :feature if intent =~ /기능|서비스|시스템/
    
    entities
  end
  
  def extract_requirements(intent)
    requirements = []
    
    # 일반적인 요구사항 패턴 추출
    requirements << :authentication if intent =~ /로그인|인증|권한/
    requirements << :database if intent =~ /데이터|저장|DB/
    requirements << :api if intent =~ /API|REST|통신/
    requirements << :testing if intent =~ /테스트|검증/
    requirements << :ui if intent =~ /디자인|UI|UX/
    
    requirements
  end
  
  def determine_priority(intent)
    return :high if intent =~ /긴급|중요|바로|즉시/
    return :low if intent =~ /나중|천천히|여유/
    :normal
  end
  
  # 필요한 도구 식별
  def identify_required_tools(analysis)
    tools = []
    
    # 엔티티와 요구사항에 따른 도구 선택
    if analysis[:entities].include?(:model)
      tools << 'database-tool'
      tools << 'migration-generator'
    end
    
    if analysis[:entities].include?(:controller)
      tools << 'route-manager'
      tools << 'api-tester'
    end
    
    if analysis[:requirements].include?(:testing)
      tools << 'test-runner'
      tools << 'coverage-analyzer'
    end
    
    tools.uniq
  end
  
  # MCP 도구 설치 (시뮬레이션)
  def install_mcp_tools(tools)
    tools.each do |tool|
      next if @mcp_tools[tool]
      
      mcp_config = @config['mcp_tools']['available'].find { |t| t['name'] == tool }
      
      if mcp_config && mcp_config['auto_install']
        log("📦 MCP 도구 설치 중: #{tool}")
        # 실제로는 npm install 등을 실행
        @mcp_tools[tool] = true
        sleep(0.5) # 설치 시뮬레이션
        log("✅ #{tool} 설치 완료")
      end
    end
  end
  
  # 개발 계획 수립
  def create_development_plan(analysis)
    plan = {
      steps: [],
      estimated_time: 0,
      risk_level: :low
    }
    
    # 의도 타입에 따른 계획 수립
    case analysis[:type]
    when :create
      plan[:steps] = create_creation_plan(analysis)
    when :update
      plan[:steps] = create_update_plan(analysis)
    when :test
      plan[:steps] = create_test_plan(analysis)
    end
    
    plan[:estimated_time] = plan[:steps].size * 5 # 각 단계당 5분 예상
    plan
  end
  
  def create_creation_plan(analysis)
    steps = []
    
    if analysis[:entities].include?(:model)
      steps << { action: :generate_model, target: 'NewModel' }
      steps << { action: :create_migration, target: 'NewModel' }
    end
    
    if analysis[:entities].include?(:controller)
      steps << { action: :generate_controller, target: 'NewController' }
      steps << { action: :add_routes, target: 'NewController' }
    end
    
    if analysis[:entities].include?(:view)
      steps << { action: :create_views, target: 'NewView' }
      steps << { action: :add_styles, target: 'NewView' }
    end
    
    steps << { action: :run_tests, target: :all }
    steps
  end
  
  def create_update_plan(analysis)
    [
      { action: :analyze_existing, target: :current },
      { action: :modify_code, target: :identified },
      { action: :run_tests, target: :modified },
      { action: :validate_changes, target: :all }
    ]
  end
  
  def create_test_plan(analysis)
    [
      { action: :generate_tests, target: :missing },
      { action: :run_tests, target: :all },
      { action: :analyze_coverage, target: :report }
    ]
  end
  
  # 계획 실행
  def execute_plan(plan)
    results = {
      success: true,
      completed_steps: [],
      outputs: []
    }
    
    plan[:steps].each do |step|
      log("🔧 실행 중: #{step[:action]} on #{step[:target]}")
      
      begin
        output = execute_step(step)
        results[:completed_steps] << step
        results[:outputs] << output
        log("✅ 완료: #{step[:action]}")
      rescue => e
        log("❌ 오류: #{e.message}")
        results[:success] = false
        results[:error] = e.message
        break
      end
    end
    
    results
  end
  
  def execute_step(step)
    # 실제 실행 시뮬레이션
    case step[:action]
    when :generate_model
      "Model #{step[:target]} generated"
    when :create_migration
      "Migration for #{step[:target]} created"
    when :generate_controller
      "Controller #{step[:target]} generated"
    when :run_tests
      "Tests passed: 42/42"
    else
      "Action #{step[:action]} completed"
    end
  end
  
  # 결과 검증
  def validate_results(results)
    validation = {
      success: true,
      issues: []
    }
    
    # 기본 검증
    unless results[:success]
      validation[:success] = false
      validation[:issues] << { type: :execution_error, message: results[:error] }
    end
    
    # 테스트 결과 검증
    if results[:outputs].any? { |o| o =~ /failed|error/i }
      validation[:success] = false
      validation[:issues] << { type: :test_failure }
    end
    
    validation
  end
  
  # 자동 문제 해결
  def auto_fix_issues(issues)
    fixed_results = {
      success: false,
      fixes_applied: []
    }
    
    issues.each do |issue|
      case issue[:type]
      when :syntax_error
        log("🔧 구문 오류 자동 수정 중...")
        # 실제로는 AI를 사용하여 수정
        fixed_results[:fixes_applied] << "Syntax error fixed"
        
      when :test_failure
        log("🔧 테스트 실패 분석 및 수정 중...")
        # 테스트 실패 원인 분석 및 수정
        fixed_results[:fixes_applied] << "Test fixed"
        
      when :execution_error
        log("⚠️ 실행 오류 - 사용자 개입 필요")
        return fixed_results
      end
    end
    
    fixed_results[:success] = true if fixed_results[:fixes_applied].any?
    fixed_results
  end
  
  def log(message)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    log_entry = "[#{timestamp}] #{message}"
    
    @history << log_entry
    puts log_entry
    
    # 로그 파일에도 저장
    File.open(Rails.root.join('log', 'ai_assistant.log'), 'a') do |f|
      f.puts log_entry
    end
  end
end

# 사용 예시
if __FILE__ == $0
  assistant = AiDevelopmentAssistant.new
  
  # 테스트 실행
  puts "\n=== AI 개발 어시스턴트 테스트 ==="
  
  test_intents = [
    "사용자 프로필 페이지를 만들어줘",
    "로그인 기능에 2단계 인증을 추가해줘",
    "모든 API 엔드포인트에 대한 테스트를 작성해줘"
  ]
  
  test_intents.each do |intent|
    puts "\n" + "="*50
    assistant.execute_intent(intent)
  end
end
