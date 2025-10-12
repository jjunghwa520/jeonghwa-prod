class GenerateImageJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(generated_image)
    Rails.logger.info "Starting image generation for ID: #{generated_image.id}"
    
    # 이미 처리 중이거나 완료된 경우 스킵
    return if generated_image.processing? || generated_image.completed?
    
    # 이미지 생성 실행
    generated_image.generate!
    
    # 성공 시 알림 (옵션)
    if generated_image.available? && generated_image.user
      # 나중에 알림 시스템 구현 시 활성화
      # NotificationMailer.image_ready(generated_image).deliver_later
    end
    
    Rails.logger.info "Image generation completed for ID: #{generated_image.id}, Status: #{generated_image.status}"
  rescue => e
    Rails.logger.error "Image generation job failed for ID: #{generated_image.id}"
    Rails.logger.error "Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise # retry_on이 처리하도록 다시 발생
  end
end
