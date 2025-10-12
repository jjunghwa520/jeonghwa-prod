#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'net/http'
require 'uri'
require 'set'

# AI 양방향 통신 브릿지
class BidirectionalAIBridge
  CURSOR_WORKSPACE = ENV['CURSOR_WORKSPACE'] || '/Users/l2dogyu/KICDA/ruby/kicda-jh'
  COMMUNICATION_DIR = ENV['AI_BRIDGE_DIR'] || "#{CURSOR_WORKSPACE}/.ai-bridge"
  
  def initialize
    setup_directories
    @task_queue = []
    @completed_tasks = []
    @pending_reviews = []
    @iteration_count = 0
    @max_iterations = 5
  end
  
  def setup_directories
    FileUtils.mkdir_p(COMMUNICATION_DIR)
    FileUtils.mkdir_p("#{COMMUNICATION_DIR}/tasks")
    FileUtils.mkdir_p("#{COMMUNICATION_DIR}/results")
    FileUtils.mkdir_p("#{COMMUNICATION_DIR}/reviews")
    FileUtils.mkdir_p("#{COMMUNICATION_DIR}/logs")
    FileUtils.mkdir_p("#{COMMUNICATION_DIR}/completed")
  end
  
  # Cursor AI가 작업 지시
  def cursor_creates_task(intent, context = {})
    task = {
      id: generate_task_id,
      source: 'cursor',
      intent: intent,
      context: context,
      status: 'pending',
      created_at: Time.now,
      iteration: 0
    }
    
    # 작업 파일 생성 (Claude가 감지)
    File.write(
      "#{COMMUNICATION_DIR}/tasks/#{task[:id]}.json",
      JSON.pretty_generate(task)
    )
    
    log("📝 Cursor → Claude: #{intent}")
    task
  end
  
  # Claude가 작업 실행 및 결과 생성
  def claude_executes_task(task_id)
    task_file = "#{COMMUNICATION_DIR}/tasks/#{task_id}.json"
    return unless File.exist?(task_file)
    
    task = JSON.parse(File.read(task_file), symbolize_names: true)
    
    # 작업 실행
    result = execute_task(task)
    
    # 결과 파일 생성 (Cursor가 검토)
    result_data = {
      task_id: task_id,
      result: result,
      status: result[:success] ? 'executed' : 'failed',
      needs_review: true,
      executed_at: Time.now
    }
    
    File.write(
      "#{COMMUNICATION_DIR}/results/#{task_id}.json",
      JSON.pretty_generate(result_data)
    )
    
    log("✅ Claude 실행 완료: #{task_id}")
    
    # 검토 요청
    request_cursor_review(task_id, result_data)
  end

  # Cursor가 승인하여 최종 완료 처리
  def approve_task(task_id)
    result_file = "#{COMMUNICATION_DIR}/results/#{task_id}.json"
    review_file = "#{COMMUNICATION_DIR}/reviews/#{task_id}.json"
    return { success: false, message: 'result not found' } unless File.exist?(result_file)

    result = JSON.parse(File.read(result_file), symbolize_names: true)
    approved = false
    review = nil
    if File.exist?(review_file)
      review = JSON.parse(File.read(review_file), symbolize_names: true)
      approved = !!review[:approved]
    end

    unless approved
      log("⏸️ 승인되지 않아 완료 처리 보류: #{task_id}")
      return { success: false, message: 'not approved' }
    end

    completed = {
      task_id: task_id,
      status: 'completed',
      executed_at: result[:executed_at],
      approved_at: Time.now,
      result: result[:result],
      review: review
    }

    File.write(
      "#{COMMUNICATION_DIR}/completed/#{task_id}.json",
      JSON.pretty_generate(completed)
    )

    log("🏁 작업 최종 완료: #{task_id}")
    { success: true }
  end

  # 작업 상태 요약
  def task_status(task_id)
    task_path = "#{COMMUNICATION_DIR}/tasks/#{task_id}.json"
    result_path = "#{COMMUNICATION_DIR}/results/#{task_id}.json"
    review_path = "#{COMMUNICATION_DIR}/reviews/#{task_id}.json"
    completed_path = "#{COMMUNICATION_DIR}/completed/#{task_id}.json"

    status = 'unknown'
    status = 'pending' if File.exist?(task_path)
    if File.exist?(result_path)
      r = JSON.parse(File.read(result_path), symbolize_names: true) rescue {}
      status = r[:status] || status
    end
    status = 'completed' if File.exist?(completed_path)

    {
      task_id: task_id,
      status: status,
      has_task: File.exist?(task_path),
      has_result: File.exist?(result_path),
      has_review: File.exist?(review_path),
      has_completed: File.exist?(completed_path)
    }
  end
  
  # Cursor가 결과 검토
  def cursor_reviews_result(task_id)
    result_file = "#{COMMUNICATION_DIR}/results/#{task_id}.json"
    return unless File.exist?(result_file)
    
    result = JSON.parse(File.read(result_file), symbolize_names: true)
    
    # 검증 로직
    review = perform_review(result)
    
    review_data = {
      task_id: task_id,
      approved: review[:approved],
      issues: review[:issues],
      suggestions: review[:suggestions],
      reviewed_at: Time.now
    }
    
    File.write(
      "#{COMMUNICATION_DIR}/reviews/#{task_id}.json",
      JSON.pretty_generate(review_data)
    )
    
    log("🔍 Cursor 검토: #{review[:approved] ? '승인' : '재작업 필요'}")
    
    # 재작업이 필요한 경우
    unless review[:approved]
      create_revision_task(task_id, review)
    end
    
    review_data
  end
  
  # Claude가 수정 작업 수행
  def claude_revises_task(task_id, review)
    original_task = JSON.parse(
      File.read("#{COMMUNICATION_DIR}/tasks/#{task_id}.json"),
      symbolize_names: true
    )
    
    # 반복 횟수 체크
    if original_task[:iteration] >= @max_iterations
      log("⚠️ 최대 반복 횟수 도달: #{task_id}")
      return finalize_task(task_id, 'max_iterations_reached')
    end
    
    # 수정 작업 수행
    revised_result = execute_revision(original_task, review)
    
    # 수정된 결과 저장
    File.write(
      "#{COMMUNICATION_DIR}/results/#{task_id}_rev#{original_task[:iteration]}.json",
      JSON.pretty_generate(revised_result)
    )
    
    # 다시 검토 요청
    original_task[:iteration] += 1
    File.write(
      "#{COMMUNICATION_DIR}/tasks/#{task_id}.json",
      JSON.pretty_generate(original_task)
    )
    
    request_cursor_review(task_id, revised_result)
  end
  
  private
  
  def execute_task(task)
    case task[:intent]
    when /모델|model/i
      execute_model_generation(task)
    when /테스트|test/i
      execute_test_generation(task)
    when /컨트롤러|controller/i
      execute_controller_generation(task)
    else
      execute_general_task(task)
    end
  end
  
  def execute_model_generation(task)
    # Rails 모델 생성
    model_name = extract_model_name(task[:intent])
    attributes = extract_attributes(task[:intent])
    
    cmd = "rails generate model #{model_name} #{attributes}"
    output = `cd #{CURSOR_WORKSPACE} && #{cmd} 2>&1`
    
    # 마이그레이션 실행
    if output.include?('create')
      migrate_output = `cd #{CURSOR_WORKSPACE} && rails db:migrate 2>&1`
      output += "\n#{migrate_output}"
    end
    
    {
      success: !output.include?('error'),
      output: output,
      files_created: extract_created_files(output),
      type: 'model_generation'
    }
  end
  
  def execute_test_generation(task)
    test_output = `cd #{CURSOR_WORKSPACE} && rails test 2>&1`
    
    {
      success: !test_output.include?('Error'),
      output: test_output,
      test_results: parse_test_results(test_output),
      type: 'test_execution'
    }
  end
  
  def execute_controller_generation(task)
    controller_name = extract_controller_name(task[:intent])
    actions = extract_actions(task[:intent])
    
    cmd = "rails generate controller #{controller_name} #{actions}"
    output = `cd #{CURSOR_WORKSPACE} && #{cmd} 2>&1`
    
    {
      success: !output.include?('error'),
      output: output,
      files_created: extract_created_files(output),
      type: 'controller_generation'
    }
  end
  
  def execute_general_task(task)
    # AI Assistant 활용
    script = <<~RUBY
      require '#{CURSOR_WORKSPACE}/lib/ai_development_assistant'
      assistant = AIDevelopmentAssistant.new
      result = assistant.execute_intent("#{task[:intent]}")
      puts result.to_json
    RUBY
    
    output = `cd #{CURSOR_WORKSPACE} && rails runner "#{script}" 2>&1`
    
    {
      success: !output.include?('Error'),
      output: output,
      type: 'general_task'
    }
  end
  
  def perform_review(result)
    issues = []
    suggestions = []
    
    # 코드 품질 검사
    if result[:type] == 'model_generation'
      # 모델 파일 검증
      result[:files_created].each do |file|
        if File.exist?("#{CURSOR_WORKSPACE}/#{file}")
          content = File.read("#{CURSOR_WORKSPACE}/#{file}")
          
          # 검증 규칙
          issues << "Validation 누락" unless content.include?('validates')
          issues << "Association 정의 필요" if content.include?('belongs_to') && !content.include?('has_many')
          suggestions << "인덱스 추가 검토" if content.include?('references')
        end
      end
    end
    
    # 테스트 결과 검증
    if result[:type] == 'test_execution'
      if result[:test_results][:failures] > 0
        issues << "테스트 실패: #{result[:test_results][:failures]}개"
        suggestions << "실패한 테스트 수정 필요"
      end
    end
    
    # Rubocop 검사
    rubocop_output = `cd #{CURSOR_WORKSPACE} && rubocop --format json 2>/dev/null`
    if rubocop_output && !rubocop_output.empty?
      rubocop_result = JSON.parse(rubocop_output) rescue {}
      if rubocop_result['summary'] && rubocop_result['summary']['offense_count'] > 0
        issues << "코드 스타일 위반: #{rubocop_result['summary']['offense_count']}개"
      end
    end
    
    {
      approved: issues.empty?,
      issues: issues,
      suggestions: suggestions
    }
  end
  
  def execute_revision(task, review)
    log("🔧 수정 작업 시작: #{review[:issues].join(', ')}")
    
    # 각 이슈에 대한 수정
    review[:issues].each do |issue|
      case issue
      when /Validation 누락/
        add_validations(task)
      when /테스트 실패/
        fix_failing_tests(task)
      when /코드 스타일/
        run_rubocop_autocorrect
      end
    end
    
    # 재실행
    execute_task(task)
  end
  
  def add_validations(task)
    # 모델에 validation 추가
    model_name = extract_model_name(task[:intent])
    model_file = "#{CURSOR_WORKSPACE}/app/models/#{model_name.downcase}.rb"
    
    if File.exist?(model_file)
      content = File.read(model_file)
      unless content.include?('validates')
        content.sub!(/class #{model_name}.*\n/, "\\0  validates :name, presence: true\n")
        File.write(model_file, content)
      end
    end
  end
  
  def fix_failing_tests(task)
    `cd #{CURSOR_WORKSPACE} && rails test:prepare 2>&1`
  end
  
  def run_rubocop_autocorrect
    `cd #{CURSOR_WORKSPACE} && rubocop -A 2>&1`
  end
  
  def request_cursor_review(task_id, result)
    # Cursor에게 검토 요청 신호
    notification = {
      type: 'review_request',
      task_id: task_id,
      message: "검토 요청: #{task_id}",
      timestamp: Time.now
    }
    
    File.write(
      "#{COMMUNICATION_DIR}/.notification",
      JSON.pretty_generate(notification)
    )
  end
  
  def create_revision_task(task_id, review)
    revision_task = {
      id: "#{task_id}_revision",
      original_task: task_id,
      issues: review[:issues],
      suggestions: review[:suggestions],
      status: 'pending',
      created_at: Time.now
    }
    
    File.write(
      "#{COMMUNICATION_DIR}/tasks/#{revision_task[:id]}.json",
      JSON.pretty_generate(revision_task)
    )
  end
  
  def finalize_task(task_id, status)
    final_report = {
      task_id: task_id,
      status: status,
      completed_at: Time.now,
      iterations: @iteration_count
    }
    
    File.write(
      "#{COMMUNICATION_DIR}/completed/#{task_id}.json",
      JSON.pretty_generate(final_report)
    )
  end
  
  def extract_model_name(intent)
    intent.match(/model\s+(\w+)/i)&.captures&.first || 'Model'
  end
  
  def extract_attributes(intent)
    intent.scan(/(\w+):(\w+)/).map { |attr| "#{attr[0]}:#{attr[1]}" }.join(' ')
  end
  
  def extract_controller_name(intent)
    intent.match(/controller\s+(\w+)/i)&.captures&.first || 'Controller'
  end
  
  def extract_actions(intent)
    intent.scan(/(index|show|new|create|edit|update|destroy)/).flatten.join(' ')
  end
  
  def extract_created_files(output)
    output.scan(/create\s+(.+)/).flatten
  end
  
  def parse_test_results(output)
    {
      total: output.match(/(\d+) runs/)&.captures&.first&.to_i || 0,
      assertions: output.match(/(\d+) assertions/)&.captures&.first&.to_i || 0,
      failures: output.match(/(\d+) failures/)&.captures&.first&.to_i || 0,
      errors: output.match(/(\d+) errors/)&.captures&.first&.to_i || 0
    }
  end
  
  def generate_task_id
    "task_#{Time.now.to_i}_#{rand(1000)}"
  end
  
  def log(message)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    log_entry = "[#{timestamp}] #{message}"
    
    puts log_entry
    File.open("#{COMMUNICATION_DIR}/logs/bridge.log", 'a') do |f|
      f.puts log_entry
    end
  end
end

# 실행 모드
if ARGV[0] == 'daemon'
  # 데몬 모드: 파일 시스템 감시 (폴링 방식)
  bridge = BidirectionalAIBridge.new
  
  puts "🌉 AI Bridge Daemon 시작..."
  puts "📂 감시 디렉토리: #{BidirectionalAIBridge::COMMUNICATION_DIR}/tasks"
  
  # 폴링 방식으로 파일 감시
  processed_tasks = Set.new
  
  loop do
    Dir.glob("#{BidirectionalAIBridge::COMMUNICATION_DIR}/tasks/*.json").each do |file|
      task_id = File.basename(file, '.json')
      
      unless processed_tasks.include?(task_id)
        puts "📨 새 작업 감지: #{task_id}"
        bridge.claude_executes_task(task_id)
        processed_tasks.add(task_id)
      end
    end
    
    sleep 2 # 2초마다 확인
  end
  
elsif ARGV[0] == 'test'
  # 테스트 모드
  bridge = BidirectionalAIBridge.new
  
  # 테스트 작업 생성
  task = bridge.cursor_creates_task("User 모델을 name:string email:string으로 생성해줘")
  puts "테스트 작업 생성: #{task[:id]}"
  
  # Claude 실행
  bridge.claude_executes_task(task[:id])
  
  # Cursor 검토
  review = bridge.cursor_reviews_result(task[:id])
  puts "검토 결과: #{review}"
  
else
  puts "사용법:"
  puts "  ruby bidirectional_bridge.rb daemon  # 데몬 모드 실행"
  puts "  ruby bidirectional_bridge.rb test    # 테스트 실행"
end
