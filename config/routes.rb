Rails.application.routes.draw do
  # 429 에러 페이지
  get '/429', to: 'static_errors#too_many_requests'
  root "home#index"
  get "classic", to: "home#index"
  get "storybook", to: "home#storybook_index"
  get "teen_content", to: "home#teen_content"
  get "hero_preview", to: "home#hero_preview"

  # 강의 관련 라우트
  resources :courses do
    collection do
      get :search
    end
    member do
      post :enroll
      get :watch
    end
    resources :reviews, only: [ :create, :destroy ]
  end

  # 사용자 관련 라우트
  resources :users, except: [ :index ] do
    member do
      get :dashboard
      get :my_courses
      get :my_teachings
      patch :update_role  # 관리자 전용 role 업데이트 라우트
    end
    # 주문 내역
    resources :orders, only: [:index, :show]
  end

  # 세션 관리 (로그인/로그아웃)
  resource :session, only: [ :new, :create, :destroy ]
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "signup", to: "users#new"

  # 장바구니
  resources :cart_items, only: [ :index, :create, :show, :destroy ] do
    collection do
      delete :clear
      post :enroll_all
      get :choice
    end
  end
  get 'cart_choice', to: 'cart_items#choice'
  
  # AI 이미지 생성
  resources :generated_images do
    member do
      post :retry
      get :status
    end
  end
  
  # 관리자 네임스페이스
  namespace :admin do
    root to: "dashboard#index"
    resources :courses do
      member do
        post :upload_files
        delete :delete_file
      end
    end
    resources :authors
    resources :uploads, only: [:new, :create]
    resources :reviews, only: [:index, :update, :destroy]
    resources :users, only: [:index, :update]
    
    # AI 콘텐츠 생성기
    resources :content_generator, only: [:index] do
      collection do
        post :generate
        get :preview_prompt
      end
    end
  end
  
  # 전자동화책 리더
  get "/courses/:id/read", to: "courses/readers#show", as: :read_course
  
  # 결제 시스템
  get "/payments/:course_id/checkout", to: "payments#checkout", as: :checkout_payment
  get "/payments/confirm", to: "payments#confirm", as: :confirm_payment
  get "/payments/fail", to: "payments#fail", as: :fail_payment
  post "/payments/:id/refund", to: "payments#refund", as: :refund_payment
  # Toss 웹훅(성공/실패/환불) 처리: 비동기 상태 동기화
  post "/payments/webhook", to: "payments#webhook", as: :payments_webhook
  
  # 커뮤니티
  get "/community", to: "community#index", as: :community
  get "/community/challenges", to: "community#reading_challenges", as: :community_challenges
  get "/community/forum", to: "community#parent_forum", as: :community_forum
  
  # 정책 페이지
  get "/pages/terms", to: "pages#terms", as: :terms
  get "/pages/privacy", to: "pages#privacy", as: :privacy
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  
  # 예외 처리 라우트(ExceptionsApp)
  get "/404", to: "static_errors#not_found"
  get "/500", to: "static_errors#internal_error"
end

 
