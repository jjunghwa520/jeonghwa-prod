namespace :subscriptions do
  desc "구독 자동갱신 처리 (매일 자정 실행)"
  task process_renewals: :environment do
    puts "구독 자동갱신 작업 시작..."
    
    results = SubscriptionBillingService.process_all_renewals
    
    puts "처리 완료:"
    puts "  - 총 대상: #{results[:total]}건"
    puts "  - 성공: #{results[:success]}건"
    puts "  - 실패: #{results[:failed]}건"
  end
  
  desc "만료된 구독 상태 업데이트"
  task update_expired: :environment do
    puts "만료된 구독 상태 업데이트 중..."
    
    expired_count = Subscription.where(status: 'active')
                                .where('end_date < ?', Date.today)
                                .update_all(status: 'expired')
    
    puts "#{expired_count}건의 구독이 만료 상태로 변경되었습니다."
  end
  
  desc "월별 구독 정산 보고서 생성"
  task generate_report: :environment do
    start_date = Date.today.beginning_of_month
    end_date = Date.today.end_of_month
    
    report = SubscriptionBillingService.generate_settlement_report(start_date, end_date)
    
    puts "=== 구독 정산 보고서 (#{report[:period]}) ==="
    puts "총 구독 수: #{report[:total_subscriptions]}"
    puts "활성 구독: #{report[:active_subscriptions]}"
    puts "총 매출: #{report[:total_revenue]}원"
    puts "\n플랜별 내역:"
    report[:by_plan].each do |plan, data|
      puts "  #{plan}: #{data[:count]}건, #{data[:revenue]}원"
    end
  end
end

namespace :settlements do
  desc "월별 작가 정산 생성"
  task create_monthly: :environment do
    puts "월별 작가 정산 생성 중..."
    
    start_date = 1.month.ago.beginning_of_month.to_date
    end_date = 1.month.ago.end_of_month.to_date
    
    authors = User.where(role: 'instructor')
    count = 0
    
    authors.each do |author|
      settlement = Settlement.create_monthly_settlement(author, start_date, end_date)
      if settlement.persisted?
        count += 1
        puts "  #{author.name}: #{settlement.amount}원"
      end
    end
    
    puts "#{count}명의 작가 정산이 생성되었습니다."
  end
  
  desc "정산 승인 및 지급 처리"
  task process_payments: :environment do
    puts "정산 지급 처리 중..."
    
    approved_settlements = Settlement.approved
    count = 0
    
    approved_settlements.each do |settlement|
      # 실제로는 계좌 이체 API 호출
      settlement.mark_as_paid!
      count += 1
    end
    
    puts "#{count}건의 정산이 지급 완료되었습니다."
  end
end

namespace :analytics do
  desc "일일 통계 생성"
  task generate_daily: :environment do
    puts "일일 통계 생성 중..."
    
    Analytic.generate_daily_stats(Date.yesterday)
    
    puts "#{Date.yesterday} 통계가 생성되었습니다."
  end
  
  desc "지난 30일 통계 생성 (누락된 데이터 보완)"
  task backfill: :environment do
    puts "과거 통계 데이터 보완 중..."
    
    (30.days.ago.to_date..Date.yesterday).each do |date|
      Analytic.generate_daily_stats(date)
      puts "  #{date} 완료"
    end
    
    puts "30일 통계 데이터 생성 완료"
  end
end

