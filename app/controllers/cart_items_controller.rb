class CartItemsController < ApplicationController
  before_action :require_login
  before_action :set_cart_item, only: [ :destroy ]

  def index
    @cart_items = current_user.cart_items.includes(:course)
    @total_price = @cart_items.sum { |item| item.total_price }
  end

  def show
    # GET 요청이 개별 cart_item으로 오는 경우 장바구니 목록으로 리다이렉트
    redirect_to cart_items_path
  end

  def create
    @course = Course.find(params[:course_id])
    
    # AJAX 요청인지 확인
    Rails.logger.info "=== 장바구니 추가 요청 ==="
    Rails.logger.info "Accept 헤더: #{request.headers['Accept']}"
    Rails.logger.info "Content-Type: #{request.content_type}"
    Rails.logger.info "XHR 요청: #{request.xhr?}"
    Rails.logger.info "요청 형식: #{request.format}"

    # AJAX 요청인지 확인
    is_ajax = request.xhr? || request.headers['X-Requested-With'] == 'XMLHttpRequest' || request.headers['Accept']&.include?('application/json')
    
    if current_user.enrolled_courses.include?(@course)
      if is_ajax
        render json: { 
          success: false, 
          message: "이미 수강 중인 강의입니다." 
        }, status: :unprocessable_entity
      else
        flash[:alert] = "이미 수강 중인 강의입니다."
        redirect_back(fallback_location: @course)
      end
    elsif current_user.cart_items.exists?(course: @course)
      if is_ajax
        render json: { 
          success: false, 
          message: "이미 장바구니에 담긴 강의입니다." 
        }, status: :unprocessable_entity
      else
        flash[:alert] = "이미 장바구니에 담긴 강의입니다."
        redirect_back(fallback_location: @course)
      end
    else
      cart_item = current_user.cart_items.create(course: @course)
      if cart_item.persisted?
        if is_ajax
          render json: { 
            success: true, 
            message: "#{@course.title}이(가) 장바구니에 추가되었습니다.",
            course_title: @course.title,
            course_id: @course.id,
            cart_count: current_user.cart_items.count,
            enrolled: current_user.enrolled_courses.include?(@course),
            in_cart: current_user.cart_items.exists?(course: @course)
          }
        else
          redirect_to cart_choice_path(course_id: @course.id)
        end
      else
        if is_ajax
          render json: { 
            success: false, 
            message: "장바구니 추가에 실패했습니다." 
          }, status: :unprocessable_entity
        else
          flash[:alert] = "장바구니 추가에 실패했습니다."
          redirect_back(fallback_location: @course)
        end
      end
    end
  end

  def choice
    @course = Course.find(params[:course_id])
    flash[:notice] = "#{@course.title}이(가) 장바구니에 추가되었습니다."
  end

  def destroy
    if @cart_item.destroy
      flash[:notice] = "장바구니에서 제거되었습니다."
    else
      flash[:alert] = "장바구니에서 제거에 실패했습니다."
    end
    redirect_to cart_items_path
  end

  def clear
    count = current_user.cart_items.count
    current_user.cart_items.destroy_all
    flash[:notice] = "장바구니의 #{count}개 아이템이 모두 제거되었습니다."
    redirect_to cart_items_path
  end

  def enroll_all
    enrolled_count = 0
    skipped_count = 0
    
    current_user.cart_items.includes(:course).each do |cart_item|
      unless current_user.enrolled_courses.include?(cart_item.course)
        current_user.enrollments.create(course: cart_item.course, enrolled_at: Time.current)
        enrolled_count += 1
      else
        skipped_count += 1
      end
    end
    
    current_user.cart_items.destroy_all
    
    if enrolled_count > 0
      flash[:notice] = "#{enrolled_count}개 강의 수강신청이 완료되었습니다!"
      if skipped_count > 0
        flash[:alert] = "#{skipped_count}개 강의는 이미 수강 중이어서 제외되었습니다."
      end
    else
      flash[:alert] = "수강신청할 새로운 강의가 없습니다."
    end
    
    redirect_to dashboard_user_path(current_user)
  end

  private

  def set_cart_item
    @cart_item = current_user.cart_items.find(params[:id])
  end

  def json_request?
    request.format.json?
  end
end
